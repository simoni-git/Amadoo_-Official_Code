//
//  AddDutyView.swift
//  NewCalendar
//
//  Created by 시모니 on 10/7/24.
//

import UIKit
import CoreData

class AddDutyVC: UIViewController {
    
    var context: NSManagedObjectContext {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }
        return app.persistentContainer.viewContext
    }
    
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
    
    private var currentMonth: Date = Date()
    private var selectedButtonType: ButtonType = .defaultDay
    private var selectedStartDate: Date?
    private var selectedEndDate: Date?
    private var selectedMultipleDates: [Date] = []
    private var selectedSingleDate: Date?
    
    var todayMounth: Date?
    var todayMounthString: String?
    
    var selectedCategoryColorHex: String?
    var selectedCategoryColorName: String?
    
    enum ButtonType: String {
        case defaultDay = "defaultDay"
        case periodDay = "periodDay"
        case multipleDay = "multipleDay"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        dutyTextField.delegate = self
        collectionView.collectionViewLayout.invalidateLayout()
        configure()
        updateButtonStyles()
        if let date = todayMounthString {
            dateLabel.text = date
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func configure() {
        defaultDayBtn.layer.cornerRadius = 10
        periodDayBtn.layer.cornerRadius = 10
        multipleDayBtn.layer.cornerRadius = 10
        categoryBtn.layer.cornerRadius = 10
        registerBtn.layer.cornerRadius = 10
    }
    
    private func updateMonthLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM월 yyyy"
        dateLabel.text = dateFormatter.string(from: todayMounth!)
    }
    
    private func updateButtonStyles() {
        let selectedColor = UIColor(hex: "FAD4D8")
        let defaultColor = UIColor(hex: "F8EDE3")
        
        defaultDayBtn.backgroundColor = selectedButtonType == .defaultDay ? selectedColor : defaultColor
        periodDayBtn.backgroundColor = selectedButtonType == .periodDay ? selectedColor : defaultColor
        multipleDayBtn.backgroundColor = selectedButtonType == .multipleDay ? selectedColor : defaultColor
    }
    
    private func popUpWarning(_ ment: String) {
        guard let warningVC = self.storyboard?.instantiateViewController(identifier: "WarningVC") as? WarningVC else {return}
        warningVC.warningLabelText = ment
        warningVC.modalPresentationStyle = .overCurrentContext
        present(warningVC, animated: true)
    }
    
    @IBAction func tapDefaultDayBtn(_ sender: UIButton) {
        selectedButtonType = .defaultDay
        selectedSingleDate = nil
        selectedStartDate = nil
        selectedEndDate = nil
        selectedMultipleDates.removeAll()
        updateButtonStyles()
        collectionView.reloadData()
    }
    
    @IBAction func tapPeriodDayBtn(_ sender: UIButton) {
        selectedButtonType = .periodDay
        selectedSingleDate = nil
        selectedStartDate = nil
        selectedEndDate = nil
        selectedMultipleDates.removeAll()
        updateButtonStyles()
        collectionView.reloadData()
    }
    
    @IBAction func tapMultipleDayBtn(_ sender: UIButton) {
        selectedButtonType = .multipleDay
        selectedSingleDate = nil
        selectedStartDate = nil
        selectedEndDate = nil
        selectedMultipleDates.removeAll()
        updateButtonStyles()
        collectionView.reloadData()
    }
    
    @IBAction func tapLeftMonthBtn(_ sender: UIButton) {
        todayMounth = Calendar.current.date(byAdding: .month, value: -1, to: todayMounth!)!
        collectionView.reloadData()
        updateMonthLabel()
    }
    
    @IBAction func tapRightMonthBtn(_ sender: UIButton) {
        todayMounth = Calendar.current.date(byAdding: .month, value: 1, to: todayMounth!)!
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
        nextVC.delegate = self
        present(nextVC, animated: true)
    }
    
    @IBAction func tapRegisterBtn(_ sender: UIButton) {
        guard let text = dutyTextField.text, !text.isEmpty else {
            popUpWarning("일정을 입력해 주세요")
            return
        }
        
        guard let categoryColor = selectedCategoryColorHex, !categoryColor.isEmpty else {
            popUpWarning("카테고리를 선택해 주세요")
            return
        }
        
        switch selectedButtonType {
        case .defaultDay:
            if let selectedDate = selectedSingleDate {
                saveSingleDate(text: text, date: selectedDate)
                NotificationCenter.default.post(name: NSNotification.Name("ScheduleSaved"), object: nil)
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            } else {
                popUpWarning("날짜를 선택해 주세요")
            }
            
        case .periodDay:
            print("기간타입 선택됨")
            guard let startDate = selectedStartDate, let endDate = selectedEndDate else {
                popUpWarning("기간을 정확히 선택해 주세요")
                return
            }
            savePeriodDates(text: text, startDate: startDate, endDate: endDate)
            NotificationCenter.default.post(name: NSNotification.Name("ScheduleSaved"), object: nil)
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            
        case .multipleDay:
            guard !selectedMultipleDates.isEmpty else {
                popUpWarning("날짜를 선택해 주세요")
                return
            }
            saveMultipleDates(text: text, dates: selectedMultipleDates)
            NotificationCenter.default.post(name: NSNotification.Name("ScheduleSaved"), object: nil)
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: { _ in
            self.view.endEditing(true)
        })
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - CoreData 저장 관련
    private func saveContext() {
        do {
            try context.save()
        } catch {
            
        }
    }
    
    private func saveSingleDate(text: String, date: Date) {
        let entity = NSEntityDescription.entity(forEntityName: "Schedule", in: context)
        let newSchedule = NSManagedObject(entity: entity!, insertInto: context)
        newSchedule.setValue(text, forKey: "title")
        newSchedule.setValue(date, forKey: "date")
        newSchedule.setValue(date, forKey: "startDay")
        newSchedule.setValue(date, forKey: "endDay")
        newSchedule.setValue(selectedButtonType.rawValue, forKey: "buttonType")
        
        
        if let colorHex = selectedCategoryColorHex {
            newSchedule.setValue(colorHex, forKey: "categoryColor")
        }
        
        saveContext()
    }
    
    private func savePeriodDates(text: String, startDate: Date, endDate: Date) {
        var currentDate = startDate
        
        while currentDate <= endDate {
            let entity = NSEntityDescription.entity(forEntityName: "Schedule", in: context)
            let newSchedule = NSManagedObject(entity: entity!, insertInto: context)
            newSchedule.setValue(text, forKey: "title")
            newSchedule.setValue(currentDate, forKey: "date")
            newSchedule.setValue(startDate, forKey: "startDay")
            newSchedule.setValue(endDate, forKey: "endDay")
            newSchedule.setValue(selectedButtonType.rawValue, forKey: "buttonType")
            
            if let colorHex = selectedCategoryColorHex {
                newSchedule.setValue(colorHex, forKey: "categoryColor")
            }
            
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        saveContext()
    }
    
    private func saveMultipleDates(text: String, dates: [Date]) {
        for date in dates {
            saveSingleDate(text: text, date: date)
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
        
        let firstDayOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: todayMounth!))!
        let firstWeekday = Calendar.current.component(.weekday, from: firstDayOfMonth) - 1
        
        let daysOffset = indexPath.item - firstWeekday
        let day = Calendar.current.date(byAdding: .day, value: daysOffset, to: firstDayOfMonth)!
        let dayNumber = Calendar.current.component(.day, from: day)
        let isCurrentMonth = Calendar.current.isDate(day, equalTo: todayMounth!, toGranularity: .month)
        
        cell.dateLabel.text = isCurrentMonth ? "\(dayNumber)" : nil
        cell.subView.layer.cornerRadius = CGFloat(8)
        cell.subView.backgroundColor = .clear
        
        switch selectedButtonType {
        case .defaultDay:
            if let selectedSingleDate = selectedSingleDate, day == selectedSingleDate {
                cell.subView.backgroundColor = UIColor(hex: "FAD4D8")
            }
            
        case .multipleDay:
            if selectedMultipleDates.contains(day) {
                cell.subView.backgroundColor = UIColor(hex: "FAD4D8")
            }
            
        case .periodDay:
            if let startDate = selectedStartDate, let endDate = selectedEndDate, day >= startDate && day <= endDate {
                cell.subView.backgroundColor = UIColor(hex: "FAD4D8")
            } else if let startDate = selectedStartDate, selectedEndDate == nil, day == startDate {
                cell.subView.backgroundColor = UIColor(hex: "FAD4D8")
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
        let firstDayOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: todayMounth!))!
        let firstWeekday = Calendar.current.component(.weekday, from: firstDayOfMonth) - 1
        
        let daysOffset = indexPath.item - firstWeekday
        let selectedDate = Calendar.current.date(byAdding: .day, value: daysOffset, to: firstDayOfMonth)!
        let isCurrentMonth = Calendar.current.isDate(selectedDate, equalTo: todayMounth!, toGranularity: .month)
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? AddDutyDateCell,
              cell.dateLabel.text != nil,
              isCurrentMonth else {
            return
        }
        
        switch selectedButtonType {
        case .defaultDay:
            selectedSingleDate = selectedDate
            collectionView.reloadData()
            
        case .multipleDay:
            if let index = selectedMultipleDates.firstIndex(of: selectedDate) {
                selectedMultipleDates.remove(at: index)
            } else {
                selectedMultipleDates.append(selectedDate)
            }
            collectionView.reloadData()
            
        case .periodDay:
            if selectedStartDate == nil {
                selectedStartDate = selectedDate
                selectedEndDate = nil
            } else if selectedEndDate == nil {
                selectedEndDate = selectedDate
                if selectedStartDate! > selectedEndDate! {
                    swap(&selectedStartDate, &selectedEndDate)
                }
            } else {
                selectedStartDate = selectedDate
                selectedEndDate = nil
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
        DispatchQueue.main.async {
            self.categoryBtn.titleLabel?.text = name
            self.categoryBtn.titleLabel?.textAlignment = .center
        }
    }
    
    func didSelectCategoryColor(_ colorHex: String) {
        selectedCategoryColorHex = colorHex
        DispatchQueue.main.async {
            self.categoryBtn.backgroundColor = UIColor(hex: colorHex)
        }
    }
    
}

//MARK: - UIColor
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}

extension UIColor {
    func toHexString() -> String {
        guard let components = cgColor.components, components.count >= 3 else { return "#FFFFFF" }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}
