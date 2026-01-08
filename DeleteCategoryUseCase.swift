//
//  DeleteCategoryUseCase.swift
//  NewCalendar
//
//  Domain Layer - 카테고리 삭제 UseCase
//

import Foundation

/// 카테고리 삭제 UseCase 프로토콜
protocol DeleteCategoryUseCaseProtocol {
    /// 카테고리 삭제
    func execute(category: CategoryItem) -> Result<Void, Error>

    /// 해당 카테고리를 사용하는 일정 개수 확인
    func countSchedules(withColor color: String) -> Int
}

/// 카테고리 삭제 UseCase 구현체
final class DeleteCategoryUseCase: DeleteCategoryUseCaseProtocol {

    private let repository: CategoryRepositoryProtocol
    private let syncService: SyncServiceProtocol

    init(
        repository: CategoryRepositoryProtocol,
        syncService: SyncServiceProtocol
    ) {
        self.repository = repository
        self.syncService = syncService
    }

    func execute(category: CategoryItem) -> Result<Void, Error> {
        let result = repository.delete(category)

        if case .success = result {
            syncService.syncIfNetworkAvailable()
            NotificationCenter.default.post(name: .deleteCategory, object: nil)
        }

        return result
    }

    func countSchedules(withColor color: String) -> Int {
        return repository.countSchedules(withColor: color)
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let deleteCategory = Notification.Name("DeleteCategory")
}
