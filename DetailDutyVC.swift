//
//  DetailDutyVC.swift
//  NewCalendar
//
//  Created by 시모니 on 10/4/24.
//

import UIKit
import CoreData

class DetailDutyVC: UIViewController {
    
    var vm = DetailDutyVM()
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dDayLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        configure()
        vm.fetchEventsForSelectedDate { [weak self] in
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
        
        if let sheet = nextVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "MM월 yyyy"
        let monthYearString = dateFormatter.string(from: vm.selectedDate!)
        
        nextVC.modalPresentationStyle = .pageSheet
        nextVC.vm.todayMounth = vm.selectedDate
        nextVC.vm.todayMounthString = monthYearString
        nextVC.vm.selectedSingleDate = vm.selectedDate
        present(nextVC, animated: true)
    }
    
    @IBAction func tapBgBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}

//MARK: - TableView 관련
extension DetailDutyVC: UITableViewDataSource , UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DutyCell") as? DutyCell else {
            return UITableViewCell()
        }
        
        if let title = vm.events[indexPath.row].value(forKey: "title") as? String {
            cell.titleLabel.text = title
        }
        
        if let colorHex = vm.events[indexPath.row].value(forKey: "categoryColor") as? String {
            cell.backgroundColor = UIColor.fromHexString(colorHex)
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let eventToDelete = vm.events[indexPath.row]
            
            if let buttonType = eventToDelete.value(forKey: "buttonType") as? String,
               let title = eventToDelete.value(forKey: "title") as? String,
               buttonType == "periodDay" {
                if let startDate = eventToDelete.value(forKey: "startDay") as? Date,
                   let endDate = eventToDelete.value(forKey: "endDay") as? Date {
                    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Schedule")
                    fetchRequest.predicate = NSPredicate(format: "title == %@ AND buttonType == %@ AND startDay == %@ AND endDay == %@", title, buttonType, startDate as NSDate, endDate as NSDate)
                    
                    do {
                        let matchingEvents = try vm.context.fetch(fetchRequest) as? [NSManagedObject]
                        matchingEvents?.forEach { vm.context.delete($0) }
                    } catch {
                        
                    }
                }
            } else {
                vm.context.delete(eventToDelete)
            }
            
            vm.saveContext()
            vm.events.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            NotificationCenter.default.post(name: NSNotification.Name("EventDeleted"), object: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "일정삭제"
    }
    
}
