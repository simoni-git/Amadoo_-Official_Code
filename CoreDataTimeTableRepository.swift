//
//  CoreDataTimeTableRepository.swift
//  NewCalendar
//
//  Data Layer - TimeTable Repository 구현체
//

import Foundation
import CoreData

/// TimeTable Repository CoreData 구현체
final class CoreDataTimeTableRepository: TimeTableRepositoryProtocol {

    private let contextProvider: CoreDataContextProviding
    private let userDefaults: UserDefaults

    // UserDefaults 키
    private let startHourKey = "TimeTableStartHour"
    private let endHourKey = "TimeTableEndHour"

    init(
        contextProvider: CoreDataContextProviding = CoreDataContextProvider.shared,
        userDefaults: UserDefaults = .standard
    ) {
        self.contextProvider = contextProvider
        self.userDefaults = userDefaults
    }

    // MARK: - Fetch

    func fetchAll() -> [TimeTableItem] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "TimeTable")

        do {
            let results = try contextProvider.context.fetch(request)
            return TimeTableMapper.toDomainList(results)
        } catch {
            print("❌ TimeTable fetchAll error: \(error)")
            return []
        }
    }

    func fetch(for dayOfWeek: Int) -> [TimeTableItem] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "TimeTable")
        request.predicate = NSPredicate(format: "dayOfWeek == %d", dayOfWeek)

        do {
            let results = try contextProvider.context.fetch(request)
            return TimeTableMapper.toDomainList(results)
        } catch {
            print("❌ TimeTable fetch for day error: \(error)")
            return []
        }
    }

    func fetchGroupedByDay() -> [Int: [TimeTableItem]] {
        let allItems = fetchAll()
        var grouped: [Int: [TimeTableItem]] = [:]

        for item in allItems {
            let day = Int(item.dayOfWeek)
            if grouped[day] == nil {
                grouped[day] = []
            }
            grouped[day]?.append(item)
        }

        // 각 요일별로 시작 시간 기준 정렬
        for (day, items) in grouped {
            grouped[day] = items.sorted { $0.startTime < $1.startTime }
        }

        return grouped
    }

    // MARK: - Save

    func save(_ item: TimeTableItem) -> Result<TimeTableItem, Error> {
        let context = contextProvider.context

        _ = TimeTableMapper.toManagedObject(item, context: context)

        do {
            try context.save()
            contextProvider.notifyWidgetUpdate()
            print("✅ TimeTable 저장 성공: \(item.title)")
            return .success(item)
        } catch {
            print("❌ TimeTable 저장 실패: \(error)")
            return .failure(error)
        }
    }

    // MARK: - Update

    func update(_ item: TimeTableItem) -> Result<TimeTableItem, Error> {
        let context = contextProvider.context
        let request = NSFetchRequest<NSManagedObject>(entityName: "TimeTable")

        request.predicate = NSPredicate(
            format: "dayOfWeek == %d AND startTime == %@ AND title == %@",
            item.dayOfWeek, item.startTime, item.title
        )

        do {
            let results = try context.fetch(request)
            if let existingObject = results.first {
                TimeTableMapper.update(existingObject, with: item)
                try context.save()
                contextProvider.notifyWidgetUpdate()
                print("✅ TimeTable 수정 성공: \(item.title)")
                return .success(item)
            } else {
                return .failure(NSError(domain: "CoreDataTimeTableRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "TimeTable not found"]))
            }
        } catch {
            print("❌ TimeTable 수정 실패: \(error)")
            return .failure(error)
        }
    }

    // MARK: - Delete

    func delete(_ item: TimeTableItem) -> Result<Void, Error> {
        let context = contextProvider.context
        let request = NSFetchRequest<NSManagedObject>(entityName: "TimeTable")

        request.predicate = NSPredicate(
            format: "dayOfWeek == %d AND startTime == %@ AND title == %@",
            item.dayOfWeek, item.startTime, item.title
        )

        do {
            let results = try context.fetch(request)
            for object in results {
                context.delete(object)
            }
            try context.save()
            contextProvider.notifyWidgetUpdate()
            print("✅ TimeTable 삭제 성공: \(item.title)")
            return .success(())
        } catch {
            print("❌ TimeTable 삭제 실패: \(error)")
            return .failure(error)
        }
    }

    // MARK: - Time Range Settings

    func getTimeRange() -> (startHour: Int, endHour: Int) {
        let startHour = userDefaults.integer(forKey: startHourKey)
        let endHour = userDefaults.integer(forKey: endHourKey)

        // 기본값 설정 (저장된 값이 없으면)
        if startHour == 0 && endHour == 0 {
            return (startHour: 9, endHour: 18)
        }

        return (startHour: startHour, endHour: endHour)
    }

    func saveTimeRange(startHour: Int, endHour: Int) {
        userDefaults.set(startHour, forKey: startHourKey)
        userDefaults.set(endHour, forKey: endHourKey)
        contextProvider.notifyWidgetUpdate()
        print("✅ TimeTable 시간 범위 저장: \(startHour):00 ~ \(endHour):00")
    }
}
