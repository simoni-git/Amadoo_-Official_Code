//
//  CalendarVM.swift
//  NewCalendar
//
//  Created by 시모니 on 1/6/25.
//

import UIKit
import CoreData

class CalendarVM {
    
    var savedEvents: [NSManagedObject] = []
    var currentMonth: Date = Date()
    
    enum ButtonType: String {
        case defaultDay = "defaultDay"
        case periodDay = "periodDay"
        case multipleDay = "multipleDay"
    }
    
    func addDefaultCategory() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        request.predicate = NSPredicate(format: "isDefault == true")
        
        do {
            let result = try context.fetch(request)
            if result.isEmpty {
                let entity = NSEntityDescription.entity(forEntityName: "Category", in: context)!
                let defaultCategory = NSManagedObject(entity: entity, insertInto: context)
                defaultCategory.setValue("할 일", forKey: "name")
                defaultCategory.setValue("#808080", forKey: "color") // 회색
                defaultCategory.setValue(true, forKey: "isDefault")
                
                try context.save()
                
            }
        } catch {
            
        }
    }
    
    func getEventsForDate(_ date: Date) -> [(title: String, color: UIColor, isPeriod: Bool, isStart: Bool, isEnd: Bool, startDate: Date, endDate: Date)] {
        var events: [(title: String, color: UIColor, isPeriod: Bool, isStart: Bool, isEnd: Bool, startDate: Date, endDate: Date)] = []
        var addedEventTitles: Set<String> = []
        var eventLevels: [Int: String] = [:]
        
        let maxLevels = 4
        
        for event in savedEvents {
            guard let eventDate = event.value(forKey: "date") as? Date,
                  let title = event.value(forKey: "title") as? String,
                  let buttonType = event.value(forKey: "buttonType") as? String,
                  let startDay = event.value(forKey: "startDay") as? Date,
                  let endDay = event.value(forKey: "endDay") as? Date,
                  let colorString = event.value(forKey: "categoryColor") as? String else { continue }
        
            let color: UIColor = UIColor.fromHexString(colorString)
            let isPeriod = (buttonType == ButtonType.periodDay.rawValue)
            
            if addedEventTitles.contains(title + startDay.description) {
                continue
            }
            
            var assignedLevel: Int = -1
            
            if isPeriod {
                if date >= startDay && date <= endDay {
                    for level in 0..<maxLevels {
                        if eventLevels[level] == nil {
                            assignedLevel = level
                            eventLevels[level] = title
                            break
                        }
                    }
                    guard assignedLevel != -1 else { continue }
                    
                    let isStart = (date == startDay)
                    let isEnd = (date == endDay)
                    events.append((title: title, color: color, isPeriod: true, isStart: isStart, isEnd: isEnd, startDate: startDay, endDate: endDay))
                    addedEventTitles.insert(title + startDay.description)
                }
            } else {
                if Calendar.current.isDate(eventDate, inSameDayAs: date) {
                    for level in 0..<maxLevels {
                        if eventLevels[level] == nil {
                            assignedLevel = level
                            eventLevels[level] = title
                            break
                        }
                    }
                    guard assignedLevel != -1 else { continue }
                    
                    events.append((title: title, color: color, isPeriod: false, isStart: true, isEnd: true, startDate: eventDate, endDate: eventDate))
                    addedEventTitles.insert(title + startDay.description)
                }
            }
        }
        
        return events
    }
    
    //MARK: - CoreData 관련
    var context: NSManagedObjectContext {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }
        return app.persistentContainer.viewContext
    }
    
    func fetchSavedEvents() {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Schedule")
        
        do {
            savedEvents = try context.fetch(request)
        } catch  {
            
        }
    }
    
}
