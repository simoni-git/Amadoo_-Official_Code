//
//  AddDutyView.swift
//  NewCalendar
//
//  Created by 시모니 on 10/7/24.
//

import UIKit

class AddDutyVC: UIViewController {
    
    var vm = AddDutyVM()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        dutyTextField.delegate = self
        collectionView.collectionViewLayout.invalidateLayout()
        configure()
    }
    
    private func configure() {
        defaultDayBtn.layer.cornerRadius = 10
        periodDayBtn.layer.cornerRadius = 10
        multipleDayBtn.layer.cornerRadius = 10
        categoryBtn.layer.cornerRadius = 10
        registerBtn.layer.cornerRadius = 10
        updateButtonStyles()
        
        if let date = vm.todayMounthString {
            dateLabel.text = date
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func updateButtonStyles() {
        let selectedColor = UIColor.fromHexString("FAD4D8")
        let defaultColor = UIColor.fromHexString("F8EDE3")
        defaultDayBtn.backgroundColor = vm.selectedButtonType == .defaultDay ? selectedColor : defaultColor
        periodDayBtn.backgroundColor = vm.selectedButtonType == .periodDay ? selectedColor : defaultColor
        multipleDayBtn.backgroundColor = vm.selectedButtonType == .multipleDay ? selectedColor : defaultColor
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func popUpWarning(_ ment: String) {
        guard let warningVC = self.storyboard?.instantiateViewController(identifier: "WarningVC") as? WarningVC else {return}
        warningVC.warningLabelText = ment
        warningVC.modalPresentationStyle = .overCurrentContext
        present(warningVC, animated: true)
    }
    
    private func updateSelectedButtonType(_ type: AddDutyVM.ButtonType) {
        vm.selectedButtonType = type
        vm.selectedSingleDate = nil
        vm.selectedStartDate = nil
        vm.selectedEndDate = nil
        vm.selectedMultipleDates.removeAll()
        updateButtonStyles()
        collectionView.reloadData()
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
        collectionView.reloadData()
        updateMonthLabel()
    }
    
    @IBAction func tapRightMonthBtn(_ sender: UIButton) {
        vm.todayMounth = Calendar.current.date(byAdding: .month, value: 1, to: vm.todayMounth!)!
        collectionView.reloadData()
        updateMonthLabel()
    }
    
    @IBAction func tapCategoryBtn(_ sender: UIButton) {
        
        guard let nextVC = storyboard?.instantiateViewController(withIdentifier: "SelectCategoryVC") as? SelectCategoryVC else {
            return
        }
        
        if let sheet = nextVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        nextVC.modalPresentationStyle = .pageSheet
        nextVC.vm.delegate = self
        present(nextVC, animated: true)
    }
    
    @IBAction func tapRegisterBtn(_ sender: UIButton) {
        guard let text = dutyTextField.text, !text.isEmpty else {
            popUpWarning("일정을 입력해 주세요")
            return
        }
        
        guard let categoryColor = vm.selectedCategoryColorHex, !categoryColor.isEmpty else {
            popUpWarning("카테고리를 선택해 주세요")
            return
        }
        
        switch vm.selectedButtonType {
        case .defaultDay:
            if let selectedDate = vm.selectedSingleDate {
                vm.saveSingleDate(text: text, date: selectedDate)
                NotificationCenter.default.post(name: NSNotification.Name("ScheduleSaved"), object: nil)
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            } else {
                popUpWarning("날짜를 선택해 주세요")
            }
            
        case .periodDay:
            print("기간타입 선택됨")
            guard let startDate = vm.selectedStartDate, let endDate = vm.selectedEndDate else {
                popUpWarning("기간을 정확히 선택해 주세요")
                return
            }
            vm.savePeriodDates(text: text, startDate: startDate, endDate: endDate)
            NotificationCenter.default.post(name: NSNotification.Name("ScheduleSaved"), object: nil)
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            
        case .multipleDay:
            guard !vm.selectedMultipleDates.isEmpty else {
                popUpWarning("날짜를 선택해 주세요")
                return
            }
            vm.saveMultipleDates(text: text, dates: vm.selectedMultipleDates)
            NotificationCenter.default.post(name: NSNotification.Name("ScheduleSaved"), object: nil)
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
}

// MARK: - CollecitonView 관련
extension AddDutyVC: UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddDutyDateCell", for: indexPath) as? AddDutyDateCell else {
            return UICollectionViewCell()
        }
        
        let firstDayOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: vm.todayMounth!))!
        let firstWeekday = Calendar.current.component(.weekday, from: firstDayOfMonth) - 1
        
        let daysOffset = indexPath.item - firstWeekday
        let day = Calendar.current.date(byAdding: .day, value: daysOffset, to: firstDayOfMonth)!
        let dayNumber = Calendar.current.component(.day, from: day)
        let isCurrentMonth = Calendar.current.isDate(day, equalTo: vm.todayMounth!, toGranularity: .month)
        
        cell.dateLabel.text = isCurrentMonth ? "\(dayNumber)" : nil
        cell.subView.layer.cornerRadius = CGFloat(8)
        cell.subView.backgroundColor = .clear
        
        switch vm.selectedButtonType {
        case .defaultDay:
            if let selectedSingleDate = vm.selectedSingleDate, day == selectedSingleDate {
                cell.subView.backgroundColor = UIColor.fromHexString("FAD4D8")
            }
            
        case .multipleDay:
            if vm.selectedMultipleDates.contains(day) {
                cell.subView.backgroundColor = UIColor.fromHexString("FAD4D8")
            }
            
        case .periodDay:
            if let startDate = vm.selectedStartDate, let endDate = vm.selectedEndDate, day >= startDate && day <= endDate {
                cell.subView.backgroundColor = UIColor.fromHexString("FAD4D8")
            } else if let startDate = vm.selectedStartDate, vm.selectedEndDate == nil, day == startDate {
                cell.subView.backgroundColor = UIColor.fromHexString("FAD4D8")
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = self.weekStackView.frame.width
        let numberOfItemsInRow: CGFloat = 7
        let itemWidth = floor(totalWidth / numberOfItemsInRow)
        let remainingWidth = totalWidth - (itemWidth * numberOfItemsInRow)
        let width = indexPath.item % 7 == 6 ? itemWidth + remainingWidth : itemWidth
        
        return CGSize(width: width, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let firstDayOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: vm.todayMounth!))!
        let firstWeekday = Calendar.current.component(.weekday, from: firstDayOfMonth) - 1
        
        let daysOffset = indexPath.item - firstWeekday
        let selectedDate = Calendar.current.date(byAdding: .day, value: daysOffset, to: firstDayOfMonth)!
        let isCurrentMonth = Calendar.current.isDate(selectedDate, equalTo: vm.todayMounth!, toGranularity: .month)
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? AddDutyDateCell,
              cell.dateLabel.text != nil,
              isCurrentMonth else {
            return
        }
        
        switch vm.selectedButtonType {
        case .defaultDay:
            vm.selectedSingleDate = selectedDate
            collectionView.reloadData()
            
        case .multipleDay:
            if let index = vm.selectedMultipleDates.firstIndex(of: selectedDate) {
                vm.selectedMultipleDates.remove(at: index)
            } else {
                vm.selectedMultipleDates.append(selectedDate)
            }
            collectionView.reloadData()
            
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
            collectionView.reloadData()
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
