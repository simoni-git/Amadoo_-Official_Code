
//  AppDelegate.swift
//  NewCalendar
//
//  Created by 시모니 on 10/1/24.
//

import UIKit
import CoreData
import WidgetKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
   
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        UINavigationBar.appearance().tintColor = .black
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -1000, vertical: 0), for: .default)
        // 네트워크 모니터링 시작
        _ = NetworkSyncManager.shared

        // UserNotificationManager 의존성 주입
        UserNotificationManager.shared.injectDependencies(
            fetchSchedulesUseCase: DIContainer.shared.makeFetchSchedulesUseCase()
        )

        // 기존 사용자 마이그레이션 체크
        handleExistingUserMigration()

        // 불필요한 마이그레이션 카테고리 정리 (한 번만 실행)
        cleanupInvalidCategories()

        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    // MARK: - Core Data stack (CloudKit 지원)
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "NewCalendar")

        // CloudKit 설정 (기존 위치 그대로 유지)
        let storeDescription = container.persistentStoreDescriptions.first
        storeDescription?.setOption(true as NSNumber,
                                  forKey: NSPersistentHistoryTrackingKey)
        storeDescription?.setOption(true as NSNumber,
                                  forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }

            // 위젯을 위한 데이터 동기화
            self.syncDataToAppGroup()
        })

        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    // MARK: - 불필요한 카테고리 정리
    /// 마이그레이션 중 생성된 불필요한 카테고리 삭제
    /// CloudKit 동기화로 인해 재생성될 수 있으므로 주기적으로 실행
    func cleanupInvalidCategories() {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Category")

        context.perform {
            do {
                let categories = try context.fetch(fetchRequest)
                var deletedCount = 0

                for category in categories {
                    var shouldDelete = false

                    if let name = category.value(forKey: "name") as? String {
                        // "마이그레이션 카테고리"로 시작하는 이름 또는 "Unknown" 이름의 카테고리 삭제
                        if name.hasPrefix("마이그레이션 카테고리") || name == "Unknown" {
                            shouldDelete = true
                        }
                    } else {
                        // name이 nil인 카테고리도 삭제
                        shouldDelete = true
                        print("🗑️ 불필요한 카테고리 삭제: (name이 nil)")
                    }

                    if shouldDelete {
                        context.delete(category)
                        deletedCount += 1
                        if let name = category.value(forKey: "name") as? String {
                            print("🗑️ 불필요한 카테고리 삭제: \(name)")
                        }
                    }
                }

                if deletedCount > 0 {
                    try context.save()
                    print("✅ 총 \(deletedCount)개의 불필요한 카테고리 삭제 완료")

                    // 위젯 데이터도 업데이트
                    DispatchQueue.main.async {
                        self.syncDataToAppGroup()

                        // 위젯 새로고침
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }

            } catch {
                print("❌ 카테고리 정리 실패: \(error)")
            }
        }
    }

    // MARK: - 위젯 데이터 동기화
    /// 메인 앱의 CoreData를 App Group 저장소에 복사 (위젯이 읽을 수 있도록)
    func syncDataToAppGroup() {
        DispatchQueue.global(qos: .background).async {
            // App Group 저장소에 데이터 복사
            self.copyDataToSharedContainer()
        }
    }

    private func copyDataToSharedContainer() {
        guard let sharedURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.Simoni.Amadoo"
        )?.appendingPathComponent("NewCalendar.sqlite") else {
            print("❌ App Group URL을 찾을 수 없습니다")
            return
        }

        // 이미 복사본이 있으면 업데이트
        let sharedContainer = NSPersistentContainer(name: "NewCalendar")
        let sharedStoreDescription = NSPersistentStoreDescription(url: sharedURL)
        sharedStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        sharedContainer.persistentStoreDescriptions = [sharedStoreDescription]

        sharedContainer.loadPersistentStores { _, error in
            if let error = error {
                print("❌ 공유 저장소 로드 실패: \(error)")
                return
            }

            // 메인 앱 데이터를 공유 저장소에 복사
            self.copyAllData(from: self.persistentContainer.viewContext,
                           to: sharedContainer.viewContext)
        }
    }

    private func copyAllData(from sourceContext: NSManagedObjectContext,
                           to destinationContext: NSManagedObjectContext) {
        sourceContext.performAndWait {
            destinationContext.performAndWait {
                // TimeTable 동기화 (추가/수정/삭제)
                self.syncEntity(entityName: "TimeTable",
                               from: sourceContext,
                               to: destinationContext)

                // Schedule 동기화 (추가/수정/삭제)
                self.syncEntity(entityName: "Schedule",
                               from: sourceContext,
                               to: destinationContext)

                // 저장
                if destinationContext.hasChanges {
                    try? destinationContext.save()
                    print("✅ 위젯 데이터 동기화 완료")

                    // 위젯 타임라인 새로고침
                    DispatchQueue.main.async {
                        WidgetCenter.shared.reloadAllTimelines()
                        print("🔄 위젯 타임라인 새로고침 완료")
                    }
                }
            }
        }
    }

    /// 엔티티 동기화 (추가/수정/삭제 모두 처리)
    private func syncEntity(entityName: String,
                           from sourceContext: NSManagedObjectContext,
                           to destinationContext: NSManagedObjectContext) {
        // 1. 소스(메인 앱)의 모든 데이터 가져오기
        let sourceFetch = NSFetchRequest<NSManagedObject>(entityName: entityName)
        guard let sourceObjects = try? sourceContext.fetch(sourceFetch) else {
            return
        }

        // 2. 대상(공유 저장소)의 모든 데이터 가져오기
        let destFetch = NSFetchRequest<NSManagedObject>(entityName: entityName)
        guard let destObjects = try? destinationContext.fetch(destFetch) else {
            return
        }

        // 3. 소스의 각 항목을 대상에 복사 (추가/수정)
        for sourceObject in sourceObjects {
            self.copyEntity(sourceObject, to: destinationContext)
        }

        // 4. 대상에만 있고 소스에 없는 항목 삭제 (삭제된 항목 제거)
        for destObject in destObjects {
            let predicate = self.createUniquePredicate(for: destObject)
            let checkFetch = NSFetchRequest<NSManagedObject>(entityName: entityName)
            checkFetch.predicate = predicate

            // 소스에 같은 항목이 있는지 확인
            if let matches = try? sourceContext.fetch(checkFetch), matches.isEmpty {
                // 소스에 없으면 대상에서 삭제
                destinationContext.delete(destObject)
                print("🗑️ 삭제 동기화: \(entityName)")
            }
        }
    }

    private func copyEntity(_ sourceObject: NSManagedObject,
                          to destinationContext: NSManagedObjectContext) {
        let entityName = sourceObject.entity.name!

        // 동일한 객체가 이미 있는지 확인
        let predicate = self.createUniquePredicate(for: sourceObject)
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        fetchRequest.predicate = predicate

        let existingObject = try? destinationContext.fetch(fetchRequest).first
        let destinationObject = existingObject ?? NSEntityDescription.insertNewObject(
            forEntityName: entityName,
            into: destinationContext
        )

        // 속성 복사
        for (key, _) in sourceObject.entity.attributesByName {
            destinationObject.setValue(sourceObject.value(forKey: key), forKey: key)
        }
    }

    private func createUniquePredicate(for object: NSManagedObject) -> NSPredicate {
        let entityName = object.entity.name!

        if entityName == "TimeTable" {
            let dayOfWeek = object.value(forKey: "dayOfWeek") as? Int16 ?? 0
            let startTime = object.value(forKey: "startTime") as? String ?? ""
            return NSPredicate(format: "dayOfWeek == %d AND startTime == %@",
                             dayOfWeek, startTime)
        } else if entityName == "Schedule" {
            let startDay = object.value(forKey: "startDay") as? Date ?? Date()
            let title = object.value(forKey: "title") as? String ?? ""
            return NSPredicate(format: "startDay == %@ AND title == %@",
                             startDay as CVarArg, title)
        }

        return NSPredicate(value: true)
    }

    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - 마이그레이션 관련
    private func handleExistingUserMigration() {
        let migrationKey = "CloudKitMigrationCompleted_v1.0"
        let hasCompletedMigration = UserDefaults.standard.bool(forKey: migrationKey)
        
        if !hasCompletedMigration {
            // 기존 NSPersistentContainer로 먼저 데이터 로드
            migrateFromOldContainer { success in
                if success {
                    UserDefaults.standard.set(true, forKey: migrationKey)
                    print("기존 사용자 데이터 마이그레이션 완료")
                }
            }
        } else {
            print("이미 마이그레이션 완료된 사용자")
        }
    }

    private func migrateFromOldContainer(completion: @escaping (Bool) -> Void) {
        // 1. 기존 NSPersistentContainer로 데이터 읽기
        let oldContainer = NSPersistentContainer(name: "NewCalendar")
        oldContainer.loadPersistentStores { _, error in
            if error != nil {
                print("기존 컨테이너 로드 실패 - 신규 사용자로 처리")
                completion(true)
                return
            }
            
            // 2. 기존 데이터 가져오기
            let oldContext = oldContainer.viewContext
            let scheduleRequest = NSFetchRequest<NSManagedObject>(entityName: "Schedule")
            let categoryRequest = NSFetchRequest<NSManagedObject>(entityName: "Category")
            
            do {
                let oldSchedules = try oldContext.fetch(scheduleRequest)
                let oldCategories = try oldContext.fetch(categoryRequest)
                
                if !oldSchedules.isEmpty || !oldCategories.isEmpty {
                    print("기존 데이터 발견 - 일정: \(oldSchedules.count)개, 카테고리: \(oldCategories.count)개")
                    // 3. 새 CloudKit 컨테이너로 데이터 복사
                    self.copyDataToNewContainer(schedules: oldSchedules, categories: oldCategories, completion: completion)
                } else {
                    print("기존 데이터 없음 - 신규 사용자")
                    completion(true)
                }
            } catch {
                print("기존 데이터 읽기 실패: \(error)")
                completion(true)
            }
        }
    }
    
    private func copyDataToNewContainer(schedules: [NSManagedObject], categories: [NSManagedObject], completion: @escaping (Bool) -> Void) {
        let newContext = persistentContainer.viewContext
        
        CloudKitSyncManager.shared.checkDetailedAccountStatus { status, message in
            switch status {
            case .available:
                do {
                    // 카테고리 복사 (유효성 검증 강화)
                    print("=== 카테고리 마이그레이션 시작 ===")
                    for (index, oldCategory) in categories.enumerated() {
                        print("카테고리 \(index + 1) 처리 중...")

                        // name과 color를 미리 검증
                        var validName: String?
                        var validColor: String?
                        var isValid = false

                        // name 검증
                        do {
                            if let name = try oldCategory.value(forKey: "name") as? String,
                               !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                validName = name
                                print("카테고리 이름: \(name)")
                            }
                        } catch {
                            print("카테고리 name 읽기 실패: \(error)")
                        }

                        // color 검증
                        do {
                            if let color = try oldCategory.value(forKey: "color") as? String,
                               !color.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                validColor = color
                            }
                        } catch {
                            print("카테고리 color 읽기 실패: \(error)")
                        }

                        // 유효한 name과 color가 모두 있을 때만 카테고리 생성
                        if let name = validName, let color = validColor {
                            let entity = NSEntityDescription.entity(forEntityName: "Category", in: newContext)!
                            let newCategory = NSManagedObject(entity: entity, insertInto: newContext)

                            newCategory.setValue(name, forKey: "name")
                            newCategory.setValue(color, forKey: "color")

                            // isDefault 속성 처리
                            do {
                                if let isDefault = try oldCategory.value(forKey: "isDefault") as? Bool {
                                    newCategory.setValue(isDefault, forKey: "isDefault")
                                } else {
                                    newCategory.setValue(false, forKey: "isDefault")
                                }
                            } catch {
                                print("카테고리 isDefault 복사 실패 - 기본값 설정: \(error)")
                                newCategory.setValue(false, forKey: "isDefault")
                            }

                            print("✅ 카테고리 '\(name)' 마이그레이션 성공")
                        } else {
                            print("⚠️ 카테고리 \(index + 1) 스킵 - 유효하지 않은 데이터 (name: \(validName ?? "nil"), color: \(validColor ?? "nil"))")
                        }
                    }
                    
                    // 일정 복사 (완전 안전 모드)
                    print("=== 일정 마이그레이션 시작 ===")
                    for (index, oldSchedule) in schedules.enumerated() {
                        print("일정 \(index + 1) 처리 중...")
                        
                        // 먼저 실제 속성 확인 (첫 번째 일정만)
                        if index == 0 {
                            print("실제 Schedule 속성들:")
                            for (key, _) in oldSchedule.entity.attributesByName {
                                do {
                                    let value = try oldSchedule.value(forKey: key)
                                    print("- \(key): \(value ?? "nil")")
                                } catch {
                                    print("- \(key): 접근 불가 (\(error))")
                                }
                            }
                        }
                        
                        let entity = NSEntityDescription.entity(forEntityName: "Schedule", in: newContext)!
                        let newSchedule = NSManagedObject(entity: entity, insertInto: newContext)
                        
                        // 각 속성을 안전하게 복사
                        let attributeHandlers: [String: () -> Any] = [
                            "title": { "마이그레이션된 일정 \(index + 1)" },
                            "date": { Date() },
                            "startDay": { Date() },
                            "endDay": { Date() },
                            "buttonType": { "defaultDay" },
                            "categoryColor": { "#808080" }
                        ]
                        
                        for (key, _) in oldSchedule.entity.attributesByName {
                            do {
                                let value = try oldSchedule.value(forKey: key)
                                if value != nil {
                                    newSchedule.setValue(value, forKey: key)
                                    print("일정 \(key) 복사 성공")
                                } else {
                                    throw NSError(domain: "Migration", code: 1, userInfo: [NSLocalizedDescriptionKey: "Nil value"])
                                }
                            } catch {
                                print("일정 \(key) 복사 실패: \(error)")
                                if let defaultValue = attributeHandlers[key] {
                                    newSchedule.setValue(defaultValue(), forKey: key)
                                    print("일정 \(key) 기본값 설정")
                                }
                            }
                        }
                    }
                    
                    try newContext.save()
                    print("마이그레이션 성공: 일정 \(schedules.count)개, 카테고리 \(categories.count)개")
                    completion(true)
                    
                } catch {
                    print("마이그레이션 전체 실패: \(error)")
                    // 실패해도 앱 실행 계속 (사용자 보호)
                    completion(true)
                }
                
            default:
                print("iCloud 사용 불가 - 로컬 모드로 실행")
                completion(true)
            }
        }
    }
    private func showiCloudAlert(title: String, message: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootVC = window.rootViewController else {
                completion(true) // 로컬 모드로 계속
                return
            }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "설정으로 가기", style: .default) { _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
                completion(true) // 로컬 모드로 계속
            })
            
            alert.addAction(UIAlertAction(title: "나중에 하기", style: .cancel) { _ in
                completion(true) // 로컬 모드로 계속
            })
            
            rootVC.present(alert, animated: true)
        }
    }
}
