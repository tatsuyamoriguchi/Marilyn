//
//  StateOfMindDescTableViewController.swift
//  Marilyn
//
//  Created by Tatsuya Moriguchi on 4/27/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData

class StateOfMindDescTableViewController: UITableViewController, UITextFieldDelegate, UISearchResultsUpdating, UISearchBarDelegate {
 
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        navBar()
        
        configureFetchedResultsController()
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    
  /*  // MARK: -Search Undo
    @IBAction func undoOnPressed(_ sender: UIBarButtonItem) {
    
    configureFetchedResultsController()
        tableView.reloadData()
    }
    */
    
    // MARK: -Search Bar
    func navBar() {
        searchController.searchBar.delegate = self
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Adjective"
        tableView.tableHeaderView = searchController.searchBar
//        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    

    // MARK: -Update Search Results
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text
        if (text?.isEmpty)! {
            print("updateSearchResults text?.isEmpty ")
            configureFetchedResultsController()
            tableView.reloadData()
            
        } else {
            self.fetchedResultsController?.fetchRequest.predicate = NSPredicate(format: "(adjective contains[c] %@ )", text!)
        }
        do {
            try self.fetchedResultsController?.performFetch()
            self.tableView.reloadData()
        } catch { print(error) }
    }
    
    
    // MARK: -Configure FetchResultsController
    private func configureFetchedResultsController() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // Create the fetch request, set some sort descriptor, then feed the fetchedResultsController
        // the request with along with the managed object context, which we'll use the view context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StateOfMindDesc")
        let sortDescriptorRate = NSSortDescriptor(key: "rate", ascending: false)
        let sortDescriptorAdjective = NSSortDescriptor(key: "adjective", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptorRate, sortDescriptorAdjective]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: "rate", cacheName: nil)
        fetchedResultsController?.delegate = self
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: -Add New Adjective
    @IBAction func addNewOnPressed(_ sender: UIBarButtonItem) {
    
        // Pass empty strings to add a new item
        stateOfMindAlert()
    }
  
    func stateOfMindAlert() {
        let alertController = UIAlertController(title: "Add New", message: "Add an adjective which the best descibes your current state of mind. Use an integer, 100, 25, -25, or -100 for rate.", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { (action) -> Void in
            
            let newAdjective = alertController.textFields![0]
            let newRate = alertController.textFields![1]
            
            let itemToAdd = newAdjective.text
            guard let rateToAdd = Int16(newRate.text!) else {
                print("rateToAdd error")
                self.inputError()
                return
            }

            self.save(itemName: itemToAdd!, itemRate: rateToAdd) // Later add no-nil validation
        })
        
        alertController.addTextField { (textField: UITextField) in
            textField.placeholder = "Adjective"
            saveAction.isEnabled = false
            
        }
        
        alertController.addTextField { (textField: UITextField) in
            textField.placeholder = "Rate"
            saveAction.isEnabled = false
            textField.delegate = self
            
        }
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alertController.textFields![1], queue: OperationQueue.main) { (notification) in
            if (alertController.textFields![0].text?.count)! > 0, let value = Int16(alertController.textFields![1].text!) {
                switch value {
                case -100:
                    saveAction.isEnabled = true
                case -25:
                    saveAction.isEnabled = true
                case 25:
                    saveAction.isEnabled = true
                case 100:
                    saveAction.isEnabled = true
                default:
                    saveAction.isEnabled = false
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    func inputError() {
        let inputAlert = UIAlertController(title: "Alert!", message: "Invalid data to State Of Mind Rate. Please type -100, -25 or 100. ", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        inputAlert.addAction(okAction)
        present(inputAlert, animated: true, completion: nil)
        
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == textField {
            let allowedCharatedrs = CharacterSet(charactersIn:"012345689-")
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharatedrs.isSuperset(of: characterSet)
        }
        return true
    }
    
    func save(itemName: String, itemRate: Int16) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "StateOfMindDesc", in: managedContext)!
        let item = NSManagedObject(entity: entity, insertInto: managedContext)
        item.setValue(itemName, forKey: "adjective")
        item.setValue(itemRate, forKey: "rate")
        
        do {
            try managedContext.save()
           
        } catch {
            print("Failed to save an item: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        guard let sections = fetchedResultsController?.sections else {
            return 0
        }
        return sections.count
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       /* if (isFilterting()) {
            print("filteredAdjectives.count: \(filteredAdjectives.count)")
            return filteredAdjectives.count

        } else {
         */
        guard let sections = fetchedResultsController?.sections else {
                return 0
            }
            let rowCount = sections[section].numberOfObjects
            print("The amount of rows in the segction are: \(rowCount)")
            
            return rowCount
            
        //}
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let StateOfMindCell = tableView.dequeueReusableCell(withIdentifier: "StateOfMindCell", for: indexPath)

            if let stateOfMindDesc = fetchedResultsController?.object(at: indexPath) as? StateOfMindDesc {
                StateOfMindCell.textLabel?.text = stateOfMindDesc.adjective
                StateOfMindCell.detailTextLabel?.text = stateOfMindDesc.rate as AnyObject as? String
                
            }
      //  }
        return StateOfMindCell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController?.sections {
            let currentSection = sections[section]
            return "State of Mind Rate: " + currentSection.name
        }
        return nil
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        //guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        //let wordToSwipe = self.fetchedResultsController?.object(at: indexPath)
        
        let edit = UITableViewRowAction(style: .default, title: "Edit") { action, index in
            print("Editing")
            
            if let stateOfMindDesc = self.fetchedResultsController?.object(at: indexPath) as? StateOfMindDesc {
                self.stateOfMindEditAlert(StateOfMindDesc: stateOfMindDesc)
            }
        }
        
        /*let delete = UITableViewRowAction(style: .default, title: "Delete") { action, index in
            print("Deleting")
            if let stateOfMindDesc = self.fetchedResultsController?.object(at: indexPath) as? StateOfMindDesc {
            self.stateOfMindDeleteAlert(StateOfMindDesc: stateOfMindDesc)
            //managedContext?.delete(wordToSwipe as! NSManagedObject)
            }
        }
        */
        
        do {
            try managedContext?.save()
        } catch {
            print("Saving Error: \(error)")
        }
        edit.backgroundColor = UIColor.blue
        //return [edit, delete]
       return [edit]
    }


    func stateOfMindDeleteAlert(StateOfMindDesc: StateOfMindDesc) {
        let alert = UIAlertController(title: "Warning", message: "This modificaiton affects your past state of your mind and locaiton record data. Are you sure to modify it?", preferredStyle: .alert)
       
        let proceedAciton = UIAlertAction(title: "Sure", style: .default) { (alert: UIAlertAction!) -> Void in
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedContext = appDelegate?.persistentContainer.viewContext
            //managedContext?.delete(wordToSwipe as! NSManagedObject)
            managedContext?.delete(StateOfMindDesc)
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(proceedAciton)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    
    func stateOfMindEditAlert(StateOfMindDesc: StateOfMindDesc) {
        let alertController = UIAlertController(title: "Edit", message: "Edit the adjective. Use an integer, 100, -25, or -100 for rate. WARNING: This modificaiton affects your past state of your mind and locaiton record data. Are you sure to modify it?", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { (action) -> Void in
            
            let newAdjective = alertController.textFields![0]
            let newRate = alertController.textFields![1]
            
            let itemToAdd = newAdjective.text
            guard let rateToAdd = Int16(newRate.text!) else {
                print("rateToAdd error")
                self.inputError()
                return
            }
            
            self.update(StateOfMindDesc: StateOfMindDesc, ItemToAdd: itemToAdd!, RateToAdd: rateToAdd)
            //self.save(itemName: itemToAdd!, itemRate: rateToAdd) // Later add no-nil validation
            
            
        })
        
        alertController.addTextField { (textField: UITextField) in
            textField.placeholder = "Adjective"
            saveAction.isEnabled = false
            textField.text = StateOfMindDesc.adjective
            
        }
        
        alertController.addTextField { (textField: UITextField) in
            textField.placeholder = "Rate"
            saveAction.isEnabled = false
            textField.delegate = self
            //textField.text = String(StateOfMindDesc.rate)
            textField.text = ""
        }
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alertController.textFields![1], queue: OperationQueue.main) { (notification) in
            if (alertController.textFields![0].text?.count)! > 0, let value = Int16(alertController.textFields![1].text!) {
                switch value {
                case -100:
                    saveAction.isEnabled = true
                case -25:
                    saveAction.isEnabled = true
                case 100:
                    saveAction.isEnabled = true
                default:
                    saveAction.isEnabled = false
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        
    }

    
    func update(StateOfMindDesc: StateOfMindDesc, ItemToAdd: String, RateToAdd: Int16) {
        
        StateOfMindDesc.setValue(ItemToAdd, forKey: "adjective")
        StateOfMindDesc.setValue(RateToAdd, forKey: "rate")
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let stateOfMindDesc = self.fetchedResultsController?.object(at: indexPath) as? StateOfMindDesc
        
        /*print("didSelectRowAt")
        print("stateOfMindDesc.adjective: \(stateOfMindDesc!.adjective)")
        print("stateOfMindDesc.rate: \(stateOfMindDesc!.rate)")
        */
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCauseDescSegue" {
            let destVC = segue.destination as! CauseDescViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            let stateOfMindObject = fetchedResultsController?.object(at: indexPath!) as! StateOfMindDesc
            
            destVC.stateOfMindDesc = stateOfMindObject
        }
    }
}

extension StateOfMindDescTableViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("The Controller Content Has Changed.")
        tableView.reloadData()
    }
    
}

