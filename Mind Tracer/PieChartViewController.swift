//
//  PieChartViewController.swift
//  Mind Tracer
//
//  Created by Tatsuya Moriguchi on 5/17/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData
import Charts

class PieChartViewController: UIViewController, ChartViewDelegate {
    
    var somArray: [Date] = []
    var average: Int16?
    var rankingDict = [String : Int16]()
    var rankingArray : [(String, Int16)] = []
    
    var causeTypeForPie: [String] = []
    var causeNumberForPie: [Double] = []
    var avgRateDict = [String : Int16]()

    var array4Pie : [(String, Int16)] = []
    
    // Create a dictionary to hold total number of stateOfMindDesc.rate for each causeType
    // to calcurate its average for the specified duration later
    var causeTypeTotalRate: [String: Int16] = [:]
    
    @IBOutlet weak var tableView: UITableView!
    
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    @IBOutlet var pieChartView: PieChartView!
    
    
    @IBAction func hrsOnPressed(_ sender: UIButton) {
        calculateCauseType(timeRangeString: "24hrs")

        let pieChartData = DrawPieChart().customizeChart(dataPoints: causeTypeForPie, values: causeNumberForPie)
        pieChartView.data = pieChartData
    }
    @IBAction func daysOnPressed(_ sender: UIButton) {
        calculateCauseType(timeRangeString: "7days")
        let pieChartData = DrawPieChart().customizeChart(dataPoints: causeTypeForPie, values: causeNumberForPie)
        pieChartView.data = pieChartData
    }
    @IBAction func monthOnPressed(_ sender: UIButton) {
        calculateCauseType(timeRangeString: "1month")
        let pieChartData = DrawPieChart().customizeChart(dataPoints: causeTypeForPie, values: causeNumberForPie)
        pieChartView.data = pieChartData
    }
    @IBAction func yearOnPressed(_ sender: UIButton) {
        calculateCauseType(timeRangeString: "1year")
        let pieChartData = DrawPieChart().customizeChart(dataPoints: causeTypeForPie, values: causeNumberForPie)
        pieChartView.data = pieChartData
    }
    @IBAction func allTimeOnPressed(_ sender: UIButton) {
        calculateCauseType(timeRangeString: "all")
        let pieChartData = DrawPieChart().customizeChart(dataPoints: causeTypeForPie, values: causeNumberForPie)
        pieChartView.data = pieChartData
    }
    
    var centerText = NSLocalizedString("Click a pie slice", comment: "Instruction displayed in the center of a pie chart as default.")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        
        //configureFetchedResultsController(EntityName: "StateOfMind", sortString: "causeType")
        
        pieChartView.centerAttributedText = NSAttributedString(string: centerText)
        pieChartView.delegate = self

    }
    

    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if let dataSet = chartView.data?.dataSets[highlight.dataSetIndex] {
            let sliceIndex: Int = dataSet.entryIndex(entry: entry)
 
            
//             avgRateDict[causeTypeForRanking] = averageRateForType
            let pieSliceCauseType = array4Pie[sliceIndex].0
            // causeTypeTotalRate[itemType!]
            //if let sliceAverageRate = avgRateDict[pieSliceCauseType] {
            
            if let totalRate = causeTypeTotalRate[pieSliceCauseType] {
                let sliceAverageRate = totalRate / array4Pie[sliceIndex].1
                centerText = "\(array4Pie[sliceIndex].0) : \(sliceAverageRate)"
            } else {
                centerText = "\(array4Pie[sliceIndex].0)"
            }

            pieChartView.centerAttributedText = NSAttributedString(string: centerText)
            
        }
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
    
    
    func calculateCauseType(timeRangeString: String) {
        
        
        switch timeRangeString {
        case "24hrs":
            print("24hrs")
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .day, value: -1, to: endDate)
            populateSOMData(startDate: startDate!, endDate: endDate)
            
        case "7days":
            print("7days")
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate)
            
            populateSOMData(startDate: startDate!, endDate: endDate)
            
        case "1month":
            print("1month")
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .month, value: -1, to: endDate)
            
            populateSOMData(startDate: startDate!, endDate: endDate)
            
        case "1year":
            print("1year")
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .year, value: -1, to: endDate)
            
            populateSOMData(startDate: startDate!, endDate: endDate)
            
        default:
            print("default all")
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .year, value: -3, to: endDate)
            populateSOMData(startDate: startDate!, endDate: endDate)
            
        }
    }
    
    func populateSOMData(startDate: Date, endDate: Date){
        
        somArray = []
        average = 0
        
        causeTypeTotalRate = [:]
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        var items : [StateOfMind] = []
        rankingArray = []
        rankingDict = [:]
        
 
        // need to move this fetch line somewere else???
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StateOfMind")
        
        // Predicate fetchRequest for specified time range
        if (startDate != endDate) {
            fetchRequest.predicate = NSPredicate(format: "(timeStamp >= %@) AND (timeStamp < %@)", startDate as CVarArg, endDate as CVarArg)
            
        } else {}
        
        // Sort fetchRequest by causetType.type
        let sortDescriptorTypeTime = NSSortDescriptor(key: "causeType.type", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorTypeTime]
        

        // Create a dictionary to hold total number of stateOfMindDesc.rate for each causeType
        // to calcurate its average for the specified duration later
        //var causeTypeTotalRate: [String: Int16] = [:]

        // Place fetchRequest values into a dictionary, rankingDict[itemType]
        do {
            items = try managedContext?.fetch(fetchRequest) as! [StateOfMind]
            var causeTypeRate: Int16 = 0
            //var totalCauseTypeRate: Int16 = 0

            for item in items {
                let itemType = item.causeType?.type
                if rankingDict[itemType!] == nil { rankingDict[itemType!] = 0 }
                rankingDict[itemType!] = rankingDict[itemType!]! + 1
                
                if causeTypeTotalRate[itemType!] == nil { causeTypeTotalRate[itemType!] = 0}
                causeTypeRate = (item.stateOfMindDesc?.rate)!

//                if itemType == "Work & School" {
//                    print("causeTypeRate: \(causeTypeRate)")
//                }
                causeTypeTotalRate[itemType!] = causeTypeTotalRate[itemType!]! + causeTypeRate

            }
            
            
        } catch { print(error) }

        // Initialize array properties to avoid duplication of causeNumber sum
        // every time pressing a UIButton, i.e. 'Past 24Hrs'
        causeNumberForPie = []
        causeTypeForPie = []
        
        // Converting a dictionary to an array to pass it to DrawPieChart
        for (causeTypeForRanking, causeNumber) in rankingDict {
            rankingArray.append((causeTypeForRanking, causeNumber))
            
            causeTypeForPie.append(causeTypeForRanking)
            causeNumberForPie.append(Double(causeNumber))
            
            // set causeTypeForRanking of 'rankingDict' (not rankingArray)
            // to 0 to avoid unneccesary accumulaiton of the value.
            rankingDict[causeTypeForRanking] = 0
        }
        
        array4Pie = rankingArray
        
        // sort the array by causeNumber $0.1 (not $0.0)
        rankingArray = rankingArray.sorted(by: { $0.1 > $1.1 })

        
        // if no topCauseTypeNow is found in userdefaults for first time using this app
        if rankingArray.count == 0 {
            
            
        } else {
            if UserDefaults.standard.bool(forKey: "preloadedTopCauseType") == false {
                UserDefaults.standard.setValue(true, forKey: "preloadedTopCauseType")
            }
            
            // To save the top cause type to UserDefaults
            // change from top cause type to one with the one with more occurances among the worst three
            // The following is ordered by the occurance only. Get average values
            let top5 = rankingArray.prefix(5)
            
            var bottom5Rate: [String:Int16] = [:]
            for item in top5 {
                let avg = causeTypeTotalRate[item.0]! / item.1
//                print("avg: \(avg)")
                bottom5Rate[item.0] = avg
            }
//            print("bottom5Rate: \(bottom5Rate)")
            
            let bottom5 = bottom5Rate.sorted(by: { $0.1 < $1.1 })
//            print("bottom5: \(bottom5)")

            let firstSOM = bottom5.first
//            print("firstSOM: \(firstSOM)")
            let (type4Today, _) = firstSOM!
            causeType4Wisdom(topCauseTypeNow: type4Today)
            
        }
        
        
        tableView.reloadData()
        
    }

    func causeType4Wisdom(topCauseTypeNow: String) {
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(topCauseTypeNow, forKey: "topCauseType")
        //print("*********topCauseTypeNow")
        //print(topCauseTypeNow)
        
    }




}

extension PieChartViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rankingArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CauseRankCell", for: indexPath)
        
        let (causeTypeForRanking, causeNumber) = rankingArray[indexPath.row]
        cell.textLabel?.text =  causeTypeForRanking
        //cell.detailTextLabel?.text = String(causeNumber)
        
        let averageRateForType = causeTypeTotalRate[causeTypeForRanking]! / causeNumber
        
        cell.detailTextLabel?.text = NSLocalizedString("Average: ", comment: "tableView cell detailTextLabel followed by avarage number") + (String(averageRateForType))

        avgRateDict[causeTypeForRanking] = averageRateForType
        
        return cell
    }
    
}
