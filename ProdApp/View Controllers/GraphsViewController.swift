//
//  GraphsViewController.swift
//  ProdApp
//
//  Created by Permindar LvL on 27/08/2021.
//

import UIKit
import Charts
import CoreData

class GraphsViewController: UIViewController, ChartViewDelegate {
    
    var selectedWeek: Week?
    
    var showActivities = true
    
    var showWeek = true
    var showMonth = false
    var showYear = false
    
    var callbackClosure: (() -> Void)?

    @IBOutlet var switchButton: UISegmentedControl!
    
    
    @IBOutlet var pieChart: PieChartView!
    
    @IBOutlet var tagLabel: UILabel!
    
    @IBOutlet var noDataLabel: UILabel!
    
    struct tagValue {
        var name = ""
        var count = 0
        var background = UIColor.white
        var highlight = UIColor.white
    }
    
    var tagValues = [tagValue]()
    
    var tagCounts = [Int]()
    var tagNames = [String]()
    
    var activityCounts = [String: Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //makes sure it is presented over context
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        view.isOpaque = false
        
        pieChart.delegate = self
        pieChart.drawEntryLabelsEnabled = false
        pieChart.usePercentValuesEnabled = true
        pieChart.drawHoleEnabled = false
        pieChart.legend.enabled = false
        
        tagLabel.text = ""
        
    }
    
    override func viewWillAppear(_ animated: Bool) { 
        makeThePieChart()
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        pieChart.highlightValue(nil)
        tagLabel.text = ""
        switch switchButton.selectedSegmentIndex {
        case 0:
            showActivities = true
            makeThePieChart()
        case 1:
            showActivities = false
            makeThePieChart()
        default:
            break
        }
    }
    
    func makeThePieChart() {
        tagValues.removeAll()
            
        let activities = selectedWeek?.totalActivities?.sortedArray(using: [NSSortDescriptor(key: "time", ascending: true)]) as? [Activity]
            
        if showActivities {
                //Collecting the attributes to use
            for tag in tags {
                tagValues.append(tagValue(name: tag.activityType, background: tag.background ?? UIColor.white, highlight: tag.highlight ?? UIColor.white))
            }

            //Count up all the tag values
            activities?.forEach { activity in
                for i in 0..<tags.count {
                    if activity.type == tags[i].activityType || activity.goal?.goalTag == tags[i].activityType {
                        tagValues[i].count += 1
                    }
                }
            }
        } else {
            if let goals = selectedWeek?.goals?.sortedArray(using: [NSSortDescriptor(key: "timeCreated", ascending: true)]) as? [Goal] {
                for goal in goals {
                    tagValues.append(tagValue(name: goal.name ?? "", background: goal.backgroundColour ?? UIColor.white, highlight: goal.highlightColour ?? UIColor.white))
                }
                    
                activities?.forEach( { activity in
                    for i in 0..<goals.count {
                        if activity.goal == goals[i] {
                            tagValues[i].count += 1
                        }
                    }
                })
            }
        }
        
        //Get rid of any '0' values
        tagValues = tagValues.filter({ $0.count != 0 })

        if tagValues.count == 0 {
            noDataLabel.isHidden = false
        } else {
            noDataLabel.isHidden = true
        }
        
        customizeChart(dataPoints: tagValues.map { $0.name }, values: tagValues.map{ Double($0.count) } )
        
        pieChart.animate(xAxisDuration: 1.0, easingOption: .easeOutSine)
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let dataSet = pieChart.data?.dataSets[highlight.dataSetIndex] else { return }
        let entryIndex = dataSet.entryIndex(entry: entry)
        
        //Creating a two-colour label
        let attrs1 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17.5), NSAttributedString.Key.foregroundColor : tagValues[entryIndex].background]
        let attrs2 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : tagValues[entryIndex].highlight]

        let attributedString1 = NSMutableAttributedString(string: "\(tagValues[entryIndex].name): ", attributes: attrs1)
        let attributedString2 = NSMutableAttributedString(string:  "\(tagValues[entryIndex].count)", attributes: attrs2)

        attributedString1.append(attributedString2)
        tagLabel.attributedText = attributedString1
        
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        tagLabel.text = ""
    }
    
    func customizeChart(dataPoints: [String], values: [Double]) {
        //1. Set ChartDataEntry
        var dataEntries = [ChartDataEntry]()
        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i], data: dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry)
        }
        
        //2. Set ChartDataSet
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
        pieChartDataSet.valueFont = UIFont.boldSystemFont(ofSize: 16)
        pieChartDataSet.colors = tagValues.map( { $0.highlight })

        //3. Set ChartData
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let format = NumberFormatter()
        format.numberStyle = .percent
        format.maximumFractionDigits = 1
        format.multiplier = 1.0
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFormatter(formatter)
        
        // 4. Assign it to the chart's data
        pieChart.data = pieChartData
    }
    
    @IBAction func dismissView(_ sender: UIButton) {
        callbackClosure?()
        dismiss(animated: true)
    }
}
