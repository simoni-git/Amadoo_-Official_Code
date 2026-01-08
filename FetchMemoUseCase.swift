//
//  FetchMemoUseCase.swift
//  NewCalendar
//
//  Domain Layer - 메모 조회 UseCase
//

import Foundation

/// 메모 조회 UseCase 프로토콜
protocol FetchMemoUseCaseProtocol {
    /// 모든 일반 메모 조회
    func executeMemos() -> [MemoItem]

    /// 모든 체크리스트 조회
    func executeCheckLists() -> [CheckListItem]

    /// 특정 제목의 체크리스트 항목들 조회
    func executeCheckLists(forTitle title: String) -> [CheckListItem]

    /// 모든 메모와 체크리스트를 제목별로 그룹화하여 조회
    func executeAllGrouped() -> [(title: String, type: String, items: [Any])]
}

/// 메모 조회 UseCase 구현체
final class FetchMemoUseCase: FetchMemoUseCaseProtocol {

    private let repository: MemoRepositoryProtocol

    init(repository: MemoRepositoryProtocol) {
        self.repository = repository
    }

    func executeMemos() -> [MemoItem] {
        return repository.fetchAllMemos()
    }

    func executeCheckLists() -> [CheckListItem] {
        return repository.fetchAllCheckLists()
    }

    func executeCheckLists(forTitle title: String) -> [CheckListItem] {
        return repository.fetchCheckLists(forTitle: title)
    }

    func executeAllGrouped() -> [(title: String, type: String, items: [Any])] {
        return repository.fetchAllGroupedByTitle()
    }
}
