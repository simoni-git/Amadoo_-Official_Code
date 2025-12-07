
//  AppDelegate.swift
//  NewCalendar
//
//  Created by 시모니 on 10/1/24.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
   
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UINavigationBar.appearance().tintColor = .black
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -1000, vertical: 0), for: .default)
        // 네트워크 모니터링 시작
        _ = NetworkSyncManager.shared
        
        // 기존 사용자 마이그레이션 체크
        handleExistingUserMigration()
        
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
        
        // CloudKit 설정
        let storeDescription = container.persistentStoreDescriptions.first
        storeDescription?.setOption(true as NSNumber,
                                  forKey: NSPersistentHistoryTrackingKey)
        storeDescription?.setOption(true as NSNumber,
                                  forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

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
                    // 카테고리 복사 (완전 안전 모드)
                    print("=== 카테고리 마이그레이션 시작 ===")
                    for (index, oldCategory) in categories.enumerated() {
                        print("카테고리 \(index + 1) 처리 중...")
                        
                        let entity = NSEntityDescription.entity(forEntityName: "Category", in: newContext)!
                        let newCategory = NSManagedObject(entity: entity, insertInto: newContext)
                        
                        // name 속성 처리
                        do {
                            if let name = try oldCategory.value(forKey: "name") as? String,
                               !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                newCategory.setValue(name, forKey: "name")
                                print("카테고리 이름: \(name)")
                            } else {
                                throw NSError(domain: "Migration", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid name"])
                            }
                        } catch {
                            print("카테고리 name 복사 실패 - 기본값 설정: \(error)")
                            newCategory.setValue("마이그레이션 카테고리 \(index + 1)", forKey: "name")
                        }
                        
                        // color 속성 처리
                        do {
                            if let color = try oldCategory.value(forKey: "color") as? String,
                               !color.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                newCategory.setValue(color, forKey: "color")
                            } else {
                                throw NSError(domain: "Migration", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid color"])
                            }
                        } catch {
                            print("카테고리 color 복사 실패 - 기본값 설정: \(error)")
                            newCategory.setValue("#808080", forKey: "color")
                        }
                        
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
