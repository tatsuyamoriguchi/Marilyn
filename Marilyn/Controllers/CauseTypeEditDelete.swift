//
//  CauseTypeEditDelete.swift
//  Marilyn
//
//  Created by Tatsuya Moriguchi on 7/20/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CauseTypeEditDelete {
    
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //var somToChange: StateOfMind?
    
    
    
    func fetchPredicatedSOM(wordToSwipe: CauseType, newCauseType: String) {
        //configureFetchedResultsController()
        
        let context = appDelegate.persistentContainer.viewContext
        //var causeTypeArray = [CauseType]()
        var existingSOMs = [StateOfMind]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StateOfMind")

        // NOTE: now it may be working now. Provide newCauseType and build and run it again.
        fetchRequest.predicate = NSPredicate(format: "causeType.type = %@", wordToSwipe.type!)
        
        do {
            existingSOMs = try context.fetch(fetchRequest) as! [StateOfMind]
            
            if existingSOMs.count > 0 {
                // If there is any existingSOMs with causeType.type = wordToSwipe.type, do the following.

                
                // add a new (edited) CauseType
                // hmm... this needs to be re-examined, how to update CausetType type value
                //let entity = NSEntityDescription.entity(forEntityName: "CauseType", in: context)!
                //let causeItem = NSManagedObject(entity: entity, insertInto: context)
                //////////////
                wordToSwipe.type = newCauseType

                for item in existingSOMs {
                    if item.causeType == wordToSwipe {
                        
                        // Update SOM relationship value
                        //item.causeType?.setValue(newCauseType, forKey: "type")
                        item.causeType?.type = newCauseType
                        
                        print("******item.causeType.type")
                        print(item.causeType?.type)
                        
                    }
                }
                
                // Delete the old CauseType after adding the edited one
                // context.delete(wordToSwipe as NSManagedObject)
                
                
            }else {
                print("No existing SOM data was found. Just go ahead to edit or delete selectedCauseType.")
                context.delete(wordToSwipe as NSManagedObject)
            }
            
        } catch {
            print("Error = \(error.localizedDescription)")
        }
        
    }
    
    
    
}
