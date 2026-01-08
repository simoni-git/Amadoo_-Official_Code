//
//  UserNotificationManager.swift
//  NewCalendar
//
//  Created by 시모니 on 2/12/25.
//

import UIKit
import UserNotifications

class UserNotificationManager {
    static let shared = UserNotificationManager()
    private init() {}

    // MARK: - Clean Architecture Dependencies
    private var fetchSchedulesUseCase: FetchSchedulesUseCaseProtocol?

    /// 의존성 주입 메서드
    func injectDependencies(fetchSchedulesUseCase: FetchSchedulesUseCaseProtocol) {
        self.fetchSchedulesUseCase = fetchSchedulesUseCase
    }
    
    func checkNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    print("알림 권한 허용됨")
                    self.requestNotificationPermission()
                case .authorized, .provisional:
                    print("이미 알림 권한 허용됨")
                    self.updateNotification()
                case .denied:
                    print("알림 권한이 거부됨, 설정에서 변경 필요")
                default:
                    break
                }
            }
        }
    }
    
    func requestNotificationPermission() {
            print("requestNotificationPermission() - called")
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if granted {
                    print("알림 권한이 허용됨")
                    DispatchQueue.main.async {
                        self.updateNotification()
                    }
                } else {
                    print("알림 권한이 거부됨")
                }
            }
        }
    
    func updateNotification() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests() // 기존 알림 제거

        let now = Date()
        let calendar = Calendar.current

        // 오늘 오전 7시
        guard let today7AM = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: now) else {
            print("❌ Error: Unable to create 7AM time for today")
            return
        }

        // 오늘 포함 7일 동안 반복
        for i in 0...6 {
            let content = UNMutableNotificationContent()

            // i일 후의 날짜 계산
            let triggerDate = calendar.date(byAdding: .day, value: i, to: now) ?? now

            // 해당 날짜의 오전 7시 설정
            var triggerDateComponents = calendar.dateComponents([.year, .month, .day], from: triggerDate)
            triggerDateComponents.hour = 7
            triggerDateComponents.minute = 0
            triggerDateComponents.second = 0

            // 해당 날짜의 일정 개수 확인
            let itemCount = fetchItemCount(for: triggerDate)
            print("\(triggerDate)일의 일정 개수: \(itemCount)개")

            content.title = "아마두"
            content.body = "오늘은 \(itemCount)개의 일정이 있군요! \n새로운 하루, 새로운 기회! 오늘은 더 나은 나를 만나는 날😄"
            content.sound = .default

            let trigger: UNNotificationTrigger?

            if i == 0 {
                // 오늘의 알림: 오전 7시 이전이면 등록, 이후면 등록 안 함
                if now < today7AM {
                    trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
                    print("오늘(\(triggerDate)) 오전 7시 알림 등록 예정")
                } else {
                    trigger = nil
                    print("오늘 오전 7시가 이미 지나서 알림을 등록하지 않음")
                }
            } else {
                // 내일부터 6일간 알림 등록
                trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
                print("\(i)일 후(\(triggerDate)) 오전 7시 알림 등록 예정")
            }

            // 트리거가 nil이 아닐 때만 알림 추가
            if let validTrigger = trigger {
                let request = UNNotificationRequest(identifier: "day\(i)_notification", content: content, trigger: validTrigger)

                notificationCenter.add(request) { error in
                    if let error = error {
                        print("\(i)일 후 알림 등록 실패: \(error.localizedDescription)")
                    } else {
                        print("\(i)일 후 알림 등록 성공")
                    }
                }
            }
        }
    }

    func fetchItemCount(for date: Date) -> Int {
        guard let useCase = fetchSchedulesUseCase else {
            print("⚠️ FetchSchedulesUseCase가 주입되지 않음")
            return 0
        }

        let schedules = useCase.execute(for: date)
        print("일정의 갯수는 => \(schedules.count)")
        return schedules.count
    }

}
