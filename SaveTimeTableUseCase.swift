//
//  SaveTimeTableUseCase.swift
//  NewCalendar
//
//  Domain Layer - 시간표 저장 UseCase
//

import Foundation

/// 시간표 저장 UseCase 프로토콜
protocol SaveTimeTableUseCaseProtocol {
    /// 시간표 항목 저장
    func execute(item: TimeTableItem) -> Result<TimeTableItem, Error>

    /// 시간표 항목 수정
    func executeUpdate(item: TimeTableItem) -> Result<TimeTableItem, Error>

    /// 시간표 시간 범위 저장
    func saveTimeRange(startHour: Int, endHour: Int)
}

/// 시간표 저장 UseCase 구현체
final class SaveTimeTableUseCase: SaveTimeTableUseCaseProtocol {

    private let repository: TimeTableRepositoryProtocol
    private let syncService: SyncServiceProtocol

    init(
        repository: TimeTableRepositoryProtocol,
        syncService: SyncServiceProtocol
    ) {
        self.repository = repository
        self.syncService = syncService
    }

    func execute(item: TimeTableItem) -> Result<TimeTableItem, Error> {
        let result = repository.save(item)

        if case .success = result {
            syncService.syncIfNetworkAvailable()
        }

        return result
    }

    func executeUpdate(item: TimeTableItem) -> Result<TimeTableItem, Error> {
        let result = repository.update(item)

        if case .success = result {
            syncService.syncIfNetworkAvailable()
        }

        return result
    }

    func saveTimeRange(startHour: Int, endHour: Int) {
        repository.saveTimeRange(startHour: startHour, endHour: endHour)
    }
}
