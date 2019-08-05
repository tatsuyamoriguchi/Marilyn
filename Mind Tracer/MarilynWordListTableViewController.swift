//
//  MarilynWordListTableViewController.swift
//  Mind Tracer
//
//  Created by Tatsuya Moriguchi on 7/18/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData

class MarilynWordListTableViewController: UITableViewController {


    var wordsOfWisdomSelected: Wisdom!
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.reloadData()
        configureFetchedResultsController(EntityName: "Wisdom", sortString: "relatedCauseType.type")
        
        self.navigationItem.title = NSLocalizedString("Words of Wisdom", comment: "Navigation title")
        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
 
    
    
    @objc func addTapped() {
        print("addTapped was executed.")
        
        performSegue(withIdentifier: "AddWisdom", sender: self)
        
    }
    
    
    func configureFetchedResultsController(EntityName: String, sortString: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        // Create the fetch request, set some sort descriptor, then feed the fetchedResultsController
        // the request with along with the managed object context, which we'll use the view context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName)
        let sortDescriptorType = NSSortDescriptor(key: sortString, ascending: true)
        let sortDescriptorB = NSSortDescriptor(key: "words", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptorType, sortDescriptorB]
        //fetchRequest.sortDescriptors = [sortDescriptorType]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self //as? NSFetchedResultsControllerDelegate
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    


    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let sections = fetchedResultsController?.sections else {
            print("numberOfRowsInSection failed.")
            return 0
        }
        let rowCount = sections[section].numberOfObjects
        print("The amount of rows in the section are: \(rowCount)")
        
        return rowCount
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WisdomCell", for: indexPath)
        if let wisdomWord = fetchedResultsController?.object(at: indexPath) as? Wisdom {
            
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = wisdomWord.words
            cell.detailTextLabel?.text = wisdomWord.relatedCauseType?.type ?? NSLocalizedString("Not assigned", comment: "Word of wisdom with no cause type assigned")
        }
        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        wordsOfWisdomSelected = self.fetchedResultsController?.object(at: indexPath) as? Wisdom
        performSegue(withIdentifier: "WisdomDetailSegue", sender: wordsOfWisdomSelected)
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
  
        if editingStyle == .delete {
            // Delete the row from the data source.
            let managedContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
            let wordToDelete = fetchedResultsController?.object(at: indexPath)
            managedContext?.delete(wordToDelete as! NSManagedObject)
            
            do {
                try managedContext?.save()
                
            } catch {
                print("Saving Error: \(error)")
                // Error occured while deleting objects
            }
        }
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "WisdomDetailSegue" {
            let destVC = segue.destination as! WisdomDetailViewController
            destVC.wordsOfWisdomSelected = wordsOfWisdomSelected
            
        } else if segue.identifier == "AddWisdom" {
            //let destVC = segue.destination as! WisdomDetailViewController
            //destVC.wordsOfWisdomSelected = nil
        }
    }
    

}

extension MarilynWordListTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
        print("controllerWillChangeContent was detected")
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath! as IndexPath], with: .fade)
        case .delete:
            print("delete was detected.")
            self.tableView.deleteRows(at: [indexPath! as IndexPath], with: .fade)
        case .update:
            if(indexPath != nil) {
                let cell = self.tableView.cellForRow(at: indexPath! as IndexPath)
                //configureCell(cell, at: indexPath)
            }
        case .move:
            self.tableView.deleteRows(at: [indexPath! as IndexPath], with: .fade)
            self.tableView.insertRows(at: [indexPath! as IndexPath], with: .fade)
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
        print("tableView data update was ended at controllerDidChangeContent().")
        
    }
}
