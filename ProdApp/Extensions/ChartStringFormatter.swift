//
//  ChartStringFormatter.swift
//  Organiser
//
//  Created by Permindar LvL on 04/01/2022.
//

import Foundation
import Charts

class ChartStringFormatter: NSObject, IAxisValueFormatter {

    var nameValues: [String]! =  ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return String(describing: nameValues[Int(value)])
    }
}
