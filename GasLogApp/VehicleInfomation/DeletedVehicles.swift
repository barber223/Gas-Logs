//
//  DeletedVehicles.swift
//  GasLogApp
//
//  Created by Eric Barber on 11/16/17.
//  Copyright © 2017 Eric Barber. All rights reserved.
//

import Foundation

class DeletedVehicles{
	
	var name: String
	var avMPG: Double
	var totalCost: Double
	var milesWent: Int
	var lastOdo: Int
	
	init (name: String, avMPG: Double, totalCost: Double, milesWent: Int, lastOdo: Int){
		self.name = name
		self.avMPG = avMPG
		self.totalCost = totalCost
		self.milesWent = milesWent
		self.lastOdo = lastOdo
	}
	
	
	
}


