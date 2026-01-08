//
//  FetchTimeTableUseCase.swift
//  NewCalendar
//
//  Domain Layer - 시간표 조회 UseCase
//

import Foundation

/// 시간표 조회 UseCase 프로토콜
protocol FetchTimeTableUseCaseProtocol {
    /// 모든 시간표 조회
    func execute() -> [TimeTableItem]

    /// 특정 요일의 시간표 조회
    func execute(for dayOfWeek: Int) -> [TimeTableItem]

    /// 요일별로 그룹화된 시간표 조회
    func executeGroupedByDay() -> [Int: [TimeTableItem]]

    /// 시간표 시간 범위 조회
    func getTimeRange() -> (startHour: Int, endHour: Int)
}

/// 시간표 조회 UseCase 구현체
final class FetchTimeTableUseCase: FetchTimeTableUseCaseProtocol {

    private let repository: TimeTableRepositoryProtocol

    init(repository: TimeTableRepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> [TimeTableItem] {
        return repository.fetchAll()
    }

    func execute(for dayOfWeek: Int) -> [TimeTableItem] {
        return repository.fetch(for: dayOfWeek)
    }

    func executeGroupedByDay() -> [Int: [TimeTableItem]] {
        return repository.fetchGroupedByDay()
    }

    func getTimeRange() -> (startHour: Int, endHour: Int) {
        return repository.getTimeRange()
    }
}
