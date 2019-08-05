//
//  CauseTableViewController.swift
//  Mind Tracer
//
//  Created by Tatsuya Moriguchi on 4/27/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData

class CauseTableViewController: UITableViewController {

    // Passed from CauseDescVC via segue
    var stateOfMindDesc: StateOfMindDesc!
    var causeDesc: Cause!
    var causeTypeSelected: CauseType!
    
    let adjectiveError = NSLocalizedString("Adjective was not selected.", comment: "Error message")
    
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFetchedResultsController()
        tableView.dataSource = self
 
        self.navigationItem.prompt = NSLocalizedString("Your Current State of Mind: ", comment: "Navigation bar title") + (stateOfMindDesc.adjective ?? adjectiveError)
    }
    
    private func configureFetchedResultsController() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // Create the fetch request, set some sort descriptor, then feed the fetchedResultsController
        // the request with along with the managed object context, which we'll use the view context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CauseType")
        let sortDescriptorType = NSSortDescriptor(key: "type", ascending: true)
  
        
        fetchRequest.sortDescriptors = [sortDescriptorType]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self //as? NSFetchedResultsControllerDelegate
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }

    @IBAction func addNewOnPressed(_ sender: UIBarButtonItem) {
        addNewAlert()
    }
    
    func addNewAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("Add New", comment: "Alert title"), message: NSLocalizedString("Add a cause type.", comment: "Alert message"), preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: NSLocalizedString("Save", comment: "Alert button"), style: .default, handler: { (action) -> Void in
            
            let newCauseType = alertController.textFields![0]
            let itemToAdd = newCauseType.text
            self.save(itemName: itemToAdd!)
        })
        
        alertController.addTextField { (textField: UITextField) in
            textField.placeholder = NSLocalizedString("Type a new cause type.", comment: "textField placeholder")
            saveAction.isEnabled = false
        }
        
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alertController.textFields![0], queue: OperationQueue.main) { (notification) in
            if (alertController.textFields![0].text?.count)! > 0 {
                    saveAction.isEnabled = true
            }
        }
        
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert button"), style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    func save(itemName: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "CauseType", in: managedContext)!
        let item = NSManagedObject(entity: entity, insertInto: managedContext)
        item.setValue(itemName, forKey: "type")
        
        do {
            try managedContext.save()
            
        } catch {
            print("Failed to save an item #3: \(error.localizedDescription)")
        }
    }
    
    func existingSOMAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("Warning", comment: "Alert title"), message: NSLocalizedString("Unable to edit or delete this cause type since there is a past State of Mind data associated with.", comment: "Alert message"), preferredStyle: .alert)
        
        self.present(alertController, animated: true, completion: nil)
        
        // Display congratAlert view for x seconds
        let when = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: when, execute: {
            alertController.dismiss(animated: true, completion: nil)
        })
    }

    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

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
        
        let CauseTypeCell = tableView.dequeueReusableCell(withIdentifier: "CauseTypeCell", for: indexPath)
        if let causeType = fetchedResultsController?.object(at: indexPath) as? CauseType {
            CauseTypeCell.textLabel?.text = causeType.type
        }
        return CauseTypeCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        causeTypeSelected = self.fetchedResultsController?.object(at: indexPath) as? CauseType
        
        performSegue(withIdentifier: "toLocationTVCSegue", sender: causeTypeSelected)
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        let wordToSwipe = self.fetchedResultsController?.object(at: indexPath) as! CauseType
        
        let edit = UITableViewRowAction(style: .default, title: NSLocalizedString("Edit", comment: "TableView row Edit")) { action, index in
            
            self.causeTypeEditAlert(CauseType: wordToSwipe)
        }
        
        let delete = UITableViewRowAction(style: .default, title: NSLocalizedString("Delete", comment: "TableView row Delete")) { action, index in
            
            self.fetchPredicatedSOM(wordToSwipe: wordToSwipe, newCauseType: "", mode: "delete")
        }
        
        do {
            try managedContext?.save()
        } catch {
            print("Saving Error: \(error)")
        }
        
        edit.backgroundColor = UIColor.blue
        return [edit, delete]
    }

    
    func causeTypeEditAlert(CauseType: CauseType) {
        let alertController = UIAlertController(title: NSLocalizedString("Edit", comment: "Alert title"), message: NSLocalizedString("Edit the cause type.", comment: "Alert message"), preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: NSLocalizedString("Save", comment: "Alert button"), style: .default, handler: { (action) -> Void in
            
            let newCauseType = alertController.textFields![0]
            let itemToAdd = newCauseType.text
          
            self.update(CauseType: CauseType, ItemToAdd: itemToAdd!)
        })
        
        alertController.addTextField { (textField: UITextField) in
            textField.placeholder = NSLocalizedString("Cause Type", comment: "Alert textField placeholder")
            saveAction.isEnabled = false
            textField.text = CauseType.type
        }
        
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alertController.textFields![0], queue: OperationQueue.main) { (notification) in
            if (alertController.textFields![0].text?.count)! > 0 {
                    saveAction.isEnabled = true
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert button"), style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    func update(CauseType: CauseType, ItemToAdd: String) {
        
        self.fetchPredicatedSOM(wordToSwipe: CauseType, newCauseType: ItemToAdd, mode: "edit")
    }
    

/////////////////////////////////////////////////////////////////////////////////////
    func fetchPredicatedSOM(wordToSwipe: CauseType, newCauseType: String, mode: String) {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        var existingSOMs = [StateOfMind]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StateOfMind")
        
        fetchRequest.predicate = NSPredicate(format: "causeType.type = %@", wordToSwipe.type!)
        
        do {
            existingSOMs = try context.fetch(fetchRequest) as! [StateOfMind]
            
            if mode == "edit" && existingSOMs.count > 0 {
                // If there is any existingSOMs with causeType.type = wordToSwipe.type, do the following
                wordToSwipe.type = newCauseType
                
                for item in existingSOMs {
                    if item.causeType == wordToSwipe {
                        
                        item.causeType?.type = newCauseType
                        print("******item.causeType.type")
                        print(item.causeType?.type)
                    }
                }
                
            } else if mode == "edit" && existingSOMs.count == 0 {
                print("No existing SOM data was found. Just go ahead to edit or delete selectedCauseType.")
                wordToSwipe.type = newCauseType
                
            } else if mode == "delete" && existingSOMs.count == 0 {
                context.delete(wordToSwipe as NSManagedObject)
            } else if mode == "delete" && existingSOMs.count > 0 {
                
                existingSOMAlert()
                
            } else {
                print("Something went wrong at if-cluase")
            }
            
        } catch {
            print("Error = \(error.localizedDescription)")
        }
    }
    

/////////////////////////////////////////////////////////////////////////////////////
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLocationTVCSegue" {
            let destVC = segue.destination as! LocationViewController
            destVC.stateOfMindDesc = stateOfMindDesc
            destVC.causeDesc = causeDesc
            destVC.causeTypeSelected = causeTypeSelected
        }
    }
}


extension CauseTableViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("The Controller Content Has Changed.")
        tableView.reloadData()
    }
}
