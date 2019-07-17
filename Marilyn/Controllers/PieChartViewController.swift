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
    var rankingDict = [String : Int]()
    var rankingArray : [(String, Int)] = []
    
    var causeTypeForPie: [String] = []
    var causeNumberForPie: [Double] = []
    

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
        
        configureFetchedResultsController(EntityName: "StateOfMind", sortString: "timeStamp")
        
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
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        var items : [StateOfMind] = []
        rankingArray = []
        
 
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StateOfMind")
        
        
        if (startDate != endDate) {
            fetchRequest.predicate = NSPredicate(format: "(timeStamp >= %@) AND (timeStamp < %@)", startDate as CVarArg, endDate as CVarArg)
            
        } else {}
        
        let sortDescriptorTypeTime = NSSortDescriptor(key: "causeType.type", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorTypeTime]
        
        
        do { items = try managedContext?.fetch(fetchRequest) as! [StateOfMind]

            for item in items {
                let itemType = item.causeType?.type
                if rankingDict[itemType!] == nil { rankingDict[itemType!] = 0 }
                rankingDict[itemType!] = rankingDict[itemType!]! + 1
            }
            
        } catch { print(error) }
        print("++++++++rankingDict+++++++")
        print(rankingDict)

        causeNumberForPie = []
        causeTypeForPie = []
        
        for (causeTypeForRanking, causeNumber) in rankingDict {
            rankingArray.append((causeTypeForRanking, causeNumber))
            
            causeTypeForPie.append(causeTypeForRanking)
            causeNumberForPie.append(Double(causeNumber))
            
            // set causeTypeForRanking of 'rankingDict' (not rankingArray)
            // to 0 to avoid unneccesary accumulaiton of the value.
            rankingDict[causeTypeForRanking] = 0
        }
        
        // sort the array by causeNumber
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
        cell.detailTextLabel?.text = String(causeNumber)
        return cell
    }
}
