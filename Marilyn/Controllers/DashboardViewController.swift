//
//  DashboardViewController.swift
//  Marilyn
//
//  Created by Tatsuya Moriguchi on 4/18/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData

class DashbardViewController: UIViewController {

    
    @IBOutlet var wisdomLabel: UILabel!
    @IBOutlet weak var marilynImage: UIImageView!
    
    //guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    var todaysWordsOfWisdom: String = "" //"Start recording your state of mind to display Marilyn's words of wisdom here."
    var causeTypeNow: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        topCauseTypeNow()
       
        wisdomLabel.text = todaysWordsOfWisdom
        
        marilynImage.layer.cornerRadius = 20
        marilynImage.layer.masksToBounds = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
   
        topCauseTypeNow()
        
        wisdomLabel.text = todaysWordsOfWisdom
    }
    
    func topCauseTypeNow() {
        let userDefaults = UserDefaults.standard
        //if userDefaults.object(forKey: "topCauseType") != nil {
        
        if userDefaults.bool(forKey: "preloadedTopCauseType") == true {
            print("preloadedTopCausetype of UserDefaults is true.")

            // Get a value from topCauseType
            causeTypeNow = userDefaults.object(forKey: "topCauseType") as! String
            todaysWisdom(Predicate: causeTypeNow)
            
        } else {
            print("preloadedTopCausetype of UserDefaults is false.")
            // In order to work around a crash bug at run-time when first time installing
            // without any SOM data, don't display Words of Wisdom
            //todaysWisdom(Predicate: "")
            
        }
        
        
    }

    
    func todaysWisdom(Predicate: String) {

        let context = appDelegate?.persistentContainer.viewContext
        var existingSOMs = [Wisdom]()
        var fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Wisdom")
      
        //if Predicate != "" {
            fetchRequest.predicate = NSPredicate(format: "relatedCauseType.type = %@", Predicate)
        //}
        print("fetchRequest")
        print(fetchRequest)


   
        do {
            existingSOMs = try context?.fetch(fetchRequest) as! [Wisdom]
            var item = existingSOMs.randomItem()
            
            if item == nil {
                
                fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Wisdom")
                print("fetchRequest again")
                print(fetchRequest)
                
                existingSOMs = try context?.fetch(fetchRequest) as! [Wisdom]
                item = existingSOMs.randomItem()

            }
            
            
            print("")
            print("item.words")
            print(item?.words)
            
            todaysWordsOfWisdom = (item?.words)!
            
        } catch {
            print("Error: \(error)")
            
        }
    }
}

extension Array {
    func randomItem() -> Element? {
        if isEmpty { return nil }
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}

