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
    
    var isEditMode: Bool = false
    var originDuty: NSManagedObject!
    
    var originButtonType: String!
    var originCategoryColor: String!
    var originTitle: String!
    var originDate: Date!
    var originStartDate: Date!
    var originEndDate: Date!
    
    var editTitle: String?
    var editDate: Date?
    var editStartDate: Date?
    var editEndDate: Date?
    
    let coreDataManager = CoreDataManager.shared
    
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
    
    func saveSingleDate(text: String, date: Date) {
        let entity = NSEntityDescription.entity(forEntityName: "Schedule", in:coreDataManager.context)
        let newSchedule = NSManagedObject(entity: entity!, insertInto: coreDataManager.context)
        newSchedule.setValue(text, forKey: "title")
        newSchedule.setValue(date, forKey: "date")
        newSchedule.setValue(date, forKey: "startDay")
        newSchedule.setValue(date, forKey: "endDay")
        newSchedule.setValue(selectedButtonType.rawValue, forKey: "buttonType")
        
        if let colorHex = selectedCategoryColorHex {
            newSchedule.setValue(colorHex, forKey: "categoryColor")
        }
        
        coreDataManager.saveContext()
    }
    
    func savePeriodDates(text: String, startDate: Date, endDate: Date , categoryColor: String) {
        var currentDate = startDate
        
        while currentDate <= endDate {
            let entity = NSEntityDescription.entity(forEntityName: "Schedule", in: coreDataManager.context)
            let newSchedule = NSManagedObject(entity: entity!, insertInto: coreDataManager.context)
            newSchedule.setValue(text, forKey: "title")
            newSchedule.setValue(currentDate, forKey: "date")
            newSchedule.setValue(startDate, forKey: "startDay")
            newSchedule.setValue(endDate, forKey: "endDay")
            newSchedule.setValue(selectedButtonType.rawValue, forKey: "buttonType")
            newSchedule.setValue(categoryColor, forKey: "categoryColor")
            
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        coreDataManager.saveContext()
    }
    
    func saveMultipleDates(text: String, dates: [Date]) {
        for date in dates {
            let entity = NSEntityDescription.entity(forEntityName: "Schedule", in: coreDataManager.context)
            let newSchedule = NSManagedObject(entity: entity!, insertInto: coreDataManager.context)
            newSchedule.setValue(text, forKey: "title")
            newSchedule.setValue(date, forKey: "date")
            newSchedule.setValue(date, forKey: "startDay")
            newSchedule.setValue(date, forKey: "endDay")
            newSchedule.setValue(selectedButtonType.rawValue, forKey: "buttonType")
            
            if let colorHex = selectedCategoryColorHex {
                newSchedule.setValue(colorHex, forKey: "categoryColor")
            }
        }
        
        coreDataManager.saveContext()
    }
    
    func fetchAndUpdateSchedule(title: String, categoryColor: String, date: Date, startDate: Date, endDate: Date) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Schedule")
        fetchRequest.predicate = NSPredicate(format: "title == %@ AND categoryColor == %@ AND date == %@ AND startDay == %@ AND endDay == %@" , title, categoryColor, date as CVarArg, startDate as CVarArg, endDate as CVarArg)
        
        do {
            let results = try coreDataManager.context.fetch(fetchRequest)
            
            if let scheduleToUpdate = results.first { 
                scheduleToUpdate.setValue(editTitle ?? title, forKey: "title")
                scheduleToUpdate.setValue(selectedCategoryColorHex ?? categoryColor, forKey: "categoryColor")
                scheduleToUpdate.setValue(editDate ?? date, forKey: "date")
                scheduleToUpdate.setValue(editDate ?? date, forKey: "startDay")
                scheduleToUpdate.setValue(editDate ?? date, forKey: "endDay")
                coreDataManager.saveContext()
            } else {
                print("해당 일정이 존재하지 않습니다.")
            }
            
        } catch {
            print("데이터를 가져오는 중 오류 발생: \(error)")
        }
    }
    
    func fetchAndUpdatePeriodSchedule(title: String, categoryColor: String, buttonType: String, startDate: Date, endDate: Date) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Schedule")
        fetchRequest.predicate = NSPredicate(format: "title == %@ AND categoryColor == %@ AND buttonType == %@ AND startDay == %@ AND endDay == %@", title, categoryColor, buttonType, startDate as CVarArg, endDate as CVarArg
        )
        
        do {
            let results = try coreDataManager.context.fetch(fetchRequest)
            
            if results.isEmpty {
                print("해당 기간 일정이 존재하지 않습니다.")
                return
            }
            
            for schedule in results {
                schedule.setValue(editTitle ?? title, forKey: "title")
                schedule.setValue(selectedCategoryColorHex ?? categoryColor, forKey: "categoryColor")
                schedule.setValue(editStartDate ?? startDate, forKey: "startDay")
                schedule.setValue(editEndDate ?? endDate, forKey: "endDay")
            }
            coreDataManager.saveContext()
            
        } catch {
            print("데이터를 가져오는 중 오류 발생: \(error)")
        }
    }
    
}
