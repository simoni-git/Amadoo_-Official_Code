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
    var minimumHour: Int  // 추가
    var maximumHour: Int  // 추가
    init(selectedHour: Int, minimumHour: Int, maximumHour: Int) {
            self.minimumHour = minimumHour
            self.maximumHour = maximumHour
            
            let calendar = Calendar.current
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
            dateComponents.hour = selectedHour
            dateComponents.minute = 0
            
            self.selectedDate = calendar.date(from: dateComponents) ?? Date()
            self.endDate = calendar.date(byAdding: .hour, value: 1, to: self.selectedDate) ?? Date()
        }
}
