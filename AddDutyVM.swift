//
//  AddDutyVM.swift
//  NewCalendar
//
//  Created by 시모니 on 1/7/25.
//

import UIKit

class AddDutyVM {

    var currentMonth: Date = Date()
    var selectedButtonType: ButtonType = .defaultDay
    var selectedStartDate: Date?
    var selectedEndDate: Date?
    var selectedMultipleDates: [Date] = []
    var selectedSingleDate: Date?
    var todayMounth: Date?
    var todayMounthString: String?
    var selectedCategoryColorHex: String?

    var isEditMode: Bool = false

    // 수정 대상 정보 (ScheduleItem 기반)
    var originButtonType: String!
    var originCategoryColor: String!
    var originTitle: String!
    var originDate: Date!
    var originStartDate: Date!
    var originEndDate: Date!

    var editTitle: String?
    var editDate: Date?
    var editStartDate: Date?
    var editEndDate: Date?

    let userNotificationManager = UserNotificationManager.shared

    // DutyType을 ButtonType으로 사용 (기존 코드와의 호환성 유지)
    typealias ButtonType = DutyType

    // MARK: - Clean Architecture Dependencies
    private let saveScheduleUseCase: SaveScheduleUseCaseProtocol
    private let deleteScheduleUseCase: DeleteScheduleUseCaseProtocol
    private let fetchCategoriesUseCase: FetchCategoriesUseCaseProtocol

    // MARK: - Initializer
    init(
        saveScheduleUseCase: SaveScheduleUseCaseProtocol,
        deleteScheduleUseCase: DeleteScheduleUseCaseProtocol,
        fetchCategoriesUseCase: FetchCategoriesUseCaseProtocol
    ) {
        self.saveScheduleUseCase = saveScheduleUseCase
        self.deleteScheduleUseCase = deleteScheduleUseCase
        self.fetchCategoriesUseCase = fetchCategoriesUseCase
    }

    // MARK: - UseCase Methods

    /// UseCase를 통한 단일 일정 저장
    func saveScheduleUsingUseCase(title: String, date: Date, categoryColor: String) -> Result<ScheduleItem, Error> {
        let schedule = ScheduleItem(
            title: title,
            date: date,
            startDay: date,
            endDay: date,
            buttonType: selectedButtonType,
            categoryColor: categoryColor
        )
        return saveScheduleUseCase.execute(schedule: schedule)
    }

    /// UseCase를 통한 기간 일정 저장
    func savePeriodScheduleUsingUseCase(title: String, startDate: Date, endDate: Date, categoryColor: String) -> Result<[ScheduleItem], Error> {
        return saveScheduleUseCase.execute(
            title: title,
            startDate: startDate,
            endDate: endDate,
            categoryColor: categoryColor,
            buttonType: selectedButtonType
        )
    }

    /// UseCase를 통한 카테고리 목록 조회
    func fetchCategoriesUsingUseCase() -> [CategoryItem] {
        return fetchCategoriesUseCase.execute()
    }

    // MARK: - Save Methods

    /// 단일 날짜 일정 저장
    func saveSingleDate(text: String, date: Date) {
        guard let categoryColor = selectedCategoryColorHex else { return }

        let schedule = ScheduleItem(
            title: text,
            date: date,
            startDay: date,
            endDay: date,
            buttonType: .defaultDay,
            categoryColor: categoryColor
        )

        let result = saveScheduleUseCase.execute(schedule: schedule)
        switch result {
        case .success:
            print("✅ 단일 일정 저장 성공")
        case .failure(let error):
            print("❌ 단일 일정 저장 실패: \(error)")
        }
    }

    /// 기간 일정 저장
    func savePeriodDates(text: String, startDate: Date, endDate: Date, categoryColor: String) {
        let result = saveScheduleUseCase.execute(
            title: text,
            startDate: startDate,
            endDate: endDate,
            categoryColor: categoryColor,
            buttonType: .periodDay
        )
        switch result {
        case .success:
            print("✅ 기간 일정 저장 성공")
        case .failure(let error):
            print("❌ 기간 일정 저장 실패: \(error)")
        }
    }

    /// 복수 날짜 일정 저장
    func saveMultipleDates(text: String, dates: [Date]) {
        guard let categoryColor = selectedCategoryColorHex else { return }

        for date in dates {
            let schedule = ScheduleItem(
                title: text,
                date: date,
                startDay: date,
                endDay: date,
                buttonType: .multipleDay,
                categoryColor: categoryColor
            )
            _ = saveScheduleUseCase.execute(schedule: schedule)
        }
        print("✅ 복수 일정 \(dates.count)개 저장 성공")
    }

    /// 단일/복수 일정 수정
    func fetchAndUpdateSchedule(title: String?, categoryColor: String?, date: Date?, startDate: Date?, endDate: Date?) {
        guard let editDate = editDate ?? date,
              let editTitle = editTitle ?? title else { return }

        let schedule = ScheduleItem(
            title: editTitle,
            date: editDate,
            startDay: editStartDate ?? editDate,
            endDay: editEndDate ?? editDate,
            buttonType: DutyType(rawValue: originButtonType) ?? .defaultDay,
            categoryColor: originCategoryColor
        )

        // 기존 일정 삭제 후 새로 저장
        if let originalTitle = title, let originalDate = date {
            _ = deleteScheduleUseCase.execute(schedule: ScheduleItem(
                title: originalTitle,
                date: originalDate,
                startDay: originalDate,
                endDay: originalDate,
                buttonType: DutyType(rawValue: originButtonType) ?? .defaultDay,
                categoryColor: originCategoryColor
            ))
        }

        _ = saveScheduleUseCase.execute(schedule: schedule)
        print("✅ 일정 수정 성공")
    }

    /// 기간 일정 수정
    func fetchAndUpdatePeriodSchedule(title: String?, categoryColor: String?, buttonType: String?, startDate: Date?, endDate: Date?) {
        guard let originalTitle = title,
              let originalStartDate = startDate else { return }

        let newTitle = editTitle ?? originalTitle
        let newStartDate = editStartDate ?? originalStartDate
        let newEndDate = editEndDate ?? (endDate ?? originalStartDate)

        let result = saveScheduleUseCase.executeUpdatePeriod(
            originalTitle: originalTitle,
            originalStartDay: originalStartDate,
            newTitle: newTitle,
            newStartDate: newStartDate,
            newEndDate: newEndDate,
            categoryColor: originCategoryColor,
            buttonType: .periodDay
        )

        switch result {
        case .success:
            print("✅ 기간 일정 수정 성공")
        case .failure(let error):
            print("❌ 기간 일정 수정 실패: \(error)")
        }
    }

    // MARK: - Helper Methods

    func getFormattedMonth() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM월 yyyy"
        return dateFormatter.string(from: todayMounth!)
    }
}
