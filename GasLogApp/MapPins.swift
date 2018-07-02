//
//  MapPins.swift
//  GasLogApp
//
//  Created by Eric Barber on 11/14/17.
//  Copyright © 2017 Eric Barber. All rights reserved.
//

import Foundation
import MapKit

//This is to add a pin or uiView for the pinpopup
//annotation is the work for the pin

class mapPin: NSObject, MKAnnotation{
	//these are required for this class
	var title: String?
	var subtitle: String?
	var coordinate: CLLocationCoordinate2D

	init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D){
		self.title = title
		self.subtitle = subtitle
		self.coordinate = coordinate
	}
}
