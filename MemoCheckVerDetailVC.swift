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

    var vm: MemoCheckVerDetailVM!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 10
        DispatchQueue.main.async { [weak self] in
            self?.titleLabel.text = self?.vm.titleText
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vm.fetchCheckListUsingUseCase { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    @IBAction func tapAddItem(_ sender: UIButton) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "EditMemoCheckVer_WarningVC") as? EditMemoCheckVer_WarningVC else { return }
        nextVC.vm = DIContainer.shared.makeEditMemoCheckVer_WarningVM()
        nextVC.vm.titleText = vm.titleText
        nextVC.vm.delegate = self
        present(nextVC, animated: true)
    }
 
}

//MARK: - TableView 관련
extension MemoCheckVerDetailVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.checkListItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoCheckVerDetail_Cell") as? MemoCheckVerDetail_Cell else {
            return UITableViewCell()
        }

        let item = vm.checkListItems[indexPath.row]
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

        // UseCase를 통한 토글 처리
        if let result = vm.toggleCompleteUsingUseCase(at: index) {
            switch result {
            case .success:
                // 데이터 다시 조회하여 정렬 반영
                vm.fetchCheckListUsingUseCase { [weak self] in
                    DispatchQueue.main.async {
                        self?.tableView.performBatchUpdates({
                            self?.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                        }, completion: nil)
                    }
                }
            case .failure(let error):
                print("토글 실패: \(error)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemToDelete = vm.checkListItems[indexPath.row]

            // UseCase를 통한 삭제
            let result = vm.deleteCheckListUsingUseCase(itemToDelete)
            switch result {
            case .success:
                vm.fetchCheckListUsingUseCase { [weak self] in
                    DispatchQueue.main.async {
                        self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
            case .failure(let error):
                print("삭제 실패: \(error)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "삭제"
    }
    
}

//MARK: - Delegate 관련
extension MemoCheckVerDetailVC: MemoCheckVerWarningDelegate {
    func didSaveMemoItem() {
        vm.fetchCheckListUsingUseCase { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}
