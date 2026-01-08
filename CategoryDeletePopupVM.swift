//
//  EditCategory_DeleteVM.swift
//  NewCalendar
//
//  Created by 시모니 on 1/14/25.
//

import UIKit

class CategoryDeletePopupVM {
    var categoryName: String?
    var selectColor: String?

    // MARK: - Clean Architecture Dependencies
    private var deleteCategoryUseCase: DeleteCategoryUseCaseProtocol?

    /// 의존성 주입 메서드
    func injectDependencies(
        deleteCategoryUseCase: DeleteCategoryUseCaseProtocol
    ) {
        self.deleteCategoryUseCase = deleteCategoryUseCase
    }

    // MARK: - UseCase Methods

    /// UseCase를 통한 카테고리 삭제
    func deleteCategoryUsingUseCase() -> Result<Void, Error>? {
        guard let useCase = deleteCategoryUseCase,
              let name = categoryName,
              let color = selectColor else { return nil }

        let category = CategoryItem(name: name, color: color, isDefault: false)
        return useCase.execute(category: category)
    }

    /// 해당 카테고리를 사용하는 일정 개수 확인
    func countSchedulesUsingUseCase() -> Int {
        guard let useCase = deleteCategoryUseCase,
              let color = selectColor else { return 0 }
        return useCase.countSchedules(withColor: color)
    }
}
