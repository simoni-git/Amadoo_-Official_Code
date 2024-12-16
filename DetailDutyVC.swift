//
//  DetailDutyVC.swift
//  NewCalendar
//
//  Created by 시모니 on 10/4/24.
//

import UIKit
import CoreData

class DetailDutyVC: UIViewController {
    
    var context: NSManagedObjectContext {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get shared context")
        }
        return app.persistentContainer.viewContext
    }
    
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dDayLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBtn: UIButton!
    
    private var events: [NSManagedObject] = []
    var selectedDate: Date?
    var selecDateString: String?
    var dDayString: String?
    
    enum ButtonType: String {
        case defaultDay = "defaultDay"
        case periodDay = "periodDay"
        case multipleDay = "multipleDay"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        tableView.dataSource = self
        tableView.delegate = self
        
        if let date = selecDateString {
            dateLabel.text = date
        }
        if let dDay = dDayString {
            dDayLabel.text = dDay
        }
        fetchEventsForSelectedDate()
    }
    
    private func configure() {
        subView.layer.cornerRadius = 10
        tableView.layer.cornerRadius = 10
        addBtn.layer.cornerRadius = 10
    }
    
    private func fetchEventsForSelectedDate() {
        guard let date = selectedDate else {
            return
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let request = NSFetchRequest<NSManagedObject>(entityName: "Schedule")
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        
        do {
            events = try context.fetch(request)
            tableView.reloadData()
        } catch {
            
        }
    }
    
    private func convertStringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: dateString)
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            
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
        let monthYearString = dateFormatter.string(from: self.selectedDate!)
        
        nextVC.modalPresentationStyle = .pageSheet
        nextVC.todayMounth = self.selectedDate
        nextVC.todayMounthString = monthYearString
        nextVC.selectedSingleDate = selectedDate
        present(nextVC, animated: true)
    }
    
    @IBAction func tapBgBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}

//MARK: - TableView 관련
extension DetailDutyVC: UITableViewDataSource , UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DutyCell") as? DutyCell else {
            return UITableViewCell()
        }
        
        if let title = events[indexPath.row].value(forKey: "title") as? String {
            cell.titleLabel.text = title
        }
        
        if let colorHex = events[indexPath.row].value(forKey: "categoryColor") as? String {
            cell.backgroundColor = UIColor(hex: colorHex)
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let eventToDelete = events[indexPath.row]
            
            if let buttonType = eventToDelete.value(forKey: "buttonType") as? String,
               let title = eventToDelete.value(forKey: "title") as? String,
               buttonType == "periodDay" {
                if let startDate = eventToDelete.value(forKey: "startDay") as? Date,
                   let endDate = eventToDelete.value(forKey: "endDay") as? Date {
                    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Schedule")
                    fetchRequest.predicate = NSPredicate(format: "title == %@ AND buttonType == %@ AND startDay == %@ AND endDay == %@", title, buttonType, startDate as NSDate, endDate as NSDate)
                    
                    do {
                        let matchingEvents = try context.fetch(fetchRequest) as? [NSManagedObject]
                        matchingEvents?.forEach { context.delete($0) }
                    } catch {
                        
                    }
                }
            } else {
                context.delete(eventToDelete)
            }
            
            saveContext()
            events.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            NotificationCenter.default.post(name: NSNotification.Name("EventDeleted"), object: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "일정삭제"
    }
    
}
