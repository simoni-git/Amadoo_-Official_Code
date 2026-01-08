//
//  NetworkServiceProtocol.swift
//  NewCalendar
//
//  Domain Protocol - 네트워크 서비스
//

import Foundation

/// 네트워크 서비스 프로토콜
protocol NetworkServiceProtocol {
    /// 현재 네트워크 연결 상태
    var isConnected: Bool { get }

    /// 네트워크 모니터링 시작
    func startMonitoring()

    /// 네트워크 모니터링 중지
    func stopMonitoring()
}
