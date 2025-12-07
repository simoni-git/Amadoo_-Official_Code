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
            print("❌ Error: Unable to access AppDelegate")
            // SceneDelegate를 사용하는 경우를 대비한 fallback
            let container = NSPersistentCloudKitContainer(name: "NewCalendar")
            container.loadPersistentStores { _, error in
                if let error = error {
                    print("❌ Core Data 로드 실패: \(error)")
                }
            }
            return container.viewContext
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
            print("❌ Error: Unable to access AppDelegate for persistentContainer")
            // 새로운 컨테이너 인스턴스 생성 (fallback)
            let container = NSPersistentCloudKitContainer(name: "NewCalendar")
            container.loadPersistentStores { _, error in
                if let error = error {
                    print("❌ Persistent store 로드 실패: \(error)")
                }
            }
            return container
        }
        return app.persistentContainer
    }
}
