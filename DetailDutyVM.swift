//
//  DetailDutyVM.swift
//  NewCalendar
//
//  Created by 시모니 on 1/7/25.
//

import UIKit
import CoreData

class DetailDutyVM {
    
    var events: [NSManagedObject] = []
    var selectedDate: Date?
    var selecDateString: String?
    var dDayString: String?
    let coreDataManager = CoreDataManager.shared
    let userNotificationManager = UserNotificationManager.shared

    // DutyType을 ButtonType으로 사용 (기존 코드와의 호환성 유지)
    typealias ButtonType = DutyType

    func fetchEventsForSelectedDate(completion: @escaping () -> Void) {
        guard let date = selectedDate else {
            return
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let request = NSFetchRequest<NSManagedObject>(entityName: "Schedule")
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        
        do {
            events = try coreDataManager.context.fetch(request)
            completion()
        } catch {
            
        }
    }
    
}
