//
//  ViewController.swift
//  NewCalendar
//
//  Created by 시모니 on 10/1/24.
//

import UIKit
import CoreData

class CalendarVC: UIViewController {
    
    var vm = CalendarVM()
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var todayBtn: UIButton!
    @IBOutlet weak var weekStackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        configure()
    }
    
    private func configure() {
        todayBtn.layer.cornerRadius = 10
        collectionView.layer.cornerRadius = 10
        updateMonthLabel()
        vm.addDefaultCategory()
        vm.fetchSavedEvents()
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        leftSwipe.direction = .left
        collectionView.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        rightSwipe.direction = .right
        collectionView.addGestureRecognizer(rightSwipe)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCalendar), name: NSNotification.Name("ScheduleSaved"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eventDeleted), name: NSNotification.Name("EventDeleted"), object: nil)
    }
    
    private func refreshCalendar() {
        DateCell.occupiedIndexesByDate.removeAll()
        collectionView.reloadData()
    }
    
    private func updateMonthLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월"
        dateLabel.text = dateFormatter.string(from: vm.currentMonth)
        collectionView.reloadData()
    }
    
    @IBAction func tapTodayBtn(_ sender: UIButton) {
        vm.currentMonth = Date()
        collectionView.reloadData()
        updateMonthLabel()
    }
    //MARK: - @objc-Code
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            vm.currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: vm.currentMonth)!
        } else if gesture.direction == .right {
            vm.currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: vm.currentMonth)!
        }
        collectionView.reloadData()
        updateMonthLabel()
        
        let transition = CATransition()
        transition.type = .push
        transition.subtype = gesture.direction == .left ? .fromRight : .fromLeft
        transition.duration = 0.1
        collectionView.layer.add(transition, forKey: nil)
    }
    
    @objc private func reloadCalendar() {
        vm.fetchSavedEvents()
        collectionView.reloadData()
        refreshCalendar()
    }
    
    @objc func eventDeleted() {
        vm.fetchSavedEvents()
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
        let firstDayOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: vm.currentMonth))!
        let firstWeekday = Calendar.current.component(.weekday, from: firstDayOfMonth) - 1
        
        let daysOffset = indexPath.item - firstWeekday
        let day = Calendar.current.date(byAdding: .day, value: daysOffset, to: firstDayOfMonth)!
        let dayNumber = Calendar.current.component(.day, from: day)
        
        cell.dateLabel.text = "\(dayNumber)"
        let isCurrentMonth = Calendar.current.isDate(day, equalTo: vm.currentMonth, toGranularity: .month)
        cell.dateLabel.alpha = isCurrentMonth ? 1.0 : 0.3
        
        if [0, 7, 14, 21, 28].contains(indexPath.item) {
            cell.dateLabel.textColor = .red
        } else if [6, 13, 20, 27, 34].contains(indexPath.item) {
            cell.dateLabel.textColor = .blue
        } else {
            cell.dateLabel.textColor = .black
        }
        
        cell.dateLabel.backgroundColor = .clear
        cell.dateLabel.layer.cornerRadius = 8
        cell.dateLabel.layer.masksToBounds = false
        
        let today = Calendar.current.startOfDay(for: Date())
        let cellDate = Calendar.current.startOfDay(for: day)
        if today == cellDate {
            cell.dateLabel.backgroundColor = UIColor(hex: "E6DFF1")
            cell.dateLabel.layer.cornerRadius = 5
            cell.dateLabel.layer.masksToBounds = true
        } else {
            
        }
        
        let dayEvents = vm.getEventsForDate(day)
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
        let firstDayOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: vm.currentMonth))!
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
        nextVC.vm.selecDateString = finalDateString
        nextVC.vm.selectedDate = selectedDate
        nextVC.vm.dDayString = dDayString
        present(nextVC, animated: true)
    }
    
}
