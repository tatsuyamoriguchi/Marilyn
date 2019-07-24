//
//  RemindersViewController.swift
//  Marilyn
//
//  Created by Tatsuya Moriguchi on 7/23/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit

class RemindersViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
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
        
        print(pickerData[row])
        reminderMode = pickerData[row]
    }
    

    @IBOutlet var reminderFreqPicker: UIPickerView!
 
    @IBAction func saveOnPressed(_ sender: UIButton) {
     

    }
    
    var pickerData: [String] = [String]()
    var reminderMode: String = ""
    
    
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
