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
    
    var todaysWordsOfWisdom: String = ""
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
        
    }
    
    func topCauseTypeNow() {
        let userDefaults = UserDefaults.standard
        if userDefaults.object(forKey: "topCauseType") as? String != nil {

            causeTypeNow = userDefaults.object(forKey: "topCauseType") as! String
            todaysWisdom(Predicate: causeTypeNow)
            
        } else {
            todaysWisdom(Predicate: causeTypeNow)
            
        }
        
        
    }

    
    func todaysWisdom(Predicate: String) {

        let context = appDelegate?.persistentContainer.viewContext
        var existingSOMs = [Wisdom]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Wisdom")
      
        if Predicate != "" {
            fetchRequest.predicate = NSPredicate(format: "relatedCauseType.type = %@", Predicate)
        }
        
        print("fetchRequest")
        print(fetchRequest)
        
        do {
            existingSOMs = try context?.fetch(fetchRequest) as! [Wisdom]
            let item = existingSOMs.randomItem()
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

