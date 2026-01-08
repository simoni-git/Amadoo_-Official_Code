//
//  NetworkMonitorService.swift
//  NewCalendar
//
//  Data Layer - 네트워크 모니터링 서비스 (기존 NetworkSyncManager 래핑)
//

import Foundation

/// 네트워크 모니터링 서비스 (Protocol 구현체)
final class NetworkMonitorService: NetworkServiceProtocol {

    private let networkManager: NetworkSyncManager

    init(networkManager: NetworkSyncManager = .shared) {
        self.networkManager = networkManager
    }

    // MARK: - Connection Status

    var isConnected: Bool {
        return networkManager.getCurrentNetworkStatus()
    }

    // MARK: - Monitoring

    func startMonitoring() {
        // NetworkSyncManager에서 이미 모니터링 시작됨 (init 시점)
        // 추가 작업이 필요하면 여기에 구현
    }

    func stopMonitoring() {
        // 필요시 구현
        // NetworkSyncManager에서 stopMonitoring() 메서드가 있다면 호출
    }
}
