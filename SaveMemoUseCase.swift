//
//  SaveMemoUseCase.swift
//  NewCalendar
//
//  Domain Layer - 메모 저장 UseCase
//

import Foundation

/// 메모 저장 UseCase 프로토콜
protocol SaveMemoUseCaseProtocol {
    // MARK: - Memo

    /// 메모 저장
    func executeSaveMemo(_ memo: MemoItem) -> Result<MemoItem, Error>

    /// 메모 수정
    func executeUpdateMemo(_ memo: MemoItem) -> Result<MemoItem, Error>

    // MARK: - CheckList

    /// 체크리스트 항목 저장
    func executeSaveCheckList(_ checkList: CheckListItem) -> Result<CheckListItem, Error>

    /// 체크리스트 항목 수정
    func executeUpdateCheckList(_ checkList: CheckListItem) -> Result<CheckListItem, Error>

    /// 체크리스트 여러 항목 저장
    func executeSaveCheckLists(_ checkLists: [CheckListItem]) -> Result<[CheckListItem], Error>
}

/// 메모 저장 UseCase 구현체
final class SaveMemoUseCase: SaveMemoUseCaseProtocol {

    private let repository: MemoRepositoryProtocol
    private let syncService: SyncServiceProtocol

    init(
        repository: MemoRepositoryProtocol,
        syncService: SyncServiceProtocol
    ) {
        self.repository = repository
        self.syncService = syncService
    }

    // MARK: - Memo

    func executeSaveMemo(_ memo: MemoItem) -> Result<MemoItem, Error> {
        let result = repository.saveMemo(memo)

        if case .success = result {
            syncService.syncIfNetworkAvailable()
        }

        return result
    }

    func executeUpdateMemo(_ memo: MemoItem) -> Result<MemoItem, Error> {
        let result = repository.updateMemo(memo)

        if case .success = result {
            syncService.syncIfNetworkAvailable()
        }

        return result
    }

    // MARK: - CheckList

    func executeSaveCheckList(_ checkList: CheckListItem) -> Result<CheckListItem, Error> {
        let result = repository.saveCheckList(checkList)

        if case .success = result {
            syncService.syncIfNetworkAvailable()
        }

        return result
    }

    func executeUpdateCheckList(_ checkList: CheckListItem) -> Result<CheckListItem, Error> {
        let result = repository.updateCheckList(checkList)

        if case .success = result {
            syncService.syncIfNetworkAvailable()
        }

        return result
    }

    func executeSaveCheckLists(_ checkLists: [CheckListItem]) -> Result<[CheckListItem], Error> {
        var savedItems: [CheckListItem] = []

        for checkList in checkLists {
            let result = repository.saveCheckList(checkList)
            switch result {
            case .success(let item):
                savedItems.append(item)
            case .failure(let error):
                return .failure(error)
            }
        }

        syncService.syncIfNetworkAvailable()
        return .success(savedItems)
    }
}
