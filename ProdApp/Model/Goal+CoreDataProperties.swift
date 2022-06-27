//
//  Goal+CoreDataProperties.swift
//  
//
//  Created by Permindar LvL on 27/01/2022.
//
//

import Foundation
import CoreData
import UIKit

extension Goal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Goal> {
        return NSFetchRequest<Goal>(entityName: "Goal")
    }

    @NSManaged public var backgroundColour: UIColor?
    @NSManaged public var duration: Int64
    @NSManaged public var goalTag: String?
    @NSManaged public var highlightColour: UIColor?
    @NSManaged public var name: String?
    @NSManaged public var totalDuration: Int64
    @NSManaged public var totalProductivity: Int64
    @NSManaged public var timeCreated: Date?
    @NSManaged public var activities: NSSet?
    @NSManaged public var week: Week?

}

// MARK: Generated accessors for activities
extension Goal {

    @objc(addActivitiesObject:)
    @NSManaged public func addToActivities(_ value: Activity)

    @objc(removeActivitiesObject:)
    @NSManaged public func removeFromActivities(_ value: Activity)

    @objc(addActivities:)
    @NSManaged public func addToActivities(_ values: NSSet)

    @objc(removeActivities:)
    @NSManaged public func removeFromActivities(_ values: NSSet)

}
