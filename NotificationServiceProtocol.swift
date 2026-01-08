//
//  NotificationServiceProtocol.swift
//  NewCalendar
//
//  Domain Layer - 알림 서비스 프로토콜
//

import Foundation

/// 알림 서비스 프로토콜
/// ViewModel이 싱글톤에 직접 의존하지 않도록 추상화
protocol NotificationServiceProtocol {
    /// 알림 권한 확인 및 요청
    func checkNotificationPermission()

    /// 알림 업데이트 (일정 변경 시 호출)
    func updateNotification()
}
