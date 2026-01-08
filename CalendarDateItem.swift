//
//  CalendarDateItem.swift
//  NewCalendar
//
//  캘린더 셀용 모델 (DiffableDataSource용)
//

import Foundation

/// 캘린더 날짜 셀 아이템
struct CalendarDateItem: Hashable {
    let id: UUID
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    let dayOfWeek: Int  // 0=일, 6=토
    let events: [ScheduleItem]

    init(
        id: UUID = UUID(),
        date: Date,
        isCurrentMonth: Bool,
        isToday: Bool,
        dayOfWeek: Int,
        events: [ScheduleItem] = []
    ) {
        self.id = id
        self.date = date
        self.isCurrentMonth = isCurrentMonth
        self.isToday = isToday
        self.dayOfWeek = dayOfWeek
        self.events = events
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: CalendarDateItem, rhs: CalendarDateItem) -> Bool {
        lhs.id == rhs.id
    }
}
