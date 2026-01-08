//
//  FetchSchedulesUseCase.swift
//  NewCalendar
//
//  Domain Layer - 일정 조회 UseCase
//

import Foundation

/// 일정 조회 UseCase 프로토콜
protocol FetchSchedulesUseCaseProtocol {
    /// 모든 일정 조회
    func execute() -> [ScheduleItem]

    /// 특정 날짜의 일정 조회
    func execute(for date: Date) -> [ScheduleItem]

    /// 기간 내 일정 조회
    func execute(from startDate: Date, to endDate: Date) -> [ScheduleItem]
}

/// 일정 조회 UseCase 구현체
final class FetchSchedulesUseCase: FetchSchedulesUseCaseProtocol {

    private let repository: ScheduleRepositoryProtocol

    init(repository: ScheduleRepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> [ScheduleItem] {
        return repository.fetchAll()
    }

    func execute(for date: Date) -> [ScheduleItem] {
        return repository.fetch(for: date)
    }

    func execute(from startDate: Date, to endDate: Date) -> [ScheduleItem] {
        return repository.fetch(from: startDate, to: endDate)
    }
}
