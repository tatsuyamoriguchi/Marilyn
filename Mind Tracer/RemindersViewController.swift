//
//  RemindersViewController.swift
//  Mind Tracer
//
//  Created by Tatsuya Moriguchi on 7/23/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit
import UserNotifications

class RemindersViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        print("*******pickerData[row]")
        print(pickerData[row])
        
        switch pickerData[row] {
        case "Reminder Off":
            freqComponent = 0
        case "Every Hour":
            freqComponent = 3600
        case "Every Two Hours":
            freqComponent = 7200
        case "Every Four Hours":
            freqComponent = 14400
        case "Every Six Hours":
            freqComponent = 21600
        case "Daily Reminder":
            freqComponent = 86400
            
        default:
            print("Exception error in switch, pickerData[row]")
        }

        // Assign a row value to timeIntervalRow to store to UserDefaults
        timeIntervalRow = row

    }
    
    func scheduleNotification() {
        let identifier: String = "MarilynInputReminder"
        content.title = NSLocalizedString("Time to tell Mind Tracer your state of mind.", comment: "Reminder message")
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "UYLReminderCategory"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(freqComponent), repeats: true)
        
        let notificationReq = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(notificationReq, withCompletionHandler: nil)
    }
    
    func addCategory() {
        
        let cancelAction = UNNotificationAction(identifier: "Cancel", title: NSLocalizedString("Cancel", comment: "Reminder view button label text"), options: [])
        let stopAction = UNNotificationAction(identifier: "StopRepeat", title: NSLocalizedString("Stop Repeat", comment: "Reminder view button label text"), options: [])
        
        let category = UNNotificationCategory(identifier: "UYLReminderCategory", actions: [cancelAction, stopAction], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
    }
    

    @IBOutlet var reminderFreqPicker: UIPickerView!
 
    @IBAction func saveOnPressed(_ sender: UIButton) {
        print("*****freqComponent")
        print(freqComponent)
        
        if freqComponent != 0 {
            scheduleNotification()
            addCategory()
            
        }else{
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }

        UserDefaults.standard.set(timeIntervalRow, forKey: "timeIntervalRow")

        navigationController!.popViewController(animated: true)
    }
    
    var pickerData: [String] = [String]()
    var freqComponent: Int = 0
    let content = UNMutableNotificationContent()
    var timeIntervalRow: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        pickerData = [
            NSLocalizedString("Reminder Off", comment: "Reminder time interval"),
            NSLocalizedString("Every Hour", comment: "Reminder time interval"),
            NSLocalizedString("Every Two Hours", comment: "Reminder time interval"),
            NSLocalizedString("Every Four Hours", comment: "Reminder time interval"),
            NSLocalizedString("Every Six Hours", comment: "Reminder time interval"),
            NSLocalizedString("Daily Reminder", comment: "Reminder time interval")
        ]

        self.reminderFreqPicker.delegate = self
        self.reminderFreqPicker.dataSource = self
        
        if let storedRaw = UserDefaults.standard.object(forKey: "timeIntervalRow") as? Int {
            // Place UIPicker.selectRow() below UIPicker.delegate and UIPicker.dataSource
            // Otherwise no data to select
            reminderFreqPicker.selectRow(storedRaw, inComponent: 0, animated: true)
            
        }

        self.navigationItem.title = NSLocalizedString("Remninders", comment: "Navigation bar title")

    }

}
