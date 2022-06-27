//
//  Week+CoreDataProperties.swift
//  
//
//  Created by Permindar LvL on 11/02/2022.
//
//

import Foundation
import CoreData


extension Week {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Week> {
        return NSFetchRequest<Week>(entityName: "Week")
    }

    @NSManaged public var endDate: Date?
    @NSManaged public var question1: String?
    @NSManaged public var question2: String?
    @NSManaged public var question3: String?
    @NSManaged public var question4: String?
    @NSManaged public var question5: String?
    @NSManaged public var questionnaireCompleted: Bool
    @NSManaged public var startDate: Date?
    @NSManaged public var days: NSSet?
    @NSManaged public var goals: NSSet?
    @NSManaged public var month: Month?
    @NSManaged public var totalActivities: NSSet?

}

// MARK: Generated accessors for days
extension Week {

    @objc(addDaysObject:)
    @NSManaged public func addToDays(_ value: Day)

    @objc(removeDaysObject:)
    @NSManaged public func removeFromDays(_ value: Day)

    @objc(addDays:)
    @NSManaged public func addToDays(_ values: NSSet)

    @objc(removeDays:)
    @NSManaged public func removeFromDays(_ values: NSSet)

}

// MARK: Generated accessors for goals
extension Week {

    @objc(addGoalsObject:)
    @NSManaged public func addToGoals(_ value: Goal)

    @objc(removeGoalsObject:)
    @NSManaged public func removeFromGoals(_ value: Goal)

    @objc(addGoals:)
    @NSManaged public func addToGoals(_ values: NSSet)

    @objc(removeGoals:)
    @NSManaged public func removeFromGoals(_ values: NSSet)

}

// MARK: Generated accessors for totalActivities
extension Week {

    @objc(addTotalActivitiesObject:)
    @NSManaged public func addToTotalActivities(_ value: Activity)

    @objc(removeTotalActivitiesObject:)
    @NSManaged public func removeFromTotalActivities(_ value: Activity)

    @objc(addTotalActivities:)
    @NSManaged public func addToTotalActivities(_ values: NSSet)

    @objc(removeTotalActivities:)
    @NSManaged public func removeFromTotalActivities(_ values: NSSet)

}
