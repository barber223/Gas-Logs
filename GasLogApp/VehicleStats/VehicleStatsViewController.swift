//
//  VehicleStatsViewController.swift
//  GasLogApp
//
//  Created by Eric Barber on 11/9/17.
//  Copyright © 2017 Eric Barber. All rights reserved.
//

import UIKit

class VehicleStatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	var vehicle: Vehicle?
	var odoRecords:[Int] = []
	var mpgRecords : [Double] = []
	var datesOfFillups: [Date] = []
	var costRecords: [Double] = []
	var headerIdentifer: String = "Header1"
	var indexOfFillup: Int = 0
	var segueIdentifier: String = ""
	var activeUserId: String?
	
	@IBOutlet weak var uiTableView: UITableView!
	
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
		if let veh = vehicle{
			//pull and set the vehicle records from veh class instance
			odoRecords = veh.odoFillups
			mpgRecords = veh.fillUpMpgs
			costRecords = veh.costRecords
			datesOfFillups = veh.datesOfFilles
		}
		//register uitabelView header
		uiTableView.register(UINib(nibName: "CustomVehicleStatsHeader", bundle: nil),forHeaderFooterViewReuseIdentifier: headerIdentifer )
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return costRecords.count
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:VehicleStatsCell = tableView.dequeueReusableCell(withIdentifier: "statsCell_01", for: indexPath) as! VehicleStatsCell
		cell.backgroundColor = UIColor(displayP3Red: 255/255, green: 243/255, blue: 176/255, alpha: 1)
		if let veh = vehicle{
			let cost = veh.costRecords[indexPath.row]
			let mpgOfFill = veh.fillUpMpgs[indexPath.row + 1]
			let dateOfFill = veh.datesOfFilles[indexPath.row]
			let currentODO = veh.odoFillups[indexPath.row]
			var milesWent: Int = 0
			if veh.odoFillups.count > 1 {
				milesWent = (veh.odoFillups[indexPath.row + 1] - veh.odoFillups[indexPath.row])
			}
			let gallonsEntered = Double(milesWent) / mpgOfFill
			cell.gallonsEnteredLabel.text = "Gallons Entered: \(gallonsEntered)"
			cell.milesWentLabel.text = "Miles Went: \(milesWent)"
			cell.odoLabel.text = "ODO: \(currentODO)"
			cell.costOfFillLabel.text = "Cost: \(cost)"
			cell.dateTimeLabel.text = "\(dateOfFill)"
			cell.mpgLabel.text = "mpg: \(mpgOfFill)"
		}
		return cell
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 110
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 40
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	//Set the view of the header
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerIdentifer) as? CustomHeaderVehicleStats
		if let veh = vehicle{
			//header?.backgroundColor = UIColor(displayP3Red: 18/255, green: 53/255, blue: 91/255, alpha: 1)
			//set the values within the view
			header?.averageMpgLabel.text = "Average MPG: \(veh.averageMpg.rounded())"
			var totalCost: Double = 0
			for cost in veh.costRecords{
				totalCost += cost
			}
			header?.totalCostLabel.text = "Total Cost: \(totalCost.rounded())"
		}
		//return the configured header
		return header
	}
	@IBAction func BackBarButtonPress(_ sender: UIBarButtonItem) {
		segueIdentifier = "unwindSeguetoSV1"
		performSegue(withIdentifier: "unwindSeguetoSV1", sender: self)
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		segueIdentifier = "toFillupDetails"
		indexOfFillup = indexPath.row
		performSegue(withIdentifier: "toFillupDetails", sender: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segueIdentifier == "toFillupDetails"{
			
			let SVC: fillupDetailsViewController = segue.destination as! fillupDetailsViewController
			SVC.vehicle = self.vehicle!
			SVC.index = self.indexOfFillup
			if let userId = activeUserId{
				SVC.userId = userId
			}
			
		}else if segueIdentifier == "unwindSeguetoSV1" {
			
		}
	}
	
	
	
	
	
	
	
	
}
