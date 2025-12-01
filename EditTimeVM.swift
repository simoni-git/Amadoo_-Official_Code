//
//  EditTimeVM.swift
//  NewCalendar
//
//  Created by 시모니의 맥북 on 12/1/25.
//


import Foundation
import CoreData

class EditTimeVM {
    var timetable: NSManagedObject
    var title: String
    var startTime: String
    var endTime: String
    var memo: String?
    var color: String
    var selectedColorCode: String  // ⭐ 추가
    var dayOfWeek: Int
    var minimumHour: Int
    var maximumHour: Int
    
    let colors = [
        (name: "프렌치로즈", code: "ECBDBF"),
        (name: "라이트오렌지", code: "FFB124"),
        (name: "머스타드옐로우", code: "DBC557"),
        (name: "에메랄드그린", code: "8FBC91"),
        (name: "스카이블루", code: "A5CBF0"),
        (name: "다크블루", code: "446592"),
        (name: "소프트바이올렛", code: "A495C6"),
        (name: "파스텔브라운", code: "BBA79C")
    ]
    
    init(timetable: NSManagedObject, minimumHour: Int, maximumHour: Int) {
        self.timetable = timetable
        self.minimumHour = minimumHour
        self.maximumHour = maximumHour
        
        self.title = timetable.value(forKey: "title") as? String ?? ""
        self.startTime = timetable.value(forKey: "startTime") as? String ?? "09:00"
        self.endTime = timetable.value(forKey: "endTime") as? String ?? "10:00"
        self.memo = timetable.value(forKey: "memo") as? String
        self.color = timetable.value(forKey: "color") as? String ?? "ECBDBF"
        self.selectedColorCode = self.color 
        self.dayOfWeek = Int(timetable.value(forKey: "dayOfWeek") as? Int16 ?? 0)
    }
    
    // 시간 문자열을 Date로 변환
    func getStartDate() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        
        if let time = formatter.date(from: startTime) {
            let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute
        }
        
        return calendar.date(from: components) ?? Date()
    }
    
    func getEndDate() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        
        if let time = formatter.date(from: endTime) {
            let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute
        }
        
        return calendar.date(from: components) ?? Date()
    }
    
    // 색상 인덱스 찾기
    func getColorIndex() -> Int? {
        return colors.firstIndex { $0.code == color }
    }
}
