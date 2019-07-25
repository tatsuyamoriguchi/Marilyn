//
//  SettingViewController.swift
//  Marilyn
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
            UserDefaults.standard.setValue(false, forKey: "locationManagerAuthorization")
            
            locationManager.stopMonitoringVisits()
            print("locationManager was stopped.")
            
            
        
        } else {
            locationManager.startMonitoringVisits()
             UserDefaults.standard.setValue(true, forKey: "locationManagerAuthorization")
            print("locationManager was started.")
        }
        navigationController!.popViewController(animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.title = "Settings"

        if UserDefaults.standard.bool(forKey: "locationManagerAuthorization") == true {
            locationReminderButton.setTitle("Location Reminder is ON now.", for: .normal)
            
        }else {
            locationReminderButton.setTitle("Location Reminder is OFF now.", for: .normal)
            
        }
        
        wisdomButton.layer.cornerRadius = 10
        timeIntervalButton.layer.cornerRadius = 10
        locationReminderButton.layer.cornerRadius = 10
        
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
