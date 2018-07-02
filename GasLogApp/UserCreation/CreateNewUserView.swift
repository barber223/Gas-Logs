//
//  CreateNewUserView.swift
//  GasLogApp
//
//  Created by Eric Barber on 11/2/17.
//  Copyright © 2017 Eric Barber. All rights reserved.
//

import UIKit
import Firebase

class CreateNewUserView: UIViewController, UITextFieldDelegate {
	
	@IBOutlet weak var UserNameTextField: UITextField!
	@IBOutlet weak var userNameView: UIView!
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var emailView: UIView!
	@IBOutlet weak var reEnterEmailTextField: UITextField!
	@IBOutlet weak var reEnterEmailView: UIView!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var passwordView: UIView!
	@IBOutlet weak var paswordReEntryTextField: UITextField!
	@IBOutlet weak var passwordReEnteryView: UIView!
	@IBOutlet weak var creatAccountButton: UIButton!
	
	var ref: DatabaseReference!
	
	//Do not allow rotation of applacation
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.portrait
	}
	override var shouldAutorotate: Bool{
		return false
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		userNameView.layer.cornerRadius = 1.0
		emailView.layer.cornerRadius = 1.0
		reEnterEmailView.layer.cornerRadius = 1.0
		passwordView.layer.cornerRadius = 1.0
		passwordReEnteryView.layer.cornerRadius = 1.0
		creatAccountButton.layer.cornerRadius = 1.0
		ref = Database.database().reference()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func createNewUser(_ sender: UIButton) {
		var errorMessage: String = ""
		func alert_FieldsIncorrect(){
			// provides an alert to the user if the above tests fail
			let alert = UIAlertController(title: "Field Error", message: errorMessage, preferredStyle: .alert)
			let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
			// add the button to the alert
			alert.addAction(okButton)
			// present the lert
			present(alert, animated: true, completion: {print("Alert was shown.")})
		}
		
		if ((emailTextField.text == reEnterEmailTextField.text) && (passwordTextField.text == paswordReEntryTextField.text) && UserNameTextField.text != "" ){
			Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
				if error == nil{
					//need acess to the new users uId
					
					Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!, completion: { (user, error) in
						
						if user != nil{
							
							let newUser = User(userName: self.UserNameTextField.text!, email: self.emailTextField.text!, numberOfVehicles: 0)
							
							let uId:String = (user?.uid)!
							
							newUser.CreateDocForNewUser(uid: uId)
						}
					})
					do{
						try Auth.auth().signOut()
						self.dismiss(animated: true, completion: nil)
					} catch{
						print("logout failed")
					}
				}
				else {
					if let myError = error?.localizedDescription{
						print(myError)
						errorMessage = myError
						alert_FieldsIncorrect()
					}
					else {
						print("Well I dont know what happened but it was in creating a new user")
					}
				}
			})
		}
		else {
			errorMessage = "Email and re email are not the same and the password and re password are not the same"
			alert_FieldsIncorrect()
		}
	}
	
	@IBAction func CancelCreateAccount(_ sender: UIButton) {
		dismiss(animated: true, completion: nil)
	}
	
	//remove first responder from keyboard
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		//allows the return button to navagate to the next text field
		if textField == UserNameTextField { emailTextField.becomeFirstResponder() }
		else if textField == emailTextField { reEnterEmailTextField.becomeFirstResponder() }
		else if textField == reEnterEmailTextField { passwordTextField.becomeFirstResponder() }
		else if textField == passwordTextField { paswordReEntryTextField.becomeFirstResponder() }
		else if textField == paswordReEntryTextField { paswordReEntryTextField.resignFirstResponder() }
		return true
	}
}
