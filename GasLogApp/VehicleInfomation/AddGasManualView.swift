//
//  AddGasManualView.swift
//  GasLogApp
//
//  Created by Eric Barber on 11/2/17.
//  Copyright © 2017 Eric Barber. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase

class AddGasManualView: UIViewController {
	
	//outlets
	@IBOutlet weak var frontAndBackCrontrol: UISegmentedControl!
	@IBOutlet weak var costTextField: UITextField!
	@IBOutlet weak var gallonsTextField: UITextField!
	@IBOutlet weak var odoTextField: UITextField!
	@IBOutlet weak var notesTextField: UITextView!
	@IBOutlet weak var addGasButton: UIButton!
	@IBOutlet weak var FinishFillUpButton: UIButton!
	@IBOutlet weak var cancelButton: UIButton!
	
	//variables
	var vehicle: Vehicle?
	var userId: String?
	//need variables for the recent fillup that can be acessed when returning to the main view controller
	var currentOdo: Int = 0
	var gallonsEntered: Double = 0.0
	var gallonsEnteredForRearTank: Double = 0.0
	var costOfFillup: Double = 0.0
	var mpgOnThisFillup: Double = 0.0
	var dateOfFillup: Date?
	var totalGallonsEntered: Double = 0.0
	var gasWasAdded: Bool = false
	var noteFromFill: String = ""

	override func viewWillAppear(_ animated: Bool) {
		// Do any additional setup after loading the view.
		if vehicle?.multipleTanks != true{
			frontAndBackCrontrol.isEnabled = false
			frontAndBackCrontrol.isHidden = true
			FinishFillUpButton.isEnabled = false
			FinishFillUpButton.isHidden = true
		}
		else {
			//activate the segented controls
			frontAndBackCrontrol.isEnabled = true
			frontAndBackCrontrol.isHidden = false
			FinishFillUpButton.isEnabled = true
			FinishFillUpButton.isHidden = false
			
			DispatchQueue.main.async {
				self.showAlert( alertMessage: "Are you putting gas in each tank")
			}
		}
	}
	
	//Do not allow rotation of applacation
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.portrait
	}
	override var shouldAutorotate: Bool{
		return false
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidAppear(_ animated: Bool) {
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func addGasButtonPress(_ sender: UIButton) {
		
		if let veh = vehicle{
			//single tank vehicle functionality
			if veh.multipleTanks != true {
				if costTextField.text != "" && gallonsTextField.text != "" && odoTextField.text != "" && notesTextField.text == ""{
					if (Int(odoTextField.text!)!) > (vehicle?.odo)!{
						let gallonsAllowed = veh.gallonCapacity - veh.gasLevel
						//This will not allow the user to "over fill" the tank
						if ((Double(gallonsTextField.text!)!) <= (gallonsAllowed)) {
							self.currentOdo = (Int(self.odoTextField.text!)!)
							self.costOfFillup = Double(self.costTextField.text!)!
							self.gallonsEntered = Double(self.gallonsTextField.text!)!
							self.calculatefillupMpg()
							self.dateOfFillup = Date()
							self.noteFromFill = notesTextField.text
							//print(self.dateOfFillup!)
							self.performSegue(withIdentifier: "unwindSeguetoSV1", sender: self)
						} else{ showAlert( alertMessage: "To many gallons where entered") }
					} else{ showAlert( alertMessage: "the odo entered is not correct") }
				}else if costTextField.text != "" && gallonsTextField.text != "" && odoTextField.text != "" && notesTextField.text != ""{
					if ((Int(odoTextField.text!)!) > (veh.odo)) && (Int(odoTextField.text!)!) < ((veh.odo) + 1000){
						let gallonsAllowed = veh.gallonCapacity - veh.gasLevel
						if ((Double(gallonsTextField.text!)!) <= (gallonsAllowed)) {
							currentOdo = (Int(odoTextField.text!)!)
							costOfFillup = Double(costTextField.text!)!
							gallonsEntered = Double(gallonsTextField.text!)!
							calculatefillupMpg()
							self.dateOfFillup = Date()
							print(self.dateOfFillup!)
							self.noteFromFill = notesTextField.text
							performSegue(withIdentifier: "unwindSeguetoSV1", sender: self)
						} else{showAlert( alertMessage: "To many gallons where entered") }
					} else{ showAlert( alertMessage: "the odo entered is not correct")}
				}
			}
				//multiple tanks functionality
			else{
				var multipleTankFill: Int = 0
				if costTextField.text != "" && gallonsTextField.text != "" && odoTextField.text != "" && notesTextField.text != ""{
					//multiple tanks being filled and first tank is being filled
					if frontAndBackCrontrol.selectedSegmentIndex == 0 && multipleTankFill == 0 && addGasButton.isEnabled == true{
						let currentOdoOnLoad = veh.odoFillups[veh.odoFillups.count - 1]
						if ((Int(odoTextField.text!)!) > (currentOdoOnLoad)) && (Int(odoTextField.text!)!) < ((currentOdoOnLoad) + 1000){
							let gallonsAllowed = veh.gallonCapacity - veh.gasLevel
							if ((Double(gallonsTextField.text!)!) <= (gallonsAllowed)) {
								currentOdo = (Int(odoTextField.text!)!)
								costOfFillup = Double(costTextField.text!)!
								gallonsEntered = Double(gallonsTextField.text!)!
								totalGallonsEntered  = gallonsEntered + gallonsEnteredForRearTank
								multipleTankFill += 1
								//disable textFields that have already been recorded
								//remove the checks for those fields
								odoTextField.isEnabled = false
								gallonsTextField.text = ""
								gallonsTextField.placeholder = "Enter pump gallons"
								costTextField.text = ""
								costTextField.placeholder = "Enter the cost on pump"
								frontAndBackCrontrol.selectedSegmentIndex = 1
								addGasButton.isEnabled = false
								self.noteFromFill = notesTextField.text
							} else{ showAlert( alertMessage: "To many gallons where entered") }
						}else{ showAlert( alertMessage: "the odo entered is not correct")}
					}
						//this is for when there is only gas being added to a single tank to the fron
					else if frontAndBackCrontrol.selectedSegmentIndex == 0 && multipleTankFill == 0 && addGasButton.isEnabled == false{
						let currentOdoOnLoad = veh.odoFillups[veh.odoFillups.count - 1]
						if ((Int(odoTextField.text!)!) > (currentOdoOnLoad)) && (Int(odoTextField.text!)!) < ((currentOdoOnLoad) + 1000){
							let gallonsAllowed = veh.gallonCapacity - veh.gasLevel
							if ((Double(gallonsTextField.text!)!) <= (gallonsAllowed)) {
								currentOdo = (Int(odoTextField.text!)!)
								costOfFillup = Double(costTextField.text!)!
								gallonsEntered = Double(gallonsTextField.text!)!
								totalGallonsEntered  = gallonsEntered + gallonsEnteredForRearTank
								multipleTankFill += 1
								//disable textFields that have already been recorded
								//remove the checks for those fields
								odoTextField.isEnabled = false
								gallonsTextField.text = ""
								gallonsTextField.placeholder = "Enter pump gallons"
								costTextField.text = ""
								costTextField.placeholder = "Enter the cost on pump"
								frontAndBackCrontrol.selectedSegmentIndex = 1
								addGasButton.isEnabled = false
								gasWasAdded = true
								self.noteFromFill = notesTextField.text
							} else{showAlert( alertMessage: "To many gallons where entered") }
						}else{showAlert( alertMessage: "the odo entered is not correct")}
					}
						///gas has already been added to one tank and there is a muliple tank being filled
					else if frontAndBackCrontrol.selectedSegmentIndex == 0 && multipleTankFill == 1{
						if ((Int(odoTextField.text!)!) > (veh.odo)) && (Int(odoTextField.text!)!) < ((veh.odo) + 1000){
							let gallonsAllowed = veh.gallonCapacity - veh.gasLevel
							if ((Double(gallonsTextField.text!)!) <= (gallonsAllowed)) {
								currentOdo = (Int(odoTextField.text!)!)
								costOfFillup = Double(costTextField.text!)!
								totalGallonsEntered += Double(gallonsTextField.text!)!
								gallonsEntered = totalGallonsEntered - gallonsEnteredForRearTank
								multipleTankFill += 1
								gasWasAdded = true
								self.noteFromFill = notesTextField.text
							} else{ showAlert( alertMessage: "To many gallons where entered") }
						} else{ showAlert( alertMessage: "the odo entered is not correct") }
					}
						//No gas has been added yet and there is a multiple fill being achieved
					else if frontAndBackCrontrol.selectedSegmentIndex == 1 &&  multipleTankFill == 0 && addGasButton.isEnabled == true{
						if ((Int(odoTextField.text!)!) > (veh.odo)) && (Int(odoTextField.text!)!) < ((veh.odo) + 1000){
							
							let gallonsAllowed = veh.gallonCapacity - veh.gasLevelSecondTank!
							if ((Double(gallonsTextField.text!)!) <= (gallonsAllowed)) {
								currentOdo = (Int(odoTextField.text!)!)
								costOfFillup = Double(costTextField.text!)!
								gallonsEnteredForRearTank = Double(gallonsTextField.text!)!
								totalGallonsEntered = gallonsEnteredForRearTank + gallonsEntered
								//disable textFields that have already been recorded
								//remove the checks for those fields
								odoTextField.isEnabled = false
								gallonsTextField.text = ""
								gallonsTextField.placeholder = "Enter pump gallons"
								costTextField.text = ""
								costTextField.placeholder = "Enter the cost on pump"
								frontAndBackCrontrol.selectedSegmentIndex = 0
								addGasButton.isEnabled = false
								multipleTankFill += 1
								self.noteFromFill = notesTextField.text
							}else{ showAlert( alertMessage: "To many gallons where entered") }
						} else{ showAlert( alertMessage: "the odo entered is not correct") }
					}
						//this is for when the single tank being filled is the rear tank
					else if frontAndBackCrontrol.selectedSegmentIndex == 1 &&  multipleTankFill == 0 && addGasButton.isEnabled == false{
						if ((Int(odoTextField.text!)!) > (veh.odo)) && (Int(odoTextField.text!)!) < ((veh.odo) + 1000){
							let gallonsAllowed = veh.gallonCapacity - veh.gasLevelSecondTank!
							if ((Double(gallonsTextField.text!)!) <= (gallonsAllowed)) {
								currentOdo = (Int(odoTextField.text!)!)
								costOfFillup = Double(costTextField.text!)!
								gallonsEnteredForRearTank = Double(gallonsTextField.text!)!
								totalGallonsEntered = gallonsEnteredForRearTank + gallonsEntered
								//disable textFields that have already been recorded
								//remove the checks for those fields
								odoTextField.isEnabled = false
								gallonsTextField.text = ""
								gallonsTextField.placeholder = "Enter pump gallons"
								costTextField.text = ""
								costTextField.placeholder = "Enter the cost on pump"
								frontAndBackCrontrol.selectedSegmentIndex = 0
								addGasButton.isEnabled = false
								multipleTankFill += 1
								gasWasAdded = true
								self.noteFromFill = notesTextField.text
							}else{ showAlert( alertMessage: "To many gallons where entered") }
						} else{ showAlert( alertMessage: "the odo entered is not correct") }
					}
						//multiple tanks being filled and there the first has been added and the second is have gas added
					else if frontAndBackCrontrol.selectedSegmentIndex == 1 &&  multipleTankFill == 1{
						if ((Int(odoTextField.text!)!) > (veh.odo)) && (Int(odoTextField.text!)!) < ((veh.odo) + 1000){
							let gallonsAllowed = veh.gallonCapacity - veh.gasLevelSecondTank!
							if ((Double(gallonsTextField.text!)!) <= (gallonsAllowed)) {
								currentOdo = (Int(odoTextField.text!)!)
								costOfFillup = Double(costTextField.text!)!
								totalGallonsEntered = Double(gallonsTextField.text!)! + gallonsEntered
								gallonsEnteredForRearTank = Double(gallonsTextField.text!)! - gallonsEntered
								multipleTankFill += 1
								gasWasAdded = true
								self.noteFromFill = notesTextField.text
							} else{ showAlert( alertMessage: "To many gallons where entered") }
						} else{ showAlert( alertMessage: "the odo entered is not correct") }
					}
				}
			}
		}
		/*testing update of vehicle name to see if it will reflect on main view on dismiss of this controller
		let db = Firestore.firestore()
		db.collection("users").document(userId!).updateData(["userName" : "Joshua"])
		*/
	}
	
	func calculatefillupMpg(){
		let milesTraveled = Int(currentOdo - (vehicle?.odo)!)
		let totalGallonsEntered = gallonsEntered + gallonsEnteredForRearTank
		mpgOnThisFillup = (Double(milesTraveled) / totalGallonsEntered)
	}
	
	@IBAction func cancelButtonPress(_ sender: UIButton) {
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func FinishFillup(_ sender: UIButton) {
		addGasButtonPress(sender)
		if gasWasAdded == true{
			calculatefillupMpg()
			self.dateOfFillup = Date()
			//print(self.dateOfFillup!)
			performSegue(withIdentifier: "unwindSeguetoSV1", sender: self)
		}else{
			DispatchQueue.main.async {
				self.showAlert( alertMessage: "There is an issue with your input fields")
			}
		}
		//need to write the note to the database to be read at a later date
		noteFromFill = notesTextField.text
	}

	func showAlert( alertMessage: String)  {
		func whenUserSelectsYes (alert: UIAlertAction!){
			showAlert( alertMessage: "Select which tank gas is being entered into. Enter cost on pump, gallons, and odometer. Switch the other tank then enter the cost of the fill from the pump, and the gallons from pump. Odometer will have already been recorded. After you are satisfied with the entries press Finish Fill")
			//UserSelectedYes = true
			//set the add gas button to not enabled ffor it is a single fill
			addGasButton.isEnabled = true
		}

		func whenUserSelectsNo(alert: UIAlertAction!){
			showAlert( alertMessage: "Select which tank gas is being entered into. Enter cost on pump, gallons, and odometer. After you are satisfied with the entries press Finish Fill")
			addGasButton.isEnabled = false
		}
	
		if alertMessage == "Are you putting gas in each tank"{
			let alert = UIAlertController(title: "2-Tank Fillup Guide", message: alertMessage, preferredStyle: .alert)
			let yesButton = UIAlertAction(title: "Yes", style: .default, handler: whenUserSelectsYes(alert: ))
			let noButton = UIAlertAction(title: "No", style: .default, handler: whenUserSelectsNo(alert: ))
			// add the button to the alert
			alert.addAction(yesButton)
			alert.addAction(noButton)
			// present the alert
			self.present(alert, animated: true, completion: nil)
			
		}
		else {
			let alert = UIAlertController(title: "2-Tank Fillup Guide", message: alertMessage, preferredStyle: .alert)
			
			let okButton = UIAlertAction(title: "ok", style: .default, handler: nil)
			// add the button to the alert
			alert.addAction(okButton)
			// present the alert
			self.present(alert, animated: true, completion: nil)
			
		}
	}
	//remove first responder from keyboard
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}
}




