//
//  MemoVM.swift
//  NewCalendar
//
//  Created by 시모니 on 1/15/25.
//

import UIKit

class MemoVM {

    // MARK: - Clean Architecture Dependencies
    private var fetchMemoUseCase: FetchMemoUseCaseProtocol?
    private var deleteMemoUseCase: DeleteMemoUseCaseProtocol?

    /// 클린 아키텍처 의존성 주입 (Domain Layer Entity 사용)
    private(set) var memoItems: [MemoItem] = []
    private(set) var checkListItems: [CheckListItem] = []
    private(set) var groupedItems: [(title: String, type: String, items: [Any])] = []

    /// 의존성 주입 메서드
    func injectDependencies(
        fetchMemoUseCase: FetchMemoUseCaseProtocol,
        deleteMemoUseCase: DeleteMemoUseCaseProtocol
    ) {
        self.fetchMemoUseCase = fetchMemoUseCase
        self.deleteMemoUseCase = deleteMemoUseCase
    }

    // MARK: - UseCase Methods

    /// UseCase를 통한 모든 데이터 조회
    func fetchAllDataUsingUseCase(completion: @escaping () -> Void) {
        guard let useCase = fetchMemoUseCase else {
            groupedItems = []
            completion()
            return
        }

        memoItems = useCase.executeMemos()
        checkListItems = useCase.executeCheckLists()
        groupedItems = useCase.executeAllGrouped()
        completion()
    }

    /// UseCase를 통한 메모 삭제
    func deleteMemoUsingUseCase(_ memo: MemoItem) -> Result<Void, Error>? {
        guard let useCase = deleteMemoUseCase else { return nil }
        return useCase.executeMemo(memo)
    }

    /// UseCase를 통한 체크리스트 삭제
    func deleteCheckListUsingUseCase(_ checkList: CheckListItem) -> Result<Void, Error>? {
        guard let useCase = deleteMemoUseCase else { return nil }
        return useCase.executeCheckList(checkList)
    }

    /// UseCase를 통한 체크리스트 전체 삭제 (제목별)
    func deleteAllCheckListsUsingUseCase(forTitle title: String) -> Result<Void, Error>? {
        guard let useCase = deleteMemoUseCase else { return nil }
        return useCase.executeAllCheckLists(forTitle: title)
    }
}
