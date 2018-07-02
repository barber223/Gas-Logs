//
//  ViewController_ext.swift
//  GasLogApp
//
//  Created by Eric Barber on 11/11/17.
//  Copyright © 2017 Eric Barber. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase

extension ViewController {
	
	func vehicleInformation(){
		
		ref = Database.database().reference()
		let db = Firestore.firestore()
		handle = Auth.auth().addStateDidChangeListener { auth, user in
			if user != nil {
				print("A user is logged in Continue onto normal operation")
				let uId = Auth.auth().currentUser?.uid
				print (uId!)
				
				self.activeUserId = uId!
				
				let docRef = db.collection("users").document(uId!)
				docRef.getDocument{(document, error) in
					if let error = error {
						print(error)
					}
					if let document = document{
						let docInfo = document.data()
						
						guard let vehicleInfo = docInfo["Vehicle\(self.vehcileSelected)"] as? [Any],
							let name = vehicleInfo[0] as? String,
							let averagempg = vehicleInfo[1] as? Double,
							let gallonCapcity = vehicleInfo[2] as? Double,
							let gasLevel = vehicleInfo[3] as? Double,
							let multipleTankes = vehicleInfo[4] as? Bool,
							let numVehicle = docInfo["numVehicles"] as? Int,
							let odoRecords = docInfo["ODO\(name)"] as? [Int],
							let mpgRecords = docInfo["MPGS\(name)"] as? [Double],
							let dateFil = docInfo["datesOfFillups\(name)"] as? [Date],
							let costRec = docInfo["CostRecords\(name)"] as? [Double],
							let tripInfo = docInfo["trip\(name)"] as? [Double],
							let notesRec = docInfo["notes\(name)"] as? [String]
							else {return}
						
						//set member variables
						self.odoRec = odoRecords
						self.datesOfFills = dateFil
						self.costOfFille = costRec
						self.datesOfFills = dateFil
						self.trip = tripInfo
						self.notes = notesRec
						
						//save member variables
						self.numVehicle = numVehicle
						self.nameOfVehicleLabel.text = name
						//need to get the most recent Odometer reading for the active vehicle
						let latestOdoRecord = odoRecords[odoRecords.count-1]
						
						//Add the activevehicle to the member variable to alter and acess the information
						if multipleTankes == true{
							guard let secondTank = vehicleInfo[5] as? Double,
								let secondTankGasLevel = vehicleInfo[6] as? Double
								else { return }
							self.vehice = Vehicle(averageMpg: averagempg, nameOfVehicle: name, odo: latestOdoRecord, multipleTanks: multipleTankes, gallonCapacity: gallonCapcity, backGallonsCapacity: secondTank, gasLevel: gasLevel, gasLevelSecondTank: secondTankGasLevel)
							self.vehice?.fillUpMpgs = mpgRecords
							self.vehice?.odoFillups = odoRecords
							self.vehice?.costRecords = costRec
							self.vehice?.datesOfFilles = dateFil
							self.vehice?.trip = tripInfo
							self.Trip = tripInfo[0]
							self.vehice?.notes = notesRec
							//Front tank on load
							
						} else{
							//single Tank vehicle
							self.vehice = Vehicle(averageMpg: averagempg, nameOfVehicle: name, odo: latestOdoRecord, multipleTanks: multipleTankes, gallonCapacity: gallonCapcity, gasLevel: gasLevel)
							self.vehice?.fillUpMpgs = mpgRecords
							self.vehice?.odoFillups = odoRecords
							self.vehice?.costRecords = costRec
							self.vehice?.datesOfFilles = dateFil
							self.vehice?.trip = tripInfo
							self.Trip = tripInfo[0]
							self.vehice?.notes = notesRec
							//singleTanks
							
						}
						self.updateUIOnLoad()
					}
					else{
						print("Unable to obtain document information within add new vehicle")
					}
				}
			}
			else {
				self.performSegue(withIdentifier: "ToLogin", sender: nil)
			}
		}
	}
	
	//unwind segue to allow nav back to theis view after log in and user creation
	@IBAction func unwindToVC1(segue:UIStoryboardSegue) {
		if let returnController = segue.source as? VehiclesTableView
		{
			self.vehcileSelected = returnController.activeVehicleIndex
			vehicleInformation()
		}
		else if let returnController = segue.source as? AddGasManualView{
			
			if let veh = vehice{
				//updateodoRecordes
				odoRec.append(returnController.currentOdo)
				veh.fillUpMpgs.append(returnController.mpgOnThisFillup)
				calculateAvergaeMPG(mpg: returnController.mpgOnThisFillup)
				datesOfFills.append(returnController.dateOfFillup!)
				costOfFille.append(returnController.costOfFillup)
				notes.append(returnController.noteFromFill)
				//update the gas level based off the gallons entered
				veh.gasLevel += returnController.gallonsEntered
				veh.gasLevelSecondTank? += returnController.gallonsEnteredForRearTank
				veh.odoFillups = odoRec
				veh.datesOfFilles = datesOfFills
				veh.costRecords = costOfFille
				veh.fillUpMpgs.append(returnController.mpgOnThisFillup)
				veh.notes.append(returnController.noteFromFill)
				
				if returnController.gallonsEntered != 0.0 {
					veh.trip[0] = 0
				}
				if returnController.gallonsEnteredForRearTank != 0.0{
					veh.trip[1] = 0
				}
				veh.updateVehicleInUserDocument(userId: activeUserId, arrayIdentifier: vehcileSelected)
				
			}
		}
	}
	
	//Fucntion to allow the information needed on the views that will be presented to have the info they need
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segueIdentifier == "ToLogin"{
			let SVC: LogInView = segue.destination as! LogInView
			SVC.ref = self.ref
		}
		else if segueIdentifier == "toVehicleList"{
			let SVC: VehiclesTableView = segue.destination as! VehiclesTableView
			SVC.userId = self.activeUserId
			//Acess to the activeVehicle
			SVC.activeVehicleIndex = self.vehcileSelected
		}
		else if segueIdentifier == "toAddGas"{
			let SVC: AddGasManualView = segue.destination as! AddGasManualView
			SVC.vehicle = self.vehice!
			SVC.userId = self.activeUserId
			
		}else if segueIdentifier == "toVehicleStats"{
			let SVC: VehicleStatsViewController = segue.destination as! VehicleStatsViewController
			SVC.vehicle = self.vehice
			SVC.activeUserId = self.activeUserId
		}
		else if segueIdentifier == "toMapOfLocalGasStations"{
			let SVC: NearByGasStations = segue.destination as! NearByGasStations
			SVC.usersLastKnownLocation = self.lastKnownLocation
		}
	}
	
	//IbAction list to allow navagation
	@IBAction func toVehicleBarButtonPress(_ sender: UIBarButtonItem) {
		segueIdentifier = "toVehicleList"
		//locationManager?.stopUpdatingLocation()
		performSegue(withIdentifier: "toVehicleList", sender: nil)
	}
	
	@IBAction func addGasBarButtonPress(_ sender: UIBarButtonItem) {
		segueIdentifier = "toAddGas"
		//locationManager?.stopUpdatingLocation()
		performSegue(withIdentifier: "toAddGas", sender: nil)
	}
	@IBAction func logout(_ sender: UIButton) {
		do {
			try Auth.auth().signOut()
			//after user has loged out need to go to log in
			segueIdentifier = "ToLogin"
			self.performSegue(withIdentifier: "ToLogin", sender: self)
		}
		catch {
			print ("Log out failed are you sure theres a user loged in")
		}
	}
	
	@IBAction func toVehicleStats(_ sender: UIBarButtonItem) {
		segueIdentifier = "toVehicleStats"
		//locationManager?.stopUpdatingLocation()
		performSegue(withIdentifier: "toVehicleStats", sender: nil)
	}
	@IBAction func SwitchOfTank(_ sender: UISegmentedControl) {
		if let veh = vehice{
			if sender.selectedSegmentIndex == 0{
				milesToEmpty = veh.gasLevel * veh.averageMpg
				milesToEmptyLabel.text = "Miles To Empty: \(milesToEmpty)"
				tripLabel.text = "Trip: \(trip[0] * 3 / 5280)"
				Trip = trip [0]
			}
			else{
				milesToEmpty = veh.gasLevelSecondTank! * veh.averageMpg
				milesToEmptyLabel.text = "Miles To Empty: \(milesToEmpty)"
				tripLabel.text = "Trip: \(trip[1] * 3 / 5280)"
				Trip = trip[1]
			}
			UpdateGasGagueValues()
		}
	}
	
	func alert(){
		
	}
}
