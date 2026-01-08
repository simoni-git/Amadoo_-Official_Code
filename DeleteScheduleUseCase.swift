//
//  DeleteScheduleUseCase.swift
//  NewCalendar
//
//  Domain Layer - 일정 삭제 UseCase
//

import Foundation

/// 일정 삭제 UseCase 프로토콜
protocol DeleteScheduleUseCaseProtocol {
    /// 단일 일정 삭제
    func execute(schedule: ScheduleItem) -> Result<Void, Error>

    /// 기간 일정 전체 삭제 (title과 startDay로 식별)
    func executeAll(title: String, startDay: Date) -> Result<Void, Error>
}

/// 일정 삭제 UseCase 구현체
final class DeleteScheduleUseCase: DeleteScheduleUseCaseProtocol {

    private let repository: ScheduleRepositoryProtocol
    private let syncService: SyncServiceProtocol

    init(
        repository: ScheduleRepositoryProtocol,
        syncService: SyncServiceProtocol
    ) {
        self.repository = repository
        self.syncService = syncService
    }

    func execute(schedule: ScheduleItem) -> Result<Void, Error> {
        let result = repository.delete(schedule)

        if case .success = result {
            syncService.syncIfNetworkAvailable()
            NotificationCenter.default.post(name: .eventDeleted, object: nil)
        }

        return result
    }

    func executeAll(title: String, startDay: Date) -> Result<Void, Error> {
        let result = repository.deleteAll(title: title, startDay: startDay)

        if case .success = result {
            syncService.syncIfNetworkAvailable()
            NotificationCenter.default.post(name: .eventDeleted, object: nil)
        }

        return result
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let eventDeleted = Notification.Name("EventDeleted")
}
