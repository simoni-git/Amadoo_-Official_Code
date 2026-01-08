//
//  TimeTableVM.swift
//  NewCalendar
//
//  Created by 시모니의 맥북 on 11/24/25.
//

import Foundation

class TimeTableVM {

    // MARK: - Clean Architecture Dependencies
    private let fetchTimeTableUseCase: FetchTimeTableUseCaseProtocol
    private let deleteTimeTableUseCase: DeleteTimeTableUseCaseProtocol

    /// 클린 아키텍처 의존성 주입 (Domain Layer Entity 사용)
    private(set) var timeTableItems: [TimeTableItem] = []

    // MARK: - Initializer
    init(
        fetchTimeTableUseCase: FetchTimeTableUseCaseProtocol,
        deleteTimeTableUseCase: DeleteTimeTableUseCaseProtocol
    ) {
        self.fetchTimeTableUseCase = fetchTimeTableUseCase
        self.deleteTimeTableUseCase = deleteTimeTableUseCase
    }

    // MARK: - UseCase Methods

    /// UseCase를 통한 시간표 데이터 로드
    func loadTimeTableData() {
        timeTableItems = fetchTimeTableUseCase.execute()
    }

    /// UseCase를 통한 요일별 그룹화된 시간표 조회
    func fetchGroupedByDay() -> [Int: [TimeTableItem]] {
        return fetchTimeTableUseCase.executeGroupedByDay()
    }

    /// UseCase를 통한 시간 범위 조회
    func getTimeRange() -> (startHour: Int, endHour: Int) {
        return fetchTimeTableUseCase.getTimeRange()
    }

    /// UseCase를 통한 시간표 삭제
    func deleteTimeTable(_ item: TimeTableItem) -> Result<Void, Error> {
        return deleteTimeTableUseCase.execute(item: item)
    }

    // MARK: - TimeTableItem Methods

    /// 특정 요일과 시간에 해당하는 TimeTableItem 반환
    func getTimetableItem(dayOfWeek: Int, hour: Int, minute: Int) -> TimeTableItem? {
        let cellTime = String(format: "%02d:%02d", hour, minute)

        for item in timeTableItems {
            if Int(item.dayOfWeek) != dayOfWeek {
                continue
            }
            if item.startTime <= cellTime && item.endTime > cellTime {
                return item
            }
        }
        return nil
    }

    /// 해당 셀이 시간표의 첫 번째 셀인지 확인
    func isFirstCellForItem(dayOfWeek: Int, hour: Int, minute: Int, timetable: TimeTableItem) -> Bool {
        let cellTime = String(format: "%02d:%02d", hour, minute)
        return timetable.startTime == cellTime
    }

    /// 범위를 벗어난 일정 확인
    func hasOutOfRangeTimetables(start: Int, end: Int) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        for item in timeTableItems {
            if let startDate = formatter.date(from: item.startTime) {
                let hour = Calendar.current.component(.hour, from: startDate)
                if hour < start || hour >= end + 1 {
                    return true
                }
            }
        }
        return false
    }
}
