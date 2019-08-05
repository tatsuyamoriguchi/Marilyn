//
//  CauseTypeEditDelete.swift
//  Mind Tracer
//
//  Created by Tatsuya Moriguchi on 7/20/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

////////// Not using this file since CauseTableViewController loses stateOfMindDesc value passed via navigation segue.

import Foundation
import CoreData
import UIKit

class CauseTypeEditDelete {
    
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    func fetchPredicatedSOM(wordToSwipe: CauseType, newCauseType: String, mode: String) {
        
        let context = appDelegate.persistentContainer.viewContext
        var existingSOMs = [StateOfMind]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StateOfMind")

        // NOTE: now it may be working now. Provide newCauseType and build and run it again.
        fetchRequest.predicate = NSPredicate(format: "causeType.type = %@", wordToSwipe.type!)
        
        do {
            
            existingSOMs = try context.fetch(fetchRequest) as! [StateOfMind]

            if mode == "edit" && existingSOMs.count > 0 {
                // If there is any existingSOMs with causeType.type = wordToSwipe.type, do the following
                wordToSwipe.type = newCauseType

                for item in existingSOMs {
                    if item.causeType == wordToSwipe {
                        
                        // Update SOM relationship value
                        item.causeType?.type = newCauseType
//                        print("******item.causeType.type")
//                        print(item.causeType?.type)
                        
                    }
                }
                
                
            } else if mode == "edit" && existingSOMs.count == 0 {
                print("No existing SOM data was found. Just go ahead to edit or delete selectedCauseType.")
                wordToSwipe.type = newCauseType
            
            } else if mode == "delete" && existingSOMs.count == 0 {
                 context.delete(wordToSwipe as NSManagedObject)
            } else if mode == "delete" && existingSOMs.count > 0 {
                
                CauseTableViewController().existingSOMAlert()
            
            } else {
                print("Something went wrong at if-cluase")
            }
            
        } catch {
            print("Error = \(error.localizedDescription)")
        }
    }

}
