//
//  PieChartViewController.swift
//  Marilyn
//
//  Created by Tatsuya Moriguchi on 5/17/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData
import Charts

class PieChartViewController: UIViewController {
    
    var somArray: [Date] = []
    var average: Int16?
    var rankingDict = [String : Int16]()
    var rankingArray : [(String, Int16)] = []
    
    var causeTypeForPie: [String] = []
    var causeNumberForPie: [Double] = []
    
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //configureFetchedResultsController(EntityName: "StateOfMind", sortString: "causeType")
        
      
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
        
        //configureFetchedResultsController(EntityName: "StateOfMind", sortString: "timeStamp")
        
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
        do { items = try managedContext?.fetch(fetchRequest) as! [StateOfMind]
            var causeTypeRate: Int16 = 0
            //var totalCauseTypeRate: Int16 = 0

            for item in items {
                let itemType = item.causeType?.type
                if rankingDict[itemType!] == nil { rankingDict[itemType!] = 0 }
                rankingDict[itemType!] = rankingDict[itemType!]! + 1
                
                // Summing item.stateOfMindDesc.rate
                //causeTypeTotalRate[itemType!] = item.stateOfMindDesc?.rate
                //print("*******item.stateOfMindDesc?.rate for \(itemType)")
                //print(item.stateOfMindDesc?.rate)
                
                if causeTypeTotalRate[itemType!] == nil { causeTypeTotalRate[itemType!] = 0}
                causeTypeRate = (item.stateOfMindDesc?.rate)!
                causeTypeTotalRate[itemType!] = causeTypeTotalRate[itemType!]! + causeTypeRate
                //print("*********Total Rate for \(itemType)")
                //print(causeTypeTotalRate[itemType!])
                //print("")
                

            }
            
            print("*********causeTypeTotalRate")
            print(causeTypeTotalRate)

            
        } catch { print(error) }
        print("++++++++rankingDict+++++++")
        print(rankingDict)

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
        
        // sort the array by causeNumber $0.1 (not $0.0)
        rankingArray = rankingArray.sorted(by: { $0.1 > $1.1 })
        
        print("++++++++rankingArray+++++++")
        print(rankingArray)
        
        tableView.reloadData()
        
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
        
        cell.detailTextLabel?.text = "Average Rate: \(String(averageRateForType))"

        print("***********causeTypeTotalRate[\(causeTypeForRanking)]")
        print(causeTypeTotalRate[causeTypeForRanking])
        print("")
        
        return cell
    }
}
