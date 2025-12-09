//
//  WidgetDataManager.swift
//  AmadooWidget
//
//  위젯에서 CoreData 데이터를 읽기 위한 매니저
//

import Foundation
import CoreData

final class WidgetDataManager {
    static let shared = WidgetDataManager()

    private let appGroupIdentifier = "group.Simoni.Amadoo"

    private init() {}

    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NewCalendar")

        // App Group의 공유 디렉토리 URL 설정
        if let storeURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        )?.appendingPathComponent("NewCalendar.sqlite") {

            let storeDescription = NSPersistentStoreDescription(url: storeURL)
            storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            container.persistentStoreDescriptions = [storeDescription]
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("❌ Widget Core Data 로드 실패: \(error)")
            } else {
                print("✅ Widget Core Data 로드 성공: \(storeDescription.url?.path ?? "unknown")")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - TimeTable 데이터 가져오기

    /// 특정 요일의 시간표 데이터 가져오기
    /// - Parameter dayOfWeek: 요일 (0: 월요일, 1: 화요일, ..., 4: 금요일)
    /// - Returns: 해당 요일의 시간표 배열
    func getTimetables(for dayOfWeek: Int) -> [TimetableData] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TimeTable")
        fetchRequest.predicate = NSPredicate(format: "dayOfWeek == %d", dayOfWeek)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]

        do {
            let results = try context.fetch(fetchRequest)
            return results.compactMap { object in
                guard let title = object.value(forKey: "title") as? String,
                      let startTime = object.value(forKey: "startTime") as? String,
                      let endTime = object.value(forKey: "endTime") as? String,
                      let colorString = object.value(forKey: "color") as? String else {
                    return nil
                }

                let memo = object.value(forKey: "memo") as? String

                return TimetableData(
                    dayOfWeek: dayOfWeek,
                    startTime: startTime,
                    endTime: endTime,
                    title: title,
                    memo: memo,
                    color: colorString
                )
            }
        } catch {
            print("❌ 시간표 데이터 로드 실패: \(error)")
            return []
        }
    }

    /// 모든 요일의 시간표 데이터 가져오기 (월~금)
    /// - Returns: 요일별 시간표 딕셔너리 [요일: [시간표]]
    func getAllTimetables() -> [Int: [TimetableData]] {
        var result: [Int: [TimetableData]] = [:]
        for day in 0...4 {
            result[day] = getTimetables(for: day)
        }
        return result
    }

    // MARK: - Schedule 데이터 가져오기

    /// 특정 날짜의 일정 데이터 가져오기
    /// - Parameter date: 날짜
    /// - Returns: 해당 날짜의 일정 배열
    func getSchedules(for date: Date) -> [ScheduleData] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Schedule")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDay", ascending: true)]

        do {
            let results = try context.fetch(fetchRequest)
            print("📊 Widget: Schedule 전체 개수 = \(results.count)")

            let calendar = Calendar.current
            let targetDate = calendar.startOfDay(for: date)

            let schedules: [ScheduleData] = results.compactMap { object -> ScheduleData? in
                guard let title = object.value(forKey: "title") as? String,
                      let startDay = object.value(forKey: "startDay") as? Date,
                      let endDay = object.value(forKey: "endDay") as? Date,
                      let colorString = object.value(forKey: "categoryColor") as? String,
                      let buttonType = object.value(forKey: "buttonType") as? String else {
                    return nil
                }

                let scheduleStart = calendar.startOfDay(for: startDay)
                let scheduleEnd = calendar.startOfDay(for: endDay)

                // 기간 일정인 경우
                if buttonType == "periodDay" {
                    if targetDate >= scheduleStart && targetDate <= scheduleEnd {
                        let isStart = calendar.isDate(targetDate, inSameDayAs: startDay)
                        let isEnd = calendar.isDate(targetDate, inSameDayAs: endDay)

                        return ScheduleData(
                            title: title,
                            color: colorString,
                            isPeriod: true,
                            isStart: isStart,
                            isEnd: isEnd
                        )
                    }
                } else {
                    // 단일 일정인 경우
                    if calendar.isDate(targetDate, inSameDayAs: startDay) {
                        return ScheduleData(
                            title: title,
                            color: colorString,
                            isPeriod: false,
                            isStart: true,
                            isEnd: true
                        )
                    }
                }

                return nil
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            print("📅 Widget: \(formatter.string(from: date)) 날짜의 일정 개수 = \(schedules.count)")
            return schedules
        } catch {
            print("❌ 일정 데이터 로드 실패: \(error)")
            return []
        }
    }

    /// 날짜 범위의 일정 데이터 가져오기 (달력 위젯용)
    /// - Parameters:
    ///   - startDate: 시작 날짜
    ///   - endDate: 종료 날짜
    /// - Returns: 날짜별 일정 딕셔너리 [날짜: [일정]]
    func getSchedules(from startDate: Date, to endDate: Date) -> [Date: [ScheduleData]] {
        var result: [Date: [ScheduleData]] = [:]
        let calendar = Calendar.current

        var currentDate = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)

        while currentDate <= end {
            result[currentDate] = getSchedules(for: currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }

        return result
    }

    // MARK: - UserDefaults (시간표 설정)

    /// 시간표 시작 시간 가져오기
    var startHour: Int {
        let defaults = UserDefaults(suiteName: appGroupIdentifier)
        let saved = defaults?.integer(forKey: "TimeTable_StartHour") ?? 0
        return saved != 0 ? saved : 9 // 기본값: 9시
    }

    /// 시간표 종료 시간 가져오기
    var endHour: Int {
        let defaults = UserDefaults(suiteName: appGroupIdentifier)
        let saved = defaults?.integer(forKey: "TimeTable_EndHour") ?? 0
        return saved != 0 ? saved : 18 // 기본값: 18시
    }
}

// MARK: - Data Models

struct TimetableData: Identifiable {
    let id = UUID()
    let dayOfWeek: Int
    let startTime: String  // "HH:mm"
    let endTime: String    // "HH:mm"
    let title: String
    let memo: String?
    let color: String      // 16진수 색상 코드

    /// 시간 문자열을 시간과 분으로 분리
    func parseTime(_ timeString: String) -> (hour: Int, minute: Int)? {
        let components = timeString.split(separator: ":").compactMap { Int($0) }
        guard components.count == 2 else { return nil }
        return (hour: components[0], minute: components[1])
    }
}

struct ScheduleData: Identifiable {
    let id = UUID()
    let title: String
    let color: String      // 16진수 색상 코드
    let isPeriod: Bool     // 기간 일정 여부
    let isStart: Bool      // 시작일 여부
    let isEnd: Bool        // 종료일 여부
}
