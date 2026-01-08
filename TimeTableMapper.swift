//
//  TimeTableMapper.swift
//  NewCalendar
//
//  Data Layer - TimeTableItem Entity <-> NSManagedObject 변환
//

import Foundation
import CoreData

/// TimeTable 매퍼
struct TimeTableMapper {

    // MARK: - CoreData -> Domain

    /// NSManagedObject를 Domain Entity로 변환
    static func toDomain(_ managedObject: NSManagedObject) -> TimeTableItem? {
        guard let title = managedObject.value(forKey: "title") as? String,
              let startTime = managedObject.value(forKey: "startTime") as? String,
              let endTime = managedObject.value(forKey: "endTime") as? String,
              let color = managedObject.value(forKey: "color") as? String else {
            return nil
        }

        let dayOfWeek = managedObject.value(forKey: "dayOfWeek") as? Int16 ?? 0
        let memo = managedObject.value(forKey: "memo") as? String

        return TimeTableItem(
            dayOfWeek: dayOfWeek,
            startTime: startTime,
            endTime: endTime,
            title: title,
            memo: memo,
            color: color
        )
    }

    /// NSManagedObject 배열을 Domain Entity 배열로 변환
    static func toDomainList(_ managedObjects: [NSManagedObject]) -> [TimeTableItem] {
        return managedObjects.compactMap { toDomain($0) }
    }

    // MARK: - Domain -> CoreData

    /// Domain Entity를 새 NSManagedObject로 변환 (INSERT)
    static func toManagedObject(_ item: TimeTableItem, context: NSManagedObjectContext) -> NSManagedObject {
        let entity = NSEntityDescription.entity(forEntityName: "TimeTable", in: context)!
        let managedObject = NSManagedObject(entity: entity, insertInto: context)

        applyToManagedObject(managedObject, from: item)

        return managedObject
    }

    /// 기존 NSManagedObject에 Domain Entity 값 적용 (UPDATE)
    static func update(_ managedObject: NSManagedObject, with item: TimeTableItem) {
        applyToManagedObject(managedObject, from: item)
    }

    // MARK: - Private

    private static func applyToManagedObject(_ managedObject: NSManagedObject, from item: TimeTableItem) {
        managedObject.setValue(item.dayOfWeek, forKey: "dayOfWeek")
        managedObject.setValue(item.startTime, forKey: "startTime")
        managedObject.setValue(item.endTime, forKey: "endTime")
        managedObject.setValue(item.title, forKey: "title")
        managedObject.setValue(item.memo, forKey: "memo")
        managedObject.setValue(item.color, forKey: "color")
    }
}
