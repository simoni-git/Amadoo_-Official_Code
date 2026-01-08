//
//  MemoMapper.swift
//  NewCalendar
//
//  Data Layer - MemoItem/CheckListItem Entity <-> NSManagedObject 변환
//

import Foundation
import CoreData

// MARK: - MemoMapper

/// Memo 매퍼
struct MemoMapper {

    // MARK: - CoreData -> Domain

    /// NSManagedObject를 Domain Entity로 변환
    static func toDomain(_ managedObject: NSManagedObject) -> MemoItem? {
        guard let title = managedObject.value(forKey: "title") as? String,
              let memoType = managedObject.value(forKey: "memoType") as? String else {
            return nil
        }

        let memoText = managedObject.value(forKey: "memoText") as? String

        return MemoItem(
            title: title,
            memoText: memoText,
            memoType: memoType
        )
    }

    /// NSManagedObject 배열을 Domain Entity 배열로 변환
    static func toDomainList(_ managedObjects: [NSManagedObject]) -> [MemoItem] {
        return managedObjects.compactMap { toDomain($0) }
    }

    // MARK: - Domain -> CoreData

    /// Domain Entity를 새 NSManagedObject로 변환 (INSERT)
    static func toManagedObject(_ memo: MemoItem, context: NSManagedObjectContext) -> NSManagedObject {
        let entity = NSEntityDescription.entity(forEntityName: "Memo", in: context)!
        let managedObject = NSManagedObject(entity: entity, insertInto: context)

        applyToManagedObject(managedObject, from: memo)

        return managedObject
    }

    /// 기존 NSManagedObject에 Domain Entity 값 적용 (UPDATE)
    static func update(_ managedObject: NSManagedObject, with memo: MemoItem) {
        applyToManagedObject(managedObject, from: memo)
    }

    // MARK: - Private

    private static func applyToManagedObject(_ managedObject: NSManagedObject, from memo: MemoItem) {
        managedObject.setValue(memo.title, forKey: "title")
        managedObject.setValue(memo.memoText, forKey: "memoText")
        managedObject.setValue(memo.memoType, forKey: "memoType")
    }
}

// MARK: - CheckListMapper

/// CheckList 매퍼
struct CheckListMapper {

    // MARK: - CoreData -> Domain

    /// NSManagedObject를 Domain Entity로 변환
    static func toDomain(_ managedObject: NSManagedObject) -> CheckListItem? {
        guard let title = managedObject.value(forKey: "title") as? String,
              let memoType = managedObject.value(forKey: "memoType") as? String else {
            return nil
        }

        let name = managedObject.value(forKey: "name") as? String
        let isComplete = managedObject.value(forKey: "isComplete") as? Bool ?? false

        return CheckListItem(
            title: title,
            name: name,
            isComplete: isComplete,
            memoType: memoType
        )
    }

    /// NSManagedObject 배열을 Domain Entity 배열로 변환
    static func toDomainList(_ managedObjects: [NSManagedObject]) -> [CheckListItem] {
        return managedObjects.compactMap { toDomain($0) }
    }

    // MARK: - Domain -> CoreData

    /// Domain Entity를 새 NSManagedObject로 변환 (INSERT)
    static func toManagedObject(_ checkList: CheckListItem, context: NSManagedObjectContext) -> NSManagedObject {
        let entity = NSEntityDescription.entity(forEntityName: "CheckList", in: context)!
        let managedObject = NSManagedObject(entity: entity, insertInto: context)

        applyToManagedObject(managedObject, from: checkList)

        return managedObject
    }

    /// 기존 NSManagedObject에 Domain Entity 값 적용 (UPDATE)
    static func update(_ managedObject: NSManagedObject, with checkList: CheckListItem) {
        applyToManagedObject(managedObject, from: checkList)
    }

    // MARK: - Private

    private static func applyToManagedObject(_ managedObject: NSManagedObject, from checkList: CheckListItem) {
        managedObject.setValue(checkList.title, forKey: "title")
        managedObject.setValue(checkList.name, forKey: "name")
        managedObject.setValue(checkList.isComplete, forKey: "isComplete")
        managedObject.setValue(checkList.memoType, forKey: "memoType")
    }
}
