//
//  RemindersViewController.swift
//  Marilyn
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
        case "Every Three Hours":
            freqComponent = 10800
        case "Every Four Hours":
            freqComponent = 14400
        case "Every Five Hours":
            freqComponent = 18000
        case "Every Six Hours":
            freqComponent = 21600
            
        default:
            print("Exception error in switch, pickerData[row]")
        }


    }
    
    func scheduleNotification() {
        let identifier: String = "MarilynInputReminder"
        content.title = "This is notification test."
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "UYLReminderCategory"
        //content.userInfo = ["reminderID" : "somInput"]
        
        // convert reminderMode String into Int
        //
        //let freqComponent = 60
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(freqComponent), repeats: true)
        
        let notificationReq = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(notificationReq, withCompletionHandler: nil)
    
    }
    
    func addCategory() {
        
        let cancelAction = UNNotificationAction(identifier: "Cancel", title: "Cancel", options: [])
        let stopAction = UNNotificationAction(identifier: "StopRepeat", title: "Stop Repeat", options: [])
        
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
        
        navigationController!.popViewController(animated: true)
    }
    
    var pickerData: [String] = [String]()
    var freqComponent: Int = 0
    let content = UNMutableNotificationContent()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        pickerData = ["Reminder Off", "Every Hour", "Every Two Hours", "Every Three Hours", "Every Four Hours", "Every Five Hours", "Every Six Hours"]
        
        self.reminderFreqPicker.delegate = self
        self.reminderFreqPicker.dataSource = self
        

        self.navigationItem.title = "Remninders"

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
