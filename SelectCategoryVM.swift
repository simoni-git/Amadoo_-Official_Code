//
//  SelectCategoryVM.swift
//  NewCalendar
//
//  Created by 시모니 on 1/14/25.
//

import UIKit

class SelectCategoryVM {

    var delegate: SelectCategoryVCDelegate?

    // MARK: - Clean Architecture Dependencies
    private var fetchCategoriesUseCase: FetchCategoriesUseCaseProtocol?

    /// 클린 아키텍처 의존성 주입 (Domain Layer Entity 사용)
    private(set) var categoryList: [CategoryItem] = []

    /// 의존성 주입 메서드
    func injectDependencies(
        fetchCategoriesUseCase: FetchCategoriesUseCaseProtocol
    ) {
        self.fetchCategoriesUseCase = fetchCategoriesUseCase
    }

    // MARK: - UseCase Methods

    /// UseCase를 통한 카테고리 조회
    func fetchCategoriesUsingUseCase(completion: @escaping () -> Void) {
        guard let useCase = fetchCategoriesUseCase else {
            categoryList = []
            completion()
            return
        }

        categoryList = useCase.execute()
        completion()
    }
}
