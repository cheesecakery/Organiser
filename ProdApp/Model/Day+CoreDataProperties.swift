//
//  Day+CoreDataProperties.swift
//  
//
//  Created by Permindar LvL on 30/12/2021.
//
//

import Foundation
import CoreData


extension Day {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Day> {
        return NSFetchRequest<Day>(entityName: "Day")
    }

    @NSManaged public var date: String?
    @NSManaged public var activities: NSSet?
    @NSManaged public var completedActivities: NSSet?
    @NSManaged public var parent: Week?

}

// MARK: Generated accessors for activities
extension Day {

    @objc(addActivitiesObject:)
    @NSManaged public func addToActivities(_ value: Activity)

    @objc(removeActivitiesObject:)
    @NSManaged public func removeFromActivities(_ value: Activity)

    @objc(addActivities:)
    @NSManaged public func addToActivities(_ values: NSSet)

    @objc(removeActivities:)
    @NSManaged public func removeFromActivities(_ values: NSSet)

}

// MARK: Generated accessors for completedActivities
extension Day {

    @objc(addCompletedActivitiesObject:)
    @NSManaged public func addToCompletedActivities(_ value: Activity)

    @objc(removeCompletedActivitiesObject:)
    @NSManaged public func removeFromCompletedActivities(_ value: Activity)

    @objc(addCompletedActivities:)
    @NSManaged public func addToCompletedActivities(_ values: NSSet)

    @objc(removeCompletedActivities:)
    @NSManaged public func removeFromCompletedActivities(_ values: NSSet)

}
