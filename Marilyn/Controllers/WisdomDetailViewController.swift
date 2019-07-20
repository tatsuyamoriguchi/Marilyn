//
//  WisdomDetailViewController.swift
//  Marilyn
//
//  Created by Tatsuya Moriguchi on 7/19/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData

class WisdomDetailViewController: UIViewController {
    
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    var wordsOfWisdomSelected: Wisdom!
    var newCauseType: CauseType!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    @IBOutlet var wordsOfWidsomTextView: UITextView!
    @IBOutlet var tableView: UITableView!
    

    @IBAction func saveOnPressed(_ sender: Any) {
        let context = appDelegate.persistentContainer.viewContext
        //let wisdom = Wisdom(context: context)
        wordsOfWisdomSelected.words = wordsOfWidsomTextView.text
        
        do {
            try context.save()
            
        } catch {
            print("Failed to save an item: \(error.localizedDescription)")
        }
        navigationController!.popViewController(animated: true)
//        self.navigationController?.popToRootViewController(animated: false)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFetchedResultsController(EntityName: "CauseType", sortString: "type")
        //configureFetchedResultsController(EntityName: "Wisdom", sortString: "words")
        
        
        wordsOfWidsomTextView.text = wordsOfWisdomSelected.words

        // Do any additional setup after loading the view.
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




    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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

            print("TEST1: wordsOfWisdomSelected.relatedCauseType?.type: \(wordsOfWisdomSelected.relatedCauseType?.type)")
            //print("causeType.type: \(causeType.type)")
            
            if wordsOfWisdomSelected.relatedCauseType?.type == causeType.type {
              cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            } else {
                cell.accessoryType = UITableViewCell.AccessoryType.none
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
                
                // ********* Something wrong with this line. It dupes relatedCauseType.type!
                //wordsOfWisdomSelected.relatedCauseType?.type = ""
                wordsOfWisdomSelected.relatedCauseType = nil

            } else {
                cell.accessoryType = .checkmark
            
                newCauseType = causeType  //cell.textLabel?.text

                wordsOfWisdomSelected.relatedCauseType = newCauseType
                tableView.reloadData()
                
                /*print("******************************************")
                print("wordsOfWisdomSelected.words: \(wordsOfWisdomSelected.words)")
                print("TEST2")
                print("wordsOfWisdomSelected.relatedCauseType?.type: \(wordsOfWisdomSelected.relatedCauseType?.type)")
                print("causeType.type: \(causeType.type)")
            */
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
