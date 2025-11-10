//
//  NetworkSyncManager.swift
//  NewCalendar
//
//  Created by 시모니의 맥북 on 9/18/25.
//

import Network
import CloudKit
import CoreData

class NetworkSyncManager {
    static let shared = NetworkSyncManager()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private var isConnected = false
    
    private init() {
        startNetworkMonitoring()
    }
    
    private func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            let wasConnected = self?.isConnected ?? false
            self?.isConnected = path.status == .satisfied
            
            // 연결이 복구되었을 때 동기화 트리거
            if !wasConnected && self?.isConnected == true {
                DispatchQueue.main.async {
                    self?.handleNetworkReconnection()
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    private func handleNetworkReconnection() {
        print("네트워크 연결 복구됨 - CloudKit 동기화 시작")
        
        // CloudKit 계정 상태 다시 확인
        CloudKitSyncManager.shared.checkAccountStatus { isAvailable in
            if isAvailable {
                // 수동으로 동기화 트리거
                self.triggerCloudKitSync()
            }
        }
        
        // UI에 동기화 상태 알림
        NotificationCenter.default.post(name: .networkReconnected, object: nil)
    }
    
    private func triggerCloudKitSync() {
        let container = CoreDataManager.shared.persistentContainer
        
        // NSPersistentCloudKitContainer가 동기화를 처리하도록 context 저장
        let context = container.newBackgroundContext()
        context.perform {
            do {
                try context.save()
                print("CloudKit 동기화 트리거됨")
            } catch {
                print("동기화 트리거 실패: \(error)")
            }
        }
    }
    
    func getCurrentNetworkStatus() -> Bool {
        return isConnected
    }
}

// Notification 확장
extension Notification.Name {
    static let networkReconnected = Notification.Name("networkReconnected")
}
