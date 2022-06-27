//
//  DayAxisValueFormatter.swift
//  Organiser
//
//  Created by Permindar LvL on 28/01/2022.
//

import Foundation
import Charts

public class DayAxisValueFormatter: NSObject, IAxisValueFormatter {
    weak var chart: BarLineChartViewBase?
    let days = ["M", "T", "W", "T", "F", "S", "S"]
    
    init(chart: BarLineChartViewBase) {
        self.chart = chart
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value)
        return days[index]
    }
}
