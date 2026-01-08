//
//  SyncServiceProtocol.swift
//  NewCalendar
//
//  Domain Protocol - 동기화 서비스
//

import Foundation

/// CloudKit 상태
enum CloudKitAccountStatus {
    case available
    case noAccount
    case restricted
    case quotaExceeded
    case unknown
}

/// 동기화 서비스 프로토콜
protocol SyncServiceProtocol {
    /// iCloud 계정 상태 확인 (간단)
    func checkAccountStatus(completion: @escaping (Bool) -> Void)

    /// iCloud 계정 상태 상세 확인
    func checkDetailedAccountStatus(completion: @escaping (CloudKitAccountStatus, String?) -> Void)

    /// 수동 동기화 트리거
    func triggerSync()

    /// 네트워크 가용 시 동기화
    func syncIfNetworkAvailable()

    /// 기존 데이터 CloudKit에 업로드
    func uploadExistingData()
}
