//
//  SaveCategoryUseCase.swift
//  NewCalendar
//
//  Domain Layer - 카테고리 저장 UseCase
//

import Foundation

/// 카테고리 저장 UseCase 프로토콜
protocol SaveCategoryUseCaseProtocol {
    /// 카테고리 저장
    func execute(category: CategoryItem) -> Result<CategoryItem, Error>

    /// 카테고리 수정
    func executeUpdate(category: CategoryItem) -> Result<CategoryItem, Error>

    /// 기본 카테고리 생성 (없으면)
    func createDefaultIfNeeded() -> Result<CategoryItem?, Error>
}

/// 카테고리 저장 UseCase 구현체
final class SaveCategoryUseCase: SaveCategoryUseCaseProtocol {

    private let repository: CategoryRepositoryProtocol
    private let syncService: SyncServiceProtocol

    init(
        repository: CategoryRepositoryProtocol,
        syncService: SyncServiceProtocol
    ) {
        self.repository = repository
        self.syncService = syncService
    }

    func execute(category: CategoryItem) -> Result<CategoryItem, Error> {
        let result = repository.save(category)

        if case .success = result {
            syncService.syncIfNetworkAvailable()
        }

        return result
    }

    func executeUpdate(category: CategoryItem) -> Result<CategoryItem, Error> {
        let result = repository.update(category)

        if case .success = result {
            syncService.syncIfNetworkAvailable()
        }

        return result
    }

    func createDefaultIfNeeded() -> Result<CategoryItem?, Error> {
        let result = repository.createDefaultCategoryIfNeeded()

        if case .success(let category) = result, category != nil {
            syncService.syncIfNetworkAvailable()
        }

        return result
    }
}
