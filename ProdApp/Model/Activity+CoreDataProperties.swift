//
//  Activity+CoreDataProperties.swift
//  
//
//  Created by Permindar LvL on 30/12/2021.
//
//

import Foundation
import CoreData
import UIKit

extension Activity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Activity> {
        return NSFetchRequest<Activity>(entityName: "Activity")
    }

    @NSManaged public var background: UIColor?
    @NSManaged public var date: String?
    @NSManaged public var duration: Int64
    @NSManaged public var highlight: UIColor?
    @NSManaged public var icon: String?
    @NSManaged public var name: String?
    @NSManaged public var productivity: String?
    @NSManaged public var time: Date?
    @NSManaged public var timerCompleted: Bool
    @NSManaged public var type: String?
    @NSManaged public var day: Day?
    @NSManaged public var dayButCompleted: Day?
    @NSManaged public var goal: Goal?
    @NSManaged public var week: Week?

}
