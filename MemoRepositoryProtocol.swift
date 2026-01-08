//
//  MemoRepositoryProtocol.swift
//  NewCalendar
//
//  Domain Protocol - 메모 저장소
//

import Foundation

/// 메모 저장소 프로토콜
protocol MemoRepositoryProtocol {
    // MARK: - Memo (일반 메모)

    /// 모든 일반 메모 조회
    func fetchAllMemos() -> [MemoItem]

    /// 메모 저장
    func saveMemo(_ memo: MemoItem) -> Result<MemoItem, Error>

    /// 메모 수정
    func updateMemo(_ memo: MemoItem) -> Result<MemoItem, Error>

    /// 메모 삭제
    func deleteMemo(_ memo: MemoItem) -> Result<Void, Error>

    // MARK: - CheckList (체크리스트)

    /// 모든 체크리스트 조회
    func fetchAllCheckLists() -> [CheckListItem]

    /// 특정 제목의 체크리스트 항목들 조회
    func fetchCheckLists(forTitle title: String) -> [CheckListItem]

    /// 체크리스트 항목 저장
    func saveCheckList(_ checkList: CheckListItem) -> Result<CheckListItem, Error>

    /// 체크리스트 항목 수정
    func updateCheckList(_ checkList: CheckListItem) -> Result<CheckListItem, Error>

    /// 체크리스트 항목 삭제
    func deleteCheckList(_ checkList: CheckListItem) -> Result<Void, Error>

    /// 특정 제목의 모든 체크리스트 항목 삭제
    func deleteAllCheckLists(forTitle title: String) -> Result<Void, Error>

    // MARK: - Combined

    /// 모든 메모와 체크리스트를 제목별로 그룹화하여 조회
    func fetchAllGroupedByTitle() -> [(title: String, type: String, items: [Any])]
}
