//
//  CoreDataManager.swift
//  NewCalendar
//
//  Created by 시모니 on 1/14/25.
//

import UIKit
import CoreData
import CloudKit
import WidgetKit

final class CoreDataManager {
    static let shared = CoreDataManager()

    // App Group identifier (위젯과 공유)
    static let appGroupIdentifier = "group.Simoni.Amadoo"

    private init() {}

    // MARK: - 메인 앱용 Context (기존 위치)
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
            print("✅ CoreData 저장 성공")

            // 저장 후 위젯 데이터 동기화
            syncToAppGroup()

            // 위젯 타임라인 새로고침
            DispatchQueue.main.async {
                WidgetCenter.shared.reloadAllTimelines()
                print("🔄 위젯 타임라인 새로고침 요청")
            }
        } catch {
            print("❌ Core Data 저장 실패: \(error)")
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

    // MARK: - 위젯 데이터 동기화
    /// 데이터 변경 시 App Group 저장소에 동기화
    private func syncToAppGroup() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        DispatchQueue.global(qos: .utility).async {
            appDelegate.syncDataToAppGroup()
        }
    }
}
