//
//  AddTimeVM.swift
//  NewCalendar
//
//  Created by 시모니의 맥북 on 11/26/25.
//

import Foundation

class AddTimeVM {
    var selectedDate: Date
    var endDate: Date
    var minimumHour: Int
    var maximumHour: Int
    var dayOfWeek: Int
    var selectColorCode: String? = ""
    var selectColorName: String? = ""
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
    
    init(selectedHour: Int, minimumHour: Int, maximumHour: Int, dayOfWeek: Int) {
        self.minimumHour = minimumHour
        self.maximumHour = maximumHour
        self.dayOfWeek = dayOfWeek  // 추가
        
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        dateComponents.hour = selectedHour
        dateComponents.minute = 0
        
        self.selectedDate = calendar.date(from: dateComponents) ?? Date()
        self.endDate = calendar.date(byAdding: .hour, value: 1, to: self.selectedDate) ?? Date()
    }
    
}
