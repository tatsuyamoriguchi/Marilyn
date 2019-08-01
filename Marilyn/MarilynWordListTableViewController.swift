//
//  MarilynWordListTableViewController.swift
//  Marilyn
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
        
        self.navigationItem.title = "Words of Wisdom"
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
   /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        //return 1
        guard let sections = fetchedResultsController?.sections else {
            return 0
        }
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController?.sections {
            let currentSection = sections[section]
            return "Cause Type: " + currentSection.name
        }
        return nil
    }
    */
    
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
            cell.detailTextLabel?.text = wisdomWord.relatedCauseType?.type ?? "Not assigned"
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
  
/*        if editingStyle == .delete {
            let wisdomWord = fetchedResultsController?.object(at: indexPath) as? Wisdom
            
            // Delete the row from the data source
            
            managedContext?.delete(wisdomWord!)
            
            
            tableView.deleteRows(at: [indexPath], with: .fade)

           
        }
        
  */
        if editingStyle == .delete {
            // Delete the row from the data source.
            let managedContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
            let wordToDelete = fetchedResultsController?.object(at: indexPath)
            managedContext?.delete(wordToDelete as! NSManagedObject)
          //  tableView.reloadData()
            
            do {
                try managedContext?.save()
                
                
            } catch {
                print("Saving Error: \(error)")
                // Error occured while deleting objects
            }
         
        }
        //else if editingStyle == .insert {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        //}

    }
    




    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "WisdomDetailSegue" {
            let destVC = segue.destination as! WisdomDetailViewController
            destVC.wordsOfWisdomSelected = wordsOfWisdomSelected
            
        } else if segue.identifier == "AddWisdom" {
            //let destVC = segue.destination as! WisdomDetailViewController
            //destVC.wordsOfWisdomSelected = nil
            
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
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
        //tableView.reloadData()
        print("tableView data was reloaded at controllerDidChangeContent().")
        
    }
}
