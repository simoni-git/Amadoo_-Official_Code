//
//  FetchCategoriesUseCase.swift
//  NewCalendar
//
//  Domain Layer - 카테고리 조회 UseCase
//

import Foundation

/// 카테고리 조회 UseCase 프로토콜
protocol FetchCategoriesUseCaseProtocol {
    /// 모든 카테고리 조회 (유효한 것만, 정렬됨)
    func execute() -> [CategoryItem]

    /// 기본 카테고리 조회
    func executeDefault() -> CategoryItem?
}

/// 카테고리 조회 UseCase 구현체
final class FetchCategoriesUseCase: FetchCategoriesUseCaseProtocol {

    private let repository: CategoryRepositoryProtocol

    init(repository: CategoryRepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> [CategoryItem] {
        return repository.fetchAll()
    }

    func executeDefault() -> CategoryItem? {
        return repository.fetchDefault()
    }
}
