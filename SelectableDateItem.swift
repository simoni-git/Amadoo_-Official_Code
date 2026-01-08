//
//  SelectableDateItem.swift
//  NewCalendar
//
//  일정 추가 화면 날짜 선택용 모델 (DiffableDataSource용)
//

import Foundation

/// 선택 가능한 날짜 아이템
struct SelectableDateItem: Hashable {
    let id: UUID
    let date: Date
    let isCurrentMonth: Bool
    let isSelected: Bool
    let isInRange: Bool  // 기간 선택 시 범위 내 여부
    let dayOfWeek: Int  // 0=일, 6=토

    init(
        id: UUID = UUID(),
        date: Date,
        isCurrentMonth: Bool,
        isSelected: Bool = false,
        isInRange: Bool = false,
        dayOfWeek: Int
    ) {
        self.id = id
        self.date = date
        self.isCurrentMonth = isCurrentMonth
        self.isSelected = isSelected
        self.isInRange = isInRange
        self.dayOfWeek = dayOfWeek
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: SelectableDateItem, rhs: SelectableDateItem) -> Bool {
        lhs.id == rhs.id
    }
}
