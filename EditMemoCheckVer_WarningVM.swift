//
//  EditMemoCheckVer_WarningVM.swift
//  NewCalendar
//
//  Created by 시모니 on 1/15/25.
//

import UIKit

class EditMemoCheckVer_WarningVM {

    var titleText: String?
    var memoType: String = "check"
    var delegate: MemoCheckVerWarningDelegate?

    // MARK: - Clean Architecture Dependencies
    private var saveMemoUseCase: SaveMemoUseCaseProtocol?
    private var deleteMemoUseCase: DeleteMemoUseCaseProtocol?

    /// 의존성 주입 메서드
    func injectDependencies(
        saveMemoUseCase: SaveMemoUseCaseProtocol,
        deleteMemoUseCase: DeleteMemoUseCaseProtocol
    ) {
        self.saveMemoUseCase = saveMemoUseCase
        self.deleteMemoUseCase = deleteMemoUseCase
    }

    // MARK: - UseCase Methods

    /// UseCase를 통한 체크리스트 아이템 저장
    func saveCheckListUsingUseCase(title: String, name: String, isComplete: Bool) -> Result<CheckListItem, Error>? {
        guard let useCase = saveMemoUseCase else { return nil }

        let item = CheckListItem(title: title, name: name, isComplete: isComplete, memoType: memoType)
        return useCase.executeSaveCheckList(item)
    }

    /// UseCase를 통한 기존 체크리스트 전체 삭제 후 새로 저장
    func replaceAllCheckListsUsingUseCase(title: String, items: [String]) -> Bool {
        guard let deleteUseCase = deleteMemoUseCase,
              let saveUseCase = saveMemoUseCase else { return false }

        // 기존 항목 삭제
        let deleteResult = deleteUseCase.executeAllCheckLists(forTitle: title)
        guard case .success = deleteResult else { return false }

        // 새 항목 저장
        for name in items where !name.isEmpty {
            let item = CheckListItem(title: title, name: name, isComplete: false, memoType: memoType)
            _ = saveUseCase.executeSaveCheckList(item)
        }
        return true
    }
}
