//
//  MemoItem.swift
//  NewCalendar
//
//  Domain Entity - 메모
//

import Foundation

/// 메모 도메인 엔티티
struct MemoItem: Identifiable, Equatable {
    let id: UUID
    var title: String
    var memoText: String?
    var memoType: String

    init(
        id: UUID = UUID(),
        title: String,
        memoText: String? = nil,
        memoType: String
    ) {
        self.id = id
        self.title = title
        self.memoText = memoText
        self.memoType = memoType
    }

    /// 기본 메모 타입인지 확인
    var isDefaultType: Bool {
        return memoType == "default" || memoType == "defaultVer"
    }
}
