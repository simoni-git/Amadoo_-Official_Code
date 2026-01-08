//
//  DeleteMemoUseCase.swift
//  NewCalendar
//
//  Domain Layer - 메모 삭제 UseCase
//

import Foundation

/// 메모 삭제 UseCase 프로토콜
protocol DeleteMemoUseCaseProtocol {
    // MARK: - Memo

    /// 메모 삭제
    func executeMemo(_ memo: MemoItem) -> Result<Void, Error>

    // MARK: - CheckList

    /// 체크리스트 항목 삭제
    func executeCheckList(_ checkList: CheckListItem) -> Result<Void, Error>

    /// 특정 제목의 모든 체크리스트 항목 삭제
    func executeAllCheckLists(forTitle title: String) -> Result<Void, Error>
}

/// 메모 삭제 UseCase 구현체
final class DeleteMemoUseCase: DeleteMemoUseCaseProtocol {

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

    func executeMemo(_ memo: MemoItem) -> Result<Void, Error> {
        let result = repository.deleteMemo(memo)

        if case .success = result {
            syncService.syncIfNetworkAvailable()
        }

        return result
    }

    // MARK: - CheckList

    func executeCheckList(_ checkList: CheckListItem) -> Result<Void, Error> {
        let result = repository.deleteCheckList(checkList)

        if case .success = result {
            syncService.syncIfNetworkAvailable()
        }

        return result
    }

    func executeAllCheckLists(forTitle title: String) -> Result<Void, Error> {
        let result = repository.deleteAllCheckLists(forTitle: title)

        if case .success = result {
            syncService.syncIfNetworkAvailable()
        }

        return result
    }
}
