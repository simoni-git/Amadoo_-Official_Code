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
    private var saveMemoUseCase: SaveMemoUseCaseProtocol?

    /// 의존성 주입 메서드
    func injectDependencies(
        saveMemoUseCase: SaveMemoUseCaseProtocol
    ) {
        self.saveMemoUseCase = saveMemoUseCase
    }

    // MARK: - UseCase Methods

    /// UseCase를 통한 메모 저장
    func saveMemoUsingUseCase(title: String, memoText: String) -> Result<MemoItem, Error>? {
        guard let useCase = saveMemoUseCase else { return nil }

        let memo = MemoItem(title: title, memoText: memoText, memoType: memoType)
        return useCase.executeSaveMemo(memo)
    }

    /// UseCase를 통한 메모 수정
    func updateMemoUsingUseCase(title: String, memoText: String) -> Result<MemoItem, Error>? {
        guard let useCase = saveMemoUseCase else { return nil }

        let memo = MemoItem(title: title, memoText: memoText, memoType: memoType)
        return useCase.executeUpdateMemo(memo)
    }
}
