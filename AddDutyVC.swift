//
//  AddDutyView.swift
//  NewCalendar
//
//  Created by 시모니 on 10/7/24.
//

import UIKit

class AddDutyVC: UIViewController {

    // MARK: - Section for DiffableDataSource
    enum Section: Hashable {
        case main
    }

    var vm: AddDutyVM!
    @IBOutlet weak var dutyTextField: UITextField!
    @IBOutlet weak var defaultDayBtn: UIButton!
    @IBOutlet weak var periodDayBtn: UIButton!
    @IBOutlet weak var multipleDayBtn: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var leftMonthBtn: UIButton!
    @IBOutlet weak var rightMonthBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var categoryBtn: UIButton!
    @IBOutlet weak var weekStackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - DiffableDataSource
    private var dataSource: UICollectionViewDiffableDataSource<Section, SelectableDateItem>!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        dutyTextField.delegate = self
        configure()
    }

    // MARK: - CollectionView Setup

    private func setupCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        configureDataSource()
        collectionView.delegate = self
        applySnapshot()
    }

    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { _, _ in
            // 6주 고정 (42일 / 7일 = 6행)
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0 / 7.0),
                heightDimension: .fractionalWidth(1.0 / 7.0)  // 정사각형
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(1.0 / 7.0)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            return section
        }
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, SelectableDateItem>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "AddDutyDateCell",
                for: indexPath
            ) as? AddDutyDateCell else {
                return UICollectionViewCell()
            }

            cell.configure(with: item)
            return cell
        }
    }

    private func applySnapshot(animatingDifferences: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SelectableDateItem>()
        snapshot.appendSections([.main])

        let items = generateSelectableDateItems()
        snapshot.appendItems(items, toSection: .main)

        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    private func generateSelectableDateItems() -> [SelectableDateItem] {
        var items: [SelectableDateItem] = []

        guard let todayMonth = vm.todayMounth else { return items }

        let firstDayOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: todayMonth))!
        let firstWeekday = Calendar.current.component(.weekday, from: firstDayOfMonth) - 1

        for index in 0..<42 {
            let daysOffset = index - firstWeekday
            let date = Calendar.current.date(byAdding: .day, value: daysOffset, to: firstDayOfMonth)!
            let isCurrentMonth = Calendar.current.isDate(date, equalTo: todayMonth, toGranularity: .month)
            let dayOfWeek = Calendar.current.component(.weekday, from: date) - 1

            // 선택 상태 계산
            let (isSelected, isInRange) = calculateSelectionState(for: date)

            let item = SelectableDateItem(
                id: UUID(),
                date: date,
                isCurrentMonth: isCurrentMonth,
                isSelected: isSelected,
                isInRange: isInRange,
                dayOfWeek: dayOfWeek
            )
            items.append(item)
        }

        return items
    }

    private func calculateSelectionState(for date: Date) -> (isSelected: Bool, isInRange: Bool) {
        if vm.isEditMode {
            return calculateEditModeSelectionState(for: date)
        } else {
            return calculateNormalModeSelectionState(for: date)
        }
    }

    private func calculateEditModeSelectionState(for date: Date) -> (isSelected: Bool, isInRange: Bool) {
        guard let buttonType = vm.originButtonType else {
            return (false, false)
        }

        if vm.editStartDate == nil {
            // 원본 데이터 기반 표시
            guard let startDay = vm.originStartDate,
                  let endDay = vm.originEndDate,
                  let eventDate = vm.originDate else {
                return (false, false)
            }

            switch buttonType {
            case "defaultDay", "multipleDay":
                let isSelected = Calendar.current.isDate(date, inSameDayAs: eventDate)
                return (isSelected, false)
            case "periodDay":
                let isInRange = date >= startDay && date <= endDay
                return (false, isInRange)
            default:
                return (false, false)
            }
        } else {
            // 편집 중인 데이터 기반 표시
            switch buttonType {
            case "defaultDay", "multipleDay":
                if let editDate = vm.editDate {
                    let isSelected = Calendar.current.isDate(date, inSameDayAs: editDate)
                    return (isSelected, false)
                }
                return (false, false)
            case "periodDay":
                if let startDate = vm.editStartDate, let endDate = vm.editEndDate {
                    let isInRange = date >= startDate && date <= endDate
                    return (false, isInRange)
                } else if let startDate = vm.editStartDate, vm.editEndDate == nil {
                    let isSelected = Calendar.current.isDate(date, inSameDayAs: startDate)
                    return (isSelected, false)
                }
                return (false, false)
            default:
                return (false, false)
            }
        }
    }

    private func calculateNormalModeSelectionState(for date: Date) -> (isSelected: Bool, isInRange: Bool) {
        switch vm.selectedButtonType {
        case .defaultDay:
            if let selectedSingleDate = vm.selectedSingleDate {
                let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedSingleDate)
                return (isSelected, false)
            }
            return (false, false)

        case .multipleDay:
            let isSelected = vm.selectedMultipleDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
            return (isSelected, false)

        case .periodDay:
            if let startDate = vm.selectedStartDate, let endDate = vm.selectedEndDate {
                let isInRange = date >= startDate && date <= endDate
                return (false, isInRange)
            } else if let startDate = vm.selectedStartDate, vm.selectedEndDate == nil {
                let isSelected = Calendar.current.isDate(date, inSameDayAs: startDate)
                return (isSelected, false)
            }
            return (false, false)
        }
    }
    
    private func configure() {
        [defaultDayBtn, periodDayBtn, multipleDayBtn, categoryBtn, registerBtn].forEach { button in
            button?.layer.cornerRadius = 10
        }

        if let date = vm.todayMounthString {
            dateLabel.text = date
        }

        if vm.isEditMode {
            updateUIWithOriginDuty()
            // originButtonType, originTitle 등은 이미 DetailDutyVC에서 설정됨
        } else {
            updateButtonStyles()
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func updateUIWithOriginDuty() {
        // 제목 설정
        if let title = vm.originTitle {
            dutyTextField.text = title
        }

        // 버튼 타입에 따른 UI 설정
        if let buttonType = vm.originButtonType {
            defaultDayBtn.isUserInteractionEnabled = false
            periodDayBtn.isUserInteractionEnabled = false
            multipleDayBtn.isUserInteractionEnabled = false

            switch buttonType {
            case "defaultDay":
                defaultDayBtn.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.2)
                periodDayBtn.backgroundColor = UIColor.fromHexString("F8EDE3")
                multipleDayBtn.backgroundColor = UIColor.fromHexString("F8EDE3")
            case "periodDay":
                defaultDayBtn.backgroundColor = UIColor.fromHexString("F8EDE3")
                periodDayBtn.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.2)
                multipleDayBtn.backgroundColor = UIColor.fromHexString("F8EDE3")
            case "multipleDay":
                defaultDayBtn.backgroundColor = UIColor.fromHexString("F8EDE3")
                periodDayBtn.backgroundColor = UIColor.fromHexString("F8EDE3")
                multipleDayBtn.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.2)
            default:
                break
            }
        }

        // 카테고리 색상 설정
        if let categoryColorHex = vm.originCategoryColor {
            categoryBtn.backgroundColor = UIColor.fromHexString(categoryColorHex)
        }
    }
    
    private func updateButtonStyles() {
        let selectedColor = UIColor.systemPurple.withAlphaComponent(0.2)
        let defaultColor = UIColor.fromHexString("F8EDE3")
        defaultDayBtn.backgroundColor = vm.selectedButtonType == .defaultDay ? selectedColor : defaultColor
        periodDayBtn.backgroundColor = vm.selectedButtonType == .periodDay ? selectedColor : defaultColor
        multipleDayBtn.backgroundColor = vm.selectedButtonType == .multipleDay ? selectedColor : defaultColor
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // popUpWarning 메서드 제거 - UIViewController+Alert extension의 presentWarning 사용

    private func updateSelectedButtonType(_ type: AddDutyVM.ButtonType) {
        vm.selectedButtonType = type
        vm.selectedSingleDate = nil
        vm.selectedStartDate = nil
        vm.selectedEndDate = nil
        vm.selectedMultipleDates.removeAll()
        updateButtonStyles()
        applySnapshot()
    }
    
    private func updateMonthLabel() {
        dateLabel.text = vm.getFormattedMonth()
    }
    
    @IBAction func tapDefaultDayBtn(_ sender: UIButton) {
        updateSelectedButtonType(.defaultDay)
    }
    
    @IBAction func tapPeriodDayBtn(_ sender: UIButton) {
        updateSelectedButtonType(.periodDay)
    }
    
    @IBAction func tapMultipleDayBtn(_ sender: UIButton) {
        updateSelectedButtonType(.multipleDay)
    }
    
    @IBAction func tapLeftMonthBtn(_ sender: UIButton) {
        vm.todayMounth = Calendar.current.date(byAdding: .month, value: -1, to: vm.todayMounth!)!
        applySnapshot()
        updateMonthLabel()
    }

    @IBAction func tapRightMonthBtn(_ sender: UIButton) {
        vm.todayMounth = Calendar.current.date(byAdding: .month, value: 1, to: vm.todayMounth!)!
        applySnapshot()
        updateMonthLabel()
    }
    
    @IBAction func tapCategoryBtn(_ sender: UIButton) {
        guard let nextVC = storyboard?.instantiateViewController(withIdentifier: "SelectCategoryVC") as? SelectCategoryVC else {
            return
        }

        nextVC.vm = DIContainer.shared.makeSelectCategoryVM()
        nextVC.vm.delegate = self
        presentAsSheet(nextVC)
    }
    
    @IBAction func tapRegisterBtn(_ sender: UIButton) {
        guard let text = dutyTextField.text, !text.isEmpty else {
            presentWarning("일정을 입력해 주세요")
            return
        }
        
        if vm.isEditMode == true {
            switch vm.originButtonType {
            case "defaultDay", "multipleDay":
                print("일반,다중일정 편집")
                vm.editTitle = dutyTextField.text
                vm.fetchAndUpdateSchedule(title: vm.originTitle, categoryColor: vm.originCategoryColor, date: vm.originDate, startDate: vm.originStartDate, endDate: vm.originEndDate)
            case "periodDay":
                print("기간일정 편집")
                vm.editTitle = dutyTextField.text
                if vm.editStartDate != nil && vm.editEndDate == nil {
                    presentWarning("기간을 정확히 선택해 주세요")
                    return
                }
                vm.fetchAndUpdatePeriodSchedule(title: vm.originTitle, categoryColor: vm.originCategoryColor, buttonType: vm.originButtonType, startDate: vm.originStartDate, endDate: vm.originEndDate)
            default:
                print("알 수 없는 버튼 타입")
            }
          
            
        } else {
            
            guard let categoryColor = vm.selectedCategoryColorHex, !categoryColor.isEmpty else {
                presentWarning("카테고리를 선택해 주세요")
                return
            }
            
            switch vm.selectedButtonType {
            case .defaultDay:
                if let selectedDate = vm.selectedSingleDate {
                    vm.saveSingleDate(text: text, date: selectedDate)
                } else {
                    presentWarning("날짜를 선택해 주세요")
                }
                
            case .periodDay:
                print("기간타입 선택됨")
                guard let startDate = vm.selectedStartDate, let endDate = vm.selectedEndDate else {
                    presentWarning("기간을 정확히 선택해 주세요")
                    return
                }
                vm.savePeriodDates(text: text, startDate: startDate, endDate: endDate, categoryColor: vm.selectedCategoryColorHex!)
            case .multipleDay:
                guard !vm.selectedMultipleDates.isEmpty else {
                    presentWarning("날짜를 선택해 주세요")
                    return
                }
                vm.saveMultipleDates(text: text, dates: vm.selectedMultipleDates)
            }
        }
        vm.userNotificationManager.updateNotification()
            self.view.window?.rootViewController?.dismiss(animated: true) {
                // dismiss 완료 후 잠시 대기 후 알림 발송
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    NotificationCenter.default.post(name: NSNotification.Name("ScheduleSaved"), object: nil)
                }
            }
    }
    
}

// MARK: - CollectionView Delegate
extension AddDutyVC: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath),
              item.isCurrentMonth else {
            return
        }

        let selectedDate = item.date

        if vm.isEditMode {
            switch vm.originButtonType {
            case "defaultDay", "multipleDay":
                vm.editDate = selectedDate
                vm.editStartDate = selectedDate
                vm.editEndDate = selectedDate
                applySnapshot()

            case "periodDay":
                if vm.editStartDate == nil {
                    vm.editStartDate = selectedDate
                    vm.editEndDate = nil
                } else if vm.editEndDate == nil {
                    vm.editEndDate = selectedDate
                    if vm.editStartDate! > vm.editEndDate! {
                        swap(&vm.editStartDate, &vm.editEndDate)
                    }
                } else {
                    vm.editStartDate = selectedDate
                    vm.editEndDate = nil
                }
                applySnapshot()

            default:
                break
            }

        } else {
            switch vm.selectedButtonType {
            case .defaultDay:
                vm.selectedSingleDate = selectedDate
                applySnapshot()

            case .multipleDay:
                if let index = vm.selectedMultipleDates.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: selectedDate) }) {
                    vm.selectedMultipleDates.remove(at: index)
                } else {
                    vm.selectedMultipleDates.append(selectedDate)
                }
                applySnapshot()

            case .periodDay:
                if vm.selectedStartDate == nil {
                    vm.selectedStartDate = selectedDate
                    vm.selectedEndDate = nil
                } else if vm.selectedEndDate == nil {
                    vm.selectedEndDate = selectedDate
                    if vm.selectedStartDate! > vm.selectedEndDate! {
                        swap(&vm.selectedStartDate, &vm.selectedEndDate)
                    }
                } else {
                    vm.selectedStartDate = selectedDate
                    vm.selectedEndDate = nil
                }
                applySnapshot()
            }
        }
    }
}

extension AddDutyVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension AddDutyVC: SelectCategoryVCDelegate {
    func didSelectCategoryName(_ name: String) {
        DispatchQueue.main.async { [weak self] in
            self?.categoryBtn.titleLabel?.text = name
            self?.categoryBtn.titleLabel?.textAlignment = .center
        }
    }
    
    func didSelectCategoryColor(_ colorHex: String) {
        vm.selectedCategoryColorHex = colorHex
        DispatchQueue.main.async {[weak self] in
            self?.categoryBtn.backgroundColor = UIColor.fromHexString(colorHex)
        }
    }
    
}
