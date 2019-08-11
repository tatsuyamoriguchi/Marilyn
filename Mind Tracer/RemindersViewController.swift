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
    
    var pickerData: [String] = [String]()
    var freqComponent: Int = 0
    let content = UNMutableNotificationContent()
    var timeIntervalRow: Int = 0
    
    
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
        
        // The followinf switch case doesn't work with non-english version unless case values are translated into that language.
        switch pickerData[row] {
        case NSLocalizedString("Reminder Off", comment: "switch case value"):
            freqComponent = 0
        case NSLocalizedString("Every Hour", comment: "switch case value"):
            freqComponent = 3600
        case NSLocalizedString("Every Two Hours", comment: "switch case value"):
            freqComponent = 7200
        case NSLocalizedString("Every Four Hours", comment: "switch case value"):
            freqComponent = 14400
        case NSLocalizedString("Every Six Hours", comment: "switch case value"):
            freqComponent = 21600
        case NSLocalizedString("Daily Reminder", comment: "switch case value"):
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

        
        if freqComponent != 0 {
            scheduleNotification()
            addCategory()
            
            print("*****freqComponent")
            print(freqComponent)
            
        }else{
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            print("Notification has been removed.")
        }

        UserDefaults.standard.set(timeIntervalRow, forKey: "timeIntervalRow")
        print("timeIntervalRow: \(timeIntervalRow)")

        navigationController!.popViewController(animated: true)
    }
    

    
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

        reminderFreqPicker.delegate = self
        reminderFreqPicker.dataSource = self
        
        if let storedRow = UserDefaults.standard.object(forKey: "timeIntervalRow") as? Int {
            // Place UIPicker.selectRow() below UIPicker.delegate and UIPicker.dataSource
            // Otherwise no data to select
            reminderFreqPicker.selectRow(storedRow, inComponent: 0, animated: true)

            // To make the timeIntervalRow as the same before when a new value wasn't selected on UIDataPicker
            // Keep the storedRow of UserDefaults when just pressing Save button.
            timeIntervalRow = storedRow
            
        }

        self.navigationItem.title = NSLocalizedString("Remninders", comment: "Navigation bar title")

    }

}
