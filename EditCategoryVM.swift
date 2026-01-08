//
//  EditCategoryVM.swift
//  NewCalendar
//
//  Created by 시모니 on 1/9/25.
//

import UIKit

class EditCategoryVM {

    var delegate: EditCategoryVCDelegate?
    var addForSelectCategoryVCDelegate: AddForSelectCategoryVCDelegate?
    var selectColorCode: String? = ""
    var selectColorName: String? = ""
    var categoryName: String? = ""
    var originCategoryName: String?
    var originSelectColor: String?
    var isEditMode: Bool = false
    var isAddMode: Bool = false

    // MARK: - Clean Architecture Dependencies
    private let saveCategoryUseCase: SaveCategoryUseCaseProtocol
    private let fetchCategoriesUseCase: FetchCategoriesUseCaseProtocol

    // MARK: - Initializer
    init(
        saveCategoryUseCase: SaveCategoryUseCaseProtocol,
        fetchCategoriesUseCase: FetchCategoriesUseCaseProtocol
    ) {
        self.saveCategoryUseCase = saveCategoryUseCase
        self.fetchCategoriesUseCase = fetchCategoriesUseCase
    }

    // MARK: - UseCase Methods

    /// UseCase를 통한 카테고리 저장
    func saveCategoryUsingUseCase(name: String, color: String) -> Result<CategoryItem, Error> {
        let category = CategoryItem(name: name, color: color, isDefault: false)
        return saveCategoryUseCase.execute(category: category)
    }

    /// UseCase를 통한 카테고리 수정
    func updateCategoryUsingUseCase(name: String, color: String) -> Result<CategoryItem, Error> {
        let category = CategoryItem(name: name, color: color, isDefault: false)
        return saveCategoryUseCase.executeUpdate(category: category)
    }

    /// UseCase를 통한 모든 카테고리 조회
    func fetchAllCategoriesUsingUseCase() -> [CategoryItem] {
        return fetchCategoriesUseCase.execute()
    }

    // MARK: - Properties

    let colors = [
        (name: "프렌치로즈", code: "ECBDBF"),
        (name: "라이트오렌지", code: "FFB124"),
        (name: "머스타드옐로우", code: "DBC557"),
        (name: "에메랄드그린", code: "8FBC91"),
        (name: "스카이블루", code: "A5CBF0"),
        (name: "다크블루", code: "446592"),
        (name: "소프트바이올렛", code: "A495C6"),
        (name: "파스텔브라운", code: "BBA79C")
    ]

    // MARK: - Validation Methods

    /// 카테고리 이름 중복 검사 (UseCase 기반)
    func isCategoryNameExists(categoryName: String) -> Bool {
        let categories = fetchAllCategoriesUsingUseCase()
        return categories.contains { $0.name == categoryName && $0.name != originCategoryName }
    }

    /// 색상 중복 검사 (UseCase 기반)
    func isColorExists(selectColor: String) -> Bool {
        let categories = fetchAllCategoriesUsingUseCase()
        return categories.contains { $0.color == selectColor && $0.color != originSelectColor }
    }
}
