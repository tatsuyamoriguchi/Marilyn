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
    
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var locationArray: [Any] = []
    var somArray: [Date] = []
    var locaName: String? = "All"
    var average: Int16?
    
    var lastDuration: [Int] = [] // = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    var average24hrs: [Double] = [] // = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    
    @IBOutlet weak var LocationPicker: UIPickerView!
    
    
    @IBAction func hrsOnPressed(_ sender: UIButton) {
        // Clear lneChartView.data
        lastDuration = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        average24hrs = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        calculateRate(timeRangeString: "24hrs")
        let stringlastDuration = lastDuration.map { String($0)}
        mockupDisplay(dataPoints: stringlastDuration, values: average24hrs)
    }
    
    @IBAction func daysOnPressed(_ sender: UIButton) {
        lastDuration = [0,0,0,0,0,0,0]
        average24hrs = [0,0,0,0,0,0,0]

        calculateRate(timeRangeString: "7days")
        let stringlastDuration = lastDuration.map { String($0)}
        mockupDisplay(dataPoints: stringlastDuration, values: average24hrs)
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

            populateSOMData(startDate: startDate!, endDate: endDate, selectedLocationName: locaName!, duration: "24hrs")
            
        case "7days":
            print("7days")
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate)
            
            populateSOMData(startDate: startDate!, endDate: endDate, selectedLocationName: locaName!, duration: "7days")
            
        case "1month":
            print("1month")
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .month, value: -1, to: endDate)
            
            populateSOMData(startDate: startDate!, endDate: endDate, selectedLocationName: locaName!, duration: "1month")
            
        case "1year":
            print("1year")
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .year, value: -1, to: endDate)
            
            populateSOMData(startDate: startDate!, endDate: endDate, selectedLocationName: locaName!, duration: "1year")
            
        default:
            print("default all")
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .year, value: 0, to: endDate)
            populateSOMData(startDate: startDate!, endDate: endDate, selectedLocationName: locaName!, duration: "all")
            
        }
    }
    
    
    func populateSOMData(startDate: Date, endDate: Date, selectedLocationName: String, duration: String){
        
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
        
        
        var array24hrs: [Int] = []
        var somCountPerUnit: [Int] = []

        let calendar = Calendar.current
        let currentDate = Date()
        var currentTime: Int = 0
        var n: Int = 0
        
        
        ///////////////////////////////////////////////////////////////////////////
        switch duration {
        case "24hrs":
            print("24hrs")
            //getlastDuration()
            array24hrs = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
            somCountPerUnit = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
            
            currentTime = calendar.component(.hour, from: currentDate)
            print("currentTime: \(currentTime)")
            
            n = 23

            
            for i in (0...n) {
                lastDuration[i] = currentTime + 1 + i
                if lastDuration[i] >= 24 { lastDuration[i] = lastDuration[i] - 24 }
            }
            
        case "7days":
            print("7days")
            array24hrs = [0,0,0,0,0,0,0]
            somCountPerUnit = [0,0,0,0,0,0,0]
            
            currentTime = calendar.component(.day, from: currentDate)
            print("currentTime: \(currentTime)")

            n = 6
            
            for i in (0...n) {
                
                let dayValue = calendar.date(byAdding: .day, value: -6 + i, to: currentDate)!
                lastDuration[i] = calendar.component(.day, from: dayValue)
                
            }
            
            print("******lastDuration********")
            print(lastDuration)
            
        case "1month":
            print("1month")
            array24hrs = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
            somCountPerUnit = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
            
            currentTime = calendar.component(.day, from: currentDate)
            print("currentTime: \(currentTime)")
            
            n = 6
            
            for i in (0...n) {
                
                let dayValue = calendar.date(byAdding: .day, value: -6 + i, to: currentDate)!
                lastDuration[i] = calendar.component(.day, from: dayValue)
                
            }
            
            print("******lastDuration********")
            print(lastDuration)
        case "1year":
            print("1year")
        default:
            print("default all")
        }

        
        
        do { items = try managedContext?.fetch(fetchRequest) as! [StateOfMind]
            for item in items {
                somArray.append(item.timeStamp!)
                
                print("item.location.locationName: \(item.location?.locationName)")
                print("item.stateOfMindDesc.rate: \(item.stateOfMindDesc?.rate)")
                
                //////TEST code to fill array24hrs with the average number of rates
                ////// each element represents an hour unit, 0 for 24 hours before, 1 for 23 hours before...
                ////// this is to create a line chart for last 24 hours. Not for 7 days and else.
                let date = item.timeStamp
                
                
                switch duration {
                case "24hrs":
                    
                    // Get hour number from date which is fetched StateOfMind data
                    ////// change 'hour' to day for 7 days and 1 month, month for 1 year, and year for All
                    let hour = calendar.component(.hour, from: date!)
                    
                    print("hour: \(hour)")
                    //              array24hrs.insert(Int((item.stateOfMindDesc?.rate)!), at: hour)
                    // To avoid an error Cannot assign Int type with Int16 type
                    var rate: Int16
                    rate = item.stateOfMindDesc?.rate ?? 0
                    
                    //let elemNum = 23 - currentTime + hour
                    var elemNum = hour - currentTime + 23
                    if elemNum >= 24 { elemNum = elemNum - 24 }
                    
                    //array24hrs[hour] += Int(rate)
                    array24hrs[elemNum] += Int(rate)
                    //somCountPerUnit[hour] += 1
                    somCountPerUnit[elemNum] += 1
                    
                    
                case "7days":
                    // Get day number from date which is fetched StateOfMind data
                    let day = calendar.component(.day, from: date!)
                    
                    print("day: \(day)")
                    var rate: Int16
                    rate = item.stateOfMindDesc?.rate ?? 0
                    
                    var elemNum = Calendar.current.dateComponents([.day], from: date!, to: currentDate).day
                    elemNum = 6 - elemNum!
                    
                    //array24hrs[hour] += Int(rate)
                    array24hrs[elemNum!] += Int(rate)
                    //somCountPerUnit[hour] += 1
                    somCountPerUnit[elemNum!] += 1
                case "1month":
                    print("")
                case "1year":
                    print("")
                default:
                    print("Default All")
                }
            }
            
                
            
        } catch {
            print("Error")
        }
        print("******somArray")
        print(somArray)
        
        print("******array24hrs")
        print(array24hrs)
        
        
        
        
    //}
            
        
        
        // /////////////////////////////////////////////////////////
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

