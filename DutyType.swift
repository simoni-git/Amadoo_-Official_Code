//
//  DutyType.swift
//  NewCalendar
//
//  Created by Claude Code on 12/8/24.
//

import Foundation

/// 일정(Duty)의 날짜 타입을 정의하는 Enum
/// 단일 날짜, 기간, 복수 날짜를 구분
enum DutyType: String {
    /// 단일 날짜 일정
    case defaultDay = "defaultDay"

    /// 기간 일정 (시작일~종료일)
    case periodDay = "periodDay"

    /// 복수 날짜 일정 (여러 개별 날짜)
    case multipleDay = "multipleDay"
}
