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
        
        //if UserDefaults.standard.bool(forKey: "locationManagerAuthorization") == true {
        if CLLocationManager.locationServicesEnabled() {


            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                locationManager.startMonitoringVisits()
                locationManager.pausesLocationUpdatesAutomatically = true
//                UserDefaults.standard.set(true, forKey: "locationManagerAuthorization")
                print("locationManager was started.")

            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.stopMonitoringVisits()
                locationManager.pausesLocationUpdatesAutomatically = false
//                UserDefaults.standard.set(false, forKey: "locationManagerAuthorization")

                print("locationManager was stopped.")
            }

            
        }
        navigationController!.popViewController(animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.title = NSLocalizedString("Settings", comment: "Navigation bar title")

        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
            locationReminderButton.setTitle(NSLocalizedString("Location Reminder is OFF now.", comment: "Button lable text"), for: .normal)

        case .authorizedAlways, .authorizedWhenInUse:
            locationReminderButton.setTitle(NSLocalizedString("Location Reminder is ON now.", comment: "Button label text"), for: .normal)

        }
        
        wisdomButton.layer.cornerRadius = 10
        timeIntervalButton.layer.cornerRadius = 10
        locationReminderButton.layer.cornerRadius = 10
  
        
    }
    
}
