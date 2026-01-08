//
//  CoreDataScheduleRepository.swift
//  NewCalendar
//
//  Data Layer - Schedule Repository 구현체
//

import Foundation
import CoreData

/// Schedule Repository CoreData 구현체
final class CoreDataScheduleRepository: ScheduleRepositoryProtocol {

    private let contextProvider: CoreDataContextProviding

    init(contextProvider: CoreDataContextProviding = CoreDataContextProvider.shared) {
        self.contextProvider = contextProvider
    }

    // MARK: - Fetch

    func fetchAll() -> [ScheduleItem] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Schedule")

        do {
            let results = try contextProvider.context.fetch(request)
            return ScheduleMapper.toDomainList(results)
        } catch {
            print("❌ Schedule fetchAll error: \(error)")
            return []
        }
    }

    func fetch(for date: Date) -> [ScheduleItem] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let request = NSFetchRequest<NSManagedObject>(entityName: "Schedule")
        // 해당 날짜의 일정만 조회 (기간 일정도 각 날짜별로 레코드가 있으므로 date만 체크)
        request.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            startOfDay as CVarArg, endOfDay as CVarArg
        )

        do {
            let results = try contextProvider.context.fetch(request)
            return ScheduleMapper.toDomainList(results)
        } catch {
            print("❌ Schedule fetch for date error: \(error)")
            return []
        }
    }

    func fetch(from startDate: Date, to endDate: Date) -> [ScheduleItem] {
        let calendar = Calendar.current
        let startOfStartDate = calendar.startOfDay(for: startDate)
        let endOfEndDate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate))!

        let request = NSFetchRequest<NSManagedObject>(entityName: "Schedule")
        request.predicate = NSPredicate(
            format: "(date >= %@ AND date < %@) OR (startDay <= %@ AND endDay >= %@)",
            startOfStartDate as CVarArg, endOfEndDate as CVarArg,
            endDate as CVarArg, startDate as CVarArg
        )

        do {
            let results = try contextProvider.context.fetch(request)
            return ScheduleMapper.toDomainList(results)
        } catch {
            print("❌ Schedule fetch range error: \(error)")
            return []
        }
    }

    // MARK: - Save

    func save(_ schedule: ScheduleItem) -> Result<ScheduleItem, Error> {
        let context = contextProvider.context

        _ = ScheduleMapper.toManagedObject(schedule, context: context)

        do {
            try context.save()
            contextProvider.notifyWidgetUpdate()
            print("✅ Schedule 저장 성공")
            return .success(schedule)
        } catch {
            print("❌ Schedule 저장 실패: \(error)")
            return .failure(error)
        }
    }

    func savePeriod(
        title: String,
        startDate: Date,
        endDate: Date,
        categoryColor: String,
        buttonType: DutyType
    ) -> Result<[ScheduleItem], Error> {
        let context = contextProvider.context
        var schedules: [ScheduleItem] = []
        var currentDate = startDate
        let calendar = Calendar.current

        while currentDate <= endDate {
            let schedule = ScheduleItem(
                title: title,
                date: currentDate,
                startDay: startDate,
                endDay: endDate,
                buttonType: buttonType,
                categoryColor: categoryColor
            )
            _ = ScheduleMapper.toManagedObject(schedule, context: context)
            schedules.append(schedule)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        do {
            try context.save()
            contextProvider.notifyWidgetUpdate()
            print("✅ 기간 Schedule \(schedules.count)개 저장 성공")
            return .success(schedules)
        } catch {
            print("❌ 기간 Schedule 저장 실패: \(error)")
            return .failure(error)
        }
    }

    // MARK: - Update

    func update(_ schedule: ScheduleItem) -> Result<ScheduleItem, Error> {
        let context = contextProvider.context
        let request = NSFetchRequest<NSManagedObject>(entityName: "Schedule")

        // title과 startDay로 찾기
        request.predicate = NSPredicate(
            format: "title == %@ AND startDay == %@",
            schedule.title, schedule.startDay as CVarArg
        )

        do {
            let results = try context.fetch(request)
            if let existingObject = results.first {
                ScheduleMapper.update(existingObject, with: schedule)
                try context.save()
                contextProvider.notifyWidgetUpdate()
                print("✅ Schedule 수정 성공")
                return .success(schedule)
            } else {
                return .failure(NSError(domain: "CoreDataScheduleRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Schedule not found"]))
            }
        } catch {
            print("❌ Schedule 수정 실패: \(error)")
            return .failure(error)
        }
    }

    // MARK: - Delete

    func delete(_ schedule: ScheduleItem) -> Result<Void, Error> {
        let context = contextProvider.context
        let request = NSFetchRequest<NSManagedObject>(entityName: "Schedule")

        request.predicate = NSPredicate(
            format: "title == %@ AND date == %@",
            schedule.title, schedule.date as CVarArg
        )

        do {
            let results = try context.fetch(request)
            for object in results {
                context.delete(object)
            }
            try context.save()
            contextProvider.notifyWidgetUpdate()
            print("✅ Schedule 삭제 성공")
            return .success(())
        } catch {
            print("❌ Schedule 삭제 실패: \(error)")
            return .failure(error)
        }
    }

    func deleteAll(title: String, startDay: Date) -> Result<Void, Error> {
        let context = contextProvider.context
        let request = NSFetchRequest<NSManagedObject>(entityName: "Schedule")

        request.predicate = NSPredicate(
            format: "title == %@ AND startDay == %@",
            title, startDay as CVarArg
        )

        do {
            let results = try context.fetch(request)
            for object in results {
                context.delete(object)
            }
            try context.save()
            contextProvider.notifyWidgetUpdate()
            print("✅ Schedule 전체 삭제 성공 (\(results.count)개)")
            return .success(())
        } catch {
            print("❌ Schedule 전체 삭제 실패: \(error)")
            return .failure(error)
        }
    }
}
