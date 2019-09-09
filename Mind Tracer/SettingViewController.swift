//
//  SettingViewController.swift
//  Mind Tracer
//
//  Created by Tatsuya Moriguchi on 7/18/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit
import CoreLocation

class SettingViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    
    @IBOutlet var wisdomButton: UIButton!
    @IBOutlet var timeIntervalButton: UIButton!
    @IBOutlet var locationReminderButton: UIButton!
    
    
    @IBAction func updateOnPressed(_ sender: UIButton) {
       
        let alert = UIAlertController(title: "Allow Location Access", message: "Turn ON or OFF Location Services in your device settings.", preferredStyle: UIAlertController.Style.alert)
        
        // Button to Open Settings
        alert.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler: { action in
            
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)")
                })
            }
            
            
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                //self.enableLocationService()
//                print("enableLocationService() was executed.")
                print(".notDetermined, .restricted, .denied was detected.")
                
            case .authorizedAlways, .authorizedWhenInUse:
                //self.disableLocationService()
//                print("case was .authorizedAlways, and disableLocaitonService() was executed.")
                print("authorizationStatus().authorizedAlways or .authorizedWhenInUse was detected.")

                //            case .authorizedWhenInUse:
//                self.disableLocationService()
//                print("case was .authorizedWhenInUse, and disableLocaitonService() was executed.")
//
            }

            self.navigationController!.popViewController(animated: true)

        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
//        if CLLocationManager.locationServicesEnabled() {

//            switch CLLocationManager.authorizationStatus() {
//            case .notDetermined, .restricted, .denied:
//                locationManager.startUpdatingLocation()
//                locationManager.startMonitoringVisits()
//                locationManager.allowsBackgroundLocationUpdates = true
//
//                locationManager.pausesLocationUpdatesAutomatically = true
//                print("locationManager was started.")
//
//            case .authorizedAlways, .authorizedWhenInUse:

//                locationManager.stopUpdatingLocation()
//                locationManager.stopMonitoringVisits()
//                locationManager.allowsBackgroundLocationUpdates = false
//
//                locationManager.pausesLocationUpdatesAutomatically = false
//                print("locationManager was stopped.")
//            }
  //      }
  
//        navigationController!.popViewController(animated: true)
        
    }
    
    
    
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.title = NSLocalizedString("Settings", comment: "Navigation bar title")
        
        locationManager.delegate = self
        enableLocationService()
        
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
            locationReminderButton.setTitle(NSLocalizedString("Location Reminder is OFF now.", comment: "Button lable text"), for: .normal)

        case .authorizedAlways:
            locationReminderButton.setTitle(NSLocalizedString("Location Reminder is Always ON now.", comment: "Button label text"), for: .normal)
        case .authorizedWhenInUse:
            locationReminderButton.setTitle(NSLocalizedString("Location Reminder is ON When This App is In Use.", comment: "Button label text"), for: .normal)

        }
        
        
        locationReminderButton.intrinsicContentSize.height
        
        
        wisdomButton.layer.cornerRadius = 10
        timeIntervalButton.layer.cornerRadius = 10
        locationReminderButton.layer.cornerRadius = 10
  
        
    }
    
    
    func disableLocationService() {
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringVisits()
        locationManager.allowsBackgroundLocationUpdates = false

        
  //      locationManager.pausesLocationUpdatesAutomatically = false
        print("locationManager was stopped.")
        
    }
    
    func enableLocationService() {
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringVisits()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.delegate = self
//        locationManager.pausesLocationUpdatesAutomatically = true
        print("locationManager was started.")
    }
}
