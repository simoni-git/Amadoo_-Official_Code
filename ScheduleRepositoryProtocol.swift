//
//  ScheduleRepositoryProtocol.swift
//  NewCalendar
//
//  Domain Protocol - 일정 저장소
//

import Foundation

/// 일정 저장소 프로토콜
protocol ScheduleRepositoryProtocol {
    /// 모든 일정 조회
    func fetchAll() -> [ScheduleItem]

    /// 특정 날짜의 일정 조회
    func fetch(for date: Date) -> [ScheduleItem]

    /// 기간 내 일정 조회
    func fetch(from startDate: Date, to endDate: Date) -> [ScheduleItem]

    /// 일정 저장
    func save(_ schedule: ScheduleItem) -> Result<ScheduleItem, Error>

    /// 기간 일정 저장 (날짜별로 여러 개 생성)
    func savePeriod(
        title: String,
        startDate: Date,
        endDate: Date,
        categoryColor: String,
        buttonType: DutyType
    ) -> Result<[ScheduleItem], Error>

    /// 일정 수정
    func update(_ schedule: ScheduleItem) -> Result<ScheduleItem, Error>

    /// 일정 삭제
    func delete(_ schedule: ScheduleItem) -> Result<Void, Error>

    /// 조건에 맞는 모든 일정 삭제 (title과 startDay 기준)
    func deleteAll(title: String, startDay: Date) -> Result<Void, Error>
}
