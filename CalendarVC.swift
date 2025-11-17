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
    @IBOutlet weak var moveDateBtn: UIButton!
    @IBOutlet weak var todayBtn: UIButton!
    @IBOutlet weak var weekStackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    private var cloudKitUpdateTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        configure()
        // 마이그레이션 상태 확인
        checkMigrationStatus()
        // 디버깅: 동기화 상태 확인
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            let scheduleRequest = NSFetchRequest<NSManagedObject>(entityName: "Schedule")
            let categoryRequest = NSFetchRequest<NSManagedObject>(entityName: "Category")
            
            do {
                let scheduleCount = try CoreDataManager.shared.context.fetch(scheduleRequest).count
                let categoryCount = try CoreDataManager.shared.context.fetch(categoryRequest).count
                print("🔍 현재 저장된 일정: \(scheduleCount)개, 카테고리: \(categoryCount)개")
            } catch {
                print("🔍 데이터 확인 실패: \(error)")
            }
        }
        
    }
    
    private func configure() {
        todayBtn.layer.cornerRadius = 10
        collectionView.layer.cornerRadius = 10
        updateMonthLabel()
        vm.addDefaultCategory()
        vm.fetchSavedEvents()
        vm.userNotificationManager.checkNotificationPermission()
        collectionView.isScrollEnabled = true  // 스크롤 활성화
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        leftSwipe.direction = .left
        collectionView.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        rightSwipe.direction = .right
        collectionView.addGestureRecognizer(rightSwipe)
        
        // configure() 메서드에 추가된 부분
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.5  // 0.5초 이상 누르면 실행
        collectionView.addGestureRecognizer(longPressGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCalendar), name: NSNotification.Name("ScheduleSaved"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eventDeleted), name: NSNotification.Name("EventDeleted"), object: nil)
        
        // CloudKit 및 네트워크 관련 알림 추가
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCloudKitUpdate),
            name: .cloudKitDataUpdated,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNetworkReconnection),
            name: .networkReconnected,
            object: nil
        )
    }
    
    private func refreshCalendar() {
        DateCell.occupiedIndexesByDate.removeAll()
        // 애니메이션 없이 새로고침
        // 애니메이션을 완전히 비활성화
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        UIView.performWithoutAnimation {
            collectionView.reloadData()
        }
        CATransaction.commit()
    }
    
    private func updateMonthLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월"
        dateLabel.text = dateFormatter.string(from: vm.currentMonth)
    }
    
    private func showSyncIndicator() {
        // 동기화 중임을 사용자에게 표시 (예: 상단에 메시지)
        // 간단한 예시:
        print("동기화 중...")
    }
    
    private func hideSyncIndicator() {
        // 동기화 완료 표시 숨김
        print("동기화 완료")
    }
    
    private func checkMigrationStatus() {
        let migrationKey = "CloudKitMigrationCompleted_v1.0"
        let hasCompleted = UserDefaults.standard.bool(forKey: migrationKey)
        
        if !hasCompleted {
            // 마이그레이션 진행 중 표시
            showMigrationProgress()
            
            // 마이그레이션 완료 감지
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(migrationCompleted),
                name: NSNotification.Name("CloudKitMigrationCompleted"),
                object: nil
            )
        }
    }
    
    private func showMigrationProgress() {
        print("기존 데이터를 iCloud로 동기화하는 중...")
    }
    
    private func showCustomMonthYearPicker() {
        let alertController = UIAlertController(title: "언제로 이동해 볼까요?", message: "\n\n\n\n\n\n\n", preferredStyle: .alert)
        
        // 알럿 배경색 변경
            if let alertView = alertController.view.subviews.first?.subviews.first?.subviews.first {
                alertView.backgroundColor = UIColor.fromHexString("F8EDE3")
            }
        
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.frame = CGRect(x: 0, y: 40, width: 270, height: 130)
        
        alertController.view.addSubview(pickerView)
        
        // 현재 년도와 월을 피커에 설정
        let currentYear = Calendar.current.component(.year, from: vm.currentMonth)
        let currentMonth = Calendar.current.component(.month, from: vm.currentMonth)
        let thisYear = Calendar.current.component(.year, from: Date())
        
        let yearRow = currentYear - (thisYear - 3)  // 현재 선택된 년도의 row 계산
        let monthRow = currentMonth - 1
        
        pickerView.selectRow(yearRow, inComponent: 0, animated: false)
        pickerView.selectRow(monthRow, inComponent: 1, animated: false)
        
        // 확인 버튼
        let confirmAction = UIAlertAction(title: "이동", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            let thisYear = Calendar.current.component(.year, from: Date())
            let selectedYear = pickerView.selectedRow(inComponent: 0) + (thisYear - 3)  // -3년부터 시작
            let selectedMonth = pickerView.selectedRow(inComponent: 1) + 1
            
            var components = DateComponents()
            components.year = selectedYear
            components.month = selectedMonth
            components.day = 1
            
            if let selectedDate = Calendar.current.date(from: components) {
                self.vm.currentMonth = selectedDate
                self.updateMonthLabel()
                self.refreshCalendar()
            }
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        // 버튼 텍스트 색상 변경
            confirmAction.setValue(UIColor.black, forKey: "titleTextColor")
            cancelAction.setValue(UIColor.black, forKey: "titleTextColor")
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func tapMoveDateBtn(_ sender: UIButton) {
        showCustomMonthYearPicker()
    }
    
    @IBAction func tapTodayBtn(_ sender: UIButton) {
        vm.currentMonth = Date()
        updateMonthLabel()
        refreshCalendar()
    }
    //MARK: - @objc-Code
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            vm.currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: vm.currentMonth)!
        } else if gesture.direction == .right {
            vm.currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: vm.currentMonth)!
        }
        updateMonthLabel()
        refreshCalendar()
        
        let transition = CATransition()
        transition.type = .push
        transition.subtype = gesture.direction == .left ? .fromRight : .fromLeft
        transition.duration = 0.1
        collectionView.layer.add(transition, forKey: nil)
    }
    
    @objc private func reloadCalendar() {
        vm.fetchSavedEvents()
        refreshCalendar()
    }
    
    @objc func eventDeleted() {
        vm.fetchSavedEvents()
        refreshCalendar()
    }
    
    @objc private func handleCloudKitUpdate() {
        // 기존 타이머 취소 (중복 요청 방지)
        cloudKitUpdateTimer?.invalidate()
        
        // 0.5초 후에 한 번만 업데이트
        cloudKitUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            print("CloudKit 데이터 업데이트됨 - 캘린더 새로고침")
            self.vm.fetchSavedEvents()
            self.refreshCalendar()
        }
    }
    
    @objc private func handleNetworkReconnection() {
        // 동기화 인디케이터 표시 (선택사항)
        showSyncIndicator()
        
        // 잠시 후 데이터 새로고침
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.vm.fetchSavedEvents()
            // self.collectionView.reloadData()
            self.refreshCalendar()
            self.hideSyncIndicator()
        }
    }
    
    @objc private func migrationCompleted() {
        print("데이터 동기화 완료!")
        // 진행 표시 숨김
    }
    
    // 롱프레스기능
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        // began 상태에서만 실행 (중복 실행 방지)
        guard gesture.state == .began else { return }
        
        let point = gesture.location(in: collectionView)
        
        // 롱프레스 위치에 해당하는 indexPath 가져오기
        guard let indexPath = collectionView.indexPathForItem(at: point) else { return }
        
        // 선택한 날짜 계산
        let firstDayOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: vm.currentMonth))!
        let firstWeekday = Calendar.current.component(.weekday, from: firstDayOfMonth) - 1
        
        let daysOffset = indexPath.item - firstWeekday
        let selectedDate = Calendar.current.date(byAdding: .day, value: daysOffset, to: firstDayOfMonth)!
        
        // 햅틱 피드백 추가 (선택 사항)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // AddDutyVC 띄우기
        guard let addDutyVC = self.storyboard?.instantiateViewController(identifier: "AddDutyVC") as? AddDutyVC else { return }
        
        if let sheet = addDutyVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "MM월 yyyy"
        let monthYearString = dateFormatter.string(from: selectedDate)
        
        addDutyVC.modalPresentationStyle = .pageSheet
        addDutyVC.vm.todayMounth = selectedDate
        addDutyVC.vm.todayMounthString = monthYearString
        addDutyVC.vm.selectedSingleDate = selectedDate
        
        present(addDutyVC, animated: true)
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

// MARK: - collecitonView 관련
extension CalendarVC: UICollectionViewDataSource , UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 해당 월에 필요한 줄 수 계산
        let firstDayOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: vm.currentMonth))!
        let firstWeekday = Calendar.current.component(.weekday, from: firstDayOfMonth) - 1
        let range = Calendar.current.range(of: .day, in: .month, for: firstDayOfMonth)!
        let numberOfDays = range.count
        
        // 필요한 셀 개수 계산
        let totalCells = firstWeekday + numberOfDays
        let numberOfRows = Int(ceil(Double(totalCells) / 7.0))
        
        return numberOfRows * 7  // 5줄(35개) 또는 6줄(42개)
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
        
        if [0, 7, 14, 21, 28, 35].contains(indexPath.item) {  // 35 추가
            cell.dateLabel.textColor = .red
        } else if [6, 13, 20, 27, 34, 41].contains(indexPath.item) {  // 41 추가
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
            cell.dateLabel.backgroundColor = UIColor.fromHexString("E6DFF1")
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
        
        // 현재 월에 필요한 줄 수 계산
        let firstDayOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: vm.currentMonth))!
        let firstWeekday = Calendar.current.component(.weekday, from: firstDayOfMonth) - 1
        let range = Calendar.current.range(of: .day, in: .month, for: firstDayOfMonth)!
        let numberOfDays = range.count
        let totalCells = firstWeekday + numberOfDays
        let numberOfRows = CGFloat(ceil(Double(totalCells) / 7.0))
        
        // 컬렉션뷰의 높이를 실제 필요한 줄 수로 나눔
        let availableHeight = collectionView.frame.height
        let itemHeight = floor(availableHeight / numberOfRows)
        
        let width: CGFloat
        
        if indexPath.item % Int(numberOfItemsInRow) == 0 {
            width = itemWidth + additionalWidth
        } else if indexPath.item % Int(numberOfItemsInRow) == Int(numberOfItemsInRow - 1) {
            width = itemWidth + additionalWidth
        } else {
            width = itemWidth
        }
        
        return CGSize(width: width, height: itemHeight)
        
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

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate
extension CalendarVC: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2 // 년도, 월
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 7 // 현재 년도 ± 3년 (총 7년)
        } else {
            return 12 // 1월 ~ 12월
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let currentYear = Calendar.current.component(.year, from: Date())
            let year = currentYear - 3 + row  // -3년부터 +3년까지
            return "\(year)년"
        } else {
            return "\(row + 1)월"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return component == 0 ? 150 : 100
    }
}
