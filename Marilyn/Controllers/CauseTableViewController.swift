//
//  CauseTableViewController.swift
//  Marilyn
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
    
    let adjectiveError = "Adjective was not selected."
    
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFetchedResultsController()
        tableView.dataSource = self
        
        print("This is CauseTableViewConroller")
        print("stateOfMindDesc.adjective: \(String(describing: stateOfMindDesc.adjective))")
        print("stateOfMindDesc.rate: \(stateOfMindDesc.rate)")
        print("causeDesc: \(String(describing: causeDesc))")
        
        
        //navigationController?.navigationBar.topItem?.title = "Your Current State of Mind: \(stateOfMindDesc.adjective ?? "ERROR")"
        self.navigationItem.prompt = "Your Current State of Mind: \(stateOfMindDesc.adjective ?? adjectiveError)"
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        fetchedResultsController?.delegate = self as? NSFetchedResultsControllerDelegate
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
        let alertController = UIAlertController(title: "Add New", message: "Add a cause type.", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { (action) -> Void in
            
            let newCauseType = alertController.textFields![0]
            let itemToAdd = newCauseType.text
            self.save(itemName: itemToAdd!)
        })
        
        alertController.addTextField { (textField: UITextField) in
            textField.placeholder = "Type a new cause type."
            saveAction.isEnabled = false
        }
        
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alertController.textFields![0], queue: OperationQueue.main) { (notification) in
            if (alertController.textFields![0].text?.count)! > 0 {
                    saveAction.isEnabled = true
            }
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
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
            print("Failed to save an item: \(error.localizedDescription)")
        }
    }
    
    
    func existingSOMAlert() {
        let alertController = UIAlertController(title: "Warning", message: "Unable to edit or delete this cause type since there is a past State of Mind data associated with.", preferredStyle: .alert)
        
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
            //CauseCell.detailTextLabel?.text = causeType.type as AnyObject as? String
        }
        return CauseTypeCell
      
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        causeTypeSelected = self.fetchedResultsController?.object(at: indexPath) as? CauseType
        //print("This is didSelectRowAt of CauseTVC")
        //print(causeTypeSelected?.type as Any)
        
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
        
        
        
        
        
        
        let edit = UITableViewRowAction(style: .default, title: "Edit") { action, index in
            
            // Add if-clause to prevent from editting a cause type which already has SOM data.
            //if self.causeTypeSelected?.stateOfMind != nil {
            
            //if let causeType = self.fetchedResultsController?.object(at: indexPath) as? CauseType {
//            if (wordToSwipe.stateOfMind?.value(forKey: "timeStamp") != nil) {
//                    print("Unable to edit since there is State of Mind past data associated with.")
//                    self.existingSOMAlert()
//                    print("****causeType.stateOfMind")
//                    print(wordToSwipe.stateOfMind?.value(forKey: "timeStamp"))
//                    //print("******selectedCauseType.stateOfMind")
//                    //print(selectedCauseType.stateOfMind)
//
//                } else {
           
            //CauseTypeEditDelete().fetchPredicatedSOM(wordToSwipe: wordToSwipe, newCauseType: wordToSwipe)

            self.causeTypeEditAlert(CauseType: wordToSwipe)
                    
                //}
            //}
        }
        
        let delete = UITableViewRowAction(style: .default, title: "Delete") { action, index in
            
            
            // Add if-clause to prevent from deleting a cause type which already has SOM data.
            
//            if let causeType = self.fetchedResultsController?.object(at: indexPath) as? CauseType {
                if wordToSwipe.stateOfMind?.value(forKey: "timeStamp") != nil {
                    print("Unable to edit since there is State of Mind past data associated with.")
                    self.existingSOMAlert()
                    
                } else {
                    managedContext?.delete(wordToSwipe as NSManagedObject)
                    
                }
  //          }
            
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
        let alertController = UIAlertController(title: "Edit", message: "Edit the cause type.", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { (action) -> Void in
            
            let newCauseType = alertController.textFields![0]
            let itemToAdd = newCauseType.text
          
            self.update(CauseType: CauseType, ItemToAdd: itemToAdd!)
        })
        
        alertController.addTextField { (textField: UITextField) in
            textField.placeholder = "Cause Type"
            saveAction.isEnabled = false
            textField.text = CauseType.type
            
        }
        
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alertController.textFields![0], queue: OperationQueue.main) { (notification) in
            if (alertController.textFields![0].text?.count)! > 0 {
                    saveAction.isEnabled = true
            
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        
    }

    func update(CauseType: CauseType, ItemToAdd: String) {
        
        CauseTypeEditDelete().fetchPredicatedSOM(wordToSwipe: CauseType, newCauseType: ItemToAdd)
        
        //CauseType.setValue(ItemToAdd, forKey: "type")
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLocationTVCSegue" {
            let destVC = segue.destination as! LocationViewController
            destVC.stateOfMindDesc = stateOfMindDesc
            destVC.causeDesc = causeDesc
            destVC.causeTypeSelected = causeTypeSelected
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}


extension CauseTableViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("The Controller Content Has Changed.")
        tableView.reloadData()
    }
    
}
