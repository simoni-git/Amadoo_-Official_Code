//
//  CategoryItem.swift
//  NewCalendar
//
//  Domain Entity - 카테고리
//

import Foundation

/// 카테고리 도메인 엔티티
/// Note: CoreData의 Category와 이름 충돌을 피하기 위해 CategoryItem으로 명명
struct CategoryItem: Identifiable, Equatable {
    let id: UUID
    var name: String
    var color: String
    var isDefault: Bool

    init(
        id: UUID = UUID(),
        name: String,
        color: String,
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.isDefault = isDefault
    }

    /// 기본 카테고리 생성
    static func createDefault() -> CategoryItem {
        return CategoryItem(
            name: "할 일",
            color: "#808080",
            isDefault: true
        )
    }

    /// 유효한 카테고리인지 확인
    var isValid: Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty &&
               trimmed != "Unknown" &&
               !trimmed.hasPrefix("마이그레이션")
    }
}
