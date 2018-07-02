//
//  vehicleClass.swift
//  GasLogApp
//
//  Created by Eric Barber on 11/3/17.
//  Copyright © 2017 Eric Barber. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase

class Vehicle{
	
	var gasLevel: Double
	var gasLevelSecondTank: Double?
	var averageMpg: Double
	var nameOfVehicle: String
	var odo: Int
	var multipleTanks: Bool
	var gallonCapacity: Double
	var backGallonsCapacity: Double?
	//Add on a way to allow the user to continueally add more mpgs after every fill up
	var fillUpMpgs: [Double] = []
	var odoFillups: [Int] = []
	var costRecords: [Double] = []
	var datesOfFilles: [Date] = []
	var trip: [Double] = []
	var notes: [String] = []
	
	//initlaize if the vehicle is only a single tank
	init ( averageMpg: Double, nameOfVehicle: String, odo: Int, multipleTanks: Bool, gallonCapacity: Double, gasLevel: Double){
		self.averageMpg = averageMpg
		self.nameOfVehicle = nameOfVehicle
		self.odo = odo
		self.multipleTanks = multipleTanks
		self.gallonCapacity = gallonCapacity
		self.gasLevel = gasLevel
		self.fillUpMpgs.append(averageMpg)
		self.odoFillups.append(odo)
	}
	
	//inilaize if the vechile has 2 tanks
	init ( averageMpg: Double, nameOfVehicle: String, odo: Int, multipleTanks: Bool, gallonCapacity: Double, backGallonsCapacity: Double?, gasLevel: Double, gasLevelSecondTank: Double?){
		
		self.averageMpg = averageMpg
		self.nameOfVehicle = nameOfVehicle
		self.odo = odo
		self.multipleTanks = multipleTanks
		self.gallonCapacity = gallonCapacity
		self.backGallonsCapacity = backGallonsCapacity
		self.gasLevel = gasLevel
		self.gasLevelSecondTank = gasLevelSecondTank
		self.fillUpMpgs.append(averageMpg)
		self.odoFillups.append(odo)
	}
	
	
	func updateAverageMpg(recentMpgAfterFillup: Double){
		
		fillUpMpgs.append(recentMpgAfterFillup)
		
		if fillUpMpgs.count >= 2{
			var totalmpg: Double = 0.0
			for mpgs in fillUpMpgs{
				totalmpg += mpgs
			}
			averageMpg = totalmpg / Double(fillUpMpgs.count)
			
		}else {
			print("There is not enough to update the average Mpg")
		}
	}
	func calculateAvgMpg(){
		if fillUpMpgs.count >= 2{
			var totalmpg: Double = 0.0
			for mpgs in fillUpMpgs{
				totalmpg += mpgs
			}
			averageMpg = totalmpg / Double(fillUpMpgs.count)
		}
		else {
			averageMpg = fillUpMpgs[0]
		}
	}
	
	func updateVehicleInUserDocument(userId: String, arrayIdentifier: Int){
		//Update the users vehicle within their document based off of the values for the active vehicle
		
		if multipleTanks != true{
			let db = Firestore.firestore()
			db.collection("users").document(userId).updateData(["Vehicle\(arrayIdentifier)": [
				nameOfVehicle,
				averageMpg,
				gallonCapacity,
				gasLevel,
				multipleTanks
				]])
			db.collection("users").document(userId).updateData(["ODO\(nameOfVehicle)": odoFillups])
			db.collection("users").document(userId).updateData(["MPGS\(nameOfVehicle)": fillUpMpgs])
			db.collection("users").document(userId).updateData(["datesOfFillups\(nameOfVehicle)": datesOfFilles])
			db.collection("users").document(userId).updateData(["CostRecords\(nameOfVehicle)": costRecords])
			db.collection("users").document(userId).updateData(["trip\(nameOfVehicle)": trip])
			db.collection("users").document(userId).updateData(["notes\(nameOfVehicle)": notes])
			
			
		}else {
			let db = Firestore.firestore()
			db.collection("users").document(userId).updateData(["Vehicle\(arrayIdentifier)" : [
				nameOfVehicle,
				averageMpg,
				gallonCapacity,
				gasLevel,
				multipleTanks,
				backGallonsCapacity!,
				gasLevelSecondTank!
				]])
			//add the array of odometer reading to the vehcile user document
			db.collection("users").document(userId).updateData(["ODO\(nameOfVehicle)": odoFillups])
			db.collection("users").document(userId).updateData(["MPGS\(nameOfVehicle)": fillUpMpgs])
			db.collection("users").document(userId).updateData(["datesOfFillups\(nameOfVehicle)": datesOfFilles])
			db.collection("users").document(userId).updateData(["CostRecords\(nameOfVehicle)": costRecords])
			db.collection("users").document(userId).updateData(["trip\(nameOfVehicle)": trip])
			db.collection("users").document(userId).updateData(["notes\(nameOfVehicle)": notes])
		}
	}
	
	func addVehicleToUserDocument(userId: String, arrayIdentifier: Int){
		//The only difference between this and the one add vehicle is it doesnt add a new vehicle to the users
		// information vairbale of num vehicle.
		if multipleTanks != true{
			let db = Firestore.firestore()
			db.collection("users").document(userId).updateData(["Vehicle\(arrayIdentifier)": [
				nameOfVehicle,
				averageMpg,
				gallonCapacity,
				gasLevel,
				multipleTanks
				]])
			db.collection("users").document(userId).updateData(["ODO\(nameOfVehicle)": odoFillups])
			db.collection("users").document(userId).updateData(["MPGS\(nameOfVehicle)": fillUpMpgs])
			db.collection("users").document(userId).updateData(["datesOfFillups\(nameOfVehicle)": datesOfFilles])
			db.collection("users").document(userId).updateData(["CostRecords\(nameOfVehicle)": costRecords])
			db.collection("users").document(userId).updateData(["trip\(nameOfVehicle)": [0]])
			db.collection("users").document(userId).updateData(["notes\(nameOfVehicle)": notes])
			
		}else {
			let db = Firestore.firestore()
			db.collection("users").document(userId).updateData(["Vehicle\(arrayIdentifier)" : [
				nameOfVehicle,
				averageMpg,
				gallonCapacity,
				gasLevel,
				multipleTanks,
				backGallonsCapacity!,
				gasLevelSecondTank!
				]])
			//add the array of odometer reading to the vehcile user document
			db.collection("users").document(userId).updateData(["ODO\(nameOfVehicle)": odoFillups])
			db.collection("users").document(userId).updateData(["MPGS\(nameOfVehicle)": fillUpMpgs])
			db.collection("users").document(userId).updateData(["datesOfFillups\(nameOfVehicle)": datesOfFilles])
			db.collection("users").document(userId).updateData(["CostRecords\(nameOfVehicle)": costRecords])
			db.collection("users").document(userId).updateData(["trip\(nameOfVehicle)": [0,0]])
			db.collection("users").document(userId).updateData(["notes\(nameOfVehicle)": notes])
		}
		//need to update the users number of vehicles after a new vehicle has been added
		updateNumVehiclesForUser(userId: userId, numVehicle: arrayIdentifier)
	}
	
	func updateNumVehiclesForUser(userId: String, numVehicle: Int){
		let db = Firestore.firestore()
		var numaricNum = numVehicle
		numaricNum += 1
		db.collection("users").document(userId).updateData(["numVehicles" : numaricNum])
	}
}

