//
//  MemoCheckVerDetailVC.swift
//  NewCalendar
//
//  Created by 시모니 on 12/5/24.
//

import UIKit
import CoreData

protocol MemoCheckVerWarningDelegate: AnyObject {
    func didSaveMemoItem()
}

class MemoCheckVerDetailVC: UIViewController {
    
    var context: NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("앱 델리게이트를 찾을 수 없습니다.")
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var items: [CheckList] = [] // 전달받은 항목들
    var titleText: String? // 전달받은 제목
    var memoType: String = "check"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        titleLabel.text = titleText
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
        
    }
    
    private func fetchData() {
        let fetchRequest: NSFetchRequest<CheckList> = CheckList.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", titleText ?? "")
        
        do {
            items = try context.fetch(fetchRequest)
            tableView.reloadData() // 테이블 뷰 갱신
        } catch {
            
        }
    }
    
    @IBAction func tapAddItem(_ sender: UIButton) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "EditMemoCheckVer_WarningVC") as? EditMemoCheckVer_WarningVC else { return }
        nextVC.titleText = self.titleText
        nextVC.delegate = self
        present(nextVC, animated: true)
    }
    
    // MARK: - CoreData 저장 관련
    private func saveContext() {
        do {
            try context.save()
        } catch {
            
        }
    }
    
}

//MARK: - TableView 관련
extension MemoCheckVerDetailVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoCheckVerDetail_Cell") as? MemoCheckVerDetail_Cell else {
            return UITableViewCell()
        }
        
        let item = items[indexPath.row]
        cell.nameLabel.text = item.name
        cell.configureButton(isComplete: item.isComplete)
        cell.completeBtn.addTarget(self, action: #selector(toggleComplete(_:)), for: .touchUpInside)
        cell.completeBtn.tag = indexPath.row
        cell.configureButton(isComplete: item.isComplete)
        cell.selectionStyle = .none
        
        return cell
    }
    
    @objc private func toggleComplete(_ sender: UIButton) {
        let index = sender.tag
        items[index].isComplete.toggle()
        saveContext()
        
        if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? MemoCheckVerDetail_Cell {
            cell.configureButton(isComplete: items[index].isComplete)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemToDelete = items[indexPath.row]
            context.delete(itemToDelete)
            saveContext()
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "삭제"
    }
    
}

//MARK: - Delegate 관련
extension MemoCheckVerDetailVC: MemoCheckVerWarningDelegate {
    func didSaveMemoItem() {
        fetchData()
        
    }
    
}
