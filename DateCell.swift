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
    private let maxDisplayEvents = 4
    
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
            
            for i in 0..<maxDisplayEvents {
                var isConflict = false
                
                for day in stride(from: startDate, through: endDate, by: 86400) { 
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
            
            for day in stride(from: startDate, through: endDate, by: 86400) {
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
            
            DispatchQueue.main.async {
                label.backgroundColor = event.color
                label.textAlignment = .center
                label.font = UIFont.systemFont(ofSize: 10)
                label.textColor = .white
                label.clipsToBounds = true
                label.layer.cornerRadius = 5
            }
            
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
