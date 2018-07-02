//
//  fillupDetailsViewController.swift
//  GasLogApp
//
//  Created by Eric Barber on 11/15/17.
//  Copyright © 2017 Eric Barber. All rights reserved.
//

import UIKit

class fillupDetailsViewController: UIViewController {
	//member variabels
	var vehicle: Vehicle?
	var index: Int?
	var userId: String?
	var segueIdentifier: String = ""
	
	//outlets
	
	@IBOutlet weak var dateOfFillLabel: UILabel!
	@IBOutlet weak var mpgOfFIllLabel: UILabel!
	@IBOutlet weak var costOfFillLabel: UILabel!
	@IBOutlet weak var milesWentLabel: UILabel!
	@IBOutlet weak var gallonsEnteredLabel: UILabel!
	@IBOutlet weak var odoOfFillLabel: UILabel!
	@IBOutlet weak var notesTextView: UITextView!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		loadInformationIntoView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	//Do not allow rotation of applacation
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.portrait
	}
	override var shouldAutorotate: Bool{
		return false
	}
	
	func loadInformationIntoView(){
		
		if let veh = vehicle{
			if let i = index{
			let cost = veh.costRecords[i]
			let mpgOfFill = veh.fillUpMpgs[i + 1]
			let dateOfFill = veh.datesOfFilles[i]
			let currentODO = veh.odoFillups[i]
			var milesWent: Int = 0
			if veh.odoFillups.count > 1 {
				milesWent = (veh.odoFillups[i + 1] - veh.odoFillups[i])
			}
			let gallonsEntered = Double(milesWent) / mpgOfFill
				let noteFromFill = veh.notes[i]
			
				costOfFillLabel.text = "Cose of Fill: $\(cost)"
				mpgOfFIllLabel.text = "Mpg of fill: \(mpgOfFill)"
				dateOfFillLabel.text = "Date of Fill: \(dateOfFill)"
				odoOfFillLabel.text = "Odo on Fill: \(currentODO)"
				milesWentLabel.text = "Miles went: \(milesWent)"
				gallonsEnteredLabel.text = "Gallons Entered: \(gallonsEntered)"
				notesTextView.text = "Notes: \n \(noteFromFill)"
			}
		}
	}
	
	@IBAction func toHomeButtonPress(_ sender: UIBarButtonItem) {
		segueIdentifier = "unwindToHome"
		performSegue(withIdentifier: "unwindToHome", sender: self)
		
	}
	
	@IBAction func toVehiclesButtonPress(_ sender: UIBarButtonItem) {
		segueIdentifier = "toVehiclesSegue"
		performSegue(withIdentifier: "toVehiclesSegue", sender: nil)
	}
	
	@IBAction func backButtonPress(_ sender: UIBarButtonItem) {
		dismiss(animated: true, completion: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segueIdentifier == "unWindToHome"{
			
		}else if segueIdentifier == "toVehiclesSegue"{
			let SVC: VehiclesTableView = segue.destination as! VehiclesTableView
			SVC.userId = self.userId
		}
	}
}
