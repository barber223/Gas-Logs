//
//  LogInView.swift
//  GasLogApp
//
//  Created by Eric Barber on 11/2/17.
//  Copyright © 2017 Eric Barber. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase


class LogInView: UIViewController, UITextFieldDelegate{
	
	//create an instance of the database reference to tell if the user is a new user or not
	var ref: DatabaseReference?
	
	@IBOutlet weak var emailTextFiel: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var logInButton: UIButton!
	
	var segueIdentifier: String = ""
	let defaultStore = Firestore.firestore()
	
	//Do not allow rotation of applacation
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.portrait
	}
	override var shouldAutorotate: Bool{
		return false
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		ref = Database.database().reference()
		logInButton.layer.cornerRadius = 1
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func Login(_ sender: UIButton) {
		
		var errorMessage: String = ""
		
		func alert_FieldsIncorrect(){
			// provides an alert to the user if there is an issue with log in
			let alert = UIAlertController(title: "Field Error", message: errorMessage, preferredStyle: .alert)
			let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
			// add the button to the alert
			alert.addAction(okButton)
			// present the lert
			present(alert, animated: true, completion: {print("Alert was shown.")})
		}
		if emailTextFiel.text != "" && passwordTextField.text != ""{
			Auth.auth().signIn(withEmail: emailTextFiel.text!, password: passwordTextField.text!, completion: { (user, error) in
				if user != nil{
					let db = Firestore.firestore()
					let docRef = db.collection("users").document((user?.uid)!)
					docRef.getDocument{(document, error) in
						if let document = document{
							let docInfo = document.data()
							guard let numberOfVehicles = docInfo["numVehicles"] as? Int
								else { print("DocInformation is not here"); return }
							if numberOfVehicles == 0{
								self.segueIdentifier = "toNewVehicle"
								self.performSegue(withIdentifier: "toNewVehicle", sender: nil)
							}else{
								//this should run if there is a vehicle that has already been created for this user
								//Sign in sucessFul Continue to new view controller
								//self.segueIdentifier = "ToMainViewLogInSuccessful"
								//self.performSegue(withIdentifier: "ToMainViewLogInSuccessful", sender: self)
								self.performSegue(withIdentifier: "unwindSeguetoSV1", sender: self)
							}
						}else {
							print("Doc doesn't exist")
						}
					}
				}else {
					if let theError = error?.localizedDescription
					{
						print(theError)
						errorMessage = theError
						alert_FieldsIncorrect()
					}
					else {
						print("Eror dont know what happened?")
					}
				}
			})
		}
		else {
			errorMessage = "Either the email or password field is empty"
			alert_FieldsIncorrect()
		}
	}
	//remove first responder from keyboard
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		//allows the return button to navagate to the next text field
		if textField == emailTextFiel{ passwordTextField.becomeFirstResponder() }
		else if textField == passwordTextField{ textField.resignFirstResponder() }
		return true
	}
}
