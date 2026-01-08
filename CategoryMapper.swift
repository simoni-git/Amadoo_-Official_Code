//
//  CategoryMapper.swift
//  NewCalendar
//
//  Data Layer - CategoryItem Entity <-> NSManagedObject 변환
//

import Foundation
import CoreData

/// Category 매퍼
struct CategoryMapper {

    // MARK: - CoreData -> Domain

    /// NSManagedObject를 Domain Entity로 변환
    static func toDomain(_ managedObject: NSManagedObject) -> CategoryItem? {
        guard let name = managedObject.value(forKey: "name") as? String,
              let color = managedObject.value(forKey: "color") as? String else {
            return nil
        }

        let isDefault = managedObject.value(forKey: "isDefault") as? Bool ?? false

        return CategoryItem(
            name: name,
            color: color,
            isDefault: isDefault
        )
    }

    /// NSManagedObject 배열을 Domain Entity 배열로 변환
    static func toDomainList(_ managedObjects: [NSManagedObject]) -> [CategoryItem] {
        return managedObjects.compactMap { toDomain($0) }
    }

    // MARK: - Domain -> CoreData

    /// Domain Entity를 새 NSManagedObject로 변환 (INSERT)
    static func toManagedObject(_ category: CategoryItem, context: NSManagedObjectContext) -> NSManagedObject {
        let entity = NSEntityDescription.entity(forEntityName: "Category", in: context)!
        let managedObject = NSManagedObject(entity: entity, insertInto: context)

        applyToManagedObject(managedObject, from: category)

        return managedObject
    }

    /// 기존 NSManagedObject에 Domain Entity 값 적용 (UPDATE)
    static func update(_ managedObject: NSManagedObject, with category: CategoryItem) {
        applyToManagedObject(managedObject, from: category)
    }

    // MARK: - Private

    private static func applyToManagedObject(_ managedObject: NSManagedObject, from category: CategoryItem) {
        managedObject.setValue(category.name, forKey: "name")
        managedObject.setValue(category.color, forKey: "color")
        managedObject.setValue(category.isDefault, forKey: "isDefault")
    }
}
