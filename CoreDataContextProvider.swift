//
//  CoreDataContextProvider.swift
//  NewCalendar
//
//  Data Layer - CoreData Context 제공자
//

import UIKit
import CoreData
import CloudKit
import WidgetKit

/// CoreData Context 제공 프로토콜
protocol CoreDataContextProviding {
    var context: NSManagedObjectContext { get }
    var persistentContainer: NSPersistentCloudKitContainer { get }
    func saveContext()
    func notifyWidgetUpdate()
}

/// CoreData Context 제공자 (기존 CoreDataManager 래핑)
final class CoreDataContextProvider: CoreDataContextProviding {

    static let shared = CoreDataContextProvider()
    static let appGroupIdentifier = "group.Simoni.Amadoo"

    private init() {}

    // MARK: - Context

    var context: NSManagedObjectContext {
        return CoreDataManager.shared.context
    }

    var persistentContainer: NSPersistentCloudKitContainer {
        return CoreDataManager.shared.persistentContainer
    }

    // MARK: - Save

    func saveContext() {
        CoreDataManager.shared.saveContext()
    }

    // MARK: - Widget Update

    func notifyWidgetUpdate() {
        DispatchQueue.main.async {
            WidgetCenter.shared.reloadAllTimelines()
            print("🔄 위젯 타임라인 새로고침 요청")
        }

        // App Group 동기화
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            DispatchQueue.global(qos: .utility).async {
                appDelegate.syncDataToAppGroup()
            }
        }
    }

    // MARK: - Background Context

    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }

    // MARK: - Perform on Context

    func performOnContext(_ block: @escaping (NSManagedObjectContext) -> Void) {
        context.perform {
            block(self.context)
        }
    }

    func performOnBackgroundContext(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let backgroundContext = newBackgroundContext()
        backgroundContext.perform {
            block(backgroundContext)
        }
    }
}
