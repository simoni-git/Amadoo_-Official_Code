//
//  CategoryVM.swift
//  NewCalendar
//
//  Created by 시모니 on 1/9/25.
//

import UIKit

class CategoryVM {

    // MARK: - Clean Architecture Dependencies
    private let fetchCategoriesUseCase: FetchCategoriesUseCaseProtocol
    private let deleteCategoryUseCase: DeleteCategoryUseCaseProtocol

    /// 클린 아키텍처 의존성 주입 (Domain Layer Entity 사용)
    private(set) var categoryList: [CategoryItem] = []

    // MARK: - Initializer
    init(
        fetchCategoriesUseCase: FetchCategoriesUseCaseProtocol,
        deleteCategoryUseCase: DeleteCategoryUseCaseProtocol
    ) {
        self.fetchCategoriesUseCase = fetchCategoriesUseCase
        self.deleteCategoryUseCase = deleteCategoryUseCase
    }

    // MARK: - UseCase Methods

    /// UseCase를 통한 카테고리 조회
    func fetchCategoriesUsingUseCase(completion: @escaping () -> Void) {
        categoryList = fetchCategoriesUseCase.execute()
        completion()
    }

    /// UseCase를 통한 카테고리 삭제
    func deleteCategoryUsingUseCase(_ category: CategoryItem) -> Result<Void, Error> {
        return deleteCategoryUseCase.execute(category: category)
    }

    /// 해당 카테고리를 사용하는 일정 개수 확인
    func countSchedulesUsingUseCase(withColor color: String) -> Int {
        return deleteCategoryUseCase.countSchedules(withColor: color)
    }
}
