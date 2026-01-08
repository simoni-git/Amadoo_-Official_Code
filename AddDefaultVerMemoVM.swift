//
//  AddDefaultVerMemoVM.swift
//  NewCalendar
//
//  Created by 시모니 on 1/15/25.
//

import UIKit

class AddDefaultVerMemoVM {

    var memoType: String = "default"
    var delegate: AddDefaultVerMemoDelegate?
    var editModeTitleTextFieldText: String?
    var editModeMemoTextViewText: String?
    var isEditMode = false

    // MARK: - Clean Architecture Dependencies
    private let saveMemoUseCase: SaveMemoUseCaseProtocol

    // MARK: - Initializer
    init(
        saveMemoUseCase: SaveMemoUseCaseProtocol
    ) {
        self.saveMemoUseCase = saveMemoUseCase
    }

    // MARK: - UseCase Methods

    /// UseCase를 통한 메모 저장
    func saveMemoUsingUseCase(title: String, memoText: String) -> Result<MemoItem, Error> {
        let memo = MemoItem(title: title, memoText: memoText, memoType: memoType)
        return saveMemoUseCase.executeSaveMemo(memo)
    }

    /// UseCase를 통한 메모 수정
    func updateMemoUsingUseCase(title: String, memoText: String) -> Result<MemoItem, Error> {
        let memo = MemoItem(title: title, memoText: memoText, memoType: memoType)
        return saveMemoUseCase.executeUpdateMemo(memo)
    }
}
