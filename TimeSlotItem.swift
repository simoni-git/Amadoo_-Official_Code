//
//  TimeSlotItem.swift
//  NewCalendar
//
//  시간표 셀용 모델 (DiffableDataSource용)
//

import Foundation

/// 시간표 슬롯 아이템
struct TimeSlotItem: Hashable {
    let id: UUID
    let dayOfWeek: Int  // 0=월, 4=금
    let hour: Int
    let minute: Int  // 0 or 30
    let timetable: TimeTableItem?
    let isFirstSlotOfSubject: Bool

    init(
        id: UUID = UUID(),
        dayOfWeek: Int,
        hour: Int,
        minute: Int,
        timetable: TimeTableItem? = nil,
        isFirstSlotOfSubject: Bool = false
    ) {
        self.id = id
        self.dayOfWeek = dayOfWeek
        self.hour = hour
        self.minute = minute
        self.timetable = timetable
        self.isFirstSlotOfSubject = isFirstSlotOfSubject
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: TimeSlotItem, rhs: TimeSlotItem) -> Bool {
        lhs.id == rhs.id
    }
}
