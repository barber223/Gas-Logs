//
//  VehiclesTableView.swift
//  GasLogApp
//
//  Created by Eric Barber on 11/7/17.
//  Copyright © 2017 Eric Barber. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase

class VehiclesTableView: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet weak var uiTableView: UITableView!
	
	//Need acess to the active userID
	var userId: String?
	var vehicles: [Vehicle] = []
	var deletedVehicles: [DeletedVehicles] = []
	var segueIdentifier: String = ""
	var activeVehicleIndex: Int = 0
	var vehicle: Vehicle?
	var indexOfEdit: Int = 0
	var headerIdentifer: String = "Header2"

	
	//Do not allow rotation of applacation
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.portrait
	}
	override var shouldAutorotate: Bool{
		return false
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		pullUserVehicles()
		
		
		//uiTableView.register(UINib(nibName: "CustomDeletedHeader", bundle: nil),forHeaderFooterViewReuseIdentifier: headerIdentifer )
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0{
		return vehicles.count
		}
		else {
			return deletedVehicles.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
	
		let cell = tableView.dequeueReusableCell(withIdentifier: "VehicleCell_01") as! vehicleTableViewCell
		let backroundColor: UIColor = UIColor(displayP3Red: 255/255, green: 243/255, blue: 176/255, alpha: 1)
		cell.backgroundColor = backroundColor
		cell.vehicleNameLabel.text = vehicles[indexPath.row].nameOfVehicle
		cell.editButton.tag = indexPath.row
			cell.deleteButton.tag = indexPath.row
		cell.deleteButton.isHidden = true
			return cell
			
		
			/*
		else {
			
			let cell = tableView.dequeueReusableCell(withIdentifier: "VehicleCell_02") as! DeletedVehicleCell
			cell.AverageMPG.text = "Average MPG: \(deletedVehicles[indexPath.row].avMPG)"
			cell.lastODOLabel.text = "Last OdO: \(deletedVehicles[indexPath.row].lastOdo)"
			cell.totalMilesWentLabel.text = "Miles Went: \(deletedVehicles[indexPath.row].milesWent)"
			cell.totalCostLabel.text = "Total Cost: \(deletedVehicles[indexPath.row].totalCost)"
			cell.vehicleNameLabel.text = "Name: \(deletedVehicles[indexPath.row].name)"
			return cell
		}
*/
		
		
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		activeVehicleIndex = indexPath.row
		segueIdentifier = "unwindSeguetoSV1"
		performSegue(withIdentifier: "unwindSeguetoSV1", sender: nil)
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 100
	}
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	/*
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if section == 1{
			let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerIdentifer) as? CustomDeletedHeader
			return header
		}
		else {
		
			
			if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerIdentifer) as? CustomDeletedHeader{
			
				
				return header
			}
			else {
				let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerIdentifer)
				return header
			}
			
			
		}
		
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 40
	}

	*/
	@IBAction func AddNewVehicleBarButton(_ sender: UIBarButtonItem) {
		segueIdentifier = "AddNewVehicle"
		performSegue(withIdentifier: "AddNewVehicle", sender: nil)
	}
	
	func pullUserVehicles (){
		if userId != ""{
			let db = Firestore.firestore()
			let docRef = db.collection("users").document(userId!)
			docRef.getDocument{(document, error) in
				if let document = document{
					let docInfo = document.data()
					guard let info = docInfo["numVehicles"] as? Int
						else{ return}
					for index in 0..<info {
						guard let vehicleInfo = docInfo["Vehicle\(index)"] as? [Any],
							let name = vehicleInfo[0] as? String,
							let averagempg = vehicleInfo[1] as? Double,
							let gallonCapcity = vehicleInfo[2] as? Double,
							let gasLevel = vehicleInfo[3] as? Double,
							let multipleTankes = vehicleInfo[4] as? Bool
							else {return}
						
						
						if gallonCapcity != -1{
							guard let odoRecords = docInfo["ODO\(name)"] as? [Int],
								let mpgRecords = docInfo["MPGS\(name)"] as? [Double],
								let dateFil = docInfo["datesOfFillups\(name)"] as? [Date],
								let costRec = docInfo["CostRecords\(name)"] as? [Double],
								let tripInfo = docInfo["trip\(name)"] as? [Double],
								let notesRec = docInfo["notes\(name)"] as? [String]
								else {return}
							
							
							if multipleTankes == true{
								guard let secondTank = vehicleInfo[5] as? Double,
									let secondTankGasLevel = vehicleInfo[6] as? Double
									else { return }
								self.vehicles.append(Vehicle(averageMpg: averagempg, nameOfVehicle: name, odo: 1, multipleTanks: true, gallonCapacity: gallonCapcity, backGallonsCapacity: secondTank, gasLevel: gasLevel, gasLevelSecondTank: secondTankGasLevel))
							}else{
								//SingleTankVehcile
								self.vehicles.append(Vehicle(averageMpg: averagempg, nameOfVehicle: name, odo: 1, multipleTanks: false, gallonCapacity: gallonCapcity, gasLevel: gasLevel))
							}
							self.vehicles[index].odoFillups = odoRecords
							self.vehicles[index].costRecords = costRec
							self.vehicles[index].datesOfFilles = dateFil
							self.vehicles[index].fillUpMpgs = mpgRecords
							self.vehicles[index].trip = tripInfo
							self.vehicles[index].notes = notesRec
						}
						/*else {
					
							guard let deltedVehInfo = docInfo["deleteInfo\(name)"] as? [Any],
							let lastOdo = deltedVehInfo[0] as? Int,
							let totalCost = deltedVehInfo[1] as? Double,
							let mikesWent = deltedVehInfo[2] as? Int
								else {return}
							self.deletedVehicles.append(DeletedVehicles(name: name, avMPG: averagempg, totalCost: totalCost, milesWent: mikesWent, lastOdo: lastOdo))
						}*/
					}
					self.uiTableView.reloadData()
				}
			}
		}
		else {
			print("There is no active user currently, ViewController will dismiss")
			dismiss(animated: true, completion: nil)
		}
	}
	
	//To add gas menu based off of the active vehicle within the main view controller
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segueIdentifier == "toAddGas"{
			let SVC: AddGasManualView = segue.destination as! AddGasManualView
			SVC.userId = userId
			SVC.vehicle = vehicles[activeVehicleIndex]
		}else if segueIdentifier == "AddNewVehicle"{
			let svc: AddVehicleView = segue.destination as! AddVehicleView
			svc.numVehicle = self.vehicles.count
		}else if segueIdentifier == "toVehicleEdit"{
			let editController: vehicleEditViewController = segue.destination as! vehicleEditViewController
			if vehicle != nil && userId != nil{
				editController.veh = vehicle
				editController.userId = userId!
				editController.index = indexOfEdit
			}else {
				print("vehicle edit seuge data not able to be passed")
			}
		}
	}
	
	@IBAction func AddGasBarButtonPress(_ sender: UIBarButtonItem) {
		segueIdentifier = "toAddGas"
		performSegue(withIdentifier: "toAddGas", sender: nil)
	}
	
	@IBAction func ToHomeMenu(_ sender: UIBarButtonItem) {
		
		segueIdentifier = "ToHomeUnwind"
		performSegue(withIdentifier: "ToHomeUnwind", sender: self)
	}
	//Create a way for the user to edit the vehicles information
	@IBAction func EditVehicleButtonPress(_ sender: UIButton) {
		//allow me to knw which reow the button was pressed in
		segueIdentifier = "toVehicleEdit"
		vehicle = vehicles[sender.tag]
		indexOfEdit = sender.tag
		performSegue(withIdentifier: "toVehicleEdit", sender: nil)
	}
	/*
	@IBAction func deleteButtonPress(_ sender: UIButton) {
		//need to remove the vehicles information from the database except the important info that will be used for quick rev after it has been deleted
		//also need to make it so when this vehicle is now selected within the this table view it goes to a seperate view controler of vehicle information
		indexOfEdit = sender.tag
		vehicle = vehicles[sender.tag]
		alertBeforeDelete()
	}
	
	
	func alertBeforeDelete(){
		let alert = UIAlertController(title: "Are you sure?", message: "After you delete this vehicle it can not be undone. Are you sure you want to permently delete this vehicle?", preferredStyle: .alert)
		let yesButton = UIAlertAction(title: "Yes", style: .default, handler: deletionHandler(Alert: ))
		let noButton = UIAlertAction(title: "No", style: .default, handler: nil)
		// add the button to the alert
		alert.addAction(noButton)
		alert.addAction(yesButton)
		// present the alert
		present(alert, animated: true, completion: {print("Alert was shown.")})
	}
	func deletionHandler(Alert: UIAlertAction!){
		
		let db = Firestore.firestore()
		let docRef = db.collection("users").document(userId!)
		
		//resave so the vehicle will not be pulled in the future
		docRef.updateData(["Vehicle\(indexOfEdit)": [
			vehicle!.nameOfVehicle,
			vehicle!.averageMpg,
			-1,
			-1,
			false
			]])
		if let veh = vehicle{
			if let lastOdo = veh.odoFillups.last{
				var totalCost: Double = 0.0
				for cost in veh.costRecords{
					totalCost += cost
				}
				let milesWent = lastOdo - veh.odoFillups[0]
				
				//before I delete the values need to add the ones that are needed to the new database structure
				db.collection("users").document(userId!).updateData(["deleteInfo\(vehicle!.nameOfVehicle)": [
					lastOdo,
					totalCost,
					milesWent,
					]])
			}
		}
		docRef.getDocument{(document, error) in
			if let document = document{
				var docInfo = document.data()
				//alter the information for the soon to be deleted vehicle
				docInfo.removeValue(forKey: "ODO\(self.vehicle!.nameOfVehicle)")
				docInfo.removeValue(forKey: "MPGS\(self.vehicle!.nameOfVehicle)")
				docInfo.removeValue(forKey: "datesOfFillups\(self.vehicle!.nameOfVehicle)")
				docInfo.removeValue(forKey: "trip\(self.vehicle!.nameOfVehicle)")
				docInfo.removeValue(forKey: "notes\(self.vehicle!.nameOfVehicle)")
			}
		}
		
		//remove the vehicle from the vehicle array and then reload the table View
		vehicles.removeAll()
		pullUserVehicles()

	}
*/
	
	
	
	
	
	//need to create a function to allow a user to delete a vehicle from the vehicles list
	//After this is created I need to allow a way to still acess base information of this vehicle
	/*
	- total cost
	- total miles
	- average mpg
	- name
	*/
}
