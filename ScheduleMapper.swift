//
//  ScheduleMapper.swift
//  NewCalendar
//
//  Data Layer - ScheduleItem Entity <-> NSManagedObject 변환
//

import Foundation
import CoreData

/// Schedule 매퍼
struct ScheduleMapper {

    // MARK: - CoreData -> Domain

    /// NSManagedObject를 Domain Entity로 변환
    static func toDomain(_ managedObject: NSManagedObject) -> ScheduleItem? {
        guard let title = managedObject.value(forKey: "title") as? String,
              let date = managedObject.value(forKey: "date") as? Date,
              let startDay = managedObject.value(forKey: "startDay") as? Date,
              let endDay = managedObject.value(forKey: "endDay") as? Date,
              let buttonTypeRaw = managedObject.value(forKey: "buttonType") as? String,
              let categoryColor = managedObject.value(forKey: "categoryColor") as? String else {
            return nil
        }

        let buttonType = DutyType(rawValue: buttonTypeRaw) ?? .defaultDay

        return ScheduleItem(
            title: title,
            date: date,
            startDay: startDay,
            endDay: endDay,
            buttonType: buttonType,
            categoryColor: categoryColor
        )
    }

    /// NSManagedObject 배열을 Domain Entity 배열로 변환
    static func toDomainList(_ managedObjects: [NSManagedObject]) -> [ScheduleItem] {
        return managedObjects.compactMap { toDomain($0) }
    }

    // MARK: - Domain -> CoreData

    /// Domain Entity를 새 NSManagedObject로 변환 (INSERT)
    static func toManagedObject(_ schedule: ScheduleItem, context: NSManagedObjectContext) -> NSManagedObject {
        let entity = NSEntityDescription.entity(forEntityName: "Schedule", in: context)!
        let managedObject = NSManagedObject(entity: entity, insertInto: context)

        applyToManagedObject(managedObject, from: schedule)

        return managedObject
    }

    /// 기존 NSManagedObject에 Domain Entity 값 적용 (UPDATE)
    static func update(_ managedObject: NSManagedObject, with schedule: ScheduleItem) {
        applyToManagedObject(managedObject, from: schedule)
    }

    // MARK: - Private

    private static func applyToManagedObject(_ managedObject: NSManagedObject, from schedule: ScheduleItem) {
        managedObject.setValue(schedule.title, forKey: "title")
        managedObject.setValue(schedule.date, forKey: "date")
        managedObject.setValue(schedule.startDay, forKey: "startDay")
        managedObject.setValue(schedule.endDay, forKey: "endDay")
        managedObject.setValue(schedule.buttonType.rawValue, forKey: "buttonType")
        managedObject.setValue(schedule.categoryColor, forKey: "categoryColor")
    }
}
