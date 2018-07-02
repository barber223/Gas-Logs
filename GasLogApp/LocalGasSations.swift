//
//  LocalGasSations.swift
//  GasLogApp
//
//  Created by Eric Barber on 11/14/17.
//  Copyright © 2017 Eric Barber. All rights reserved.
//

import Foundation

class LocalGasStations{
	
	var reg_Price: String
	var mid_Price: String
	var pre_Price: String
	var diesel_Price: String
	var station_Name: String
	var lat: String
	var long: String
	
	//initilaize the class
	init(reg_Price: String, mid_Price: String, pre_Price: String, diesel_Price: String,  station_Name: String, lat: String, long: String){
		
		//save the class member variables
		self.reg_Price = reg_Price
		self.mid_Price = mid_Price
		self.pre_Price = pre_Price
		self.diesel_Price = diesel_Price
		self.station_Name = station_Name
		self.lat = lat
		self.long = long
		
	}
	
	
}





