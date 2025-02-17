//
//  UserNotificationManager.swift
//  NewCalendar
//
//  Created by 시모니 on 2/12/25.
//

import UIKit
import UserNotifications
import CoreData

class UserNotificationManager {
    static let shared = UserNotificationManager()
    private init() {}
    var context: NSManagedObjectContext {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }
        return app.persistentContainer.viewContext
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
        // 모든 알림을 지움
        notificationCenter.removeAllPendingNotificationRequests()
        
        // 오늘부터 7일간의 날짜에 대해 알림을 설정
        for i in 1...7 {
            let content = UNMutableNotificationContent()
            
            // 오늘 날짜로부터 1일, 2일, ..., 7일 후의 날짜 계산
            let triggerDate = Calendar.current.date(byAdding: .day, value: i, to: Date()) ?? Date()
            
            // 7일 뒤의 알림 시간을 오전 7시로 설정
            let calendar = Calendar.current
            var triggerDateComponents = calendar.dateComponents([.year, .month, .day], from: triggerDate)
            triggerDateComponents.hour = 7  // 오전 7시 설정
            triggerDateComponents.minute = 0
            triggerDateComponents.second = 0
            
            // 해당 날짜의 아이템 갯수를 계산
            let itemCount = fetchItemCount(for: triggerDate)
            print("\(triggerDate)일의 일정 개수: \(itemCount)개")
            // 알림 내용 설정
            content.title = "아마두"
            content.body = "오늘은 \(itemCount)개의 일정이 있군요! \n새로운 하루, 새로운 기회! 오늘은 더 나은 나를 만나는 날😄"
            content.sound = .default
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
            
            // 알림 등록
            let request = UNNotificationRequest(identifier: "day\(i)_notification", content: content, trigger: trigger)

            notificationCenter.add(request) { error in
                if let error = error {
                    print("\(i)일 후 알림 등록 실패: \(error.localizedDescription)")
                } else {
                    print("\(i)일 후 알림 등록 성공")
                }
            }
        }
    }
    
    func fetchItemCount(for date: Date) -> Int {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Schedule")
        
        // 해당 날짜와 정확히 일치하는 날짜를 찾기 위한 predicate 설정
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        fetchRequest.predicate = NSPredicate(format: "date == %@", startOfDay as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            print("일정의 갯수는 => \(results.count)")
            return results.count  // 해당 날짜에 해당하는 일정의 개수를 반환
        } catch {
            print("일정 개수 가져오기 실패: \(error.localizedDescription)")
            return 0  // 에러가 나면 0개로 간주
        }
    }

}
