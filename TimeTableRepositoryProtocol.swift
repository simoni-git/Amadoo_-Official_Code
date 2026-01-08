//
//  TimeTableRepositoryProtocol.swift
//  NewCalendar
//
//  Domain Protocol - 시간표 저장소
//

import Foundation

/// 시간표 저장소 프로토콜
protocol TimeTableRepositoryProtocol {
    /// 모든 시간표 항목 조회
    func fetchAll() -> [TimeTableItem]

    /// 특정 요일의 시간표 항목 조회
    func fetch(for dayOfWeek: Int) -> [TimeTableItem]

    /// 요일별로 그룹화된 시간표 조회
    func fetchGroupedByDay() -> [Int: [TimeTableItem]]

    /// 시간표 항목 저장
    func save(_ item: TimeTableItem) -> Result<TimeTableItem, Error>

    /// 시간표 항목 수정
    func update(_ item: TimeTableItem) -> Result<TimeTableItem, Error>

    /// 시간표 항목 삭제
    func delete(_ item: TimeTableItem) -> Result<Void, Error>

    /// 시간표 시작/종료 시간 설정 조회
    func getTimeRange() -> (startHour: Int, endHour: Int)

    /// 시간표 시작/종료 시간 설정 저장
    func saveTimeRange(startHour: Int, endHour: Int)
}
