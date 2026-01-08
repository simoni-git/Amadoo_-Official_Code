//
//  TimeTableVC.swift
//  NewCalendar
//
//  Created by 시모니의 맥북 on 11/21/25.
//

import UIKit

class TimeTableVC: UIViewController {

    // MARK: - Section for DiffableDataSource
    enum Section: Hashable {
        case main
    }

    var vm = TimeTableVM()
    @IBOutlet weak var optionBtn: UIButton!
    @IBOutlet weak var dayStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var timeStackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeStackViewWidthConstaint: NSLayoutConstraint!

    // MARK: - DiffableDataSource
    private var dataSource: UICollectionViewDiffableDataSource<Section, TimeSlotItem>!

    private let startHourKey = "TimeTable_StartHour"
    private let endHourKey = "TimeTable_EndHour"

    // App Group Shared UserDefaults
    private var sharedDefaults: UserDefaults? {
        return UserDefaults(suiteName: "group.Simoni.Amadoo")
    }

    // 시간 범위 - App Group UserDefaults에서 불러오기 (위젯과 공유)
    var startHour: Int {
        get {
            let saved = sharedDefaults?.integer(forKey: startHourKey) ?? 0
            return saved != 0 ? saved : 9 // 저장된 값이 없으면 기본값 9
        }
        set {
            sharedDefaults?.set(newValue, forKey: startHourKey)
        }
    }

    var endHour: Int {
        get {
            let saved = sharedDefaults?.integer(forKey: endHourKey) ?? 0
            return saved != 0 ? saved : 16 // 저장된 값이 없으면 기본값 16
        }
        set {
            sharedDefaults?.set(newValue, forKey: endHourKey)
        }
    }
    
    // Picker에서 선택된 임시 값
    private var tempStartHour = 9
    private var tempEndHour = 16
    
    // 시간 배열
    var hours: [Int] {
        return Array(startHour...endHour)
    }
    
    var timeSlots: [(hour: Int, minute: Int)] {
        var slots: [(Int, Int)] = []
        for hour in hours {
            slots.append((hour, 0))   // 정각
            slots.append((hour, 30))  // 30분
        }
        return slots
    }
    
    var cellHeight: CGFloat {
        let dayLabelWidth = dayStackView.bounds.width / 6
        return dayLabelWidth * 0.8
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm = TimeTableVM()
        DIContainer.shared.injectTimeTableVM(vm)
        setupCollectionView()
        configureDataSource()
        collectionView.delegate = self
        setupTimeLabels()
        loadSavedTimeRange()

        // 롱프레스 제스처 추가
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.3
        collectionView.addGestureRecognizer(longPressGesture)

        // NotificationCenter observer 추가
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadTimetableData),
            name: NSNotification.Name("ReloadTimetable"),
            object: nil
        )
    }

    // MARK: - CompositionalLayout 설정
    private func setupCollectionView() {
        collectionView.collectionViewLayout = createLayout()
    }

    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self = self else { return nil }

            let slotCount = CGFloat(self.timeSlots.count)
            guard slotCount > 0 else { return nil }

            // 아이템: 너비 1/5 (5요일), 높이는 그룹 높이
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0 / 5.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            // 그룹: 한 시간대 (5요일)
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0 / slotCount)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            return section
        }
    }

    // MARK: - DiffableDataSource 설정
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, TimeSlotItem>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "TimeTableCell",
                for: indexPath
            ) as? TimeTableCell else {
                return UICollectionViewCell()
            }

            cell.configure(with: item)
            return cell
        }
    }

    // MARK: - Snapshot 적용
    private func applySnapshot(animatingDifferences: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, TimeSlotItem>()
        snapshot.appendSections([.main])

        let items = generateTimeSlotItems()
        snapshot.appendItems(items, toSection: .main)

        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    private func generateTimeSlotItems() -> [TimeSlotItem] {
        var items: [TimeSlotItem] = []

        for slotIndex in 0..<timeSlots.count {
            let timeSlot = timeSlots[slotIndex]

            for column in 0..<5 {  // 월~금
                let timetable = vm.getTimetableItem(dayOfWeek: column, hour: timeSlot.hour, minute: timeSlot.minute)
                let isFirst = timetable != nil && vm.isFirstCellForItem(
                    dayOfWeek: column,
                    hour: timeSlot.hour,
                    minute: timeSlot.minute,
                    timetable: timetable!
                )

                let item = TimeSlotItem(
                    dayOfWeek: column,
                    hour: timeSlot.hour,
                    minute: timeSlot.minute,
                    timetable: timetable,
                    isFirstSlotOfSubject: isFirst
                )
                items.append(item)
            }
        }

        return items
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ViewModel에서 데이터 로드 후 스냅샷 적용
        vm.loadTimeTableData()
        applySnapshot()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // timeStackView 너비를 dayStackView 기준으로 설정
        let dayLabelWidth = dayStackView.bounds.width / 6
        timeStackViewWidthConstaint.constant = dayLabelWidth
        
        // cellHeight로 계산 (고정 공식 사용)
        scrollViewHeightConstraint.constant = cellHeight * CGFloat(hours.count)
        
        collectionView.collectionViewLayout.invalidateLayout()
        // 컬렉션뷰 우측 상하 모서리 둥글게
        collectionView.layer.cornerRadius = 10
        collectionView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        collectionView.clipsToBounds = true
        
        // timeStackView 좌측 상하 모서리 둥글게 (추가)
        timeStackView.layer.cornerRadius = 10
        timeStackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        timeStackView.clipsToBounds = true
    }
    
    
    // 저장된 시간 범위 불러오기
    func loadSavedTimeRange() {
        // 첫 실행 시 기본값 저장
        if UserDefaults.standard.object(forKey: startHourKey) == nil {
            UserDefaults.standard.set(9, forKey: startHourKey)
        }
        if UserDefaults.standard.object(forKey: endHourKey) == nil {
            UserDefaults.standard.set(16, forKey: endHourKey)
        }
        
        print("불러온 시간 범위: \(startHour):00 ~ \(endHour):00")
    }
    
    func setupTimeLabels() {
        // 기존 라벨 제거
        timeStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // StackView 설정
        timeStackView.axis = .vertical
        timeStackView.alignment = .fill
        timeStackView.distribution = .fillEqually
        timeStackView.spacing = 0
        
        // 새로운 시간 라벨 추가
        for hour in hours {
            // 컨테이너 뷰 생성
            let containerView = UIView()
            containerView.backgroundColor = UIColor.fromHexString("E6DFF1")
            containerView.layer.borderWidth = 0.5
            containerView.layer.borderColor = UIColor.systemGray4.cgColor
            
            // 라벨 생성
            let label = UILabel()
            label.text = String(format: "%02d:00", hour)
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 12)
            label.textColor = .black
            label.translatesAutoresizingMaskIntoConstraints = false
            
            containerView.addSubview(label)
            
            // 라벨을 상단에 배치
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
                label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
            ])
            
            timeStackView.addArrangedSubview(containerView)
        }
    }
    
    @IBAction func tapOptionBtn(_ sender: UIButton) {
        showTimeRangePicker()
    }
    
    
    func showTimeRangePicker() {
        let alert = UIAlertController(title: "시간 범위 설정",
                                      message: "\n\n\n\n\n\n\n\n\n",
                                      preferredStyle: .alert)
        
        // 임시 값 초기화
        tempStartHour = startHour
        tempEndHour = endHour
        
        // 배경색 파란색으로 변경
        if let firstSubview = alert.view.subviews.first,
           let alertContentView = firstSubview.subviews.first {
            alertContentView.backgroundColor = UIColor.fromHexString("F8EDE3")
        }
        
        // 타이틀 색상 변경 (선택사항)
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        let attributedTitle = NSAttributedString(string: "시간 범위 설정", attributes: titleAttributes)
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        
        // 레이블 추가 - 위치 조정
        let startLabel = UILabel(frame: CGRect(x: 35, y: 55, width: 80, height: 25))
        startLabel.text = "시작 시간"
        startLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        startLabel.textAlignment = .center
        startLabel.textColor = .black // 파란 배경에 흰색 글씨
        
        let endLabel = UILabel(frame: CGRect(x: 155, y: 55, width: 80, height: 25))
        endLabel.text = "종료 시간"
        endLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        endLabel.textAlignment = .center
        endLabel.textColor = .black // 파란 배경에 흰색 글씨
        
        // Picker View 생성 - 위치 아래로 이동
        let pickerFrame = CGRect(x: 10, y: 85, width: 250, height: 140)
        let pickerView = UIPickerView(frame: pickerFrame)
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = .clear
        
        // 현재 값으로 초기 선택
        pickerView.selectRow(startHour, inComponent: 0, animated: false)
        pickerView.selectRow(endHour, inComponent: 1, animated: false)
        
        // 레이블과 Picker 모두 추가
        alert.view.addSubview(startLabel)
        alert.view.addSubview(endLabel)
        alert.view.addSubview(pickerView)
        
        // 적용 버튼 - 검정색 텍스트
        let applyAction = UIAlertAction(title: "적용하기", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            // 최소 9시간 차이 검증
            let timeDiff = self.tempEndHour - self.tempStartHour
            
            if timeDiff < 7 {
                self.showErrorAlert(message: "시작 시간과 종료 시간의 차이는\n최소 7시간 이상이어야 합니다")
                return
            }
            
            self.updateTimeRange(start: self.tempStartHour, end: self.tempEndHour)
        }
        applyAction.setValue(UIColor.black, forKey: "titleTextColor")
        alert.addAction(applyAction)
        
        // 취소 버튼 - 검정색 텍스트
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        cancelAction.setValue(UIColor.black, forKey: "titleTextColor")
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    // 에러 알럿도 업데이트 (선택사항)
    func showErrorAlert(message: String? = nil) {
        let alert = UIAlertController(title: "오류",
                                      message: message ?? "올바른 시간 범위를 입력해주세요",
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default)
        okAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
    
    // ⭐ 범위 벗어난 일정 확인 메서드
    private func checkAndHandleOutOfRangeTimetables(start: Int, end: Int) {
        if vm.hasOutOfRangeTimetables(start: start, end: end) {
            showOutOfRangeAlert()
        }
    }

    // ⭐ 경고 알럿 추가
    private func showOutOfRangeAlert() {
        let alert = UIAlertController(
            title: "알림",
            message: "선택한 시간 범위 밖에 일정이 있습니다.\n해당 일정은 표시되지 않습니다.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        
        present(alert, animated: true)
    }
    
    func updateTimeRange(start: Int, end: Int) {
        startHour = start
        endHour = end

        // 범위를 벗어난 일정 확인 및 경고
        checkAndHandleOutOfRangeTimetables(start: start, end: end)

        // 1. 시간 라벨 업데이트
        setupTimeLabels()

        // 2. 강제 레이아웃 업데이트
        view.setNeedsLayout()
        view.layoutIfNeeded()

        // 3. 스크롤뷰 높이 다시 계산
        let dayLabelWidth = dayStackView.bounds.width / 6
        timeStackViewWidthConstaint.constant = dayLabelWidth
        scrollViewHeightConstraint.constant = cellHeight * CGFloat(hours.count)

        // 4. 레이아웃 무효화 및 스냅샷 적용
        collectionView.collectionViewLayout.invalidateLayout()
        applySnapshot()

        // 5. 다시 한번 레이아웃
        view.layoutIfNeeded()
    }
    
    private func showEditTimeVC(timetable: TimeTableItem) {
        guard let editVC = storyboard?.instantiateViewController(identifier: "EditTimeVC") as? EditTimeVC else {
            return
        }

        let editVM = EditTimeVM(timetable: timetable, minimumHour: startHour, maximumHour: endHour)
        editVC.vm = editVM

        present(editVC, animated: true)
    }
    
    func showErrorAlert() {
        let alert = UIAlertController(title: "오류",
                                      message: "시작 시간은 종료 시간보다 작아야 합니다",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    
    
    //MARK: - @objc func
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        // began 상태에서만 실행 (중복 방지)
        guard gesture.state == .began else { return }

        // 햅틱 피드백 (진동)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let location = gesture.location(in: collectionView)
        
        if let indexPath = collectionView.indexPathForItem(at: location) {
            let slotIndex = indexPath.item / 5  // 30분 슬롯 인덱스
            let column = indexPath.item % 5     // 요일 인덱스
            
            // 1시간 단위로 변환 (정각만 선택)
            let hourIndex = slotIndex / 2  // 30분 슬롯을 1시간 단위로 변환
            let hour = hours[hourIndex]
            
            let day = ["월", "화", "수", "목", "금"][column]
            
            print("눌린 셀: \(indexPath.item)번째")
            print("위치: \(day)요일 \(hour):00")
            
            // ViewModel 생성 (항상 정각으로 전달)
            let nextVM = AddTimeVM(
                selectedHour: hour,
                minimumHour: startHour,
                maximumHour: endHour,
                dayOfWeek: column
            )
            
            guard let nextVC = self.storyboard?.instantiateViewController(identifier: "AddTimeVC") as? AddTimeVC else { return }
            nextVC.vm = nextVM
            present(nextVC, animated: true)
        }
    }
    
    @objc private func reloadTimetableData() {
        vm.loadTimeTableData()
        applySnapshot()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
// MARK: - UICollectionViewDelegate
extension TimeTableVC: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // DiffableDataSource에서 아이템 가져오기
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }

        // 해당 위치에 시간표가 있는지 확인
        if let timetable = vm.getTimetableItem(dayOfWeek: item.dayOfWeek,
                                               hour: item.hour,
                                               minute: item.minute) {
            // EditTimeVC로 이동
            showEditTimeVC(timetable: timetable)
        }
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension TimeTableVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            // 시작 시간: 0 ~ 16
            return 18
        } else {
            // 종료 시간: 시작시간+7 ~ 24
            return 25
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return String(format: "%02d:00", row)
        } else {
            return String(format: "%02d:00", row)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            // 시작 시간 선택
            tempStartHour = row
            
            // 종료 시간이 시작시간+9보다 작으면 자동 조정
            if tempEndHour < tempStartHour + 7 {
                tempEndHour = tempStartHour + 7
                pickerView.selectRow(tempEndHour, inComponent: 1, animated: true)
            }
            
            // 종료 시간 컴포넌트 리로드
            pickerView.reloadComponent(1)
            
        } else {
            // 종료 시간 선택
            tempEndHour = row
            
            // 최소 9시간 차이 유지
            if tempEndHour < tempStartHour + 7 {
                tempEndHour = tempStartHour + 7
                pickerView.selectRow(tempEndHour, inComponent: 1, animated: true)
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 100
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20)
        
        if component == 0 {
            label.text = String(format: "%02d:00", row)
        } else {
            label.text = String(format: "%02d:00", row)
            
            // 선택 불가능한 시간은 회색으로 표시
            if row < tempStartHour + 7 {
                label.textColor = .lightGray
            } else {
                label.textColor = .black
            }
        }
        
        return label
    }
}
