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
    let coreDataManager = CoreDataManager.shared
    let userNotificationManager = UserNotificationManager.shared
    
    enum ButtonType: String {
        case defaultDay = "defaultDay"
        case periodDay = "periodDay"
        case multipleDay = "multipleDay"
    }
    
    func addDefaultCategory() {
        // CloudKit 동기화가 완료될 때까지 잠시 대기
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            let context = self.coreDataManager.context
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
            
            do {
                let allCategories = try context.fetch(request)
                
                // 전체 카테고리가 없을 때만 기본 카테고리 생성
                if allCategories.isEmpty {
                    let entity = NSEntityDescription.entity(forEntityName: "Category", in: context)!
                    let defaultCategory = NSManagedObject(entity: entity, insertInto: context)
                    defaultCategory.setValue("할 일", forKey: "name")
                    defaultCategory.setValue("#808080", forKey: "color")
                    defaultCategory.setValue(true, forKey: "isDefault")
                    
                    self.coreDataManager.saveContext()
                    print("기본 카테고리 '할 일' 생성됨")
                } else {
                    print("카테고리가 이미 존재함 (CloudKit에서 복원되었거나 기존 데이터)")
                }
            } catch {
                print("카테고리 확인 실패: \(error)")
            }
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
    
    func fetchSavedEvents() {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Schedule")
        
        do {
            savedEvents = try coreDataManager.context.fetch(request)
        } catch  {
            
        }
    }
    
}
