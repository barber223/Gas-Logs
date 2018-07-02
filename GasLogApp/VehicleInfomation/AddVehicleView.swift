//
//  AddVehicleView.swift
//  GasLogApp
//
//  Created by Eric Barber on 11/2/17.
//  Copyright © 2017 Eric Barber. All rights reserved.
//

import UIKit
import Firebase

class AddVehicleView: UIViewController, UITextFieldDelegate {
	
	var ref: DatabaseReference?
	var handle : AuthStateDidChangeListenerHandle?
	var vehicle: Vehicle?
	var numVehicle: Int = 0

	@IBOutlet weak var vehicleName: UITextField!
	@IBOutlet weak var mpgTextFild: UITextField!
	@IBOutlet weak var currentODOTextField: UITextField!
	@IBOutlet weak var gallonsTextField: UITextField!
	@IBOutlet weak var twoTanksSwitch: UISwitch!
	@IBOutlet weak var secondTanksView: UIView!
	@IBOutlet weak var secondTanksGallonsTextField: UITextField!
	@IBOutlet weak var addVehicleButton: UIButton!
	@IBOutlet weak var cancelButton: UIButton!
	
	//Do not allow rotation of applacation
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.portrait
	}
	override var shouldAutorotate: Bool{
		return false
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		//Upon opening of this viw need the 2Tanks option to be not active because most vechiles dont contain 2 tanks
		
		twoTanksSwitch.isOn = false
		secondTanksView.isHidden = true
		secondTanksGallonsTextField.isEnabled = false
		secondTanksGallonsTextField.isHidden = true
		addVehicleButton.layer.cornerRadius = 1
		ref = Database.database().reference()
		//need to allow use of the cancel button based on if there is more than one vehicle within the users database
		if numVehicle > 0{
			cancelButton.isHidden = false
			cancelButton.isEnabled = true
			cancelButton.isUserInteractionEnabled = true
		}
		else {
			cancelButton.isHidden = true
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func switchPress(_ sender: UISwitch) {
		//Need to acresses a IBAction for when the shich has changed values so that I can tell if there is multiple tanks or not
		if sender.isOn == true{
			secondTanksView.isHidden = false
			secondTanksGallonsTextField.isEnabled = true
			secondTanksGallonsTextField.isHidden = false
		}
		else if sender.isOn == false{
			secondTanksView.isHidden = true
			secondTanksGallonsTextField.isEnabled = false
			secondTanksGallonsTextField.isHidden = true
		}
	}
	
	@IBAction func AddVehicleButtonPress(_ sender: UIButton) {
		//Neeed to set the tests to make sure that the fields are not able blank and contain the proper information
		//ToDo
		//Make sure there is a way to allow the user to edit the values for the vehicle that was created.
		var errorMessage: String = ""
		func alert_FieldsIncorrect(){
			// provides an alert to the user if there is an issue with Add vehicle
			let alert = UIAlertController(title: "Field Error", message: errorMessage, preferredStyle: .alert)
			let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
			// add the button to the alert
			alert.addAction(okButton)
			// present the alert
			present(alert, animated: true, completion: {print("Alert was shown.")})
		}
		//need acess to the active user
		handle = Auth.auth().addStateDidChangeListener { auth, user in
			if user != nil {
				if self.vehicleName.text != "" && self.mpgTextFild.text != "" && self.currentODOTextField.text != "" && self.gallonsTextField.text != ""{
					let db = Firestore.firestore()
					if self.twoTanksSwitch.isOn && self.secondTanksGallonsTextField.text != ""{
						//This is for when there is a two tank entry
						let newVehicle: Vehicle = Vehicle(averageMpg: Double(self.mpgTextFild.text!)!, nameOfVehicle: self.vehicleName.text!, odo: Int(self.currentODOTextField.text!)!, multipleTanks: true, gallonCapacity: Double(self.gallonsTextField.text!)!, backGallonsCapacity: Double(self.secondTanksGallonsTextField.text!), gasLevel: Double(self.gallonsTextField.text!)!, gasLevelSecondTank: Double(self.secondTanksGallonsTextField.text!)!)
						let uId: String = (user?.uid)!
						let docRef = db.collection("users").document(uId)
						docRef.getDocument{(document, error) in
							if let document = document{
								let docInfo = document.data()
								guard let numVehicles = docInfo["numVehicles"] as? Int
									else{ return}
								newVehicle.addVehicleToUserDocument(userId: uId, arrayIdentifier: numVehicles)
								//self.performSegue(withIdentifier: "ToMainStoryBoard", sender: nil)
								//Add the unwind segue to elimate the issue within the nav stack
								self.performSegue(withIdentifier: "unwindSeguetoSV1", sender: self)
							}
							else{
								print("Unable to obtain document information within add new vehicle")
							}
						}
					}
					else {
						//this is for when there is a single tank entry
						let newVehicle: Vehicle = Vehicle(averageMpg: Double(self.mpgTextFild.text!)! , nameOfVehicle: self.vehicleName.text!, odo: Int(self.currentODOTextField.text!)!, multipleTanks: false, gallonCapacity: Double(self.gallonsTextField.text!)!, gasLevel: Double(self.gallonsTextField.text!)!)
						let uId: String = (user?.uid)!
						let docRef = db.collection("users").document(uId)
						docRef.getDocument{(document, error) in
							if let document = document{
								let docInfo = document.data()
								guard let numVehicles = docInfo["numVehicles"] as? Int
									else{ return}
								newVehicle.addVehicleToUserDocument(userId: uId, arrayIdentifier: numVehicles)
								//need to go to the root view controller
								self.performSegue(withIdentifier: "unwindSeguetoSV1", sender: self)
							}
							else{
								print("Unable to obtain document information within add new vehicle")
							}
						}
					}
				}else{
					errorMessage = "There is an issue with the values entered please double check and try again"
					alert_FieldsIncorrect()
				}
			} else {
				print("There is no active user")
			}
		}
	}
	//Handeling the keyboard functionality
	//-
	//remove first responder from keyboard
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		//allows the return button to navagate to the next text field
		if textField == vehicleName{ mpgTextFild.becomeFirstResponder() }
		else if textField == mpgTextFild{ currentODOTextField.becomeFirstResponder() }
		else if textField == gallonsTextField && twoTanksSwitch.isOn{ secondTanksGallonsTextField.becomeFirstResponder()  }
		else if ((textField == gallonsTextField) && (twoTanksSwitch.isOn == false)) {gallonsTextField.resignFirstResponder()}
		else if textField == secondTanksGallonsTextField {secondTanksGallonsTextField.resignFirstResponder()}
		return true
	}
	
	//action for the cancel button
	@IBAction func cancelButtonPressed(_ sender: UIButton) {
		performSegue(withIdentifier: "unwindSeguetoSV1", sender: self)
	}//remove first responder from keyboard
	
}
