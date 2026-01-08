//
//  EditTimeVM.swift
//  NewCalendar
//
//  Created by 시모니의 맥북 on 12/1/25.
//


import Foundation

class EditTimeVM {
    var originalItem: TimeTableItem
    var title: String
    var startTime: String
    var endTime: String
    var memo: String?
    var color: String
    var selectedColorCode: String
    var dayOfWeek: Int
    var minimumHour: Int
    var maximumHour: Int

    // MARK: - Clean Architecture Dependencies
    private let saveTimeTableUseCase: SaveTimeTableUseCaseProtocol
    private let deleteTimeTableUseCase: DeleteTimeTableUseCaseProtocol
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
        timetable: TimeTableItem,
        minimumHour: Int,
        maximumHour: Int,
        saveTimeTableUseCase: SaveTimeTableUseCaseProtocol,
        deleteTimeTableUseCase: DeleteTimeTableUseCaseProtocol,
        fetchTimeTableUseCase: FetchTimeTableUseCaseProtocol
    ) {
        self.originalItem = timetable
        self.minimumHour = minimumHour
        self.maximumHour = maximumHour
        self.saveTimeTableUseCase = saveTimeTableUseCase
        self.deleteTimeTableUseCase = deleteTimeTableUseCase
        self.fetchTimeTableUseCase = fetchTimeTableUseCase

        self.title = timetable.title
        self.startTime = timetable.startTime
        self.endTime = timetable.endTime
        self.memo = timetable.memo
        self.color = timetable.color
        self.selectedColorCode = timetable.color
        self.dayOfWeek = Int(timetable.dayOfWeek)
    }

    // MARK: - UseCase Methods

    /// UseCase를 통한 시간표 수정
    func updateTimeTable(title: String, memo: String?, startTime: String, endTime: String, color: String) -> Result<TimeTableItem, Error> {
        // 기존 항목 삭제 후 새로 저장 (시간이 변경될 수 있으므로)
        _ = deleteTimeTableUseCase.execute(item: originalItem)

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

    /// UseCase를 통한 시간표 삭제
    func deleteTimeTable() -> Result<Void, Error> {
        return deleteTimeTableUseCase.execute(item: originalItem)
    }

    /// 시간 겹침 확인
    func isTimeOverlapping(newStart: String, newEnd: String) -> Bool {
        let allItems = fetchTimeTableUseCase.execute()

        for item in allItems {
            // 같은 요일만 확인
            if Int(item.dayOfWeek) != dayOfWeek {
                continue
            }

            // 자기 자신은 제외 (원본과 동일한 시간표)
            if item.startTime == originalItem.startTime &&
               item.endTime == originalItem.endTime &&
               Int(item.dayOfWeek) == Int(originalItem.dayOfWeek) {
                continue
            }

            // 시간 겹침 체크
            if (newStart >= item.startTime && newStart < item.endTime) ||
               (newEnd > item.startTime && newEnd <= item.endTime) ||
               (newStart <= item.startTime && newEnd >= item.endTime) {
                return true
            }
        }
        return false
    }
    
    // 시간 문자열을 Date로 변환
    func getStartDate() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        
        if let time = formatter.date(from: startTime) {
            let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute
        }
        
        return calendar.date(from: components) ?? Date()
    }
    
    func getEndDate() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        
        if let time = formatter.date(from: endTime) {
            let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute
        }
        
        return calendar.date(from: components) ?? Date()
    }
    
    // 색상 인덱스 찾기
    func getColorIndex() -> Int? {
        return colors.firstIndex { $0.code == color }
    }
}
