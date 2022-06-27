//
//  BarChartViewController.swift
//  Organiser
//
//  Created by Permindar LvL on 27/01/2022.
//

import UIKit
import Charts
import CoreData

class BarChartViewController: UIViewController, ChartViewDelegate {
    
    let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    @IBOutlet var noDataLabel: UILabel!
    
    @IBOutlet var barChart: BarChartView!
    
    @IBOutlet var correspondingLabel: UILabel!
    
    var callbackClosure: (() -> Void)?
    var showTabBar: (() -> Void)?
    var moveToSecondTab: (() -> Void)?
    
    var selectedWeek: Week?
    
    var showWeek = true
    var showMonth = false
    var showYear = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        correspondingLabel.text = ""
        
        noDataLabel.isHidden = true
        
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        view.isOpaque = false
        
        barChart.delegate = self
        barChart.borderLineWidth = 20
        barChart.doubleTapToZoomEnabled = false
        
        //X-Axis stuff
        let xAxis = barChart.xAxis
        xAxis.drawGridLinesEnabled = false
        xAxis.granularity = 1
        xAxis.labelPosition = .bottom
        xAxis.valueFormatter = DayAxisValueFormatter(chart: barChart)
        xAxis.labelFont = UIFont.systemFont(ofSize: 12)
        
        //Y-Axis stuff
        let yAxis = barChart.leftAxis
        barChart.rightAxis.enabled = false
        yAxis.drawGridLinesEnabled = false
        yAxis.granularityEnabled = true
        yAxis.granularity = 1
        yAxis.axisMinimum = 0
        yAxis.axisMaximum = 5
        yAxis.labelFont = UIFont.systemFont(ofSize: 12)
        
        barChart.legend.enabled = false
        
        makeTheBarChart()

    }
    
    func makeTheBarChart() {
        var dataEntries = [ChartDataEntry]()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        if var date = selectedWeek?.startDate {
            for i in 0..<7 {
                if let days = selectedWeek?.days?.sortedArray(using: [NSSortDescriptor(key: "date", ascending: true) ]) as? [Day] {                    
                    let currentDay = days.filter( { $0.date == dateFormatter.string(from: date) }).first
                    
                    var score = 0.0
                    
                    if let activities = currentDay?.completedActivities?.sortedArray(using: [NSSortDescriptor(key: "time", ascending: true)]) as? [Activity] {
                            
                        var totalPoints = 0
                        //Only include ones which have activity
                        let filteredActivities = activities.filter( { $0.productivity != "0" && $0.productivity != nil })
                        filteredActivities.forEach({ totalPoints += Int($0.productivity ?? "0") ?? 0})
  
                        if filteredActivities.count != 0 {
                            score = Double(totalPoints) / Double(filteredActivities.count)
                        }
                    }
                    
                    let dataEntry = BarChartDataEntry(x: Double(i), y: score)
                    dataEntries.append(dataEntry)
                    
                    let calendar = Calendar.current
                    date = calendar.date(byAdding: .day, value: 1, to: date) ?? Date()
                }
            }
        }
        
        if dataEntries.count == 0 {
            noDataLabel.isHidden = false
            barChart.isHidden = true
        } else {
            noDataLabel.isHidden = true
            barChart.isHidden = false
        }
        
        let chartDataSet = BarChartDataSet(dataEntries)
        chartDataSet.colors = [UIColor(named: "NavyB")!]
        chartDataSet.drawValuesEnabled = false
        let chartData = BarChartData(dataSet: chartDataSet)
        barChart.data = chartData
        
        barChart.animate(yAxisDuration: 1.0, easingOption: .easeInOutSine)
        
        
//
//        if let days = selectedWeek?.days?.sortedArray(using: [NSSortDescriptor(key: "date", ascending: true)]) as? [Day] {
//            for (index, day) in days.enumerated() {
//                if let activities = day.completedActivities?.sortedArray(using: [NSSortDescriptor(key: "time", ascending: true)]) as? [Activity] {
//
//                    var totalPoints = 0
//                    //Only include ones which have activity
//                    let filteredActivities = activities.filter( { $0.productivity != "0"})
//                    filteredActivities.forEach({ totalPoints += Int($0.productivity ?? "0") ?? 0})
//
//                    var score = 0.0
//                    if filteredActivities.count != 0 {
//                        score = Double(totalPoints) / Double(filteredActivities.count)
//                    }
//
//                    let dataEntry = BarChartDataEntry(x: Double(index), y: score)
//                    dataEntries.append(dataEntry)
//                }
//            }
//
//
//        }
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let dataSet = barChart.data?.dataSets[highlight.dataSetIndex] else { return }
        let entryIndex = dataSet.entryIndex(entry: entry)
        
        //Creating the label
        if entry.y != 0.0 {
            correspondingLabel.text = "\(weekdays[entryIndex]): \(String(format: "%.1f", entry.y))"
        } else {
            correspondingLabel.text = ""
        }
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        correspondingLabel.text = ""
    }

    @IBAction func dismissView(_ sender: UIButton) {
        showTabBar?()
        dismiss(animated: true, completion: nil)
    }
}
