//
//  AddDutyVM.swift
//  NewCalendar
//
//  Created by 시모니 on 1/7/25.
//

import UIKit
import CoreData

class AddDutyVM {
    
    var currentMonth: Date = Date()
    var selectedButtonType: ButtonType = .defaultDay
    var selectedStartDate: Date?
    var selectedEndDate: Date?
    var selectedMultipleDates: [Date] = []
    var selectedSingleDate: Date?
    var todayMounth: Date?
    var todayMounthString: String?
    var selectedCategoryColorHex: String?
    var selectedCategoryColorName: String?
    
    enum ButtonType: String {
        case defaultDay = "defaultDay"
        case periodDay = "periodDay"
        case multipleDay = "multipleDay"
    }
    
    func getFormattedMonth() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM월 yyyy"
        return dateFormatter.string(from: todayMounth!)
    }
    
    //MARK: - CoreData 저장관련
    var context: NSManagedObjectContext {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }
        return app.persistentContainer.viewContext
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            
        }
    }
    
    func saveSingleDate(text: String, date: Date) {
        let entity = NSEntityDescription.entity(forEntityName: "Schedule", in: context)
        let newSchedule = NSManagedObject(entity: entity!, insertInto: context)
        newSchedule.setValue(text, forKey: "title")
        newSchedule.setValue(date, forKey: "date")
        newSchedule.setValue(date, forKey: "startDay")
        newSchedule.setValue(date, forKey: "endDay")
        newSchedule.setValue(selectedButtonType.rawValue, forKey: "buttonType")
        
        if let colorHex = selectedCategoryColorHex {
            newSchedule.setValue(colorHex, forKey: "categoryColor")
        }
        
        saveContext()
    }
    
    func savePeriodDates(text: String, startDate: Date, endDate: Date) {
        var currentDate = startDate
        
        while currentDate <= endDate {
            let entity = NSEntityDescription.entity(forEntityName: "Schedule", in: context)
            let newSchedule = NSManagedObject(entity: entity!, insertInto: context)
            newSchedule.setValue(text, forKey: "title")
            newSchedule.setValue(currentDate, forKey: "date")
            newSchedule.setValue(startDate, forKey: "startDay")
            newSchedule.setValue(endDate, forKey: "endDay")
            newSchedule.setValue(selectedButtonType.rawValue, forKey: "buttonType")
            
            if let colorHex = selectedCategoryColorHex {
                newSchedule.setValue(colorHex, forKey: "categoryColor")
            }
            
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        saveContext()
    }
    
    func saveMultipleDates(text: String, dates: [Date]) {
        for date in dates {
            let entity = NSEntityDescription.entity(forEntityName: "Schedule", in: context)
            let newSchedule = NSManagedObject(entity: entity!, insertInto: context)
            newSchedule.setValue(text, forKey: "title")
            newSchedule.setValue(date, forKey: "date")
            newSchedule.setValue(date, forKey: "startDay")
            newSchedule.setValue(date, forKey: "endDay")
            newSchedule.setValue(selectedButtonType.rawValue, forKey: "buttonType")
            
            if let colorHex = selectedCategoryColorHex {
                newSchedule.setValue(colorHex, forKey: "categoryColor")
            }
        }
        
        saveContext()
    }
    
}
