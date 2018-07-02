//
//  User.swift
//  GasLogApp
//
//  Created by Eric Barber on 11/5/17.
//  Copyright © 2017 Eric Barber. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase

class User {
	
	var userName: String
	var email: String
	var numberOfVehicles: Int
	
	init ( userName: String, email: String, numberOfVehicles: Int){
		self.userName = userName
		self.email = email
		self.numberOfVehicles = numberOfVehicles
	}
	
	func CreateDocForNewUser (uid: String){
		let db = Firestore.firestore()
		db.collection("users").document(uid).setData([
			"userName" : userName,
			"email" : email,
			"numVehicles" : numberOfVehicles
			])
	}
}
