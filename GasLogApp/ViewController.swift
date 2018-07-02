//
//  ViewController.swift
//  GasLogApp
//
//  Created by Eric Barber on 10/22/17.
//  Copyright © 2017 Eric Barber. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase
import CoreLocation
import CoreMotion

class ViewController: UIViewController, CLLocationManagerDelegate {
	
	//location information
	var locationManager: CLLocationManager?
	var startingLocation: CLLocation!
	var lastKnownLocation: CLLocation!
	var Trip: Double = 0
	
	//acelorometer
	var accel = CMMotionManager()
	
	//create outlets
	@IBOutlet weak var multipleTanksSegControl: UISegmentedControl!
	@IBOutlet weak var nameOfVehicleLabel: UILabel!
	@IBOutlet weak var milesToEmptyLabel: UILabel!
	@IBOutlet weak var odoLabel: UILabel!
	@IBOutlet weak var tripLabel: UILabel!
	@IBOutlet weak var averageMpgLabel: UILabel!
	
	//need acess to the gad guage views
	@IBOutlet weak var gasView1_12: UIView!
	@IBOutlet weak var gasView2_12: UIView!
	@IBOutlet weak var gasView3_12: UIView!
	@IBOutlet weak var gasView4_12: UIView!
	@IBOutlet weak var gasView5_12: UIView!
	@IBOutlet weak var gasView6_12: UIView!
	@IBOutlet weak var gasView7_12: UIView!
	@IBOutlet weak var gasView8_12: UIView!
	@IBOutlet weak var gasView9_12: UIView!
	@IBOutlet weak var gasView10_12: UIView!
	@IBOutlet weak var gasView11_12: UIView!
	@IBOutlet weak var gasView12_12: UIView!
	//Outlets for developing
	@IBOutlet weak var toNavMapButton: UIButton!
	@IBOutlet weak var logoutButton: UIButton!
	//outlet for futureRevisions
	
	@IBOutlet weak var settingbutton: UIImageView!
	
	//member variables
	var activeUserId: String = ""
	var vehcileSelected: Int = 0
	var numVehicle: Int = 0
	var ref: DatabaseReference!
	var handle : AuthStateDidChangeListenerHandle?
	//a string to tell which segue is being performed
	var segueIdentifier: String = ""
	var vehice: Vehicle?
	var milesToEmpty: Double = 0.0
	var odoRec: [Int] = []
	var datesOfFills: [Date] = []
	var costOfFille: [Double] = []
	var trip: [Double] = []
	var milesOnLastUpdate: Double = 0.0
	var notes: [String] = []
	var fullTankMiles: Double = 0.0
	
	var timer: Timer?
	
	override func viewWillAppear(_ animated: Bool) {
		vehicleInformation()
		toNavMapButton.isEnabled = false
		toNavMapButton.isHidden = true
		logoutButton.isEnabled = false
		logoutButton.isHidden = true
		settingbutton.isHidden = true
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view, typically from a nib.
		vehicleInformation()
		locationManager = CLLocationManager()
		
		DispatchQueue.main.async {
			self.locationManager?.requestAlwaysAuthorization()
			self.locationManager?.requestWhenInUseAuthorization()
		}
		locationManager?.delegate = self
		locationManager?.desiredAccuracy = kCLLocationAccuracyBest
		locationManager?.distanceFilter = 5
		updateUIOnLoad()
		UpdateGasGagueValues()
	}
	override func viewDidAppear(_ animated: Bool) {
		updateUIOnLoad()
		UpdateGasGagueValues()
	}
	//Do not allow rotation of applacation
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.portrait
	}
	override var shouldAutorotate: Bool{
		return false
	}
	
	func startAccelerometers() {
		// Make sure the accelerometer hardware is available.
		if self.accel.isAccelerometerAvailable {
			self.accel.accelerometerUpdateInterval = 2.0 / 60.0  // 60 Hz
			self.accel.startAccelerometerUpdates()
			
			// Configure a timer to fetch the data.
			self.timer = Timer(fire: Date(), interval: (2.0/60.0), repeats: true, block: { (timer) in
				// Get the accelerometer data.
				if let data = self.accel.accelerometerData {
					let x = data.acceleration.x
					let y = data.acceleration.y
					let z = data.acceleration.z
					if ((1.2 < x) || (x < -1.2) || (y > 1.2) || (y < -1.2) || (z > 1.2) || (z < -1.2)){
						self.vehice?.averageMpg = self.vehice!.averageMpg * 0.80
						//self.UpdateGasGagueValues()
					}
					else {
						self.vehice?.calculateAvgMpg()
					}
					//self.UpdateGasGagueValues()
				}
			})
			// Add the timer to the current run loop.
			RunLoop.current.add(self.timer!, forMode: .defaultRunLoopMode)
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		Auth.auth().removeStateDidChangeListener(handle!)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//required methods for locationManager
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		if startingLocation == nil{
			startingLocation = locations.first
		}
		else if let location = locations.last{
			Trip += lastKnownLocation.distance(from: location)
			print ("Traveled Distance: \(Trip)")
			print ("Straight Distance: \(startingLocation.distance(from: locations.last!))")
		}
		lastKnownLocation = locations.last
		self.UpdateGasGagueValues()
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print(error)
	}
	
	func updateUIOnLoad(){
		
		if let veh = vehice{
			odoLabel.text = "ODO: \(veh.odo)"
			let mpg = String(format: "%.2f", veh.averageMpg)
			averageMpgLabel.text = "Avg mpg: \(mpg)"
			let miles = (Trip * 3) / 5280
			let formatMile = String(format: "%.2f", miles)
			tripLabel.text = "Trip: \(formatMile)"
			
			if veh.multipleTanks != true{
				multipleTanksSegControl.isEnabled = false
				multipleTanksSegControl.isHidden = true
				milesToEmpty = veh.gasLevel * veh.averageMpg
				let toEmpty = String(format: "%.2f", milesToEmpty)
				milesToEmptyLabel.text = "Miles To Empty: \(toEmpty)"
			}
			else {
				multipleTanksSegControl.isHidden = false
				multipleTanksSegControl.isEnabled = true
				
				if multipleTanksSegControl.selectedSegmentIndex == 0{
					milesToEmpty = veh.gasLevel * veh.averageMpg
					let toEmpty = String(format: "%.2f", milesToEmpty)
					milesToEmptyLabel.text = "Miles To Empty: \(toEmpty)"
				}
				else{
					milesToEmpty = veh.gasLevelSecondTank! * veh.averageMpg
					let toEmpty = String(format: "%.2f", milesToEmpty)
					milesToEmptyLabel.text = "Miles To Empty: \(toEmpty)"
				}
			}
		}
	}
	
	func calculateAvergaeMPG(mpg: Double){
		vehice?.updateAverageMpg(recentMpgAfterFillup: mpg)
	}
	
	func UpdateGasGagueValues(){
		//gas gaue will directly reflect based off of the miles till empty
		//as the miles to 00000000empty lesson the gas gague will lower as well
		let db = Firestore.firestore()
		//I need the differnece in total miles gone vs miles sence last gone so i can minus from the gas tanks level accurenty insead of coninulay subtracting more and more untill gone.
		
		if let veh = vehice{
			let miles = (Trip * 3.28084) / 5280
			if miles == 0{
				tripLabel.text = "Trip: 0.0"
			}
			else {
				let formattedMile = String(format: "%.2f", miles)
				tripLabel.text = "Trip: \(formattedMile)"
			}
			
			if veh.multipleTanks == true{
				//need to save the trip and gas level to the database
				if multipleTanksSegControl.selectedSegmentIndex == 0{
					fullTankMiles = veh.gallonCapacity * veh.averageMpg
					let milesToSubtract = miles - milesOnLastUpdate
					veh.gasLevel = veh.gasLevel - (milesToSubtract / veh.averageMpg)
					milesToEmpty = veh.gasLevel * veh.averageMpg
					let toEmpty = String(format: "%.2f", milesToEmpty)
					milesToEmptyLabel.text = "Miles To Empty: \(toEmpty)"
					trip[0] = Trip
					
					//record current miles on this update
					milesOnLastUpdate = miles
					db.collection("users").document(activeUserId).updateData(["trip\(veh.nameOfVehicle)": trip])
					//UpdateGasGagueValues()
				}
				else{
					fullTankMiles = veh.backGallonsCapacity! * veh.averageMpg
					let milesToSubtract = miles - milesOnLastUpdate
					veh.gasLevelSecondTank = veh.gasLevelSecondTank! - (milesToSubtract / veh.averageMpg)
					milesToEmpty = veh.gasLevelSecondTank! * veh.averageMpg
					let toEmpty = String(format: "%.2f", milesToEmpty)
					milesToEmptyLabel.text = "Miles To Empty: \(toEmpty)"
					milesToEmptyLabel.text = "Miles To Empty: \(milesToEmpty)"
					trip[1] = Trip
					//record current miles on this update
					milesOnLastUpdate = miles
					db.collection("users").document(activeUserId).updateData(["trip\(veh.nameOfVehicle)": trip])
				}
			}
			else {
				fullTankMiles = veh.gallonCapacity * veh.averageMpg
				let milesToSubtract = miles - milesOnLastUpdate
				veh.gasLevel = veh.gasLevel - (milesToSubtract / veh.averageMpg)
				milesToEmpty = veh.gasLevel * veh.averageMpg
				let toEmpty = String(format: "%.2f", milesToEmpty)
				milesToEmptyLabel.text = "Miles To Empty: \(toEmpty)"
				trip[0] = Trip
				//record current miles on this update
				milesOnLastUpdate = miles
				db.collection("users").document(activeUserId).updateData(["trip\(veh.nameOfVehicle)": trip])
			}
			
			//will only percent the alert if the user has a location so they must start driving
			if milesToEmpty <= 50 && milesToEmpty >= 48{
				if lastKnownLocation != nil{
				alertUserAmostOutOfGas()
				}else {
					//alert the user the is no gas left and they need to start driving
					let alert = UIAlertController(title: "Low on gas", message: "You need to start driving so We can help you find a gas station", preferredStyle: .alert)
					let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
					// add the button to the alert
					alert.addAction(okButton)
					// present the alert
					present(alert, animated: true, completion: {print("Alert was shown.")})
				}
			}
			//will only percent the alert if the user has a location so they must start driving More urgent!
			if milesToEmpty <= 20 && milesToEmpty >= 19.5{
				if lastKnownLocation != nil{
				alertUserThereIs20MilesLeft()
				}
				else {
					//alert the user the is no gas left and they need to start driving
					let alert = UIAlertController(title: "OUT OF GAS!!!", message: "You need to start driving so We can help you find a gas station", preferredStyle: .alert)
					let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
					// add the button to the alert
					alert.addAction(okButton)
					// present the alert
					present(alert, animated: true, completion: {print("Alert was shown.")})
				}
			}
			
			DispatchQueue.main.async {
				self.setGague()
			}
		}
	}
	func setGague(){
		let sectionsOfGasGague = fullTankMiles / 12
		if milesToEmpty <= sectionsOfGasGague * 2{
			gasView1_12.isHidden = false
			gasView2_12.isHidden = true
			gasView3_12.isHidden = true
			gasView4_12.isHidden = true
			gasView5_12.isHidden = true
			gasView6_12.isHidden = true
			gasView7_12.isHidden = true
			gasView8_12.isHidden = true
			gasView9_12.isHidden = true
			gasView10_12.isHidden = true
			gasView11_12.isHidden = true
			gasView12_12.isHidden = true
		}else if milesToEmpty <= sectionsOfGasGague * 3{
			gasView1_12.isHidden = false
			gasView2_12.isHidden = false
			gasView3_12.isHidden = true
			gasView4_12.isHidden = true
			gasView5_12.isHidden = true
			gasView6_12.isHidden = true
			gasView7_12.isHidden = true
			gasView8_12.isHidden = true
			gasView9_12.isHidden = true
			gasView10_12.isHidden = true
			gasView11_12.isHidden = true
			gasView12_12.isHidden = true
		}else if milesToEmpty <= sectionsOfGasGague * 4{
			gasView1_12.isHidden = false
			gasView2_12.isHidden = false
			gasView3_12.isHidden = false
			gasView4_12.isHidden = true
			gasView5_12.isHidden = true
			gasView6_12.isHidden = true
			gasView7_12.isHidden = true
			gasView8_12.isHidden = true
			gasView9_12.isHidden = true
			gasView10_12.isHidden = true
			gasView11_12.isHidden = true
			gasView12_12.isHidden = true
		}else if milesToEmpty <= sectionsOfGasGague * 5{
			gasView1_12.isHidden = false
			gasView2_12.isHidden = false
			gasView3_12.isHidden = false
			gasView4_12.isHidden = false
			gasView5_12.isHidden = true
			gasView6_12.isHidden = true
			gasView7_12.isHidden = true
			gasView8_12.isHidden = true
			gasView9_12.isHidden = true
			gasView10_12.isHidden = true
			gasView11_12.isHidden = true
			gasView12_12.isHidden = true
		}else if milesToEmpty <= sectionsOfGasGague * 6{
			gasView1_12.isHidden = false
			gasView2_12.isHidden = false
			gasView3_12.isHidden = false
			gasView4_12.isHidden = false
			gasView5_12.isHidden = false
			gasView6_12.isHidden = true
			gasView7_12.isHidden = true
			gasView8_12.isHidden = true
			gasView9_12.isHidden = true
			gasView10_12.isHidden = true
			gasView11_12.isHidden = true
			gasView12_12.isHidden = true
		}else if milesToEmpty <= sectionsOfGasGague * 7{
			gasView1_12.isHidden = false
			gasView2_12.isHidden = false
			gasView3_12.isHidden = false
			gasView4_12.isHidden = false
			gasView5_12.isHidden = false
			gasView6_12.isHidden = false
			gasView7_12.isHidden = true
			gasView8_12.isHidden = true
			gasView9_12.isHidden = true
			gasView10_12.isHidden = true
			gasView11_12.isHidden = true
			gasView12_12.isHidden = true
		}else if milesToEmpty <= sectionsOfGasGague * 8{
			gasView1_12.isHidden = false
			gasView2_12.isHidden = false
			gasView3_12.isHidden = false
			gasView4_12.isHidden = false
			gasView5_12.isHidden = false
			gasView6_12.isHidden = false
			gasView7_12.isHidden = false
			gasView8_12.isHidden = true
			gasView9_12.isHidden = true
			gasView10_12.isHidden = true
			gasView11_12.isHidden = true
			gasView12_12.isHidden = true
		}else if milesToEmpty <= sectionsOfGasGague * 9{
			gasView1_12.isHidden = false
			gasView2_12.isHidden = false
			gasView3_12.isHidden = false
			gasView4_12.isHidden = false
			gasView5_12.isHidden = false
			gasView6_12.isHidden = false
			gasView7_12.isHidden = false
			gasView8_12.isHidden = false
			gasView9_12.isHidden = true
			gasView10_12.isHidden = true
			gasView11_12.isHidden = true
			gasView12_12.isHidden = true
		}else if milesToEmpty <= sectionsOfGasGague * 10{
			gasView1_12.isHidden = false
			gasView2_12.isHidden = false
			gasView3_12.isHidden = false
			gasView4_12.isHidden = false
			gasView5_12.isHidden = false
			gasView6_12.isHidden = false
			gasView7_12.isHidden = false
			gasView8_12.isHidden = false
			gasView9_12.isHidden = false
			gasView10_12.isHidden = true
			gasView11_12.isHidden = true
			gasView12_12.isHidden = true
		}else if milesToEmpty <= sectionsOfGasGague * 11{
			gasView1_12.isHidden = false
			gasView2_12.isHidden = false
			gasView3_12.isHidden = false
			gasView4_12.isHidden = false
			gasView5_12.isHidden = false
			gasView6_12.isHidden = false
			gasView7_12.isHidden = false
			gasView8_12.isHidden = false
			gasView9_12.isHidden = false
			gasView10_12.isHidden = false
			gasView11_12.isHidden = true
			gasView12_12.isHidden = true
		}else if milesToEmpty <= sectionsOfGasGague * 12{
			gasView1_12.isHidden = false
			gasView2_12.isHidden = false
			gasView3_12.isHidden = false
			gasView4_12.isHidden = false
			gasView5_12.isHidden = false
			gasView6_12.isHidden = false
			gasView7_12.isHidden = false
			gasView8_12.isHidden = false
			gasView9_12.isHidden = false
			gasView10_12.isHidden = false
			gasView11_12.isHidden = false
			gasView12_12.isHidden = false
		}
	}
	
	func alertUserThereIs20MilesLeft(){
		//alert the user the is no gas left and the display of local gas stations will be displayed
		let alert = UIAlertController(title: "OUT OF GAS!!!", message: "You have 20 miles left to empty you will run out of gas if you do not go to a gas station now!", preferredStyle: .alert)
		let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
		let locateNearBY = UIAlertAction(title: "Locate near by gas stations", style: .default, handler: locateNearByGasStations(alert: ))
		// add the button to the alert
		alert.addAction(okButton)
		alert.addAction(locateNearBY)
		// present the lert
		present(alert, animated: true, completion: {print("Alert was shown.")})
	}
	
	// function to alert the user when there is low amount of gas left and needs to be refilled at 50 miles
	func alertUserAmostOutOfGas(){
		let alert = UIAlertController(title: "Almost Out Of Gas", message: "There is 50 miles left untill empty. Would you like to locate near by Gas stations?", preferredStyle: .alert)
		let yesButton = UIAlertAction(title: "Yes", style: .default, handler: locateNearByGasStations(alert: ))
		let noButton = UIAlertAction(title: "No", style: .default, handler: nil)
		// add the button to the alert
		alert.addAction(yesButton)
		alert.addAction(noButton)
		// present the alert
		present(alert, animated: true, completion: {print("Alert was shown.")})
	}
	func locateNearByGasStations(alert: UIAlertAction!){
		segueIdentifier = "toMapOfLocalGasStations"
		performSegue(withIdentifier: "toMapOfLocalGasStations", sender: nil)
	}
	
	@IBAction func TestFunction(_ sender: UIButton) {
		alertUserAmostOutOfGas()
	}
	
	@IBAction func StartDrivingButton(_ sender: UIButton) {
		locationManager?.startUpdatingLocation()
		locationManager?.startMonitoringSignificantLocationChanges()
		startAccelerometers()
	}
	
	@IBAction func StopDrivingButton(_ sender: UIButton) {
		locationManager?.stopUpdatingLocation()
		locationManager?.stopMonitoringSignificantLocationChanges()
		//reset location varaiables
		accel.stopAccelerometerUpdates()
		print("\(Trip)")
		let db = Firestore.firestore()
		if let veh = vehice{
			veh.calculateAvgMpg()
			updateUIOnLoad()
			if multipleTanksSegControl.isHidden == false{
				if multipleTanksSegControl.selectedSegmentIndex == 0{
					trip[0] = Trip
					db.collection("users").document(activeUserId).updateData(["trip\(veh.nameOfVehicle)" : trip])
					
				}else {
					trip[1] = Trip
					db.collection("users").document(activeUserId).updateData(["trip\(veh.nameOfVehicle)" : trip])
				}
			}else {
				trip[0] = Trip
				db.collection("users").document(activeUserId).updateData(["trip\(veh.nameOfVehicle)": trip])
			}
		}
		
	}
	
}
