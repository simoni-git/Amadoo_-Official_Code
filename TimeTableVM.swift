//
//  TimeTableVM.swift
//  NewCalendar
//
//  Created by 시모니의 맥북 on 11/24/25.
//

import Foundation
import CoreData

class TimeTableVM {
    
    // MARK: - Properties
    private var timetableData: [NSManagedObject] = []
    
    // MARK: - Public Methods
    
    /// Core Data에서 시간표 데이터 로드
    func loadTimetableData() {
        let context = CoreDataManager.shared.context
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TimeTable")
        
        // 정렬: 요일 -> 시작시간 순
        let daySort = NSSortDescriptor(key: "dayOfWeek", ascending: true)
        let timeSort = NSSortDescriptor(key: "startTime", ascending: true)
        fetchRequest.sortDescriptors = [daySort, timeSort]
        
        do {
            timetableData = try context.fetch(fetchRequest)
            print("시간표 로드 완료: \(timetableData.count)개")
        } catch {
            print("시간표 로드 실패: \(error)")
            timetableData = []
        }
    }
    
//    /// 특정 요일과 시간에 해당하는 시간표 찾기
//    /// - Parameters:
//    ///   - dayOfWeek: 요일 (0:월 ~ 4:금)
//    ///   - hour: 시간 (0~23)
//    /// - Returns: 해당 시간표 데이터 또는 nil
//    func getTimetable(dayOfWeek: Int, hour: Int) -> NSManagedObject? {
//        for timetable in timetableData {
//            guard let day = timetable.value(forKey: "dayOfWeek") as? Int16,
//                  let startTime = timetable.value(forKey: "startTime") as? String,
//                  let endTime = timetable.value(forKey: "endTime") as? String else {
//                continue
//            }
//            
//            // 요일이 같은지 확인
//            if Int(day) != dayOfWeek {
//                continue
//            }
//            
//            // 현재 셀의 시간 범위
//            let cellStartTime = String(format: "%02d:00", hour)
//            
//            // 시간표가 이 셀 시간대에 포함되는지 확인
//            if startTime <= cellStartTime && endTime > cellStartTime {
//                return timetable
//            }
//        }
//        
//        return nil
//    }
    
    // getTimetable 메서드 전체 교체
    func getTimetable(dayOfWeek: Int, hour: Int, minute: Int) -> NSManagedObject? {
        for timetable in timetableData {
            guard let day = timetable.value(forKey: "dayOfWeek") as? Int16,
                  let startTime = timetable.value(forKey: "startTime") as? String,
                  let endTime = timetable.value(forKey: "endTime") as? String else {
                continue
            }
            
            // 요일이 같은지 확인
            if Int(day) != dayOfWeek {
                continue
            }
            
            // 현재 셀의 시간
            let cellTime = String(format: "%02d:%02d", hour, minute)
            
            // 시간표가 이 셀 시간대에 포함되는지 확인
            if startTime <= cellTime && endTime > cellTime {
                return timetable
            }
        }
        
        return nil
    }
    
    /// 시간표의 표시 텍스트 가져오기 (제목 + 메모)
    func getDisplayText(from timetable: NSManagedObject) -> String {
        var displayText = ""
        
        if let title = timetable.value(forKey: "title") as? String {
            displayText = title
        }
        
        if let memo = timetable.value(forKey: "memo") as? String, !memo.isEmpty {
            displayText += "\n\(memo)"
        }
        
        return displayText
    }
    
    /// 시간표의 배경색 코드 가져오기
    func getColorCode(from timetable: NSManagedObject) -> String? {
        return timetable.value(forKey: "color") as? String
    }
    
//    func isFirstCell(dayOfWeek: Int, hour: Int, timetable: NSManagedObject) -> Bool {
//        guard let startTime = timetable.value(forKey: "startTime") as? String else {
//            return false
//        }
//        
//        let cellStartTime = String(format: "%02d:00", hour)
//        return startTime == cellStartTime
//    }
    // isFirstCell 메서드 전체 교체
    func isFirstCell(dayOfWeek: Int, hour: Int, minute: Int, timetable: NSManagedObject) -> Bool {
        guard let startTime = timetable.value(forKey: "startTime") as? String else {
            return false
        }
        
        let cellTime = String(format: "%02d:%02d", hour, minute)
        return startTime == cellTime
    }
    

    /// 시간표가 차지하는 셀의 개수 계산
    func getCellCount(for timetable: NSManagedObject) -> Int {
        guard let startTime = timetable.value(forKey: "startTime") as? String,
              let endTime = timetable.value(forKey: "endTime") as? String else {
            return 1
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let start = formatter.date(from: startTime),
              let end = formatter.date(from: endTime) else {
            return 1
        }
        
        let hourDiff = Calendar.current.dateComponents([.hour], from: start, to: end).hour ?? 1
        return hourDiff
    }
}
