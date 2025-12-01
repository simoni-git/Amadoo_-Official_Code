//
//  EditTimeVC.swift
//  NewCalendar
//
//  Created by 시모니의 맥북 on 12/1/25.
//

import UIKit
import CoreData

class EditTimeVC: UIViewController {
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
    
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    
    var vm: EditTimeVM!
    private var colorButtons: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupColorButtons()
        loadData()
        setupDatePickers()
        setupDatePickerActions()
        
        // 키보드 노티피케이션 등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // 빈 공간 탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    
    // MARK: - Setup
    private func setupUI() {
        colorSubView.layer.cornerRadius = 10
        deleteBtn.layer.cornerRadius = 10
        editBtn.layer.cornerRadius = 10
    }
    
    private func setupColorButtons() {
        colorButtons = [colorBtn1, colorBtn2, colorBtn3, colorBtn4, colorBtn5, colorBtn6, colorBtn7, colorBtn8]
        
        // 모든 버튼을 alpha 0.1로 초기화
        colorButtons.forEach { $0.alpha = 0.1 }
        
        // 버튼 corner radius 설정
        colorButtons.forEach { $0.layer.cornerRadius = 10 }
    }
    
    private func setupDatePickers() {
        guard let vm = vm else { return }
        
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
                endDatePicker.maximumDate = endMaxDate
            } else {
                endDatePicker.maximumDate = maxDate
            }
        }
    }
    
    private func setupDatePickerActions() {
        startDatePicker.addTarget(self, action: #selector(startDateChanged), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(endDateChanged), for: .valueChanged)
    }
    
    private func loadData() {
        guard let vm = vm else { return }
        
        // 제목 설정
        titleTextField.text = vm.title
        
        // 날짜 피커 설정
        startDatePicker.date = vm.getStartDate()
        endDatePicker.date = vm.getEndDate()
        
        // 메모 설정
        memoTextField.text = vm.memo
        
        // 색상 버튼 설정
        if let colorIndex = vm.getColorIndex() {
            colorButtons.forEach { $0.alpha = 0.1 }
            colorButtons[colorIndex].alpha = 1.0
        }
    }
    
    // MARK: - Color Button Management
    private func updateButtonSelection(selectedButton: UIButton) {
        colorButtons.forEach { $0.alpha = 0.1 }
        selectedButton.alpha = 1.0
        
        if let index = colorButtons.firstIndex(of: selectedButton) {
            vm.selectedColorCode = vm.colors[index].code
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
    
    @IBAction func tapDeleteBtn(_ sender: UIButton) {
        // 삭제 확인 알럿
        let alert = UIAlertController(title: "일정 삭제",
                                      message: "이 일정을 삭제하시겠습니까?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.deleteTimetable()
        })
       
        present(alert, animated: true)
    }
    
    @IBAction func tapEditBtn(_ sender: UIButton) {
        // 제목 검증
        guard let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !title.isEmpty else {
            showWarning(message: "제목을 입력해 주세요")
            return
        }
        
        guard !vm.selectedColorCode.isEmpty else {
            showWarning(message: "색상을 선택해 주세요")
            return
        }
        
        // 시간 겹침 검증
        if isTimeOverlapping() {
            showWarning(message: "해당 시간엔 일정이 있어요")
            return
        }
        
        updateTimetable(title: title, colorCode: vm.selectedColorCode)
    }
    
    private func deleteTimetable() {
        guard let vm = vm else { return }
        
        let context = CoreDataManager.shared.context
        context.delete(vm.timetable)
        CoreDataManager.shared.saveContext()
        
        print("시간표 삭제 완료")
        
        // NotificationCenter로 리로드 알림
        NotificationCenter.default.post(name: NSNotification.Name("ReloadTimetable"), object: nil)
        dismiss(animated: true)
    }
    
    private func updateTimetable(title: String, colorCode: String) {
        guard let vm = vm else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        vm.timetable.setValue(title, forKey: "title")
        vm.timetable.setValue(formatter.string(from: startDatePicker.date), forKey: "startTime")
        vm.timetable.setValue(formatter.string(from: endDatePicker.date), forKey: "endTime")
        vm.timetable.setValue(memoTextField.text, forKey: "memo")
        vm.timetable.setValue(colorCode, forKey: "color")
        
        CoreDataManager.shared.saveContext()
        
        print("시간표 수정 완료")
        
        // NotificationCenter로 리로드 알림
        NotificationCenter.default.post(name: NSNotification.Name("ReloadTimetable"), object: nil)
        dismiss(animated: true)
    }
    
    private func isTimeOverlapping() -> Bool {
        guard let vm = vm else { return false }
        
        let context = CoreDataManager.shared.context
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TimeTable")
        
        // 같은 요일의 시간표만 가져오기
        fetchRequest.predicate = NSPredicate(format: "dayOfWeek == %d", vm.dayOfWeek)
        
        do {
            let existingTimetables = try context.fetch(fetchRequest)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            
            let newStart = formatter.string(from: startDatePicker.date)
            let newEnd = formatter.string(from: endDatePicker.date)
            
            for timetable in existingTimetables {
                // 자기 자신은 제외
                if timetable == vm.timetable {
                    continue
                }
                
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
        if startDatePicker.date >= endDatePicker.date {
            if let newEndDate = Calendar.current.date(byAdding: .hour, value: 1, to: startDatePicker.date) {
                endDatePicker.date = newEndDate
            }
        }
        
        if let minEndDate = Calendar.current.date(byAdding: .minute, value: 30, to: startDatePicker.date) {
            endDatePicker.minimumDate = minEndDate
        }
    }
    
    @objc func endDateChanged() {
        if endDatePicker.date <= startDatePicker.date {
            if let newEndDate = Calendar.current.date(byAdding: .hour, value: 1, to: startDatePicker.date) {
                endDatePicker.date = newEndDate
            }
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard memoTextField.isFirstResponder else { return }
        
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        let textFieldFrame = memoTextField.convert(memoTextField.bounds, to: view.window)
        let textFieldBottom = textFieldFrame.maxY
        let keyboardTop = view.frame.height - keyboardHeight
        let overlap = textFieldBottom - keyboardTop
        
        if overlap > 0 {
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


