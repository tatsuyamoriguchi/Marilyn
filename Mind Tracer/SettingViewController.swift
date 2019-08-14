//
//  SettingViewController.swift
//  Mind Tracer
//
//  Created by Tatsuya Moriguchi on 7/18/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit
import CoreLocation

class SettingViewController: UIViewController {

    let locationManager = CLLocationManager()
    
    @IBOutlet var wisdomButton: UIButton!
    @IBOutlet var timeIntervalButton: UIButton!
    @IBOutlet var locationReminderButton: UIButton!
    
    @IBAction func updateOnPressed(_ sender: UIButton) {
        
        if UserDefaults.standard.bool(forKey: "locationManagerAuthorization") == true {
            
            locationManager.stopMonitoringVisits()
            locationManager.pausesLocationUpdatesAutomatically = false
            
            print("locationManager was stopped.")
            UserDefaults.standard.setValue(false, forKey: "locationManagerAuthorization")
            
            // Test if the following lines work or not
            //locationManager.delegate = nil
            
        
        } else {
            
            locationManager.startMonitoringVisits()
            locationManager.pausesLocationUpdatesAutomatically = true
            
            print("locationManager was started.")
            
            UserDefaults.standard.setValue(true, forKey: "locationManagerAuthorization")
            
        }
        navigationController!.popViewController(animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.title = NSLocalizedString("Settings", comment: "Navigation bar title")

        if UserDefaults.standard.bool(forKey: "locationManagerAuthorization") == true {
            locationReminderButton.setTitle(NSLocalizedString("Location Reminder is ON now.", comment: "Button label text"), for: .normal)
            
        }else {
            locationReminderButton.setTitle(NSLocalizedString("Location Reminder is OFF now.", comment: "Button lable text"), for: .normal)
            
        }
        
        wisdomButton.layer.cornerRadius = 10
        timeIntervalButton.layer.cornerRadius = 10
        locationReminderButton.layer.cornerRadius = 10
        
        
    }
    
}
