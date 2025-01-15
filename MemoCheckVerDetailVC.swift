//
//  MemoCheckVerDetailVC.swift
//  NewCalendar
//
//  Created by 시모니 on 12/5/24.
//

import UIKit

protocol MemoCheckVerWarningDelegate: AnyObject {
    func didSaveMemoItem()
}

class MemoCheckVerDetailVC: UIViewController {

    var vm = MemoCheckVerDetailVM()
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        DispatchQueue.main.async { [weak self] in
            self?.titleLabel.text = self?.vm.titleText
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vm.fetchData { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    @IBAction func tapAddItem(_ sender: UIButton) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "EditMemoCheckVer_WarningVC") as? EditMemoCheckVer_WarningVC else { return }
        nextVC.vm.titleText = vm.titleText
        nextVC.vm.delegate = self
        present(nextVC, animated: true)
    }
 
}

//MARK: - TableView 관련
extension MemoCheckVerDetailVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoCheckVerDetail_Cell") as? MemoCheckVerDetail_Cell else {
            return UITableViewCell()
        }
        
        let item = vm.items[indexPath.row]
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
        vm.items[index].isComplete.toggle()
        vm.coreDataManager.saveContext()
        
        if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? MemoCheckVerDetail_Cell {
            cell.configureButton(isComplete: vm.items[index].isComplete)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemToDelete = vm.items[indexPath.row]
            vm.coreDataManager.context.delete(itemToDelete)
            vm.coreDataManager.saveContext()
            vm.items.remove(at: indexPath.row)
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
        vm.fetchData { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
}
