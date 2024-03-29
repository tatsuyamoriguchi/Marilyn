//
//  LineChartViewController.swift
//  Mind Tracer
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
    var averageRateArray: [Double] = [] // = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    
    @IBOutlet weak var LocationPicker: UIPickerView!

    @IBOutlet var lineChartView: LineChartView!

    
    @IBAction func hrsOnPressed(_ sender: UIButton) {
        // Clear lneChartView.data
        lastDuration = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        averageRateArray = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        calculateRate(timeRangeString: "24hrs")
        let stringlastDuration = lastDuration.map { String($0)}
        mockupDisplay(dataPoints: stringlastDuration, values: averageRateArray)
    }
    
    @IBAction func daysOnPressed(_ sender: UIButton) {
        lastDuration = [0,0,0,0,0,0,0]
        averageRateArray = [0,0,0,0,0,0,0]

        calculateRate(timeRangeString: "7days")
        let stringlastDuration = lastDuration.map { String($0)}
        mockupDisplay(dataPoints: stringlastDuration, values: averageRateArray)
        print("stringlastDuration: \(stringlastDuration)")
        print("averageRateArray: \(averageRateArray)")
        
    }
    
    @IBAction func monthOnPressed(_ sender: UIButton) {
        lastDuration = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        averageRateArray = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

        calculateRate(timeRangeString: "1month")
        let stringlastDuration = lastDuration.map { String($0)}
        mockupDisplay(dataPoints: stringlastDuration, values: averageRateArray)
    }
    
    @IBAction func yearOnPressed(_ sender: UIButton) {
        lastDuration = [0,0,0,0,0,0,0,0,0,0,0,0]
        averageRateArray = [0,0,0,0,0,0,0,0,0,0,0,0]
        
        calculateRate(timeRangeString: "1year")
        let stringlastDuration = lastDuration.map { String($0)}
        mockupDisplay(dataPoints: stringlastDuration, values: averageRateArray)
    }
    
    @IBAction func allTimeOnPressed(_ sender: UIButton) {
        
//        let lastDuration: [Int] = [0,0,0,0]
//        let averageRateArray: [Double] = [0,0,0,0]
        lastDuration = [0,0,0,0]
        averageRateArray = [0,0,0,0]

        
        calculateRate(timeRangeString: "all")
        let stringlastDuration = lastDuration.map { String($0)}
        mockupDisplay(dataPoints: stringlastDuration, values: averageRateArray)
    }
    
    func mockupDisplay(dataPoints: [String], values: [Double]) {
        
        // 1. Set ChartDataEntry
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
        

            dataEntries.append(dataEntry)
        }
        
        print("dataEntries: \(dataEntries)")

        
        // 2. Set ChartDataSet
        let lineChartDataSet = LineChartDataSet(entries: dataEntries, label: NSLocalizedString("Average Rates of Your Mind of State", comment: "Line chart index name"))
 
        // 3. Set ChartData
        let lineChartData = LineChartData(dataSet: lineChartDataSet)

        lineChartDataSet.colors = [UIColor.white]
        lineChartDataSet.circleRadius = 2.0
        lineChartDataSet.circleColors = [UIColor.darkGray]
        lineChartDataSet.valueFont = UIFont(name: "Helvetica", size: 14.0)!
        
        lineChartDataSet.mode = .cubicBezier
        lineChartDataSet.cubicIntensity = 0.1
        
        //lineChartView.leftAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        lineChartView.leftAxis.granularity = 1
        
        // 4. Assign it to the chart's data
        lineChartView.data = lineChartData
        self.lineChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
    }
    
    
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
        // Sort fetche data by timeStamp.
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
            print("endDate: \(endDate)")
            let startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate)
            print("startDate: \(startDate)")
            populateSOMData(startDate: startDate!, endDate: endDate, selectedLocationName: locaName!, duration: "7days")
            
            
        case "1month":
            print("1month")
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .day, value: -30, to: endDate)
            print("endDate: \(endDate)")
            print("startDate: \(startDate)")
            populateSOMData(startDate: startDate!, endDate: endDate, selectedLocationName: locaName!, duration: "1month")
            
        case "1year":
            print("1year")
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .month, value: -12, to: endDate)
            
            populateSOMData(startDate: startDate!, endDate: endDate, selectedLocationName: locaName!, duration: "1year")
            
        case "all":
            print("all")
            let endDate = Date()
            // Get the olderst data year and calculate how many year is to be set for 'value' for Calendar.current.date()
            // How to get the first element
            let startDate = Calendar.current.date(byAdding: .year, value: -3, to: endDate)

            populateSOMData(startDate: startDate!, endDate: endDate, selectedLocationName: locaName!, duration: "all")

        default:
            print("Something wrong went at timeRangeString switch.")
        }
    }
    
    
    func populateSOMData(startDate: Date, endDate: Date, selectedLocationName: String, duration: String){
        
        somArray = []
        average = 0
        
        //var countNum: Int = 0
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
 
        
        var items = [StateOfMind]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StateOfMind")
        
        if (selectedLocationName != "All") && (startDate != endDate) {
            // For a specific locaiton and for a specific range of period
            //fetchRequest.predicate = NSPredicate(format: "(timeStamp >= %@) AND (timeStamp < %@)", startDate as CVarArg, endDate as CVarArg)
            fetchRequest.predicate = NSPredicate(format: "(location.locationName == %@) AND (timeStamp > %@) AND (timeStamp <= %@)", selectedLocationName, startDate as CVarArg, endDate as CVarArg)
            
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
   
        

        var array4Duration: [Int] = []
        var somCountPerUnit: [Int] = []

        var calendar = Calendar.current
        ///
        calendar.timeZone = .current
        ///
        let currentDate = Date()
        var currentTime: Int = 0
        var n: Int = 0
        
        
        ///////////////////////////////////////////////////////////////////////////
        switch duration {
        case "24hrs":
            print("24hrs")
            //getlastDuration()
            array4Duration = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
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
            array4Duration = [0,0,0,0,0,0,0]
            somCountPerUnit = [0,0,0,0,0,0,0]
            
            currentTime = calendar.component(.day, from: currentDate)
            print("currentTime: \(currentTime)")

            n = 6
            
            for i in (0...n) {
                
                let dayValue = calendar.date(byAdding: .day, value: i - 6, to: currentDate)!
                lastDuration[i] = calendar.component(.day, from: dayValue)
                
            }
            
            print("******lastDuration********")
            print(lastDuration)
            
        case "1month":
            print("1month")
            array4Duration = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
            somCountPerUnit = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
            
            currentTime = calendar.component(.day, from: currentDate)
            print("currentTime: \(currentTime)")
            
            n = 29
            
            for i in (0...n) {
                
                let dayValue = calendar.date(byAdding: .day, value: i - 29, to: currentDate)!
                lastDuration[i] = calendar.component(.day, from: dayValue)
                
            }
            
            print("******lastDuration********")
            print(lastDuration)
        case "1year":
            print("1year")
            array4Duration = [0,0,0,0,0,0,0,0,0,0,0,0]
            somCountPerUnit = [0,0,0,0,0,0,0,0,0,0,0,0]
            
            currentTime = calendar.component(.month, from: currentDate)
            print("currentTime: \(currentTime)")
            
            n = 11
            
            for i in (0...n) {
                
                let dayValue = calendar.date(byAdding: .month, value: i - 11, to: currentDate)!
                lastDuration[i] = calendar.component(.month, from: dayValue)
                
            }
            
            print("******lastDuration********")
            print(lastDuration)


        default:
            print("default all")
            array4Duration = [0,0,0,0]
            somCountPerUnit = [0,0,0,0]
            
            currentTime = calendar.component(.year, from: currentDate)
            print("currentTime: \(currentTime)")
            
            n = 3
            
            for i in (0...n) {
                
                let dayValue = calendar.date(byAdding: .year, value: i - 3, to: currentDate)!
                lastDuration[i] = calendar.component(.year, from: dayValue)
                
            }
            
            print("******lastDuration********")
            print(lastDuration)

        }

        
        
        do { items = try managedContext?.fetch(fetchRequest) as! [StateOfMind]
            for item in items {
                somArray.append(item.timeStamp!)
                
                //////TEST code to fill array4Duration with the average number of rates
                ////// each element represents an hour unit, 0 for 24 hours before, 1 for 23 hours before...
                ////// this is to create a line chart for last 24 hours. Not for 7 days and else.
                let date = item.timeStamp
                print("date: \(date)")
                
                
                
                switch duration {
                case "24hrs":
                    
                    // Get hour number from date which is fetched StateOfMind data
                    ////// change 'hour' to day for 7 days and 1 month, month for 1 year, and year for All
                    
                    let currentDay = calendar.component(.day, from: currentDate)
                    print("currentDay: \(currentDay)")
                    
                    print("date: \(date!)")
                    let hour = calendar.component(.hour, from: date!)
                    let day = calendar.component(.day, from: date!)
                    print("data day - hour: \(day) - \(hour)")
                    
                    // To avoid an error Cannot assign Int type with Int16 type
                    
                    var rate: Int16
                    rate = item.stateOfMindDesc?.rate ?? 0
                    
                    var elemNum = hour - currentTime + 23
                    if elemNum >= 24 { elemNum = elemNum - 24 }
                    
                    print("elemNum: \(elemNum)")
                    
                    
                    if day < currentDay && hour == currentTime {
    
                        print("The same hour but a day before data was detected [ date: \(date) hour: \(hour) elemNum: \(elemNum) ] ")
                    
                    } else {
                        array4Duration[elemNum] += Int(rate)
                        somCountPerUnit[elemNum] += 1
                    }
                    
                    
                case "7days":

                    var rate: Int16
                    rate = item.stateOfMindDesc?.rate ?? 0
                    
                    var calendar = Calendar.current
                    calendar.timeZone = .current
                    let components = calendar.dateComponents([.day], from: date!)
                    
                    let currentDay = calendar.component(.day, from: currentDate)
                    print("currentDay: \(currentDay)")
                    let currentDateInt = Int(currentDay)
                    
                    
                    let localDateDay = components.day
                    print("localDateDay: \(localDateDay)")
                    
                    // Since the fetch duration is 24 horus x 7 days and today is 8/26, the code fetches data
                    // from 8/19 - 8/26 depending on the time of a day that you fetched.
                    // 8/19 data produces gurad let statement error since lastDuration doesn't have 19
                    // it lists from 20 (26 - 6).
                    // To avoid this error, the following if statement checks if localDateDay is 8/20 - 8/26,
                    // not 8/19 data.
                    if localDateDay! >=  currentDateInt - 6 {
                        guard let elemNum = lastDuration.firstIndex(of: localDateDay!) else {
                            print("Error at guard let elemNum")
                            return }
                        
                        
                        print("elemNum: \(elemNum)")
                        
                        array4Duration[elemNum] += Int(rate)
                        somCountPerUnit[elemNum] += 1
                        
                    } else { print("Out of range day data was detected at if localDateDay! >= currentDateInt - 6 statement. localDateDay: \(localDateDay) currentDateInt - 6 : \(currentDateInt - 6)") }
                case "1month":

                    var rate: Int16
                    rate = item.stateOfMindDesc?.rate ?? 0
                   
                    
                    calendar.timeZone = .current
                    let components = calendar.dateComponents([.day], from: date!)
                    let localDateDay = components.day
                    print("localDateDay: \(localDateDay)")
                    guard let elemNum = lastDuration.firstIndex(of: localDateDay!) else {
                        print("Error at guard let elemNum")
                        return }
                    print("elemNum: \(elemNum)")
                    
                    array4Duration[elemNum] += Int(rate)
                    somCountPerUnit[elemNum] += 1
                    
                case "1year":
                    // Get day number from date which is fetched StateOfMind data
                    let month = calendar.component(.month, from: date!)
                    let currentMonth = calendar.component(.month, from: currentDate)
                    
                    var diff: Int
                    if currentMonth >= month { diff = currentMonth - month } else {
                        diff = currentMonth - month + 12
                    }
                    
                    let elemNum = 11 - diff
                    
                    print("month: \(month)")
                    print("currentMonth: \(currentMonth)")
                    print("diff: \(diff)")
                    print("elemNum: \(elemNum)")
                    
                    
                    var rate: Int16
                    rate = item.stateOfMindDesc?.rate ?? 0
                    
//                    print("date: \(date)")
//                    var elemNum = Calendar.current.dateComponents([.month], from: currentDate, to: date!).month
//                    print("pre-elemNum: \(elemNum)")
//                    elemNum = 11 - elemNum!
//                    print("post-elemNum: \(elemNum)")
                    
                    array4Duration[elemNum] += Int(rate)
                    somCountPerUnit[elemNum] += 1
                    
                case "all":
                    // Get day number from date which is fetched StateOfMind data
                    let year = calendar.component(.year, from: date!)
                    
                    print("year: \(year)")
                    var rate: Int16
                    rate = item.stateOfMindDesc?.rate ?? 0
                    
                    var elemNum = Calendar.current.dateComponents([.year], from: date!, to: currentDate).year
                    elemNum = 3 - elemNum!
                    
                    array4Duration[elemNum!] += Int(rate)
                    somCountPerUnit[elemNum!] += 1
                    
                default:
                    print("Something went wrong at switch condition of duration")
                }
            }
            
            
            
        } catch {
            print("Error")
        }

        
        
        // /////////////////////////////////////////////////////////
        // sum up the adjective rate data of each somArray elements
        let sum = items.reduce(0, {$0 + ($1.stateOfMindDesc?.rate)!})
        
        if items.count > 0 {
            average = sum/Int16(items.count)
        } else { print("No data to calculate found.") }
        
        /////////
        // Place each average rate to each hour
        var arrayIndex = 0
        for i in array4Duration {
            if i != 0 {
                
                let average = i/somCountPerUnit[arrayIndex]
                averageRateArray[arrayIndex] = Double(average)
                
            }
            arrayIndex += 1
        }
    }
    
    func populateLocationData(){
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
    }
    
}


extension LineChartViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    
        return locationArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        locaName = locationArray[row] as? String ?? NSLocalizedString("All", comment: "Default value to location name for line chart.")
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return locationArray[row] as? String
    }
}

extension Date {
    func toString(style : DateFormatter.Style) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = style
        return dateFormatter.string(from: self)
    }
    
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }
        return end - start
    }
    
}

