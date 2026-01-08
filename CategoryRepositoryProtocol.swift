//
//  CategoryRepositoryProtocol.swift
//  NewCalendar
//
//  Domain Protocol - 카테고리 저장소
//

import Foundation

/// 카테고리 저장소 프로토콜
protocol CategoryRepositoryProtocol {
    /// 모든 카테고리 조회 (유효한 것만, 정렬됨)
    func fetchAll() -> [CategoryItem]

    /// 기본 카테고리 조회
    func fetchDefault() -> CategoryItem?

    /// 카테고리 저장
    func save(_ category: CategoryItem) -> Result<CategoryItem, Error>

    /// 카테고리 수정
    func update(_ category: CategoryItem) -> Result<CategoryItem, Error>

    /// 카테고리 삭제
    func delete(_ category: CategoryItem) -> Result<Void, Error>

    /// 카테고리가 없으면 기본 카테고리 생성
    func createDefaultCategoryIfNeeded() -> Result<CategoryItem?, Error>

    /// 해당 색상의 카테고리 개수 조회 (삭제 시 일정 업데이트용)
    func countSchedules(withColor color: String) -> Int
}
