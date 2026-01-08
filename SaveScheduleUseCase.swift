//
//  SaveScheduleUseCase.swift
//  NewCalendar
//
//  Domain Layer - 일정 저장 UseCase
//

import Foundation

/// 일정 저장 UseCase 프로토콜
protocol SaveScheduleUseCaseProtocol {
    /// 단일 일정 저장
    func execute(schedule: ScheduleItem) -> Result<ScheduleItem, Error>

    /// 기간/복수 일정 저장
    func execute(
        title: String,
        startDate: Date,
        endDate: Date,
        categoryColor: String,
        buttonType: DutyType
    ) -> Result<[ScheduleItem], Error>

    /// 단일 일정 수정
    func executeUpdate(schedule: ScheduleItem) -> Result<ScheduleItem, Error>

    /// 기간 일정 수정 (기존 삭제 후 새로 생성)
    func executeUpdatePeriod(
        originalTitle: String,
        originalStartDay: Date,
        newTitle: String,
        newStartDate: Date,
        newEndDate: Date,
        categoryColor: String,
        buttonType: DutyType
    ) -> Result<[ScheduleItem], Error>
}

/// 일정 저장 UseCase 구현체
final class SaveScheduleUseCase: SaveScheduleUseCaseProtocol {

    private let repository: ScheduleRepositoryProtocol
    private let syncService: SyncServiceProtocol

    init(
        repository: ScheduleRepositoryProtocol,
        syncService: SyncServiceProtocol
    ) {
        self.repository = repository
        self.syncService = syncService
    }

    func execute(schedule: ScheduleItem) -> Result<ScheduleItem, Error> {
        let result = repository.save(schedule)

        if case .success = result {
            syncService.syncIfNetworkAvailable()
            NotificationCenter.default.post(name: .scheduleSaved, object: nil)
        }

        return result
    }

    func execute(
        title: String,
        startDate: Date,
        endDate: Date,
        categoryColor: String,
        buttonType: DutyType
    ) -> Result<[ScheduleItem], Error> {
        let result = repository.savePeriod(
            title: title,
            startDate: startDate,
            endDate: endDate,
            categoryColor: categoryColor,
            buttonType: buttonType
        )

        if case .success = result {
            syncService.syncIfNetworkAvailable()
            NotificationCenter.default.post(name: .scheduleSaved, object: nil)
        }

        return result
    }

    func executeUpdate(schedule: ScheduleItem) -> Result<ScheduleItem, Error> {
        let result = repository.update(schedule)

        if case .success = result {
            syncService.syncIfNetworkAvailable()
            NotificationCenter.default.post(name: .scheduleSaved, object: nil)
        }

        return result
    }

    func executeUpdatePeriod(
        originalTitle: String,
        originalStartDay: Date,
        newTitle: String,
        newStartDate: Date,
        newEndDate: Date,
        categoryColor: String,
        buttonType: DutyType
    ) -> Result<[ScheduleItem], Error> {
        // 기존 일정 삭제
        let deleteResult = repository.deleteAll(title: originalTitle, startDay: originalStartDay)

        if case .failure(let error) = deleteResult {
            return .failure(error)
        }

        // 새 일정 저장
        let saveResult = repository.savePeriod(
            title: newTitle,
            startDate: newStartDate,
            endDate: newEndDate,
            categoryColor: categoryColor,
            buttonType: buttonType
        )

        if case .success = saveResult {
            syncService.syncIfNetworkAvailable()
            NotificationCenter.default.post(name: .scheduleSaved, object: nil)
        }

        return saveResult
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let scheduleSaved = Notification.Name("ScheduleSaved")
}
