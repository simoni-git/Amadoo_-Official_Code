//
//  DateCell.swift
//  NewCalendar
//
//  Created by 시모니 on 10/2/24.
//

import UIKit

class DateCell: UICollectionViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dutyStackView: UIStackView!
    static var globalEventIndexes: [String: Int] = [:]
    static var occupiedIndexesByDate: [Date: [Int: String]] = [:]
    private let maxDisplayEvents = Constants.Calendar.maxDisplayedEvents

    // MARK: - Configure with CalendarDateItem (DiffableDataSource용)

    func configure(with item: CalendarDateItem) {
        // 날짜 표시
        dateLabel.text = "\(Calendar.current.component(.day, from: item.date))"
        dateLabel.alpha = item.isCurrentMonth ? 1.0 : 0.3

        // 요일별 색상
        switch item.dayOfWeek {
        case 0: dateLabel.textColor = .red     // 일요일
        case 6: dateLabel.textColor = .blue    // 토요일
        default: dateLabel.textColor = .black
        }

        // 오늘 표시
        if item.isToday {
            dateLabel.backgroundColor = UIColor.fromHexString("E6DFF1")
            dateLabel.layer.cornerRadius = 5
            dateLabel.layer.masksToBounds = true
        } else {
            dateLabel.backgroundColor = .clear
            dateLabel.layer.masksToBounds = false
        }

        // 이벤트 표시 - ScheduleItem 배열을 기존 형식으로 변환
        let events = item.events.map { schedule -> (title: String, color: UIColor, isPeriod: Bool, isStart: Bool, isEnd: Bool, startDate: Date, endDate: Date) in
            let isPeriod = schedule.buttonType == .periodDay
            let isStart = Calendar.current.isDate(item.date, inSameDayAs: schedule.startDay)
            let isEnd = Calendar.current.isDate(item.date, inSameDayAs: schedule.endDay)

            return (
                title: schedule.title,
                color: UIColor.fromHexString(schedule.categoryColor),
                isPeriod: isPeriod,
                isStart: isStart,
                isEnd: isEnd,
                startDate: schedule.startDay,
                endDate: schedule.endDay
            )
        }

        configure(with: events, for: item.date)
    }

    /// 시작일부터 종료일까지의 날짜 배열을 생성 (성능 최적화)
    private func dateRange(from startDate: Date, to endDate: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = DateHelper.shared.startOfDay(for: startDate)
        let end = DateHelper.shared.startOfDay(for: endDate)

        while currentDate <= end {
            dates.append(currentDate)
            guard let nextDate = DateHelper.shared.date(byAddingDays: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }

        return dates
    }

    func configure(with events: [(title: String, color: UIColor, isPeriod: Bool, isStart: Bool, isEnd: Bool, startDate: Date, endDate: Date)], for date: Date) {
        dutyStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let sortedEvents = events.sorted { (lhs, rhs) -> Bool in
            if lhs.isPeriod != rhs.isPeriod {
                return lhs.isPeriod && !rhs.isPeriod
            }
            return lhs.title < rhs.title
        }
        
        var eventLabels: [UILabel?] = Array(repeating: nil, count: maxDisplayEvents)
        var usedIndexes: Set<Int> = Set(DateCell.occupiedIndexesByDate[date]?.keys.map { Int($0) } ?? [])
        
        for event in sortedEvents {
            let title = event.title
            let startDate = event.startDate
            let endDate = event.endDate
            var assignedIndex: Int = -1
            
            // 날짜 범위를 미리 계산 (성능 최적화)
            let dateRangeArray = dateRange(from: startDate, to: endDate)

            for i in 0..<maxDisplayEvents {
                var isConflict = false

                for day in dateRangeArray {
                    if let occupiedTitle = DateCell.occupiedIndexesByDate[day]?[i], occupiedTitle != title {
                        isConflict = true
                        break
                    }
                }

                if !isConflict {
                    assignedIndex = i
                    break
                }
            }
            
            guard assignedIndex != -1 else { continue }

            // 이미 계산된 날짜 배열 재사용 (성능 최적화)
            for day in dateRangeArray {
                if DateCell.occupiedIndexesByDate[day] == nil {
                    DateCell.occupiedIndexesByDate[day] = [:]
                }
                DateCell.occupiedIndexesByDate[day]?[assignedIndex] = title
            }
            
            usedIndexes.insert(assignedIndex)
            
            let label = UILabel()
            if event.isPeriod && !event.isStart {
                label.text = ""
            } else {
                label.text = title
            }

            // 이미 main thread에서 실행 중이므로 async 불필요 (성능 최적화)
            label.backgroundColor = event.color
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 10)
            label.textColor = .white
            label.clipsToBounds = true
            label.layer.cornerRadius = 5
            
            if event.isStart && event.isEnd {
                label.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            } else if event.isStart {
                label.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            } else if event.isEnd {
                label.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            } else {
                label.layer.maskedCorners = []
            }
            
            eventLabels[assignedIndex] = label
        }
        
        for i in 0..<maxDisplayEvents {
            if let label = eventLabels[i] {
                dutyStackView.addArrangedSubview(label)
            } else {
                let emptyLabel = UILabel()
                emptyLabel.text = ""
                emptyLabel.backgroundColor = .clear
                dutyStackView.addArrangedSubview(emptyLabel)
            }
        }
    }
    
}
