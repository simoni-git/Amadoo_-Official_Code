//
//  ViewController.swift
//  NewCalendar
//
//  Created by 시모니 on 10/1/24.
//

import UIKit
import CoreData

class CalendarVC: UIViewController {
    
    var context: NSManagedObjectContext {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }
        return app.persistentContainer.viewContext
    }
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var todayBtn: UIButton!
    @IBOutlet weak var weekStackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var currentMonth: Date = Date()
    private var savedEvents: [NSManagedObject] = []
    
    enum ButtonType: String {
        case defaultDay = "defaultDay"
        case periodDay = "periodDay"
        case multipleDay = "multipleDay"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        configure()
        addDefaultCategoryIfNeeded()
        fetchSavedEvents()
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        leftSwipe.direction = .left
        collectionView.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        rightSwipe.direction = .right
        collectionView.addGestureRecognizer(rightSwipe)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCalendar), name: NSNotification.Name("ScheduleSaved"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eventDeleted), name: NSNotification.Name("EventDeleted"), object: nil)
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
        } else if gesture.direction == .right {
            currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
        }
        collectionView.reloadData()
        updateMonthLabel()

        let transition = CATransition()
        transition.type = .push
        transition.subtype = gesture.direction == .left ? .fromRight : .fromLeft
        transition.duration = 0.1
        collectionView.layer.add(transition, forKey: nil)
    }
    
    private func configure() {
        todayBtn.layer.cornerRadius = 10
        collectionView.layer.cornerRadius = 10
        updateMonthLabel()
    }
    
    private func addDefaultCategoryIfNeeded() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        request.predicate = NSPredicate(format: "isDefault == true")
        
        do {
            let result = try context.fetch(request)
            if result.isEmpty {
                let entity = NSEntityDescription.entity(forEntityName: "Category", in: context)!
                let defaultCategory = NSManagedObject(entity: entity, insertInto: context)
                defaultCategory.setValue("할 일", forKey: "name")
                defaultCategory.setValue("#808080", forKey: "color") // 회색
                defaultCategory.setValue(true, forKey: "isDefault")
                
                try context.save()
                
            }
        } catch {
            
        }
    }
    
    private func colorFromCoreData(_ colorString: String) -> UIColor {
        let components = colorString.split(separator: ",").compactMap { CGFloat(Double($0) ?? 0) }
        guard components.count == 3 else { return UIColor.systemGray } // 기본 색상
        return UIColor(red: components[0] / 255.0, green: components[1] / 255.0, blue: components[2] / 255.0, alpha: 1.0)
    }
    
    private func getEventsForDate(_ date: Date) -> [(title: String, color: UIColor, isPeriod: Bool, isStart: Bool, isEnd: Bool, startDate: Date, endDate: Date)] {
        var events: [(title: String, color: UIColor, isPeriod: Bool, isStart: Bool, isEnd: Bool, startDate: Date, endDate: Date)] = []
        var addedEventTitles: Set<String> = []
        var eventLevels: [Int: String] = [:]
        
        let maxLevels = 4
        
        for event in savedEvents {
            guard let eventDate = event.value(forKey: "date") as? Date,
                  let title = event.value(forKey: "title") as? String,
                  let buttonType = event.value(forKey: "buttonType") as? String,
                  let startDay = event.value(forKey: "startDay") as? Date,
                  let endDay = event.value(forKey: "endDay") as? Date,
                  let colorString = event.value(forKey: "categoryColor") as? String else { continue }
            
            let color: UIColor = UIColor(hex: colorString)
            let isPeriod = (buttonType == ButtonType.periodDay.rawValue)
            
            if addedEventTitles.contains(title + startDay.description) {
                continue
            }
            
            var assignedLevel: Int = -1
            
            if isPeriod {
                if date >= startDay && date <= endDay {
                    for level in 0..<maxLevels {
                        if eventLevels[level] == nil {
                            assignedLevel = level
                            eventLevels[level] = title
                            break
                        }
                    }
                    guard assignedLevel != -1 else { continue }
                    
                    let isStart = (date == startDay)
                    let isEnd = (date == endDay)
                    events.append((title: title, color: color, isPeriod: true, isStart: isStart, isEnd: isEnd, startDate: startDay, endDate: endDay))
                    addedEventTitles.insert(title + startDay.description)
                }
            } else {
                if Calendar.current.isDate(eventDate, inSameDayAs: date) {
                    for level in 0..<maxLevels {
                        if eventLevels[level] == nil {
                            assignedLevel = level
                            eventLevels[level] = title
                            break
                        }
                    }
                    guard assignedLevel != -1 else { continue }
                    
                    events.append((title: title, color: color, isPeriod: false, isStart: true, isEnd: true, startDate: eventDate, endDate: eventDate))
                    addedEventTitles.insert(title + startDay.description)
                }
            }
        }
        
        return events
    }
    
    private func refreshCalendar() {
        DateCell.occupiedIndexesByDate.removeAll()
        collectionView.reloadData()
    }
    
    private func updateMonthLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월"
        dateLabel.text = dateFormatter.string(from: currentMonth)
        collectionView.reloadData()
    }
    
    private func fetchSavedEvents() {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Schedule")
        
        do {
            savedEvents = try context.fetch(request)
        } catch  {
            
        }
    }
    
    private func hasEvent(for date: Date) -> Bool {
        return savedEvents.contains { event in
            if let eventDate = event.value(forKey: "date") as? Date {
                return Calendar.current.isDate(eventDate, inSameDayAs: date)
            }
            return false
        }
    }
    
    private func isStartDate(for date: Date) -> Bool {
        let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: date)!
        return !savedEvents.contains { event in
            if let eventDate = event.value(forKey: "date") as? Date,
               Calendar.current.isDate(eventDate, inSameDayAs: previousDate) {
                let buttonType = event.value(forKey: "buttonType") as? String
                return buttonType == ButtonType.periodDay.rawValue
            }
            return false
        }
    }
    
    private func isEndDate(for date: Date) -> Bool {
        let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        return !savedEvents.contains { event in
            if let eventDate = event.value(forKey: "date") as? Date,
               Calendar.current.isDate(eventDate, inSameDayAs: nextDate) {
                let buttonType = event.value(forKey: "buttonType") as? String
                return buttonType == ButtonType.periodDay.rawValue
            }
            return false
        }
    }
    
    @IBAction func tapTodayBtn(_ sender: UIButton) {
        currentMonth = Date()
        collectionView.reloadData()
        updateMonthLabel()
    }
    
    @objc private func reloadCalendar() {
        fetchSavedEvents()
        collectionView.reloadData()
        refreshCalendar()
    }
    
    @objc func eventDeleted() {
        fetchSavedEvents()
        collectionView.reloadData()
        refreshCalendar()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

// MARK: - collecitonView 관련
extension CalendarVC: UICollectionViewDataSource , UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as? DateCell else {
            return UICollectionViewCell()
        }
        let firstDayOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: currentMonth))!
        let firstWeekday = Calendar.current.component(.weekday, from: firstDayOfMonth) - 1
        
        let daysOffset = indexPath.item - firstWeekday
        let day = Calendar.current.date(byAdding: .day, value: daysOffset, to: firstDayOfMonth)!
        let dayNumber = Calendar.current.component(.day, from: day)
        
        cell.dateLabel.text = "\(dayNumber)"
        let isCurrentMonth = Calendar.current.isDate(day, equalTo: currentMonth, toGranularity: .month)
        cell.dateLabel.alpha = isCurrentMonth ? 1.0 : 0.3
        
        if [0, 7, 14, 21, 28].contains(indexPath.item) {
            cell.dateLabel.textColor = .red
        } else if [6, 13, 20, 27, 34].contains(indexPath.item) {
            cell.dateLabel.textColor = .blue
        } else {
            cell.dateLabel.textColor = .black
        }
        
        DispatchQueue.main.async {
            cell.dateLabel.backgroundColor = .clear
            cell.dateLabel.layer.cornerRadius = 8
            cell.dateLabel.layer.masksToBounds = false
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        let cellDate = Calendar.current.startOfDay(for: day)
        if today == cellDate {
            DispatchQueue.main.async {
                cell.dateLabel.backgroundColor = UIColor(hex: "E6DFF1")
                cell.dateLabel.layer.cornerRadius = 5
                cell.dateLabel.layer.masksToBounds = true
            }
        } else {
            
        }
        
        let dayEvents = getEventsForDate(day)
        cell.configure(with: dayEvents, for: day)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let totalWidth = self.weekStackView.frame.width
        let numberOfItemsInRow: CGFloat = 7
        let itemWidth = floor(totalWidth / numberOfItemsInRow)
        let remainingWidth = totalWidth - (itemWidth * numberOfItemsInRow)
        let additionalWidth = remainingWidth / 2
        let width: CGFloat
        
        if indexPath.item % Int(numberOfItemsInRow) == 0 {
            width = itemWidth + additionalWidth
        } else if indexPath.item % Int(numberOfItemsInRow) == Int(numberOfItemsInRow - 1) {
            width = itemWidth + additionalWidth
        } else {
            width = itemWidth
        }
        
        return CGSize(width: width, height: itemWidth * 1.5)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let firstDayOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: currentMonth))!
        let firstWeekday = Calendar.current.component(.weekday, from: firstDayOfMonth) - 1
        
        let daysOffset = indexPath.item - firstWeekday
        let selectedDate = Calendar.current.date(byAdding: .day, value: daysOffset, to: firstDayOfMonth)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM월 dd일"
        let dateString = dateFormatter.string(from: selectedDate)
        
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.locale = Locale(identifier: "ko_KR")
        weekdayFormatter.dateFormat = "EEEE"
        let weekdayString = weekdayFormatter.string(from: selectedDate)
        let finalDateString = "\(dateString) (\(weekdayString))"
        
        let today = Date()
        let calendar = Calendar.current
        
        let startOfToday = calendar.startOfDay(for: today)
        let startOfSelectedDate = calendar.startOfDay(for: selectedDate)
        
        let dayDifference = calendar.dateComponents([.day], from: startOfToday, to: startOfSelectedDate).day ?? 0
        var dDayString = ""
        
        if dayDifference > 0 {
            dDayString = "D-\(dayDifference)"
        } else if dayDifference == 0 {
            dDayString = "D-day!"
        } else {
            dDayString = "D+\(-dayDifference)"
        }
        
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "DetailDutyVC") as? DetailDutyVC else { return }
        nextVC.selecDateString = finalDateString
        nextVC.selectedDate = selectedDate
        nextVC.dDayString = dDayString
        present(nextVC, animated: true)
    }
    
}
