//
//  DeleteTimeTableUseCase.swift
//  NewCalendar
//
//  Domain Layer - 시간표 삭제 UseCase
//

import Foundation

/// 시간표 삭제 UseCase 프로토콜
protocol DeleteTimeTableUseCaseProtocol {
    /// 시간표 항목 삭제
    func execute(item: TimeTableItem) -> Result<Void, Error>
}

/// 시간표 삭제 UseCase 구현체
final class DeleteTimeTableUseCase: DeleteTimeTableUseCaseProtocol {

    private let repository: TimeTableRepositoryProtocol
    private let syncService: SyncServiceProtocol

    init(
        repository: TimeTableRepositoryProtocol,
        syncService: SyncServiceProtocol
    ) {
        self.repository = repository
        self.syncService = syncService
    }

    func execute(item: TimeTableItem) -> Result<Void, Error> {
        let result = repository.delete(item)

        if case .success = result {
            syncService.syncIfNetworkAvailable()
        }

        return result
    }
}
