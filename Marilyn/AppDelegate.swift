//
//  AppDelegate.swift
//  Marilyn
//
//  Created by Tatsuya Moriguchi on 4/18/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static let geoCoder = CLGeocoder()
    
    var window: UIWindow?
    let center = UNUserNotificationCenter.current()
    let locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        preloadData()
        
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
        }
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringVisits()
        locationManager.delegate = self
        

        return true
    }
    
    private func preloadData()
    {
        
        let preloadedDataKey = "didPreloadData"
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: preloadedDataKey) == false
        {
            // Preload
            
            let dataFile = ["CauseDesc", "CauseType", "StateOfMindDesc", "Wisdom"]
            
            
            for file in dataFile
            {
                
                guard let urlPath = Bundle.main.url(forResource: file, withExtension: "plist") else
                {
                    return
                }
                
                // Import data in background thread
                let backgroundContext = persistentContainer.newBackgroundContext()
                
                // non-parent-child separate cotext from backgroundContext
                // context associated with main que, make persistentContainer to be aware of any change
                persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
                
                backgroundContext.perform {
                    do {
                        switch file {
                        case "CauseDesc":
                            if let arrayContents = NSArray(contentsOf: urlPath) as? [String] {
                                let now = Date()
                                for item in arrayContents {
                                    let dataObject = Cause(context: backgroundContext)
                                    dataObject.causeDesc = item
                                    dataObject.timeStamp = now
                                }
                                print("CauseDec loaded")
                            }
                        case "CauseType":
                            if let arrayContents = NSArray(contentsOf: urlPath) as? [String] {
                                for item in arrayContents {
                                    let dataObject = CauseType(context: backgroundContext)
                                    dataObject.type = item
                                }
                                print("CauseType loaded")
                            }
                        
                        case "StateOfMindDesc":
                            if let dictContents = NSDictionary(contentsOf: urlPath) as? ([String : AnyObject]){
                                for (itemA, itemB) in dictContents {
                                    let dataObject = StateOfMindDesc(context: backgroundContext)
                                    dataObject.adjective = itemA
                                    //let itemBInt16 = Int16(itemB)
                                    dataObject.rate = itemB as! Int16
                                }
                                print("StateOfMindDesc loaded")
                            }
                       
                        
                        case "Wisdom":
                            if let arrayContents = NSArray(contentsOf: urlPath) as? [String] {
                                for item in arrayContents {
                                    let dataObject = Wisdom(context: backgroundContext)
                                    dataObject.words = item
                                    print("Wisdom item was entered: \(item)")
                                }
 
                                print("Wisdom loaded")
                            }
 
                            
                            
                            
                       /* case "StateOfMind":
                              if let arrayContents = NSArray(contentsOf: urlPath) as? [Date] {
                                for (item) in arrayContents {
                                    let dataObjects = StateOfMind(context: backgroundContext)
                                    dataObjects.timeStamp = item
                            
                            }
/*                            if let arrayContents = NSArray(contentsOf: urlPath) as? [[String : AnyObject]] {
                                for (_) in arrayContents {
                                    
                                    //for (itemA, itemB) in item {
                                    
                                        let dataObject = StateOfMind(context: backgroundContext)
                                        
                                    dataObject.timeStamp = (arrayContents[0]["timeStamp"] as! Date)
                                    
                             
                                    dataObject.cause = arrayContents[1]["cause"] as? Cause
                                        dataObject.causeType = arrayContents[2]["causeType"] as? CauseType
                                        dataObject.stateOfMindDesc?.adjective = arrayContents[3]["adjective"] as? String
                                    dataObject.stateOfMindDesc?.rate = (arrayContents[4]["rate"] as? Int16)!
                                        dataObject.location?.locationName = arrayContents[5]["locationName"] as? String
                                    dataObject.location?.latitude = (arrayContents[6]["latitude"] as? Double)!
                                    dataObject.location?.longitude = (arrayContents[7]["longitude"] as? Double)!
                                        dataObject.location?.timeStamp = arrayContents[8]["locaitonTimeStamp"] as? Date
 */

                                        
                                        /*
                                        switch itemA {
                                        case "timeStamp":
                                            dataObject.timeStamp = itemB as? Date
                                        case "cause":
                                            dataObject.cause = itemB as? Cause
                                        case "causeType":
                                            dataObject.causeType = itemB as? CauseType
                                        case "adjective":
                                            dataObject.stateOfMindDesc?.adjective = itemB as? String
                                        case "rate":
                                            dataObject.stateOfMindDesc?.rate = (itemB as? Int16)!
                                        case "locationName":
                                            dataObject.location?.locationName = itemB as? String
                                        case "latitude":
                                            dataObject.location?.latitude = (itemB as? Double)!
                                        case "longitude":
                                            dataObject.location?.longitude = (itemB as? Double)!
                                        case "locationTimeStamp":
                                            dataObject.location?.timeStamp = itemB as? Date
                                        default:
                                            print("Switch default was selected")
                                        
                                        }
                                        */
                                        
                                    //}
                                //}
                            }
                        */
                            
                        default:
                            
                            print("*******WARNING*******default was chosen at switch statement backgroundContext.perform clause in AppDelegate.swift.")
                        }
                        
                        
                        
                        
                        try backgroundContext.save()
                        userDefaults.setValue(true, forKey: preloadedDataKey)
                        
                    } catch {
                        print(error.localizedDescription)
                        print("ERROR loading data")
                    }
                }
                
            }
            
        
 /*
            // Import data in background thread
            let backgroundContext = persistentContainer.newBackgroundContext()
            
            // non-parent-child separate cotext from backgroundContext
            // context associated with main que, make persistentContainer to be aware of any change
            persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
            
            backgroundContext.perform {
                do {
                    
                    //
                    guard let urlPath2 = Bundle.main.url(forResource: "Wisdom", withExtension: "plist") else
                    {
                        return
                    }
                    
                    if let dictContents = NSDictionary(contentsOf: urlPath2) as? ([String : String]) {
                        for (itemA, itemB) in dictContents {
                            let dataObject = Wisdom(context: backgroundContext)
                            dataObject.words = itemA
                            dataObject.relatedCauseType?.type = itemB
                            
                        }
                        
                        print("Wisdom loaded")
                    }
                    
                    
                    try backgroundContext.save()
                    userDefaults.setValue(true, forKey: preloadedDataKey)
                    
                } catch {
                    print(error.localizedDescription)
                    print("ERROR loading data")
                }
            }
            
   */
        } else {
            print("Data has already been imported.")
        }
    }
                
                

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.saveContext()
        
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Marilyn")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}


extension AppDelegate: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        // create CLLOcation from the coordinates of CLVisit
        let clLocation = CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)
        // Get the location description
        
        AppDelegate.geoCoder.reverseGeocodeLocation(clLocation) { placemarks, _ in
            if let place = placemarks?.first {
                // placemarks, description from CPLacemark devodec by CLGeocoder,
                // contain country, state, city, and street address
                // Also inlcude points of interest and geographically related data
                // Use CLPlacemark to create its object
                let description = "\(place)"
                self.newVisitReceived(visit, description: description)
            }
        }
    }
        
    func newVisitReceived(_ visit: CLVisit, description: String) {
        let location = LocationData(visit: visit, descriptionString: description)
        // CLVisit has four properties: arrivalDate, departureDate, coordinate, horizontlAccuracy
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "How do you feel so far here? Time to log current state of your mind"
        content.body = location.description
        content.sound = .default
        // Create a one second long trigger and notification request with that trigger.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: location.dateString, content: content, trigger: trigger)
        // Schedule the notificaiton by adding the request to notificaiton center.
        center.add(request, withCompletionHandler: nil)
        
    }
    
}
