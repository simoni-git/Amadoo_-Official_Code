//
//  CloudKitSyncManager.swift
//  NewCalendar
//
//  Created by 시모니의 맥북 on 9/18/25.
//

//
//  CloudKitSyncManager.swift
//  NewCalendar
//
//  Created by 시모니의 맥북 on 9/18/25.
//

import CloudKit
import CoreData

enum CloudKitStatus {
    case available
    case noAccount
    case restricted
    case quotaExceeded
    case unknown
}

class CloudKitSyncManager {
    static let shared = CloudKitSyncManager()
    private let container = CKContainer.default()
    private let coreDataManager = CoreDataManager.shared
    private var lastNotificationTime: Date = Date(timeIntervalSince1970: 0)
    
    private init() {
        setupRemoteChangeNotifications()
    }
    
    // CloudKit 계정 상태 확인 (기본)
    func checkAccountStatus(completion: @escaping (Bool) -> Void) {
        container.accountStatus { status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    print("iCloud 사용 가능")
                    completion(true)
                case .noAccount:
                    print("iCloud 계정이 설정되지 않음")
                    completion(false)
                case .restricted, .couldNotDetermine:
                    print("iCloud 사용 제한됨")
                    completion(false)
                @unknown default:
                    completion(false)
                }
            }
        }
    }
    
    // CloudKit 계정 상태 상세 확인
    func checkDetailedAccountStatus(completion: @escaping (CloudKitStatus, String?) -> Void) {
        container.accountStatus { status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    // 용량 체크도 함께 진행
                    self.checkiCloudQuota { hasSpace in
                        if hasSpace {
                            completion(.available, nil)
                        } else {
                            completion(.quotaExceeded, "iCloud 저장 공간이 부족합니다")
                        }
                    }
                case .noAccount:
                    completion(.noAccount, "iCloud 계정이 설정되지 않았습니다")
                case .restricted:
                    completion(.restricted, "iCloud 사용이 제한되어 있습니다")
                case .couldNotDetermine:
                    completion(.unknown, "iCloud 상태를 확인할 수 없습니다")
                @unknown default:
                    completion(.unknown, "알 수 없는 오류가 발생했습니다")
                }
            }
        }
    }
    
    private func checkiCloudQuota(completion: @escaping (Bool) -> Void) {
        // 간단한 테스트 레코드로 용량 체크
        let testRecord = CKRecord(recordType: "TestQuota")
        container.publicCloudDatabase.save(testRecord) { record, error in
            if let error = error as? CKError {
                if error.code == .quotaExceeded {
                    completion(false)
                } else {
                    completion(true)
                }
                // 테스트 레코드 삭제
                if let record = record {
                    self.container.publicCloudDatabase.delete(withRecordID: record.recordID) { _, _ in }
                }
            } else {
                completion(true)
                // 테스트 레코드 삭제
                if let record = record {
                    self.container.publicCloudDatabase.delete(withRecordID: record.recordID) { _, _ in }
                }
            }
        }
    }
    
    // 원격 변경사항 감지 설정
    private func setupRemoteChangeNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRemoteChange),
            name: .NSPersistentStoreRemoteChange,
            object: coreDataManager.persistentContainer.persistentStoreCoordinator
        )
    }
    
    @objc private func handleRemoteChange(_ notification: Notification) {
        let now = Date()
        
        // 마지막 알림으로부터 2초 이내면 무시
        if now.timeIntervalSince(lastNotificationTime) < 2.0 {
            print("CloudKit 변경 감지 - 너무 빈번함, 무시")
            return
        }
        
        lastNotificationTime = now
        print("CloudKit에서 데이터 변경 감지됨")
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .cloudKitDataUpdated, object: nil)
        }
    }
    
    func uploadExistingDataToCloudKit() {
        let context = coreDataManager.context
        
        context.perform {
            let scheduleRequest = NSFetchRequest<NSManagedObject>(entityName: "Schedule")
            
            do {
                let schedules = try context.fetch(scheduleRequest)
                let categoryRequest = NSFetchRequest<NSManagedObject>(entityName: "Category")
                let categories = try context.fetch(categoryRequest)
                
                if !schedules.isEmpty || !categories.isEmpty {
                    try context.save()
                    print("기존 데이터 CloudKit 동기화 완료")
                    
                    // 마이그레이션 완료 알림
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(
                            name: NSNotification.Name("CloudKitMigrationCompleted"),
                            object: nil
                        )
                    }
                }
            } catch {
                print("기존 데이터 동기화 실패: \(error)")
            }
        }
    }
    
    // 수동 동기화 트리거
    func triggerSync() {
        let backgroundContext = coreDataManager.persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            do {
                try backgroundContext.save()
                print("수동 동기화 트리거됨")
            } catch {
                print("수동 동기화 실패: \(error)")
            }
        }
    }
    
    // 네트워크 상태를 확인한 후 동기화
    func syncIfNetworkAvailable() {
        if NetworkSyncManager.shared.getCurrentNetworkStatus() {
            checkAccountStatus { isAvailable in
                if isAvailable {
                    self.triggerSync()
                } else {
                    print("iCloud 계정을 확인해주세요")
                }
            }
        } else {
            print("네트워크 연결을 확인해주세요")
        }
    }
}

// Notification 확장
extension Notification.Name {
    static let cloudKitDataUpdated = Notification.Name("cloudKitDataUpdated")
}
