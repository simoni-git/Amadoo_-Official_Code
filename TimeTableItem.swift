//
//  TimeTableItem.swift
//  NewCalendar
//
//  Domain Entity - 시간표 항목
//

import Foundation

/// 시간표 도메인 엔티티
struct TimeTableItem: Identifiable, Equatable {
    let id: UUID
    var dayOfWeek: Int16      // 0: 월요일 ~ 4: 금요일
    var startTime: String     // "HH:mm" 형식
    var endTime: String       // "HH:mm" 형식
    var title: String
    var memo: String?
    var color: String

    init(
        id: UUID = UUID(),
        dayOfWeek: Int16,
        startTime: String,
        endTime: String,
        title: String,
        memo: String? = nil,
        color: String
    ) {
        self.id = id
        self.dayOfWeek = dayOfWeek
        self.startTime = startTime
        self.endTime = endTime
        self.title = title
        self.memo = memo
        self.color = color
    }

    /// 시간 문자열을 시간과 분으로 파싱
    func parseTime(_ timeString: String) -> (hour: Int, minute: Int)? {
        let components = timeString.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return nil
        }
        return (hour, minute)
    }

    /// 시작 시간 (시)
    var startHour: Int? {
        return parseTime(startTime)?.hour
    }

    /// 종료 시간 (시)
    var endHour: Int? {
        return parseTime(endTime)?.hour
    }

    /// 요일 이름
    var dayName: String {
        let dayNames = ["월", "화", "수", "목", "금"]
        guard dayOfWeek >= 0 && dayOfWeek < dayNames.count else {
            return ""
        }
        return dayNames[Int(dayOfWeek)]
    }
}
