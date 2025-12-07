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
