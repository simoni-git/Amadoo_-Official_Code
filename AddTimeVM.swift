//
//  AddTimeVM.swift
//  NewCalendar
//
//  Created by 시모니의 맥북 on 11/26/25.
//

import Foundation

class AddTimeVM {
    var selectedDate: Date
    var endDate: Date
    var minimumHour: Int
    var maximumHour: Int
    var dayOfWeek: Int
    var selectColorCode: String? = ""
    var selectColorName: String? = ""

    // MARK: - Clean Architecture Dependencies
    private let saveTimeTableUseCase: SaveTimeTableUseCaseProtocol
    private let fetchTimeTableUseCase: FetchTimeTableUseCaseProtocol

    // MARK: - Properties

    let colors = [
        (name: "프렌치로즈", code: "ECBDBF"),
        (name: "라이트오렌지", code: "FFB124"),
        (name: "머스타드옐로우", code: "DBC557"),
        (name: "에메랄드그린", code: "8FBC91"),
        (name: "스카이블루", code: "A5CBF0"),
        (name: "다크블루", code: "446592"),
        (name: "소프트바이올렛", code: "A495C6"),
        (name: "파스텔브라운", code: "BBA79C")
    ]

    // MARK: - Initializer
    init(
        selectedHour: Int,
        minimumHour: Int,
        maximumHour: Int,
        dayOfWeek: Int,
        saveTimeTableUseCase: SaveTimeTableUseCaseProtocol,
        fetchTimeTableUseCase: FetchTimeTableUseCaseProtocol
    ) {
        self.minimumHour = minimumHour
        self.maximumHour = maximumHour
        self.dayOfWeek = dayOfWeek
        self.saveTimeTableUseCase = saveTimeTableUseCase
        self.fetchTimeTableUseCase = fetchTimeTableUseCase

        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        dateComponents.hour = selectedHour
        dateComponents.minute = 0

        self.selectedDate = calendar.date(from: dateComponents) ?? Date()
        self.endDate = calendar.date(byAdding: .hour, value: 1, to: self.selectedDate) ?? Date()
    }

    // MARK: - UseCase Methods

    /// UseCase를 통한 시간표 저장
    func saveTimeTableUsingUseCase(title: String, memo: String?, startTime: String, endTime: String, color: String) -> Result<TimeTableItem, Error> {
        let item = TimeTableItem(
            dayOfWeek: Int16(dayOfWeek),
            startTime: startTime,
            endTime: endTime,
            title: title,
            memo: memo,
            color: color
        )
        return saveTimeTableUseCase.execute(item: item)
    }

    /// UseCase를 통한 시간 범위 저장
    func saveTimeRangeUsingUseCase(startHour: Int, endHour: Int) {
        saveTimeTableUseCase.saveTimeRange(startHour: startHour, endHour: endHour)
    }

    /// UseCase를 통한 시간 겹침 확인
    func isTimeOverlapping(newStart: String, newEnd: String) -> Bool {
        let allTimetables = fetchTimeTableUseCase.execute()

        // 같은 요일의 시간표만 필터링
        let sameDayTimetables = allTimetables.filter { $0.dayOfWeek == Int16(dayOfWeek) }

        for timetable in sameDayTimetables {
            let existingStart = timetable.startTime
            let existingEnd = timetable.endTime

            // 시간 겹침 체크
            if (newStart >= existingStart && newStart < existingEnd) ||
                (newEnd > existingStart && newEnd <= existingEnd) ||
                (newStart <= existingStart && newEnd >= existingEnd) {
                return true
            }
        }

        return false
    }
}
