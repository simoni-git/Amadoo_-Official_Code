//
//  CheckListItem.swift
//  NewCalendar
//
//  Domain Entity - 체크리스트 항목
//

import Foundation

/// 체크리스트 도메인 엔티티
struct CheckListItem: Identifiable, Equatable {
    let id: UUID
    var title: String         // 체크리스트 그룹 제목
    var name: String?         // 개별 항목 이름
    var isComplete: Bool
    var memoType: String

    init(
        id: UUID = UUID(),
        title: String,
        name: String? = nil,
        isComplete: Bool = false,
        memoType: String
    ) {
        self.id = id
        self.title = title
        self.name = name
        self.isComplete = isComplete
        self.memoType = memoType
    }

    /// 체크리스트 타입인지 확인
    var isCheckListType: Bool {
        return memoType == "check" || memoType == "checkVer"
    }

    /// 완료 상태 토글
    mutating func toggleComplete() {
        isComplete = !isComplete
    }
}
