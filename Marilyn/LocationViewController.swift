//
//  LocationViewController.swift
//  Marilyn
//
//  Created by Tatsuya Moriguchi on 5/4/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation
import UserNotifications

// To use CNPostalAddressFormatter()
import Contacts


class LocationViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    var stateOfMindDesc: StateOfMindDesc!
    var causeDesc: Cause!
    var causeTypeSelected: CauseType!
    var timeStamp: Date!
    
    let searchController = UISearchController(searchResultsController: nil)
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func addOnPressed(_ sender: UIBarButtonItem) {
        
        // To save current location data
        guard let currentLocation = mapView.userLocation.location else {
            return
        }
        
        let alert = UIAlertController(title: "Add Location", message: "Add a new location.", preferredStyle: .alert)
        
        let add = UIAlertAction(title: "Add", style: .default) { (alertAction: UIAlertAction) in
            guard let locationName = alert.textFields?[0].text else {
                print("alert.textFields?[0].text got nil.")
                return
            }
            
            let latitude = currentLocation.coordinate.latitude
            let longitude = currentLocation.coordinate.longitude
            self.timeStamp = currentLocation.timestamp
            let descriptionString = currentLocation.description
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: latitude, longitude: longitude)
            
            geoCoder.reverseGeocodeLocation(location, preferredLocale: nil) { (clPlacemark: [CLPlacemark]?, error: Error?) in
                
                guard let place = clPlacemark?.first else {
                    print("No placemark from Apple: \(String(describing: error))")
                    return
                }
                
                let postalAddressFormatter = CNPostalAddressFormatter()
                postalAddressFormatter.style = .mailingAddress
                var addressString: String?
                if let postalAddress = place.postalAddress {
                    addressString = postalAddressFormatter.string(from: postalAddress)
                    addressString = addressString?.replacingOccurrences(of: "\n", with: ", ")
                    
                    // Create a new location data to Core Data
                    self.add(locationName: locationName, descriptionString: descriptionString, latitude: latitude, longitude: longitude, timeStamp: self.timeStamp, address: addressString ?? "ERROR: addressString is nil.")

                }
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addTextField(configurationHandler: nil)
        alert.addAction(add)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        
    }

    // Add a new location with a location name to Location entity
    func add(locationName: String, descriptionString: String, latitude: Double, longitude: Double, timeStamp: Date, address: String ) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Location", in: managedContext)!
        let item = NSManagedObject(entity: entity, insertInto: managedContext)
        
        item.setValue(locationName, forKey: "locationName")
        item.setValue(descriptionString, forKey: "descriptionString")
        item.setValue(latitude, forKey: "latitude")
        item.setValue(longitude, forKey: "longitude")
        item.setValue(timeStamp, forKey: "timeStamp")
        item.setValue(address, forKey: "address")
        do {
            try managedContext.save()
            
        } catch {
            print("Failed to save an item: \(error.localizedDescription)")
        }
        
        configureFetchedResultsController()
        tableView.reloadData()
       
    }
    
    
    func saveSOM(location: Location) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "StateOfMind", in: managedContext)!
        let item = NSManagedObject(entity: entity, insertInto: managedContext)
       
        item.setValue(location, forKey: "location")
        item.setValue(timeStamp, forKey: "timeStamp")
        item.setValue(causeDesc, forKey: "cause")
        item.setValue(causeTypeSelected, forKey: "causeType")
        item.setValue(stateOfMindDesc, forKey: "stateOfMindDesc")

        do {
            try managedContext.save()
            
        } catch {
            print("Failed to save an item: \(error.localizedDescription)")
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar()
        
        configureFetchedResultsController()
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        fetchAnnotations()
        
    }
 /*
    @IBAction func undoSearchOnPressed(_ sender: UIBarButtonItem) {
        configureFetchedResultsController()
        tableView.reloadData()
    }
  */
    // MARK: -Search Bar
    func navBar() {
        searchController.searchBar.delegate = self
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Location"
        navigationItem.searchController = searchController
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
            self.fetchedResultsController?.fetchRequest.predicate = NSPredicate(format: "(locationName contains[c] %@ )", text!)
        }
        do {
            try self.fetchedResultsController?.performFetch()
            self.tableView.reloadData()
        } catch { print(error) }
    }
    
    
    
    
    func fetchAnnotations() {
        
        guard let pins = fetchedResultsController?.fetchedObjects as? [Location] else { return }
        
        // Place past pins onto the map
        for pin in pins {
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            pointAnnotation.title = pin.locationName
            pointAnnotation.subtitle = pin.address
            self.mapView.addAnnotation(pointAnnotation)
        }
        
    }
    
    
    func configureFetchedResultsController() {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        // Create the fetch request, set some sort descriptor, then feed the fetchedResultsController
        // the request with along with the managed object context, which we'll use the view context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        let sortDescriptorType = NSSortDescriptor(key: "timeStamp", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptorType]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self as NSFetchedResultsControllerDelegate
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

extension LocationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
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
        let LocationCell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        
        if let loca = fetchedResultsController?.object(at: indexPath) as? Location {
            LocationCell.textLabel?.text = loca.locationName
            LocationCell.detailTextLabel?.text = loca.address
            
        }
        return LocationCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 
        timeStamp = Date()
        let location = self.fetchedResultsController?.object(at: indexPath) as? Location
        
        location?.setValue(timeStamp, forKey: "timeStamp")
        location?.setValue(stateOfMindDesc.adjective, forKey: "lastAdjective")
        saveSOM(location: location!)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // Back to TabBarController
        if let tabBarController = appDelegate.window!.rootViewController as? UITabBarController {
            tabBarController.selectedIndex = 0
        }
        // animated: true returns warning "Swift Unbalanced calls to begin/end appearance transitions for"
        // This line should be placed at the bottom this funciton
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        	return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        let wordToSwipe = self.fetchedResultsController?.object(at: indexPath)
        
        let edit = UITableViewRowAction(style: .default, title: "Edit") { action, index in
            print("Editing")
            if let location = self.fetchedResultsController?.object(at: indexPath) as? Location {
                
                self.locationAlert(Location: location)
            }
        }
        
        let delete = UITableViewRowAction(style: .default, title: "Delete") { action, index in
            print("Deleting")
            managedContext?.delete(wordToSwipe as! NSManagedObject)
            
            }
        
        do {
            try managedContext?.save()
        } catch {
            print("Saving Error: \(error)")
        }
        
        edit.backgroundColor = UIColor.blue
        return [edit, delete]
    }
    
    func locationAlert(Location: Location) {
        let alertController = UIAlertController(title: "Edit", message: "Edit and Update the Location Name.", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { (action) -> Void in
            
            let nameToUpdate = alertController.textFields![0].text
            
            self.update(Location: Location, NameToUpdate: nameToUpdate!)
        })
        
        alertController.addTextField { (textField: UITextField) in
            textField.placeholder = "Type Location Name to Update"
            saveAction.isEnabled = false
            textField.text = Location.locationName
            
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
    
    
    func update(Location: Location, NameToUpdate: String) {
        Location.setValue(NameToUpdate, forKey: "locationName")
    }
    
    
}
extension LocationViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("The Controller Content Has Changed.")
        tableView.reloadData()
    }
}

extension LocationViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        print("An annotation was tapped!")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        // Create the fetch request, set some sort descriptor, then feed the fetchedResultsController
        // the request with along with the managed object context, which we'll use the view context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        
        if let selectedAnnotation = view.annotation as? MKPointAnnotation {
        
         let selectedLocationName = selectedAnnotation.title
        fetchRequest.predicate = NSPredicate(format: "locationName == %@", selectedLocationName!)
        
        print("selectedAnnotation.title: \(String(describing: selectedAnnotation.title))")
        }
        
        let sortDescriptorType = NSSortDescriptor(key: "timeStamp", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptorType]
        
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self as NSFetchedResultsControllerDelegate
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
        tableView.reloadData()
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        configureFetchedResultsController()
        tableView.reloadData()
    }
}
