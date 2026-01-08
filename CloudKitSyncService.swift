//
//  CloudKitSyncService.swift
//  NewCalendar
//
//  Data Layer - CloudKit 동기화 서비스 (기존 CloudKitSyncManager 래핑)
//

import Foundation

/// CloudKit 동기화 서비스 (Protocol 구현체)
final class CloudKitSyncService: SyncServiceProtocol {

    private let cloudKitManager: CloudKitSyncManager
    private let networkService: NetworkServiceProtocol

    init(
        cloudKitManager: CloudKitSyncManager = .shared,
        networkService: NetworkServiceProtocol = NetworkMonitorService()
    ) {
        self.cloudKitManager = cloudKitManager
        self.networkService = networkService
    }

    // MARK: - Account Status

    func checkAccountStatus(completion: @escaping (Bool) -> Void) {
        cloudKitManager.checkAccountStatus(completion: completion)
    }

    func checkDetailedAccountStatus(completion: @escaping (CloudKitAccountStatus, String?) -> Void) {
        cloudKitManager.checkDetailedAccountStatus { status, message in
            // 기존 CloudKitStatus를 Domain의 CloudKitAccountStatus로 변환
            let domainStatus: CloudKitAccountStatus
            switch status {
            case .available:
                domainStatus = .available
            case .noAccount:
                domainStatus = .noAccount
            case .restricted:
                domainStatus = .restricted
            case .quotaExceeded:
                domainStatus = .quotaExceeded
            case .unknown:
                domainStatus = .unknown
            }
            completion(domainStatus, message)
        }
    }

    // MARK: - Sync

    func triggerSync() {
        cloudKitManager.triggerSync()
    }

    func syncIfNetworkAvailable() {
        if networkService.isConnected {
            checkAccountStatus { [weak self] isAvailable in
                if isAvailable {
                    self?.triggerSync()
                } else {
                    print("⚠️ iCloud 계정 사용 불가")
                }
            }
        } else {
            print("⚠️ 네트워크 연결 없음")
        }
    }

    func uploadExistingData() {
        cloudKitManager.uploadExistingDataToCloudKit()
    }
}
