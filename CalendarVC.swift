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
    @IBOutlet weak var categoryBtn: UIButton!
    @IBOutlet weak var moveDateBtn: UIButton!
    @IBOutlet weak var todayBtn: UIButton!
    @IBOutlet weak var weekStackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var cloudKitUpdateTimer: Timer?
    private var dragStartIndexPath: IndexPath?
    private var dragEndIndexPath: IndexPath?
    private var selectedCells: Set<IndexPath> = []
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 레이아웃이 완료된 후 스크롤 동작 업데이트
        updateScrollBehavior()
    }
    
    private func configure() {
        todayBtn.layer.cornerRadius = Constants.UI.standardCornerRadius
        collectionView.layer.cornerRadius = Constants.UI.standardCornerRadius
        updateMonthLabel()
        vm.addDefaultCategory()
        vm.fetchSavedEvents()
        vm.userNotificationManager.checkNotificationPermission()
        collectionView.isScrollEnabled = false  // 스크롤 비활성화
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCalendar), name: NSNotification.Name(Constants.NotificationName.scheduleSaved), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eventDeleted), name: NSNotification.Name(Constants.NotificationName.eventDeleted), object: nil)
        
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
        DateCell.globalEventIndexes.removeAll()  // 메모리 누수 방지
        // 애니메이션 없이 새로고침
        // 애니메이션을 완전히 비활성화
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        UIView.performWithoutAnimation {
            collectionView.reloadData()
        }
        CATransaction.commit()
        // 스크롤 동작 업데이트 (월이 변경되면 필요한 높이가 달라질 수 있음)
        DispatchQueue.main.async {
            self.updateScrollBehavior()
        }
    }
    
    private func updateMonthLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월"
        dateLabel.text = dateFormatter.string(from: vm.currentMonth)
    }
  
    // 화면 크기에 따라 스크롤 활성화 여부 결정
    private func updateScrollBehavior() {
        // DateHelper를 사용하여 줄 수 계산
        let numberOfRows = CGFloat(DateHelper.shared.numberOfRowsForCalendar(currentMonth: vm.currentMonth))
        
        // 컬렉션뷰의 사용 가능한 높이
        let availableHeight = collectionView.frame.height
        
        // 각 셀이 차지해야 하는 높이
        let cellHeight = availableHeight / numberOfRows
        
        // 실제 필요한 총 높이
        let requiredHeight = cellHeight * numberOfRows
        
        // 필요한 높이가 사용 가능한 높이보다 크면 스크롤 활성화
        // 여유를 위해 5포인트 버퍼 추가
        collectionView.isScrollEnabled = (requiredHeight > availableHeight + 5)
        
        print("📱 화면 높이: \(availableHeight), 필요 높이: \(requiredHeight), 스크롤: \(collectionView.isScrollEnabled)")
    }

    // 현재 월에 필요한 줄 수를 계산하는 헬퍼 메서드
    private func getNumberOfRows() -> Int {
        return DateHelper.shared.numberOfRowsForCalendar(currentMonth: vm.currentMonth)
    }
    
    // 각 셀의 높이를 계산하는 헬퍼 메서드
    private func getCellHeight(for numberOfRows: CGFloat) -> CGFloat {
        // 컬렉션뷰의 사용 가능한 최대 높이 (화면 크기에 따라 조정 가능)
        let maxHeight: CGFloat = 500 // 필요에 따라 조정
        return floor(maxHeight / numberOfRows)
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
    
    //MARK: - Action func
    
    @IBAction func tapCategoryBtn(_ sender: UIButton) {
        guard let categoryVC = storyboard?.instantiateViewController(
                withIdentifier: "CategoryVC"
            ) as? CategoryVC else { return }
            
            navigationController?.pushViewController(categoryVC, animated: true)
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
    
    // 드래그로 날짜 범위 선택 기능
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: collectionView)
        
        switch gesture.state {
        case .began:
            // 드래그 시작
            guard let indexPath = collectionView.indexPathForItem(at: point) else { return }
            dragStartIndexPath = indexPath
            dragEndIndexPath = indexPath
            selectedCells = [indexPath]
            
            // 햅틱 피드백
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            // 시작 셀 하이라이트
            highlightSelectedCells()
            
        case .changed:
            // 드래그 중
            guard let startIndexPath = dragStartIndexPath,
                  let currentIndexPath = collectionView.indexPathForItem(at: point) else { return }
            
            // 이전과 같은 위치면 무시
            if dragEndIndexPath == currentIndexPath { return }
            
            dragEndIndexPath = currentIndexPath
            
            // 시작과 끝 사이의 모든 셀 선택
            selectedCells = getIndexPathsInRange(from: startIndexPath, to: currentIndexPath)
            highlightSelectedCells()
            
        case .ended:
            // 드래그 종료 - AddDutyVC 표시
            guard let startIndexPath = dragStartIndexPath,
                  let endIndexPath = dragEndIndexPath else {
                clearSelection()
                return
            }
            
            // 시작 날짜와 종료 날짜 계산
            let startDate = getDateForIndexPath(startIndexPath)
            let endDate = getDateForIndexPath(endIndexPath)
            
            // 더 이른 날짜를 시작으로 설정
            let sortedDates = [startDate, endDate].sorted()
            let finalStartDate = sortedDates[0]
            let finalEndDate = sortedDates[1]
            
            // AddDutyVC 표시
            showAddDutyVC(startDate: finalStartDate, endDate: finalEndDate)
            
            // 선택 초기화
            clearSelection()
            
        case .cancelled, .failed:
            clearSelection()
            
        default:
            break
        }
    }
        
    // IndexPath에 해당하는 날짜 반환
    private func getDateForIndexPath(_ indexPath: IndexPath) -> Date {
        let firstDayOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: vm.currentMonth))!
        let firstWeekday = Calendar.current.component(.weekday, from: firstDayOfMonth) - 1
        let daysOffset = indexPath.item - firstWeekday
        return Calendar.current.date(byAdding: .day, value: daysOffset, to: firstDayOfMonth)!
    }
    
    // 시작과 끝 사이의 모든 IndexPath 반환
    private func getIndexPathsInRange(from start: IndexPath, to end: IndexPath) -> Set<IndexPath> {
        let minItem = min(start.item, end.item)
        let maxItem = max(start.item, end.item)
        
        var paths = Set<IndexPath>()
        for item in minItem...maxItem {
            paths.insert(IndexPath(item: item, section: 0))
        }
        return paths
    }
    
    // 선택된 셀 하이라이트
    private func highlightSelectedCells() {
        // 모든 셀의 배경색 초기화
        for cell in collectionView.visibleCells {
            cell.contentView.backgroundColor = .clear
        }
        
        // 선택된 셀만 하이라이트
        for indexPath in selectedCells {
            if let cell = collectionView.cellForItem(at: indexPath) {
                cell.contentView.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.2)
                cell.contentView.layer.cornerRadius = 8
            }
        }
    }
    
    // 선택 초기화
    private func clearSelection() {
        // 모든 셀의 배경색 초기화
        for cell in collectionView.visibleCells {
            cell.contentView.backgroundColor = .clear
        }
        
        dragStartIndexPath = nil
        dragEndIndexPath = nil
        selectedCells.removeAll()
    }
    
    // AddDutyVC 표시
    private func showAddDutyVC(startDate: Date, endDate: Date) {
        guard let addDutyVC = self.storyboard?.instantiateViewController(identifier: "AddDutyVC") as? AddDutyVC else { return }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "MM월 yyyy"
        let monthYearString = dateFormatter.string(from: startDate)

        addDutyVC.vm.todayMounth = startDate
        addDutyVC.vm.todayMounthString = monthYearString

        // 시작 날짜와 종료 날짜가 같으면 단일 날짜
        if Calendar.current.isDate(startDate, inSameDayAs: endDate) {
            addDutyVC.vm.selectedSingleDate = startDate
        } else {
            // 날짜 범위 전달 (AddDutyVC의 ViewModel에 이 프로퍼티가 있어야 함)
            addDutyVC.vm.selectedStartDate = startDate
            addDutyVC.vm.selectedEndDate = endDate
            addDutyVC.vm.selectedButtonType = .periodDay
        }

        presentAsSheet(addDutyVC)
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

        // DateHelper를 사용하여 날짜 계산
        guard let day = DateHelper.shared.dateForCalendarCell(at: indexPath.item, currentMonth: vm.currentMonth) else {
            return cell
        }

        let dayNumber = DateHelper.shared.day(from: day)
        cell.dateLabel.text = "\(dayNumber)"

        let isCurrentMonth = DateHelper.shared.isDateInCurrentMonth(day, currentMonth: vm.currentMonth)
        cell.dateLabel.alpha = isCurrentMonth ? 1.0 : 0.3
        
        if [0, 7, 14, 21, 28, 35].contains(indexPath.item) {  // 35 추가
            cell.dateLabel.textColor = .red
        } else if [6, 13, 20, 27, 34, 41].contains(indexPath.item) {  // 41 추가
            cell.dateLabel.textColor = .blue
        } else {
            cell.dateLabel.textColor = .black
        }
        
        cell.dateLabel.backgroundColor = .clear
        cell.dateLabel.layer.cornerRadius = Constants.UI.smallCornerRadius
        cell.dateLabel.layer.masksToBounds = false

        let today = DateHelper.shared.startOfDay(for: Date())
        let cellDate = DateHelper.shared.startOfDay(for: day)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { //🧪
        return .zero
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
