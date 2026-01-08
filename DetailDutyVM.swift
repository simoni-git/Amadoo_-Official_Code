//
//  DetailDutyVM.swift
//  NewCalendar
//
//  Created by 시모니 on 1/7/25.
//

import Foundation

class DetailDutyVM {

    var selectedDate: Date?
    var selecDateString: String?
    var dDayString: String?

    // DutyType을 ButtonType으로 사용 (기존 코드와의 호환성 유지)
    typealias ButtonType = DutyType

    // MARK: - Clean Architecture Dependencies
    private let fetchSchedulesUseCase: FetchSchedulesUseCaseProtocol
    private let deleteScheduleUseCase: DeleteScheduleUseCaseProtocol
    let notificationService: NotificationServiceProtocol

    /// 클린 아키텍처 의존성 주입 (Domain Layer Entity 사용)
    private(set) var schedules: [ScheduleItem] = []

    // MARK: - Initializer
    init(
        fetchSchedulesUseCase: FetchSchedulesUseCaseProtocol,
        deleteScheduleUseCase: DeleteScheduleUseCaseProtocol,
        notificationService: NotificationServiceProtocol
    ) {
        self.fetchSchedulesUseCase = fetchSchedulesUseCase
        self.deleteScheduleUseCase = deleteScheduleUseCase
        self.notificationService = notificationService
    }

    // MARK: - UseCase Methods

    /// UseCase를 통한 선택된 날짜의 일정 조회
    func fetchSchedulesForSelectedDate(completion: @escaping () -> Void) {
        guard let date = selectedDate else {
            schedules = []
            completion()
            return
        }

        schedules = fetchSchedulesUseCase.execute(for: date)
        completion()
    }

    /// UseCase를 통한 일정 삭제
    func deleteScheduleUsingUseCase(_ schedule: ScheduleItem) -> Result<Void, Error> {
        return deleteScheduleUseCase.execute(schedule: schedule)
    }

    /// UseCase를 통한 기간 일정 전체 삭제
    func deleteAllSchedulesUsingUseCase(title: String, startDay: Date) -> Result<Void, Error> {
        return deleteScheduleUseCase.executeAll(title: title, startDay: startDay)
    }
}
