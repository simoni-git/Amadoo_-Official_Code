//
//  CalendarVM.swift
//  NewCalendar
//
//  Created by 시모니 on 1/6/25.
//

import UIKit

class CalendarVM {

    var currentMonth: Date = Date()
    let userNotificationManager = UserNotificationManager.shared

    // DutyType을 ButtonType으로 사용 (기존 코드와의 호환성 유지)
    typealias ButtonType = DutyType

    // MARK: - Clean Architecture Dependencies
    private var fetchSchedulesUseCase: FetchSchedulesUseCaseProtocol?
    private var fetchCategoriesUseCase: FetchCategoriesUseCaseProtocol?
    private var saveCategoryUseCase: SaveCategoryUseCaseProtocol?

    /// 클린 아키텍처 의존성 주입 (Domain Layer Entity 사용)
    private(set) var schedules: [ScheduleItem] = []

    /// 의존성 주입 메서드
    func injectDependencies(
        fetchSchedulesUseCase: FetchSchedulesUseCaseProtocol,
        fetchCategoriesUseCase: FetchCategoriesUseCaseProtocol,
        saveCategoryUseCase: SaveCategoryUseCaseProtocol
    ) {
        self.fetchSchedulesUseCase = fetchSchedulesUseCase
        self.fetchCategoriesUseCase = fetchCategoriesUseCase
        self.saveCategoryUseCase = saveCategoryUseCase
    }

    // MARK: - UseCase Methods

    /// UseCase를 통한 일정 조회
    func fetchSchedules() {
        guard let useCase = fetchSchedulesUseCase else {
            schedules = []
            return
        }
        schedules = useCase.execute()
    }

    /// UseCase를 통한 특정 날짜 일정 조회
    func fetchSchedules(for date: Date) -> [ScheduleItem] {
        guard let useCase = fetchSchedulesUseCase else { return [] }
        return useCase.execute(for: date)
    }

    /// 특정 날짜에 해당하는 ScheduleItem 배열 반환 (DiffableDataSource용)
    func getScheduleItems(for date: Date) -> [ScheduleItem] {
        let calendar = Calendar.current
        return schedules.filter { schedule in
            if schedule.buttonType == .periodDay {
                return date >= schedule.startDay && date <= schedule.endDay
            } else {
                return calendar.isDate(schedule.date, inSameDayAs: date)
            }
        }
    }

    /// Domain Entity 기반 이벤트 조회
    func getEventsForDate(_ date: Date) -> [(title: String, color: UIColor, isPeriod: Bool, isStart: Bool, isEnd: Bool, startDate: Date, endDate: Date)] {
        var events: [(title: String, color: UIColor, isPeriod: Bool, isStart: Bool, isEnd: Bool, startDate: Date, endDate: Date)] = []
        var addedEventTitles: Set<String> = []
        var eventLevels: [Int: String] = [:]
        let maxLevels = 4
        let calendar = Calendar.current

        for schedule in schedules {
            let color = UIColor.fromHexString(schedule.categoryColor)
            let isPeriod = schedule.isPeriod

            let eventKey = schedule.title + schedule.startDay.description
            if addedEventTitles.contains(eventKey) { continue }

            var assignedLevel: Int = -1

            if isPeriod {
                if date >= schedule.startDay && date <= schedule.endDay {
                    for level in 0..<maxLevels {
                        if eventLevels[level] == nil {
                            assignedLevel = level
                            eventLevels[level] = schedule.title
                            break
                        }
                    }
                    guard assignedLevel != -1 else { continue }

                    let isStart = calendar.isDate(date, inSameDayAs: schedule.startDay)
                    let isEnd = calendar.isDate(date, inSameDayAs: schedule.endDay)
                    events.append((title: schedule.title, color: color, isPeriod: true, isStart: isStart, isEnd: isEnd, startDate: schedule.startDay, endDate: schedule.endDay))
                    addedEventTitles.insert(eventKey)
                }
            } else {
                if calendar.isDate(schedule.date, inSameDayAs: date) {
                    for level in 0..<maxLevels {
                        if eventLevels[level] == nil {
                            assignedLevel = level
                            eventLevels[level] = schedule.title
                            break
                        }
                    }
                    guard assignedLevel != -1 else { continue }

                    events.append((title: schedule.title, color: color, isPeriod: false, isStart: true, isEnd: true, startDate: schedule.date, endDate: schedule.date))
                    addedEventTitles.insert(eventKey)
                }
            }
        }

        return events
    }

    /// 기본 카테고리 생성 (없으면)
    func addDefaultCategory() {
        // CloudKit 동기화가 완료될 때까지 잠시 대기
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            guard let useCase = self?.saveCategoryUseCase else { return }
            if case .success(let category) = useCase.createDefaultIfNeeded() {
                if category != nil {
                    print("기본 카테고리 '할 일' 생성됨")
                } else {
                    print("카테고리가 이미 존재함 (CloudKit에서 복원되었거나 기존 데이터)")
                }
            }
        }
    }
}
