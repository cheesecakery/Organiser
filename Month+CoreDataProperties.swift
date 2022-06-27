//
//  Month+CoreDataProperties.swift
//  
//
//  Created by Permindar LvL on 11/02/2022.
//
//

import Foundation
import CoreData


extension Month {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Month> {
        return NSFetchRequest<Month>(entityName: "Month")
    }

    @NSManaged public var endDate: Date?
    @NSManaged public var startDate: Date?
    @NSManaged public var weeks: NSSet?
    @NSManaged public var year: Year?

}

// MARK: Generated accessors for weeks
extension Month {

    @objc(addWeeksObject:)
    @NSManaged public func addToWeeks(_ value: Week)

    @objc(removeWeeksObject:)
    @NSManaged public func removeFromWeeks(_ value: Week)

    @objc(addWeeks:)
    @NSManaged public func addToWeeks(_ values: NSSet)

    @objc(removeWeeks:)
    @NSManaged public func removeFromWeeks(_ values: NSSet)

}
