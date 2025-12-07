//
//  Constants.swift
//  NewCalendar
//
//  Created by Claude Code on 12/8/24.
//

import UIKit

/// 앱 전체에서 사용하는 상수들을 정의
struct Constants {

    /// UI 관련 상수
    struct UI {
        /// 표준 corner radius (버튼, 뷰 등)
        static let standardCornerRadius: CGFloat = 10

        /// 작은 corner radius (셀 내부 요소 등)
        static let smallCornerRadius: CGFloat = 8

        /// 달력 셀 배경색 투명도
        static let cellBackgroundAlpha: CGFloat = 0.2
    }

    /// 달력 관련 상수
    struct Calendar {
        /// 달력에 표시되는 총 셀 개수 (6주 × 7일)
        static let totalCells = 42

        /// 주당 일수
        static let daysPerWeek = 7

        /// 각 날짜에 표시할 최대 이벤트 개수
        static let maxDisplayedEvents = 4

        /// 하루의 초 단위 시간
        static let secondsPerDay: TimeInterval = 86400
    }

    /// Core Data Entity 이름
    struct Entity {
        static let schedule = "Schedule"
        static let category = "Category"
        static let checkList = "CheckList"
        static let memo = "Memo"
        static let timeTable = "TimeTable"
    }

    /// Storyboard Identifier
    struct StoryboardID {
        static let warningVC = "WarningVC"
        static let addDutyVC = "AddDutyVC"
        static let detailDutyVC = "DetailDutyVC"
        static let categoryVC = "CategoryVC"
        static let editCategoryVC = "EditCategoryVC"
        static let selectCategoryVC = "SelectCategoryVC"
        static let categoryDeletePopupVC = "CategoryDeletePopupVC"
        static let memoVC = "MemoVC"
        static let addDefaultVerMemoVC = "AddDefaultVerMemoVC"
        static let addCheckVerMemoVC = "AddCheckVerMemoVC"
        static let memoDefaultVerDetailVC = "MemoDefaultVerDetailVC"
        static let memoCheckVerDetailVC = "MemoCheckVerDetailVC"
        static let editMemoCheckVerWarningVC = "EditMemoCheckVer_WarningVC"
        static let timeTableVC = "TimeTableVC"
        static let addTimeVC = "AddTimeVC"
        static let editTimeVC = "EditTimeVC"
    }

    /// 지연 시간 (초 단위)
    struct Delay {
        static let short: TimeInterval = 0.5
        static let medium: TimeInterval = 2.0
        static let long: TimeInterval = 3.0
        static let cloudKitDebug: TimeInterval = 5.0
    }

    /// Notification 이름
    struct NotificationName {
        static let scheduleSaved = "ScheduleSaved"
        static let eventDeleted = "EventDeleted"
        static let cloudKitDataUpdated = "cloudKitDataUpdated"
        static let networkReconnected = "networkReconnected"
    }

    /// 알림 관련 상수
    struct Notification {
        /// 알림 시간 (오전 7시)
        static let scheduleHour = 7
        static let scheduleMinute = 0

        /// 알림 설정 일수 (오늘 포함 7일)
        static let scheduleDays = 7
    }

    /// 색상 관련 상수
    struct Color {
        /// 기본 회색 색상
        static let defaultGray = "#808080"

        /// 연한 베이지 색상
        static let lightBeige = "#F8EDE3"
    }
}
