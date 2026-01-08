//
//  AddCheckVerMemoVM.swift
//  NewCalendar
//
//  Created by 시모니 on 1/15/25.
//

import UIKit

class AddCheckVerMemoVM {

    var delegate: AddCheckVerMemoDelegate?
    var memoType: String = "check"
    var checkListItems: [String] = [""]

    // MARK: - Clean Architecture Dependencies
    private var saveMemoUseCase: SaveMemoUseCaseProtocol?

    /// 의존성 주입 메서드
    func injectDependencies(
        saveMemoUseCase: SaveMemoUseCaseProtocol
    ) {
        self.saveMemoUseCase = saveMemoUseCase
    }

    // MARK: - UseCase Methods

    /// UseCase를 통한 체크리스트 아이템 저장
    func saveCheckListUsingUseCase(title: String, name: String, isComplete: Bool) -> Result<CheckListItem, Error>? {
        guard let useCase = saveMemoUseCase else { return nil }

        let item = CheckListItem(title: title, name: name, isComplete: isComplete, memoType: memoType)
        return useCase.executeSaveCheckList(item)
    }

    /// UseCase를 통한 여러 체크리스트 아이템 저장
    func saveAllCheckListItemsUsingUseCase(title: String) -> [Result<CheckListItem, Error>] {
        guard let useCase = saveMemoUseCase else { return [] }

        var results: [Result<CheckListItem, Error>] = []
        for name in checkListItems where !name.isEmpty {
            let item = CheckListItem(title: title, name: name, isComplete: false, memoType: memoType)
            let result = useCase.executeSaveCheckList(item)
            results.append(result)
        }
        return results
    }
}
