//
//  DetailDutyVC.swift
//  NewCalendar
//
//  Created by 시모니 on 10/4/24.
//

import UIKit

class DetailDutyVC: UIViewController {

    var vm = DetailDutyVM()
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dDayLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        DIContainer.shared.injectDetailDutyVM(vm)
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        tableView.dataSource = self
        tableView.delegate = self
        configure()
        vm.fetchSchedulesForSelectedDate { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    private func configure() {
        subView.layer.cornerRadius = 10
        tableView.layer.cornerRadius = 10
        addBtn.layer.cornerRadius = 10
        
        if let date = vm.selecDateString {
            dateLabel.text = date
        }
        if let dDay = vm.dDayString {
            dDayLabel.text = dDay
        }
    }
    
    @IBAction func tapAddBtn(_ sender: UIButton) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "AddDutyVC") as? AddDutyVC else { return }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "MM월 yyyy"
        let monthYearString = dateFormatter.string(from: vm.selectedDate!)

        nextVC.vm.todayMounth = vm.selectedDate
        nextVC.vm.todayMounthString = monthYearString
        nextVC.vm.selectedSingleDate = vm.selectedDate
        presentAsSheet(nextVC)
    }
    
    @IBAction func tapBgBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}

//MARK: - TableView 관련
extension DetailDutyVC: UITableViewDataSource , UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.schedules.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DutyCell") as? DutyCell else {
            return UITableViewCell()
        }

        let schedule = vm.schedules[indexPath.row]
        cell.titleLabel.text = schedule.title
        cell.backgroundColor = UIColor.fromHexString(schedule.categoryColor)
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let scheduleToDelete = vm.schedules[indexPath.row]

            // UseCase를 통한 삭제
            if scheduleToDelete.buttonType == .periodDay {
                // 기간 일정: 전체 삭제
                if let result = vm.deleteAllSchedulesUsingUseCase(title: scheduleToDelete.title, startDay: scheduleToDelete.startDay) {
                    switch result {
                    case .success:
                        vm.fetchSchedulesForSelectedDate { [weak self] in
                            DispatchQueue.main.async {
                                self?.tableView.deleteRows(at: [indexPath], with: .fade)
                                self?.vm.userNotificationManager.updateNotification()
                                NotificationCenter.default.post(name: NSNotification.Name("EventDeleted"), object: nil)
                            }
                        }
                    case .failure(let error):
                        print("삭제 실패: \(error)")
                    }
                }
            } else {
                // 단일 일정 삭제
                if let result = vm.deleteScheduleUsingUseCase(scheduleToDelete) {
                    switch result {
                    case .success:
                        vm.fetchSchedulesForSelectedDate { [weak self] in
                            DispatchQueue.main.async {
                                self?.tableView.deleteRows(at: [indexPath], with: .fade)
                                self?.vm.userNotificationManager.updateNotification()
                                NotificationCenter.default.post(name: NSNotification.Name("EventDeleted"), object: nil)
                            }
                        }
                    case .failure(let error):
                        print("삭제 실패: \(error)")
                    }
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "일정삭제"
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.row) 번째 셀입니다")
        let schedule = vm.schedules[indexPath.row]

        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "AddDutyVC") as? AddDutyVC else { return }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "MM월 yyyy"
        let monthYearString = dateFormatter.string(from: vm.selectedDate!)

        nextVC.modalPresentationStyle = .pageSheet
        nextVC.vm.todayMounth = vm.selectedDate
        nextVC.vm.todayMounthString = monthYearString
        nextVC.vm.isEditMode = true

        // ScheduleItem 정보를 전달
        nextVC.vm.originTitle = schedule.title
        nextVC.vm.originCategoryColor = schedule.categoryColor
        nextVC.vm.originButtonType = schedule.buttonType.rawValue
        nextVC.vm.originDate = schedule.date
        nextVC.vm.originStartDate = schedule.startDay
        nextVC.vm.originEndDate = schedule.endDay

        present(nextVC, animated: true)
    }
}
