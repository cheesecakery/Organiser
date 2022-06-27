//
//  extensions.swift
//  ProdApp
//
//  Created by Permindar LvL on 29/08/2021.
//

import Foundation
import UIKit
import CoreData

extension Int {
    func roundedDown(toMultipleOf m: Self) -> Self {
        return (self < 0) ? self.roundedAwayFromZero(toMultipleOf: m)
                      : self.roundedTowardZero(toMultipleOf: m)
    }
  
    func roundedUp(toMultipleOf m: Self) -> Self {
        return (self > 0) ? self.roundedAwayFromZero(toMultipleOf: m)
                      : self.roundedTowardZero(toMultipleOf: m)
    }

    func timeToString() -> String {
        let hours = (self / 60).roundedDown(toMultipleOf: 1)
        let minutes = self % 60
        
        if hours == 0 {
            return "\(minutes) mins"
        } else {
            if minutes == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h \(minutes)"
            }
        }
    }
    
    func roundedTowardZero(toMultipleOf m: Self) -> Self {
        return self - (self % m)
    }
  
    func roundedAwayFromZero(toMultipleOf m: Self) -> Self {
        let x = self.roundedTowardZero(toMultipleOf: m)
        if x == self { return x }
        return (m.signum() == self.signum()) ? (x + m) : (x - m)
    }
  
}

// MARK: -

extension Date {
    func dateToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
    
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
        
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    
    func startOfYear() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year], from: Calendar.current.startOfDay(for: self)))!
    }
        
    func endOfYear() -> Date {
        return Calendar.current.date(byAdding: DateComponents(year: 1, day: -1), to: self.startOfYear())!
    }
    
    func secondsSinceMidnight() -> TimeInterval {
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: self)
        return self.timeIntervalSince(midnight)
    }
    
    func addTimeToDate(from date: Date) -> Date {
        let rounded = (self.timeIntervalSinceReferenceDate / 300.0).rounded(.down) * 300.0
        let time = (Date(timeIntervalSinceReferenceDate: rounded)).secondsSinceMidnight()
        return date + time
    }
}

// MARK: -

extension Calendar {
    typealias WeekBoundary = (startOfWeek: Date?, endOfWeek: Date?)
    
    func currentWeekBoundary(date: Date) -> WeekBoundary? {
        return weekBoundary(for: date)
    }
    
    func weekBoundary(for date: Date) -> WeekBoundary? {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        
        guard let startOfWeek = self.date(from: components) else {
            return nil
        }
        
        let endOfWeekOffset = weekdaySymbols.count - 1
        let endOfWeekComponents = DateComponents(day: endOfWeekOffset, hour: 23, minute: 59, second: 59)
        guard let endOfWeek = self.date(byAdding: endOfWeekComponents, to: startOfWeek) else {
            return nil
        }
        
        return (startOfWeek, endOfWeek)
    }
    
    func checkIfPastWeek(for date: Date) -> Bool {
        let currentComponents = dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)

        if let startOfCurrentWeek = self.date(from: currentComponents) {
            if let startOfPastWeek = self.date(from: components) {
                return startOfPastWeek >= startOfCurrentWeek
            }
        }
        
        return false
        
    }
}

// MARK: -

extension UIColor {
    ///Lightens a UIColor
    /// - Parameter percentage: How much to alter the UIColour by.
    /// - Returns: The altered UIColor
    func lighter(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjustBrightness(by: abs(percentage))
    }
  
    ///Darkens a UIColor
    func darker(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjustBrightness(by: -abs(percentage))
    }
  
    ///Adjusts brightness
    func adjustBrightness(by percentage: CGFloat = 30.0) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if self.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            if b < 1.0 {
                let newB: CGFloat = max(min(b + (percentage/100.0)*b, 1.0), 0.0)
                return UIColor(hue: h, saturation: s, brightness: newB, alpha: a)
            } else {
                let newS: CGFloat = min(max(s - (percentage/100.0)*s, 0.0), 1.0)
                return UIColor(hue: h, saturation: newS, brightness: b, alpha: a)
            }
        }
    return self
  }
}

// MARK: -

//For reflection view controller
extension BinaryInteger {
    var digits: [Int] {
        return String(describing: self).compactMap { Int(String($0)) }
    }
}

// MARK: -

//View for when screen is empty
extension UITableView {
    func setEmptyMessage(_ message: String) {
//        let config = UIImage.SymbolConfiguration(pointSize: 75)
//        let image = UIImage(systemName: "eye", withConfiguration: config)
//        
//
//        let emptyView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.layer.bounds.width, height: self.layer.bounds.height - 49))
//        emptyView.image = image
//        emptyView.tintColor = UIColor(named: "BackgroundColour")
//        emptyView.contentMode = .center
//
//        self.backgroundView = emptyView
//        
//        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .none
    }
}
