//
//  ScheduleItem.swift
//  NewCalendar
//
//  Domain Entity - 일정
//

import Foundation

/// 일정 도메인 엔티티
/// Note: CoreData의 Schedule과 이름 충돌을 피하기 위해 ScheduleItem으로 명명
struct ScheduleItem: Identifiable, Equatable, Hashable {
    let id: UUID
    var title: String
    var date: Date
    var startDay: Date
    var endDay: Date
    var buttonType: DutyType
    var categoryColor: String

    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        startDay: Date,
        endDay: Date,
        buttonType: DutyType,
        categoryColor: String
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.startDay = startDay
        self.endDay = endDay
        self.buttonType = buttonType
        self.categoryColor = categoryColor
    }

    /// 해당 날짜가 일정 기간에 포함되는지 확인
    func contains(date: Date) -> Bool {
        let calendar = Calendar.current
        let startOfDate = calendar.startOfDay(for: date)
        let startOfStartDay = calendar.startOfDay(for: startDay)
        let startOfEndDay = calendar.startOfDay(for: endDay)

        return startOfDate >= startOfStartDay && startOfDate <= startOfEndDay
    }

    /// 기간 일정인지 확인
    var isPeriod: Bool {
        return buttonType == .periodDay
    }
}
