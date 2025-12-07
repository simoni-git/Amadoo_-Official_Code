//
//  DateHelper.swift
//  NewCalendar
//
//  Created by Claude Code on 12/8/24.
//

import Foundation

/// 날짜 계산 관련 유틸리티 클래스
/// CalendarVC와 AddDutyVC에서 중복되는 날짜 계산 로직을 통합
final class DateHelper {

    // MARK: - Singleton
    static let shared = DateHelper()
    private let calendar = Calendar.current
    private init() {}

    // MARK: - Month Information

    /// 주어진 날짜의 월의 첫 날을 반환
    /// - Parameter date: 기준 날짜
    /// - Returns: 해당 월의 첫 날, 실패 시 nil
    func firstDayOfMonth(from date: Date) -> Date? {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)
    }

    /// 주어진 날짜의 월의 첫 요일을 반환 (일요일: 0, 월요일: 1, ...)
    /// - Parameter date: 기준 날짜
    /// - Returns: 첫 요일 인덱스, 실패 시 nil
    func firstWeekdayOfMonth(from date: Date) -> Int? {
        guard let firstDay = firstDayOfMonth(from: date) else { return nil }
        return calendar.component(.weekday, from: firstDay) - 1
    }

    /// 주어진 날짜의 월의 일수를 반환
    /// - Parameter date: 기준 날짜
    /// - Returns: 해당 월의 일수, 실패 시 nil
    func numberOfDaysInMonth(from date: Date) -> Int? {
        guard let firstDay = firstDayOfMonth(from: date),
              let range = calendar.range(of: .day, in: .month, for: firstDay) else {
            return nil
        }
        return range.count
    }

    // MARK: - Date Calculations

    /// 달력 셀의 indexPath로부터 실제 날짜를 계산
    /// - Parameters:
    ///   - index: 컬렉션뷰 셀의 인덱스 (0부터 시작)
    ///   - currentMonth: 현재 표시 중인 월
    /// - Returns: 해당 셀의 날짜, 실패 시 nil
    func dateForCalendarCell(at index: Int, currentMonth: Date) -> Date? {
        guard let firstDay = firstDayOfMonth(from: currentMonth),
              let firstWeekday = firstWeekdayOfMonth(from: currentMonth) else {
            return nil
        }

        let daysOffset = index - firstWeekday
        return calendar.date(byAdding: .day, value: daysOffset, to: firstDay)
    }

    /// 특정 날짜가 현재 월에 속하는지 확인
    /// - Parameters:
    ///   - date: 확인할 날짜
    ///   - currentMonth: 현재 월
    /// - Returns: 같은 월이면 true
    func isDateInCurrentMonth(_ date: Date, currentMonth: Date) -> Bool {
        return calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }

    /// 두 날짜가 같은 날인지 확인
    /// - Parameters:
    ///   - date1: 첫 번째 날짜
    ///   - date2: 두 번째 날짜
    /// - Returns: 같은 날이면 true
    func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        return calendar.isDate(date1, inSameDayAs: date2)
    }

    /// 특정 시간으로 날짜 생성
    /// - Parameters:
    ///   - hour: 시간 (0-23)
    ///   - minute: 분 (0-59)
    ///   - second: 초 (0-59)
    ///   - date: 기준 날짜
    /// - Returns: 생성된 날짜, 실패 시 nil
    func date(bySettingHour hour: Int, minute: Int, second: Int, of date: Date) -> Date? {
        return calendar.date(bySettingHour: hour, minute: minute, second: second, of: date)
    }

    /// 날짜에 일수를 더하거나 빼기
    /// - Parameters:
    ///   - days: 더하거나 뺄 일수 (음수 가능)
    ///   - date: 기준 날짜
    /// - Returns: 계산된 날짜, 실패 시 nil
    func date(byAddingDays days: Int, to date: Date) -> Date? {
        return calendar.date(byAdding: .day, value: days, to: date)
    }

    /// 날짜에 월수를 더하거나 빼기
    /// - Parameters:
    ///   - months: 더하거나 뺄 월수 (음수 가능)
    ///   - date: 기준 날짜
    /// - Returns: 계산된 날짜, 실패 시 nil
    func date(byAddingMonths months: Int, to date: Date) -> Date? {
        return calendar.date(byAdding: .month, value: months, to: date)
    }

    // MARK: - Components

    /// 날짜에서 일(day) 컴포넌트 추출
    /// - Parameter date: 날짜
    /// - Returns: 일 (1-31)
    func day(from date: Date) -> Int {
        return calendar.component(.day, from: date)
    }

    /// 날짜의 시작 시간 (00:00:00) 반환
    /// - Parameter date: 날짜
    /// - Returns: 해당 날짜의 00:00:00
    func startOfDay(for date: Date) -> Date {
        return calendar.startOfDay(for: date)
    }

    // MARK: - Formatting

    /// 날짜를 "yyyy년 M월" 형식으로 포맷
    /// - Parameter date: 날짜
    /// - Returns: 포맷된 문자열
    func formatYearMonth(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월"
        return dateFormatter.string(from: date)
    }

    /// 날짜를 "yyyy.MM.dd" 형식으로 포맷
    /// - Parameter date: 날짜
    /// - Returns: 포맷된 문자열
    func formatYearMonthDay(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        return dateFormatter.string(from: date)
    }

    /// 날짜를 "M월 d일" 형식으로 포맷
    /// - Parameter date: 날짜
    /// - Returns: 포맷된 문자열
    func formatMonthDay(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M월 d일"
        return dateFormatter.string(from: date)
    }

    // MARK: - Layout Calculations

    /// 달력 컬렉션뷰의 행 개수 계산
    /// - Parameter currentMonth: 현재 월
    /// - Returns: 필요한 행 개수, 실패 시 6 (기본값)
    func numberOfRowsForCalendar(currentMonth: Date) -> Int {
        guard let firstWeekday = firstWeekdayOfMonth(from: currentMonth),
              let numberOfDays = numberOfDaysInMonth(from: currentMonth) else {
            return 6 // 기본값: 최대 6주
        }

        let totalCells = firstWeekday + numberOfDays
        return Int(ceil(Double(totalCells) / Double(Constants.Calendar.daysPerWeek)))
    }
}
