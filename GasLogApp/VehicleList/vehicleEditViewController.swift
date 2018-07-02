//
//  vehicleEditViewController.swift
//  GasLogApp
//
//  Created by Eric Barber on 11/15/17.
//  Copyright © 2017 Eric Barber. All rights reserved.
//

import UIKit

class vehicleEditViewController: UIViewController, UITextFieldDelegate {
	
	//varaible for the information of the selected vehicle to be edited
	var veh: Vehicle?
	//variable to allow the database to be updated after edits
	var userId: String?
	var index: Int?
	
	//need outlets
	@IBOutlet weak var vehicleNameLAbel: UILabel!
	@IBOutlet weak var odoTextField: UITextField!
	@IBOutlet weak var tankLevelTextField: UITextField!
	@IBOutlet weak var secondTankLevelTextField: UITextField!
	
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
		if let vehicle = veh{
			if vehicle.multipleTanks != true{
				secondTankLevelTextField.isHidden = true
			}
			else {
				secondTankLevelTextField.placeholder = "\(vehicle.gasLevelSecondTank!)"
			}
			odoTextField.placeholder = "\(vehicle.odoFillups.last!)"
			tankLevelTextField.placeholder = "\(vehicle.gasLevel)"
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func EditVehicleButtonPress(_ sender: UIButton) {
		var newOdo: Double = 0.0
		var newTankLevel: Double = 0.0
		var newRearTankLevel: Double = 0.0
		func alert(message: String){
			// provides an alert to the user if the above tests fail
			let alert = UIAlertController(title: "There is an issue with entries", message: message, preferredStyle: .alert)
			let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
			// add the button to the alert
			alert.addAction(okButton)
			// present the lert
			present(alert, animated: true, completion: {print("Alert was shown.")})
		}
		if let vehicle = veh{
			if odoTextField.text != "" {
				if let odo = Double(odoTextField.text!) {
					newOdo = odo
				}
			}
			if tankLevelTextField.text != "" {
				if let tankLevel = Double(tankLevelTextField.text!){
					if tankLevel <= vehicle.gallonCapacity{
						newTankLevel = tankLevel
					}else {
						//alert saying the gas level cant be greater than the capcity
						alert(message: "The new tank level can't be over the set capacity")
					}
				}
			}
			if secondTankLevelTextField.text != "" {
				if let rearlevel = Double(secondTankLevelTextField.text!){
					if rearlevel <= vehicle.backGallonsCapacity!{
						newRearTankLevel = rearlevel
					}
					else {
						alert(message: "The new tank level can't be over the set capacity")
					}
				}
			}
			
			//updating all
			if newOdo != 0.0 && newTankLevel != 0.0 && newRearTankLevel != 0.0{
				vehicle.odo = Int(newOdo)
				vehicle.odoFillups[vehicle.odoFillups.count - 1] = Int(newOdo)
				vehicle.gasLevel = newTankLevel
				vehicle.gasLevelSecondTank = newRearTankLevel
				vehicle.updateVehicleInUserDocument(userId: userId!, arrayIdentifier: index!)
				dismiss(animated: true, completion: nil)
			}
				//updating odo and main tank level
			else if newOdo != 0.0 && newTankLevel != 0.0 && newRearTankLevel == 0.0{
				vehicle.odo = Int(newOdo)
				vehicle.odoFillups[vehicle.odoFillups.count - 1] =  Int(newOdo)
				vehicle.gasLevel = newTankLevel
				//update the document with new iformation
				vehicle.updateVehicleInUserDocument(userId: userId!, arrayIdentifier: index!)
				dismiss(animated: true, completion: nil)
			}
				//only updating odo
			else if newOdo != 0.0 && newTankLevel == 0.0 && newRearTankLevel == 0.0{
				vehicle.odo = Int(newOdo)
				vehicle.odoFillups[vehicle.odoFillups.count - 1 ] = Int(newOdo)
				//udate with new odo
				vehicle.updateVehicleInUserDocument(userId: userId!, arrayIdentifier: index!)
				dismiss(animated: true, completion: nil)
			}	//only updating rear tank level
			else if newRearTankLevel != 0.0 && newOdo == 0.0 && newTankLevel == 0.0{
				vehicle.gasLevelSecondTank = newRearTankLevel
				vehicle.updateVehicleInUserDocument(userId: userId!, arrayIdentifier: index!)
				dismiss(animated: true, completion: nil)
			}
				// only updating main tank
			else if newOdo == 0.0 && newTankLevel != 0.0 && newRearTankLevel == 0.0{
				vehicle.gasLevel = newTankLevel
				
				vehicle.updateVehicleInUserDocument(userId: userId!, arrayIdentifier: index!)
				dismiss(animated: true, completion: nil)
			}
				// updating odo and rear tank
			else if newOdo != 0.0 && newTankLevel == 0.0 && newRearTankLevel != 0.0{
				vehicle.odo = Int(newOdo)
				vehicle.odoFillups[vehicle.odoFillups.count - 1] = Int(newOdo)
				dismiss(animated: true, completion: nil)
			}
				//update on if there is no value for odd but the 2 tanks want to be updated
			else if newOdo == 0.0 && newTankLevel != 0.0 && newRearTankLevel != 0.0{
				vehicle.gasLevel = newTankLevel
				vehicle.gasLevelSecondTank = newRearTankLevel
				vehicle.updateVehicleInUserDocument(userId: userId!, arrayIdentifier: index!)
				dismiss(animated: true, completion: nil)
			}
			else { alert(message: "Somthing went wrong please contact support"); return}
		}
	}
	//control of the keyboards
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		//allows the return button to navagate to the next text field
		if textField == odoTextField{ tankLevelTextField.becomeFirstResponder() }
		else if textField == tankLevelTextField{ secondTankLevelTextField.becomeFirstResponder() }
		else if textField == tankLevelTextField{ tankLevelTextField.resignFirstResponder()}
		else if textField == secondTankLevelTextField{ secondTankLevelTextField.resignFirstResponder() }
		return true
	}
	@IBAction func cancel(_ sender: UIButton) {
		dismiss(animated: true, completion: nil)
	}
}
