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
    
    enum ButtonType: String {
        case defaultDay = "defaultDay"
        case periodDay = "periodDay"
        case multipleDay = "multipleDay"
    }
    
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
            events = try context.fetch(request)
            completion()
        } catch {
            
        }
    }
    
    
    //MARK: - CoreData 저장관련
    var context: NSManagedObjectContext {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get shared context")
        }
        return app.persistentContainer.viewContext
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            
        }
    }
    
}
