//
//  AddTimeVC.swift
//  NewCalendar
//
//  Created by 시모니의 맥북 on 11/25/25.
//

import UIKit
import CoreData

class AddTimeVC: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var memoTextField: UITextField!
    
    @IBOutlet weak var colorSubView: UIView!
    @IBOutlet weak var colorBtn1: UIButton!
    @IBOutlet weak var colorBtn2: UIButton!
    @IBOutlet weak var colorBtn3: UIButton!
    @IBOutlet weak var colorBtn4: UIButton!
    @IBOutlet weak var colorBtn5: UIButton!
    @IBOutlet weak var colorBtn6: UIButton!
    @IBOutlet weak var colorBtn7: UIButton!
    @IBOutlet weak var colorBtn8: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    
    var vm: AddTimeVM!
    private var colorButtons: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDatePickers()
        setupDatePickerActions()
        setupColorButtons()
        colorSubView.layer.cornerRadius = 10
        saveBtn.layer.cornerRadius = 10
        memoTextField.isHidden = true
        // 키보드 노티피케이션 등록 (추가)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // 빈 공간 탭 제스처 추가 (추가)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
    }
    // MARK: - Setup
    func setupDatePickers() {
        guard let vm = vm else { return }
        
        startDatePicker.date = vm.selectedDate
        endDatePicker.date = vm.endDate
        startDatePicker.minuteInterval = 30
        endDatePicker.minuteInterval = 30
        
        // 시작 시간 범위 설정
        let calendar = Calendar.current
        var minComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        minComponents.hour = vm.minimumHour
        minComponents.minute = 0
        
        var maxComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        maxComponents.hour = vm.maximumHour
        maxComponents.minute = 0
        
        if let minDate = calendar.date(from: minComponents),
           let maxDate = calendar.date(from: maxComponents) {
            startDatePicker.minimumDate = minDate
            startDatePicker.maximumDate = maxDate
            
            // 종료시간은 최대 +1시간까지 가능
            endDatePicker.minimumDate = minDate
            if let endMaxDate = calendar.date(byAdding: .hour, value: 1, to: maxDate) {
                endDatePicker.maximumDate = endMaxDate  // maximumHour + 1
            } else {
                endDatePicker.maximumDate = maxDate
            }
        }
    }
    
    func setupDatePickerActions() {
        // DatePicker 값 변경 감지
        startDatePicker.addTarget(self, action: #selector(startDateChanged), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(endDateChanged), for: .valueChanged)
    }
    
    func setupColorButtons() {
        colorButtons = [colorBtn1, colorBtn2, colorBtn3, colorBtn4, colorBtn5, colorBtn6, colorBtn7, colorBtn8]
        
        // 모든 버튼을 alpha 0.1로 초기화
        colorButtons.forEach { $0.alpha = 0.1 }
        
        // 버튼 corner radius 설정
        colorButtons.forEach { $0.layer.cornerRadius = 10 }
    }
    
    // MARK: - Color Button Management
    private func updateButtonSelection(selectedButton: UIButton) {
        // 모든 버튼을 alpha 0.1로 설정
        colorButtons.forEach { $0.alpha = 0.1 }
        
        // 선택된 버튼만 alpha 1.0으로 설정
        selectedButton.alpha = 1.0
        
        // VM에 선택된 색상 정보 저장 (필요한 경우)
        if let index = colorButtons.firstIndex(of: selectedButton) {
            vm.selectColorName = vm.colors[index].name
            vm.selectColorCode = vm.colors[index].code
        }
    }
    
    // MARK: - Actions
    
    @IBAction func tapColorButton(_ sender: UIButton) {
        updateButtonSelection(selectedButton: sender)
    }
    
    
    @IBAction func tapMomoBtn(_ sender: UIButton) {
        // 메모 필드 토글
        memoTextField.isHidden.toggle()
        
        // 버튼 타이틀 변경
        if memoTextField.isHidden {
            sender.setTitle("간단한 메모하기", for: .normal)
        } else {
            sender.setTitle("메모접기", for: .normal)
            // 메모 필드가 나타날 때 포커스 (선택사항)
            memoTextField.becomeFirstResponder()
        }
        
    }
    
    @IBAction func tapSaveBtn(_ sender: UIButton) {
        // 1. 제목 검증
        guard let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !title.isEmpty else {
            showWarning(message: "제목을 입력해 주세요")
            return
        }
        
        // 2. 색상 선택 검증
        guard let colorCode = vm.selectColorCode,
              !colorCode.isEmpty else {
            showWarning(message: "색상을 선택해 주세요")
            return
        }
        
        // 3. 시간 겹침 검증
        if isTimeOverlapping() {
            showWarning(message: "해당 시간엔 일정이 있어요")
            return
        }
        
        // 4. Core Data 저장
        saveTimetable(title: title, colorCode: colorCode)
    }
    
    private func isTimeOverlapping() -> Bool {
        let context = CoreDataManager.shared.context
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TimeTable")
        
        // 같은 요일의 시간표만 가져오기 (vm.dayOfWeek 사용)
        fetchRequest.predicate = NSPredicate(format: "dayOfWeek == %d", vm.dayOfWeek)
        
        do {
            let existingTimetables = try context.fetch(fetchRequest)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            
            let newStart = formatter.string(from: startDatePicker.date)
            let newEnd = formatter.string(from: endDatePicker.date)
            
            for timetable in existingTimetables {
                guard let existingStart = timetable.value(forKey: "startTime") as? String,
                      let existingEnd = timetable.value(forKey: "endTime") as? String else {
                    continue
                }
                
                // 시간 겹침 체크
                if (newStart >= existingStart && newStart < existingEnd) ||
                    (newEnd > existingStart && newEnd <= existingEnd) ||
                    (newStart <= existingStart && newEnd >= existingEnd) {
                    return true
                }
            }
            
            return false
        } catch {
            print("시간표 조회 실패: \(error)")
            return false
        }
    }
    
    private func saveTimetable(title: String, colorCode: String) {
        let context = CoreDataManager.shared.context
        
        guard let entity = NSEntityDescription.entity(forEntityName: "TimeTable", in: context) else {
            print("Timetable 엔티티를 찾을 수 없습니다")
            return
        }
        
        let timetable = NSManagedObject(entity: entity, insertInto: context)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        timetable.setValue(Int16(vm.dayOfWeek), forKey: "dayOfWeek")  // vm.dayOfWeek 사용
        timetable.setValue(formatter.string(from: startDatePicker.date), forKey: "startTime")
        timetable.setValue(formatter.string(from: endDatePicker.date), forKey: "endTime")
        timetable.setValue(title, forKey: "title")
        timetable.setValue(memoTextField.text, forKey: "memo")
        timetable.setValue(colorCode, forKey: "color")
        
        CoreDataManager.shared.saveContext()
        
        print("시간표 저장 완료: \(["월","화","수","목","금"][vm.dayOfWeek])요일 \(formatter.string(from: startDatePicker.date))~\(formatter.string(from: endDatePicker.date))")
        
        // NotificationCenter로 리로드 알림
        NotificationCenter.default.post(name: NSNotification.Name("ReloadTimetable"), object: nil)
        dismiss(animated: true)
        
    }
    
    private func showWarning(message: String) {
        guard let warningVC = storyboard?.instantiateViewController(withIdentifier: "WarningVC") as? WarningVC else {
            return
        }
        
        warningVC.warningLabelText = message
        warningVC.modalPresentationStyle = .overFullScreen
        warningVC.modalTransitionStyle = .crossDissolve
        
        present(warningVC, animated: true)
    }
    
    
    
    //MARK: - @objc
    @objc func startDateChanged() {
        // 시작 시간이 종료 시간보다 크거나 같으면
        if startDatePicker.date >= endDatePicker.date {
            // 종료 시간을 시작 시간 + 1시간으로 자동 조정
            if let newEndDate = Calendar.current.date(byAdding: .hour, value: 1, to: startDatePicker.date) {
                endDatePicker.date = newEndDate
            }
        }
        
        // 종료 시간의 최소값을 시작 시간 + 30분으로 설정
        if let minEndDate = Calendar.current.date(byAdding: .minute, value: 30, to: startDatePicker.date) {
            endDatePicker.minimumDate = minEndDate
        }
    }
    
    @objc func endDateChanged() {
        // 종료 시간이 시작 시간보다 작거나 같으면
        if endDatePicker.date <= startDatePicker.date {
            // 종료 시간을 시작 시간 + 1시간으로 자동 조정
            if let newEndDate = Calendar.current.date(byAdding: .hour, value: 1, to: startDatePicker.date) {
                endDatePicker.date = newEndDate
            }
        }
    }
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        // 메모 텍스트필드가 편집 중일 때만 처리
        guard memoTextField.isFirstResponder else { return }
        
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        
        // 메모 텍스트필드의 화면 상 위치
        let textFieldFrame = memoTextField.convert(memoTextField.bounds, to: view.window)
        let textFieldBottom = textFieldFrame.maxY
        
        // 키보드가 시작되는 위치
        let keyboardTop = view.frame.height - keyboardHeight
        
        // 겹치는 부분 계산
        let overlap = textFieldBottom - keyboardTop
        
        if overlap > 0 {
            // 여유 공간 추가 (20pt)
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = -(overlap + 20)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
