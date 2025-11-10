//
//  CoreDataManager.swift
//  NewCalendar
//
//  Created by 시모니 on 1/14/25.
//

import UIKit
import CoreData
import CloudKit

final class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    var context: NSManagedObjectContext {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }
        return app.persistentContainer.viewContext
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Core Data 저장 실패: \(error)")
        }
    }
    
    // CloudKit 관련 추가 메서드들
    var persistentContainer: NSPersistentCloudKitContainer {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }
        return app.persistentContainer
    }
}
