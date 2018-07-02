//
//  NearByGasStations.swift
//  GasLogApp
//
//  Created by Eric Barber on 11/14/17.
//  Copyright © 2017 Eric Barber. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class NearByGasStations: UIViewController, MKMapViewDelegate {
	
	var usersLastKnownLocation: CLLocation?
	//array of local gas stations in the are So that I can populate the map pull from json Gasfeed api
	var localGasStations: [LocalGasStations] = []
	var myGasFeedAPIString: String = ""
	
	//instance of the map
	@IBOutlet weak var mapView: MKMapView!
	//nav button
	var navButton: UIButton!
	var pin: mapPin!
	
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
		//Create the urlString and set its values based off the userslasknown location
		// future revs will allow the user to have more say in what is searched for
		//   /stations/radius/(Latitude)/(Longitude)/(distance)/(fuel type)/(sort by)/apikey.json?callback=?
		if let userLocation = usersLastKnownLocation{
			let lat = userLocation.coordinate.latitude
			let long = userLocation.coordinate.longitude
			myGasFeedAPIString	 = "http://api.mygasfeed.com/stations/radius/\(lat)/\(long)/1/reg/price/rp9hmnve7s.json?"
			//Need to sent the string to the download to be picked apart
			downloadJsonAndParse(urlString: myGasFeedAPIString)
			//set up the map view
			mapView.delegate = self
			mapView.showsBuildings = true
			mapView.showsScale = true
			mapView.mapType = .hybrid
			mapView.showsUserLocation = true
			let locationSearch: CLLocationCoordinate2D = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
			self.mapView.setCenter(locationSearch, animated: true)
			self.mapView .setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
			
		}else {
			print("User has not recorded any locations")
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//create a function to allow me to be able to pull the api information using the users last known location.
	//- Hopefully the user stops the vehicle before continueing to use their phone :)
	
	func downloadJsonAndParse(urlString: String){
		
		let config = URLSessionConfiguration.default
		let session = URLSession(configuration: config)
		if let validURL = URL(string: urlString) {
			let task = session.dataTask(with: validURL, completionHandler: { (o_data, o_response, o_error) in
				//return on error
				if o_error != nil {
					print("\(o_error!)")
					return
				}
				//Check the response, statusCode, and data make sure they are valid
				guard let response = o_response as? HTTPURLResponse,
					response.statusCode == 200,
					let data = o_data
					else { return }
				
				do {
					//De-Serialize data object to a readable object
					if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
						
						//Parse Data
						if let jsonDataModel = json["stations"] as? [[String: Any]]{
							//cycles through all of the children of the json object
							for station in jsonDataModel{
								// pulls the data of each child object
								// pulling the required information of the data object
								//loop through the aray of array of objects to pull the desired information from each station then append it to the local gas stations array
								guard let regPrice = station["reg_price"] as? String,
									let midPrice = station["mid_price"] as? String,
									let prePrice = station["pre_price"] as? String,
									let dieselPrice = station["diesel_price"] as? String,
									let name = station ["station"] as? String,
									let latOfStation = station["lat"] as? String,
									let longOfStation = station["lng"] as? String
									else{print("UnableToPullinformationFrom Stations"); return}
								//need to append the information that was pulled to the array
								self.localGasStations.append(LocalGasStations(reg_Price: regPrice, mid_Price: midPrice, pre_Price: prePrice, diesel_Price: dieselPrice, station_Name: name, lat: latOfStation, long: longOfStation))
							}
							self.setPinsForMap()
						}
					}
				}
				catch {
					print(error.localizedDescription)
				}
				// forces the thread to coplete task as main responsablity
				DispatchQueue.main.async {
					//self.uiTableView.reloadData()
				}
			})
			task.resume()
		}
	}
	
	@IBAction func GoHomeButton(_ sender: UIButton) {
		
		performSegue(withIdentifier: "backToHome", sender: self)
	}
	func setPinsForMap(){
		//let spanOfView: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 9000, longitudeDelta: 9000)
		for stations in localGasStations{
			//set pin information based off near by stations and add to the map
			pin = mapPin(title: stations.station_Name, subtitle: "Reg: \(stations.reg_Price) Mid: \(stations.mid_Price) Pre: \(stations.pre_Price) Diesal: \(stations.diesel_Price)", coordinate: CLLocationCoordinate2D(latitude: Double(stations.lat)!, longitude: Double(stations.long)!))

				self.mapView.addAnnotation(self.pin)
			
		}
	}
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		let annotationView = MKPinAnnotationView(annotation: pin, reuseIdentifier: "pinId_01")
		annotationView.canShowCallout = true
		annotationView.calloutOffset = CGPoint(x: -5, y: -5)
		let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 5, height: 5)))
		mapsButton.titleLabel?.text = "Nav"
		let button = UIButton(type: .detailDisclosure)
		button.setImage(#imageLiteral(resourceName: "NavIcon"), for: .normal)
		button.setImage(#imageLiteral(resourceName: "NavIcon"), for: .highlighted)
		button.addTarget(self, action: #selector(NearByGasStations.getDirections), for: .touchUpInside)
		annotationView.rightCalloutAccessoryView = button
		return annotationView
	}
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		guard let selectedPin = view.annotation as? mapPin
			else { print("pin can not be pulled"); return}
		pin = selectedPin
	}
	
	@objc func getDirections(){
		guard let activePin = pin
			else {return}
		let plceMark = MKPlacemark(coordinate: activePin.coordinate)
		let mapItem = MKMapItem(placemark: plceMark)
		let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
		mapItem.openInMaps(launchOptions: launchOptions)
	}
}

