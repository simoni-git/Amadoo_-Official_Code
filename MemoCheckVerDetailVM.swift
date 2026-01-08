//
//  MemoCheckVerDetailVM.swift
//  NewCalendar
//
//  Created by 시모니 on 1/15/25.
//

import Foundation

class MemoCheckVerDetailVM {

    var titleText: String?
    var memoType: String = "check"

    // MARK: - Clean Architecture Dependencies
    private let fetchMemoUseCase: FetchMemoUseCaseProtocol
    private let saveMemoUseCase: SaveMemoUseCaseProtocol
    private let deleteMemoUseCase: DeleteMemoUseCaseProtocol

    /// 클린 아키텍처 Entity
    private(set) var checkListItems: [CheckListItem] = []

    // MARK: - Initializer
    init(
        fetchMemoUseCase: FetchMemoUseCaseProtocol,
        saveMemoUseCase: SaveMemoUseCaseProtocol,
        deleteMemoUseCase: DeleteMemoUseCaseProtocol
    ) {
        self.fetchMemoUseCase = fetchMemoUseCase
        self.saveMemoUseCase = saveMemoUseCase
        self.deleteMemoUseCase = deleteMemoUseCase
    }

    // MARK: - UseCase Methods

    /// UseCase를 통한 체크리스트 조회
    func fetchCheckListUsingUseCase(completion: @escaping () -> Void) {
        guard let title = titleText else {
            checkListItems = []
            completion()
            return
        }

        checkListItems = fetchMemoUseCase.executeCheckLists(forTitle: title)
        completion()
    }

    /// UseCase를 통한 체크리스트 완료 상태 토글
    func toggleCompleteUsingUseCase(at index: Int) -> Result<CheckListItem, Error>? {
        guard index < checkListItems.count else { return nil }

        var item = checkListItems[index]
        item.isComplete.toggle()
        return saveMemoUseCase.executeUpdateCheckList(item)
    }

    /// UseCase를 통한 체크리스트 삭제
    func deleteCheckListUsingUseCase(_ item: CheckListItem) -> Result<Void, Error> {
        return deleteMemoUseCase.executeCheckList(item)
    }

    /// UseCase를 통한 전체 체크리스트 삭제
    func deleteAllCheckListsUsingUseCase() -> Result<Void, Error>? {
        guard let title = titleText else { return nil }
        return deleteMemoUseCase.executeAllCheckLists(forTitle: title)
    }
}
