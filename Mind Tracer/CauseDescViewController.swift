//
//  CauseDescViewController.swift
//  Mind Tracer
//
//  Created by Tatsuya Moriguchi on 4/29/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData

class CauseDescViewController: UIViewController, UITextViewDelegate, NSFetchedResultsControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
 
    // Passed from StateOfMindTVC via segue
    var stateOfMindDesc: StateOfMindDesc!
    var wordToSave: Cause?
    var buttonMode: String = NSLocalizedString("Add New", comment: "Button string")
    
    let adjectiveError = NSLocalizedString("Adjective was not selected.", comment: "Error message")
    
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
  
    let searchController = UISearchController(searchResultsController: nil)

    @IBOutlet weak var Button: UIButton!
    @IBOutlet weak var ClearTextButton: UIButton!
    //@IBOutlet weak var UndoSearchButton: UIButton!
    
    @IBOutlet weak var causeTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func clearToAddNewOnPressed(_ sender: UIButton) {
        buttonMode = NSLocalizedString("Add New", comment: "Button text string")
        causeTextView.text = "" //"Type a new cause here."
        self.changeTitle(title: NSLocalizedString("Add New", comment: "Title string"))
        self.causeTextView.isEditable = true
    }
  
    
   /* // Undo Search to display all causes
    @IBAction func undoOnPressed(_ sender: UIButton) {
        configureFetchedResultsController()
        tableView.reloadData()
    }
    */
    
    @IBAction func saveOnPressed(_ sender: Any) {
        // Add a new cause
        if causeTextView.text == "" {
            print("Nothing to save here, really")
            // add a alert here
            causeTextView.text = NSLocalizedString("No text was found. Type something to proceed.", comment: "Error message")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.causeTextView.text = ""
            }
    
        } else {
            
            switch buttonMode {
            case NSLocalizedString("Update", comment: ""):
            update(itemToUpdate: wordToSave!, itemName: causeTextView.text)
            case NSLocalizedString("Add New", comment: ""):
                save(itemName: causeTextView.text)
            case NSLocalizedString("Select", comment: ""):
                print("")
            case NSLocalizedString("Undo Search", comment: ""):
                print("Undo Search was pressed.")
                configureFetchedResultsController()
                tableView.reloadData()
                
            default:
                print("")
            }
            
            wordToSave?.setValue(Date(), forKey: "timeStamp")

            view.endEditing(true)
            causeTextView.text = ""
            causeTextView.isEditable = true
            changeTitle(title: NSLocalizedString("Add New", comment: ""))
            performSegue(withIdentifier: "toCauseTVCSegue", sender: wordToSave)
  
        }
    }
    
    // MARK: -viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        causeTextView.layer.masksToBounds = true
        causeTextView.layer.cornerRadius = 10
        
        configureFetchedResultsController()
        tableView.dataSource = self
        tableView.dataSource = self
        
        navBar()
        // To dismiss a keyboard
        causeTextView.delegate = self // as? UITextViewDelegate
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
 
        self.causeTextView.isEditable = true
        self.changeTitle(title: "Add New")
        
        let newPosition = causeTextView.endOfDocument
        causeTextView.selectedTextRange = causeTextView.textRange(from: newPosition, to: newPosition)
    }
    
    func navBar() {
        self.navigationItem.prompt = NSLocalizedString("Your Current State of Mind:", comment: "Navigation bar title") + (stateOfMindDesc.adjective ?? adjectiveError)
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Search Bar
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Search Cause", comment: "Search placeholder")
        tableView.tableHeaderView = searchController.searchBar
        //navigationItem.searchController = searchController
        
        definesPresentationContext = true
    }
    
    // Search bar
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text
        if (text?.isEmpty)! {
            print("updateSearchResults text?.isEmpty ")
            
            configureFetchedResultsController()
            tableView.reloadData()
            
        } else {
            self.fetchedResultsController?.fetchRequest.predicate = NSPredicate(format: "(causeDesc contains[c] %@ )", text!)
            buttonMode = NSLocalizedString("Undo Search", comment: "Button text string")
            
        }
        do {
            try self.fetchedResultsController?.performFetch()
            self.tableView.reloadData()
        } catch { print(error) }
    }
    
    
    // Change Navigation Bar Item Button Title, dynamically
    func changeTitle(title: String) {
        
        Button.titleLabel?.font.withSize(30)
        Button.setTitle(title, for: .normal)
    }

    
    // MARK: - Clear UITextView upon Editing and Dismissing a Keyboard
    @objc func tap(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    
    private func configureFetchedResultsController() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // Create the fetch request, set some sort descriptor, then feed the fetchedResultsController
        // the request with along with the managed object context, which we'll use the view context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cause")
        //let sortDescriptorType = NSSortDescriptor(key: "causeDesc", ascending: true)
        let sortDescriptorTypeTime = NSSortDescriptor(key: "timeStamp", ascending: false)
       
        //fetchRequest.sortDescriptors = [sortDescriptorTypeTime, sortDescriptorType]
        fetchRequest.sortDescriptors = [sortDescriptorTypeTime]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self //as? NSFetchedResultsControllerDelegate
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    

    func save(itemName: String) {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
       
        let entity = NSEntityDescription.entity(forEntityName: "Cause", in: managedContext)!
        let item = NSManagedObject(entity: entity, insertInto: managedContext)
        

        item.setValue(itemName, forKey: "causeDesc")
        item.setValue(Date(), forKey: "timeStamp")
        wordToSave = item as? Cause
        
        do {
            try managedContext.save()
            
        } catch {
            print("Failed to save an item #2: \(error.localizedDescription)")
        }
        
        // Change button title back to Add New, and clear TextView content
        buttonMode = NSLocalizedString("Add New", comment: "Button text string")
        causeTextView.text = ""
    }
   
    func update(itemToUpdate: NSManagedObject, itemName: String) {
        print("update itemToUpdate: \(itemToUpdate)")
        itemToUpdate.setValue(itemName, forKey: "causeDesc")
       // itemToUpdate.setValue(Date(), forKey: "timeStamp")

        buttonMode = NSLocalizedString("Update", comment: "Button text string")
        causeTextView.text = ""
        self.causeTextView.isEditable = true
        self.changeTitle(title: NSLocalizedString("Add New", comment: "Title text string"))
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCauseTVCSegue" {
            let destVC = segue.destination as! CauseTableViewController
            destVC.stateOfMindDesc = stateOfMindDesc
            destVC.causeDesc = wordToSave
            
        }
    }
}


extension CauseDescViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else {
            print("numberOfRowsInSection failed.")
            return 0
        }
        let rowCount = sections[section].numberOfObjects
        print("The amount of rows in the section are: \(rowCount)")
        
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CauseDescCell = tableView.dequeueReusableCell(withIdentifier: "CauseDescCell", for: indexPath)
        if let causeDesc = fetchedResultsController?.object(at: indexPath) as? Cause {
            CauseDescCell.textLabel?.text = causeDesc.causeDesc
        }
        return CauseDescCell
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        wordToSave = self.fetchedResultsController?.object(at: indexPath) as? Cause
        
        let edit = UITableViewRowAction(style: .default, title: NSLocalizedString("Edit", comment: "TableView row Edit")) { action, index in
            
            self.causeTextView.text = self.wordToSave!.causeDesc
            
            //let causeDescToUpdate = wordToSave.causeDesc
            //self.causeEditAlert(CauseDesc: wordToSave)
            //}
            // call a function passing wordToSave
            self.buttonMode = NSLocalizedString("Update", comment: "")

            self.causeTextView.isEditable = true
            self.changeTitle(title: NSLocalizedString("Update", comment: ""))

            let newPosition = self.causeTextView.endOfDocument
            self.causeTextView.selectedTextRange = self.causeTextView.textRange(from: newPosition, to: newPosition)
            
            //let selectedRange: UITextRange? = causeTextView.selectedTextRange
        
        }

        let delete = UITableViewRowAction(style: .default, title: NSLocalizedString("Delete", comment: "")) { action, index in
            print("Deleting")
            managedContext?.delete(self.wordToSave!)
            
            do {
                try managedContext?.save()
            } catch {
                print("Saving Error: \(error)")
            }
            
            self.causeTextView.text = ""
            self.causeTextView.isEditable = true
            self.changeTitle(title: NSLocalizedString("Add New", comment: ""))
        }
        
        edit.backgroundColor = UIColor.blue
        return [edit, delete]
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        wordToSave = self.fetchedResultsController?.object(at: indexPath) as? Cause
        
        print(wordToSave?.causeDesc as Any)
        self.causeTextView.text = wordToSave?.causeDesc
        causeTextView.isEditable = false
        changeTitle(title: NSLocalizedString("Select", comment: ""))
        buttonMode = NSLocalizedString("Select", comment: "")
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("The Controller Content Has Changed.")
        tableView.reloadData()
    }
}

