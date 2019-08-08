//
//  WisdomDetailViewController.swift
//  Mind Tracer
//
//  Created by Tatsuya Moriguchi on 7/19/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData

class WisdomDetailViewController: UIViewController, UITextViewDelegate {
    
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    var wordsOfWisdomSelected: Wisdom!
    var newCauseType: CauseType!
    var causeType4Add: CauseType!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    @IBOutlet var wordsOfWisdomTextView: UITextView!
    @IBOutlet var tableView: UITableView!
    

    @IBAction func saveOnPressed(_ sender: Any) {
        let context = appDelegate.persistentContainer.viewContext
        
        
        let newWisdomText = wordsOfWisdomTextView.text
        if wordsOfWisdomSelected != nil {
            wordsOfWisdomSelected.setValue(newWisdomText, forKey: "words")
        } else {
            let newWisdom = Wisdom(context: context)
            newWisdom.setValue(newWisdomText, forKey: "words")
            newWisdom.setValue(causeType4Add, forKey: "relatedCauseType")
        }
        
        do {
            try context.save()
            
        } catch {
            print("Failed to save an item #7: \(error.localizedDescription)")
        }
        navigationController!.popViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        configureFetchedResultsController(EntityName: "CauseType", sortString: "type")
        
        if wordsOfWisdomSelected != nil {
            wordsOfWisdomTextView.text = wordsOfWisdomSelected.words
        } else {
        
            wordsOfWisdomTextView.text = ""
        }
        
        // To dismiss a keyboard
        wordsOfWisdomTextView.delegate = self


        let tap = UITapGestureRecognizer(target: self.wordsOfWisdomTextView, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.wordsOfWisdomTextView.addGestureRecognizer(tap)
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    


    func configureFetchedResultsController(EntityName: String, sortString: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        // Create the fetch request, set some sort descriptor, then feed the fetchedResultsController
        // the request with along with the managed object context, which we'll use the view context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName)
        let sortDescriptorType = NSSortDescriptor(key: sortString, ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptorType]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self as? NSFetchedResultsControllerDelegate
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
}


// Display a list of Cause Types to choose or deselect from
extension WisdomDetailViewController: UITableViewDelegate, UITableViewDataSource {
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        guard let sections = fetchedResultsController?.sections else {
            print("numberOfRowsInSection failed.")
            return 0
        }
        
        let rowCount = sections[section].numberOfObjects
        //print("The amount of rows in the section are: \(rowCount)")
        
        return rowCount
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "CauseTypeCell", for: indexPath)
        if let causeType = fetchedResultsController?.object(at: indexPath) as? CauseType {
            
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = causeType.type

            if wordsOfWisdomSelected != nil {
                if wordsOfWisdomSelected.relatedCauseType?.type == causeType.type {
                    cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                } else {
                    cell.accessoryType = UITableViewCell.AccessoryType.none
                }
            }
            
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        let context = appDelegate.persistentContainer.viewContext
        
        if let cell = tableView.cellForRow(at: indexPath) {
            if let causeType = fetchedResultsController?.object(at: indexPath) as? CauseType {
                
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
                wordsOfWisdomSelected.relatedCauseType = nil

            } else if wordsOfWisdomSelected == nil {
                // To add a new words of wisdom, assign relatedCauseType value in newCauseType.
                // Save it when a button is pressed.
                cell.accessoryType = .checkmark
                causeType4Add = causeType
                
                tableView.reloadData()
  
            }else {
                cell.accessoryType = .checkmark
                newCauseType = causeType  //cell.textLabel?.text
              wordsOfWisdomSelected.relatedCauseType = newCauseType
                tableView.reloadData()
            
                }
            }
        }
        

        do {
            try context.save()
            print("Context was saved.")
            
        } catch {
            print("Cannot save object: \(error.localizedDescription)")
        }
 
    }
}
