//
//  LineChartViewController.swift
//  Marilyn
//
//  Created by Tatsuya Moriguchi on 5/14/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData
import Charts


class LineChartViewController: UIViewController {
    
    
    //private let dataSource = ["All", "Home", "Work", "School", "Grocery Store", "Ramen Shop", "Cafe", "On the Road"]
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var locationArray: [Any] = []
    var somArray: [Date] = []
    var locaName: String? = "All"
    var average: Int16?
    
    var last24Hrs: [Int] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    var average24hrs: [Double] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    
    
    
    @IBOutlet weak var LocationPicker: UIPickerView!
    
    
    @IBAction func hrsOnPressed(_ sender: UIButton) {
        // Clear lneChartView.data
        last24Hrs = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        average24hrs = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        calculateRate(timeRangeString: "24hrs")
        let stringLast24Hrs = last24Hrs.map { String($0)}
        mockupDisplay(dataPoints: stringLast24Hrs, values: average24hrs)
    }
    @IBAction func daysOnPressed(_ sender: UIButton) {
        calculateRate(timeRangeString: "7days")
//        mockupDisplay()
    }
    @IBAction func monthOnPressed(_ sender: UIButton) {
        calculateRate(timeRangeString: "1month")
  //      mockupDisplay()
    }
    @IBAction func yearOnPressed(_ sender: UIButton) {
        calculateRate(timeRangeString: "1year")
    //    mockupDisplay()
    }
    @IBAction func allTimeOnPressed(_ sender: UIButton) {
        calculateRate(timeRangeString: "all")
      //  mockupDisplay()
    }
    
    func mockupDisplay(dataPoints: [String], values: [Double]) {
        /* var somArrayString: String = ""
         for i in somArray {
         print("i: \(i)")
         // let today = Date()
         //today.toString(dateFormat: "MM-dd-yyyy-hh-mm-ss")
         somArrayString = i.toString(style: .long)
         print("somArrayString: \(somArrayString)")
         somArrayString.append(somArrayString)
         }
         */
        //textView.text = "somArray: \(somArray)  average: \(String(describing: average))"
        

        
        
        // 1. Set ChartDataEntry
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
        

            dataEntries.append(dataEntry)
        }
        // 2. Set ChartDataSet
        let lineChartDataSet = LineChartDataSet(entries: dataEntries, label: "Hourly Average of Your Mind of State")
        
        // 3. Set ChartData
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        
        //lineChartView.leftAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        lineChartView.leftAxis.granularity = 1
        
        // 4. Assign it to the chart's data
        lineChartView.data = lineChartData
        self.lineChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
    }
    
    //// Mock up for graphic line chart, for now testing purpose,
    // just show row values
    //@IBOutlet weak var textView: UITextView!
    @IBOutlet var lineChartView: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocationPicker.dataSource = self
        LocationPicker.delegate = self
        
        configureFetchedResultsController(EntityName: "Location", sortString: "timeStamp")
        
        populateLocationData()
        
    }
    
    // To reload UIPickerView data with new location data
    override func viewDidAppear(_ animated: Bool) {
        // To avoid append array data to itself
        locationArray = []
        viewDidLoad()
    }
    
    func configureFetchedResultsController(EntityName: String, sortString: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        // Create the fetch request, set some sort descriptor, then feed the fetchedResultsController
        // the request with along with the managed object context, which we'll use the view context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName)
        let sortDescriptorType = NSSortDescriptor(key: sortString, ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptorType]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self as? NSFetchedResultsControllerDelegate
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func calculateRate(timeRangeString: String) {
        
        configureFetchedResultsController(EntityName: "StateOfMind", sortString: "timeStamp")
        
        switch timeRangeString {
        case "24hrs":
            print("24hrs")
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .day, value: -1, to: endDate)
            //let startDate = Calendar.current.date(byAdding: .hour, value: -7, to: endDate)
            //print("startDate: \(startDate)")
            //print("endDate: \(endDate)")
            populateSOMData(startDate: startDate!, endDate: endDate, selectedLocationName: locaName!)
            
        case "7days":
            print("7days")
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate)
            
            populateSOMData(startDate: startDate!, endDate: endDate, selectedLocationName: locaName!)
            
        case "1month":
            print("1month")
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .month, value: -1, to: endDate)
            
            populateSOMData(startDate: startDate!, endDate: endDate, selectedLocationName: locaName!)
            
        case "1year":
            print("1year")
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .year, value: -1, to: endDate)
            
            populateSOMData(startDate: startDate!, endDate: endDate, selectedLocationName: locaName!)
            
        default:
            print("default all")
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .year, value: 0, to: endDate)
            populateSOMData(startDate: startDate!, endDate: endDate, selectedLocationName: locaName!)
            
        }
    }
    
    
    func populateSOMData(startDate: Date, endDate: Date, selectedLocationName: String){
        
        somArray = []
        average = 0
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        var items = [StateOfMind]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StateOfMind")
        
        
        if (selectedLocationName != "All") && (startDate != endDate) {
            // For a specific locaiton and for a specific range of period
            //fetchRequest.predicate = NSPredicate(format: "(timeStamp >= %@) AND (timeStamp < %@)", startDate as CVarArg, endDate as CVarArg)
            fetchRequest.predicate = NSPredicate(format: "(location.locationName == %@) AND (timeStamp >= %@) AND (timeStamp < %@)", selectedLocationName, startDate as CVarArg, endDate as CVarArg)
            
        } else if (selectedLocationName != "All") && (startDate == endDate) {
            // For a specific location data and for all past period data
            fetchRequest.predicate = NSPredicate(format: "location.locationName == %@", selectedLocationName)
            
        } else if (selectedLocationName == "All") && (startDate != endDate) {
            // For all location data and for a specific range of period
            fetchRequest.predicate = NSPredicate(format: "(timeStamp >= %@) AND (timeStamp < %@)", startDate as CVarArg, endDate as CVarArg)
            
        } else { print("WARNING*****Out of predefined conditions at populateSOMData()")}
        
        // To sort predicated data
        let sortDescriptorTypeTime = NSSortDescriptor(key: "timeStamp", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorTypeTime]
        
        
        
        /*
         
         /////////////////////////////////////////////////
         ///// For a year /////////////////////////////////
         var arrayYear = [0,0,0,0,0,0,0,0,0,0,0,0]
         var somCountPerUnit = [0,0,0,0,0,0,0,0,0,0,0,0]
         var averageYear = [0,0,0,0,0,0,0,0,0,0,0,0]
         let calendar = Calendar.current
         let now = Date()
         let today = calendar.component(.month, from: now)
         
         do { items = try managedContext?.fetch(fetchRequest) as! [StateOfMind]
         for item in items {
         somArray.append(item.timeStamp!)
         
         print("item.location.locationName: \(String(describing: item.location?.locationName))")
         
         //////TEST code to fill array24hrs with the average number of rates
         ////// each element represents an hour unit, 0 for 24 hours before, 1 for 23 hours before...
         ////// this is to create a line chart, later.
         let date = item.timeStamp
         let month = calendar.component(.month, from: date!)
         print("month: \(month)")
         // calculate how many months between the date and today, if 12, index is 0, 11 : 1, 10 : 2, 9 : 3, 1 : 10, 0 : 11
         let diff = today - month
         
         print("+++++++diff+++++++++")
         print(diff)
         
         let index = 11 - diff  /// if diff is 1, then index => 10, 0 : 11, 11 : 0
         
         //              array24hrs.insert(Int((item.stateOfMindDesc?.rate)!), at: hour)
         // To avoid an error Cannot assign Int type with Int16 type
         
         var rate: Int16
         rate = item.stateOfMindDesc?.rate ?? 0
         
         arrayYear[index] += Int(rate)
         /// Will execute the following line only if there is a SOM data. If no SOM data,
         /// the element of the array remains the same as '0'
         somCountPerUnit[index] += 1
         }
         
         } catch {   print("Error")  }
         
         //
         print("++++++++++arrayYear+++++++++")
         print(arrayYear)
         print(" ")
         // sum up the adjective rate data of each somArray elements
         let sum = items.reduce(0, {$0 + ($1.stateOfMindDesc?.rate)!})
         print("+++++++++Total Rate Sum++++++++++++")
         print("sum: \(sum)")
         
         if items.count > 0 { average = sum/Int16(items.count)
         
         print("++++++++avegrage++++++++++++++")
         print(average ?? 0)
         
         } else { print("No data to calculate found.") }
         
         var arrayIndex = 0
         for i in arrayYear {
         if i != 0 {
         
         let average = i/somCountPerUnit[arrayIndex]
         averageYear[arrayIndex] = average
         
         }
         arrayIndex += 1
         }
         
         print("++++++averageYear++++++++")
         print(averageYear)
         
         */
        
        
        
        /*
         /////////////////////////////////////////////////
         ///// For 30days /////////////////////////////////
         var array30days = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
         var somCountPerUnit = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
         var average30days = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
         
         let calendar = Calendar.current
         let now = Date()
         let today = calendar.component(.day, from: now)
         
         do { items = try managedContext?.fetch(fetchRequest) as! [StateOfMind]
         for item in items {
         somArray.append(item.timeStamp!)
         
         print("item.location.locationName: \(String(describing: item.location?.locationName))")
         
         //////TEST code to fill array24hrs with the average number of rates
         ////// each element represents an hour unit, 0 for 24 hours before, 1 for 23 hours before...
         ////// this is to create a line chart, later.
         let date = item.timeStamp
         let day = calendar.component(.day, from: date!)
         print("day: \(day)")
         // calculate how many days between the date and today, if 30, index is 0, 29 : 1, 28 : 2, 20 : 10, 15 : 15, 10: 20, 5 : 25, 0 : 30
         let diff = today - day
         
         
         
         
         print("+++++++diff+++++++++")
         print(diff)
         
         let index = 30 - diff  /// today = 16, if day = 15 then index => 28, 16:29, 14;27, 10:23,
         
         //              array24hrs.insert(Int((item.stateOfMindDesc?.rate)!), at: hour)
         // To avoid an error Cannot assign Int type with Int16 type
         var rate: Int16
         rate = item.stateOfMindDesc?.rate ?? 0
         array30days[index] += Int(rate)
         somCountPerUnit[index] += 1
         }
         
         } catch {
         print("Error")
         }
         
         //
         print("++++++++++array30days+++++++++")
         print(array30days)
         print(" ")
         // sum up the adjective rate data of each somArray elements
         let sum = items.reduce(0, {$0 + ($1.stateOfMindDesc?.rate)!})
         print("+++++++++Total Rate Sum++++++++++++")
         print("sum: \(sum)")
         
         if items.count > 0 { average = sum/Int16(items.count)
         
         print("++++++++avegrage++++++++++++++")
         print(average ?? 0)
         
         } else { print("No data to calculate found.") }
         
         /////////
         var arrayIndex = 0
         for i in array30days {
         if i != 0 {
         
         let average = i/somCountPerUnit[arrayIndex]
         average30days[arrayIndex] = average
         
         }
         arrayIndex += 1
         }
         
         print("++++++average30days++++++++")
         print(average30days)
         
         
         */
        
        
        /*
         /////////////////////////////////////////////////
         ///// For 7days /////////////////////////////////
         var array7days = [0,0,0,0,0,0,0]
         var somCountPerUnit = [0,0,0,0,0,0,0]
         var average7days = [0,0,0,0,0,0,0]
         
         let calendar = Calendar.current
         let now = Date()
         let today = calendar.component(.day, from: now)
         
         do { items = try managedContext?.fetch(fetchRequest) as! [StateOfMind]
         for item in items {
         somArray.append(item.timeStamp!)
         
         print("item.location.locationName: \(item.location?.locationName)")
         
         //////TEST code to fill array24hrs with the average number of rates
         ////// each element represents an hour unit, 0 for 24 hours before, 1 for 23 hours before...
         ////// this is to create a line chart, later.
         let date = item.timeStamp
         let day = calendar.component(.day, from: date!)
         print("day: \(day)")
         let index = day - today + 6 /// today = 16, if day = 15 then index => 5, 16=6, 14=4, 10=0
         
         //              array24hrs.insert(Int((item.stateOfMindDesc?.rate)!), at: hour)
         // To avoid an error Cannot assign Int type with Int16 type
         var rate: Int16
         rate = item.stateOfMindDesc?.rate ?? 0
         array7days[index] += Int(rate)
         somCountPerUnit[index] += 1
         }
         
         } catch {
         print("Error")
         }
         
         //
         print("++++++++++array24hrs+++++++++")
         print(array7days)
         print(" ")
         // sum up the adjective rate data of each somArray elements
         let sum = items.reduce(0, {$0 + ($1.stateOfMindDesc?.rate)!})
         print("+++++++++Total Rate Sum++++++++++++")
         print("sum: \(sum)")
         
         if items.count > 0 { average = sum/Int16(items.count)
         
         print("++++++++avegrage++++++++++++++")
         print(average)
         
         } else { print("No data to calculate found.") }
         
         /////////
         var arrayIndex = 0
         for i in array7days {
         if i != 0 {
         
         let average = i/somCountPerUnit[arrayIndex]
         average7days[arrayIndex] = average
         
         }
         arrayIndex += 1
         }
         
         print("++++++average7days++++++++")
         print(average7days)
         
         
         
         */
        
 
        
        
        
        
        ////// For now, pressing 7 days, 1 month, 1 year , or All process hour data as 24 hours
        ////// Change the number of elements of an array from 24 to 7 for 7days, 30 for 1 month, 12 for 1 year,
        ////// and count number of data for All.
        ///// For 24hrs /////////////////////////////////
        var array24hrs = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        var somCountPerUnit = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        //var average24hrs = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        



        let calendar = Calendar.current
        let currentDate = Date()
        let currentHour = calendar.component(.hour, from: currentDate)
        print("currentHour: \(currentHour)")
        
        ////////////////////////////////////////////////////////////////////////
        // For X axis label for line chart
        //var last24Hrs: [Int] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        for i in (0...23) {
            last24Hrs[i] = currentHour + 1 + i
            if last24Hrs[i] >= 24 { last24Hrs[i] = last24Hrs[i] - 24 }
        }
        
        print("********last24Hrs")
        print(last24Hrs)
        ////////////////////////////////////////////////////////////////////////
        
        
        do { items = try managedContext?.fetch(fetchRequest) as! [StateOfMind]
            for item in items {
                somArray.append(item.timeStamp!)
                
                print("item.location.locationName: \(item.location?.locationName)")
                print("item.stateOfMindDesc.rate: \(item.stateOfMindDesc?.rate)")
                
                //////TEST code to fill array24hrs with the average number of rates
                ////// each element represents an hour unit, 0 for 24 hours before, 1 for 23 hours before...
                ////// this is to create a line chart for last 24 hours. Not for 7 days and else.
                let date = item.timeStamp
                
                // Get hour number from date which is fetched StateOfMind data
                ////// change 'hour' to day for 7 days and 1 month, month for 1 year, and year for All
                let hour = calendar.component(.hour, from: date!)
                
                print("hour: \(hour)")
                //              array24hrs.insert(Int((item.stateOfMindDesc?.rate)!), at: hour)
                // To avoid an error Cannot assign Int type with Int16 type
                var rate: Int16
                rate = item.stateOfMindDesc?.rate ?? 0
                
                //let elemNum = 23 - currentHour + hour
                var elemNum = hour - currentHour + 23
                if elemNum >= 24 { elemNum = elemNum - 24 }
                
                //array24hrs[hour] += Int(rate)
                array24hrs[elemNum] += Int(rate)
                //somCountPerUnit[hour] += 1
                somCountPerUnit[elemNum] += 1
            }
            
        } catch {
            print("Error")
        }
        print("******somArray")
        print(somArray)
        
        print("******array24hrs")
        print(array24hrs)
        
        // sum up the adjective rate data of each somArray elements
        let sum = items.reduce(0, {$0 + ($1.stateOfMindDesc?.rate)!})
        print("+++++++++Total Rate Sum++++++++++++")
        print("sum: \(sum)")
        
        if items.count > 0 { average = sum/Int16(items.count)
            
            print("++++++++avegrage++++++++++++++")
            print(average)
            
        } else { print("No data to calculate found.") }
        
        /////////
        // Place each average rate to each hour
        var arrayIndex = 0
        for i in array24hrs {
            if i != 0 {
                
                let average = i/somCountPerUnit[arrayIndex]
                average24hrs[arrayIndex] = Double(average)
                
            }
            arrayIndex += 1
        }
        
        print("++++++average24hrs++++++++")
        print(average24hrs)
        
        
        /*
         
         
         
         /////
         ///// X axis uit: Last 24hrs-> hour, Last 7 days-> day, Last month -> day, Last year -> 12 months
         ///// All time -> per year average
         
         //// for past 24hrs, get 24 hrs ago from the current time, if any som data exists, calculate their rate average
         //// value, then put them into one of 24 elements of the array.
         //// calculate the sum of som values for every hour and get the average value then put it into array24hrs
         //// take MM data and everytime MM value changes, run the calculation
         ////
         //// Get the current local time Date()
         //// let currentLocalTime = Date().description(with: Locale.current)
         
         ///////////////TEST//////////////////////
         print("++++++++++++TEST STARTS++++++++++++++++++")
         //let currentLocalTime = Date().description(with: Locale.current)
         let timeZone = TimeZone.current
         let currentLocalTime = Calendar.current.dateComponents(in: timeZone, from: Date())
         
         // For past 24 hrs
         var endPoint = currentLocalTime.hour! + 1
         var startPoint = endPoint - 24
         print("24hrs startPoint : endPoint = \(startPoint) : \(endPoint)")
         // For past 7 days
         endPoint = currentLocalTime.day! + 1
         startPoint = endPoint - 7
         print("7days startPoint : endPoint = \(startPoint) : \(endPoint)")
         // For past 30 days
         endPoint = currentLocalTime.day! + 1
         startPoint = endPoint - 30
         print("1month startPoint : endPoint = \(startPoint) : \(endPoint)")
         // For past year
         endPoint = currentLocalTime.month! + 1
         startPoint = endPoint - 12
         print("1year startPoint : endPoint = \(startPoint) : \(endPoint)")
         // For All Time
         endPoint = currentLocalTime.year!
         startPoint = 0 // whatever the first element timeStamp value is
         print("alltime startPoint : endPoint = \(startPoint) : \(endPoint)")
         print("++++++++++++TEST ENDS++++++++++++++++++")
         
         */
        
    }
    
    
    
    func populateLocationData(){
        //var resultData: [String]
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        var items = [Location]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        
        let sortDescriptorTypeTime = NSSortDescriptor(key: "locationName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorTypeTime]
        
        do { items = try managedContext?.fetch(fetchRequest) as! [Location]
            for item in items {
                locationArray.append(item.locationName as Any)
            }
        } catch {
            print("Error")
        }
        locationArray.insert("All", at: 0)
        print("locationArray: \(locationArray)")
    }
    
}


extension LineChartViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //return dataSource.count
        return locationArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        //textView.text = locationArray[row] as? String
        locaName = locationArray[row] as? String ?? "All"
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //return dataSource[row]
        return locationArray[row] as? String
    }
}

extension Date {
    func toString(style : DateFormatter.Style) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = style
        return dateFormatter.string(from: self)
    }
    
    
}

