//
//  AddTimeVC.swift
//  NewCalendar
//
//  Created by 시모니의 맥북 on 11/25/25.
//

import UIKit

class AddTimeVC: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    var vm: AddTimeVM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDatePickers()
        setupDatePickerActions()
    }
    
//    func setupDatePickers() {
//        guard let vm = vm else { return }
//        
//        startDatePicker.date = vm.selectedDate
//        endDatePicker.date = vm.endDate
//    }
    
    func setupDatePickers() {
        guard let vm = vm else { return }
        
        startDatePicker.date = vm.selectedDate
        endDatePicker.date = vm.endDate
        
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
            
            endDatePicker.minimumDate = minDate
            endDatePicker.maximumDate = maxDate
        }
    }
    
    func setupDatePickerActions() {
        // DatePicker 값 변경 감지
        startDatePicker.addTarget(self, action: #selector(startDateChanged), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(endDateChanged), for: .valueChanged)
    }
    
    //MARK: - @objc
    @objc func startDateChanged() {
        // 시작 시간이 종료 시간보다 크거나 같으면
        if startDatePicker.date >= endDatePicker.date {
            // 종료 시간을 시작 시간 + 30분으로 자동 조정
            if let newEndDate = Calendar.current.date(byAdding: .hour, value: 1, to: startDatePicker.date) {
                endDatePicker.date = newEndDate
            }
        }
    }
    
    @objc func endDateChanged() {
        // 종료 시간이 시작 시간보다 작거나 같으면
        if endDatePicker.date <= startDatePicker.date {
            // 종료 시간을 시작 시간 + 30분으로 자동 조정
            if let newEndDate = Calendar.current.date(byAdding: .hour, value: 1, to: startDatePicker.date) {
                endDatePicker.date = newEndDate
            }
        }
    }
    
}
