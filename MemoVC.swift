//
//  MemoVC.swift
//  NewCalendar
//
//  Created by 시모니 on 12/5/24.
//

import UIKit

protocol AddCheckVerMemoDelegate: AnyObject {
    func didSaveCheckVerMemoItems()
}

protocol AddDefaultVerMemoDelegate: AnyObject {
    func didSaveDefaultVerMemoItems()
}

class MemoVC: UIViewController {

    var vm: MemoVM!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Storyboard에서 직접 로드된 경우 VM이 nil일 수 있으므로 fallback
        if vm == nil {
            vm = DIContainer.shared.makeMemoVM()
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 10
        vm.fetchAllDataUsingUseCase { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    @IBAction func tapAddCheckVerMemo(_ sender: UIButton) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "AddCheckVerMemoVC") as? AddCheckVerMemoVC else { return }
        nextVC.vm = DIContainer.shared.makeAddCheckVerMemoVM()
        nextVC.vm.delegate = self
        navigationController?.pushViewController(nextVC, animated: true)
    }

    @IBAction func tapAddDefaultVerMemo(_ sender: UIButton) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "AddDefaultVerMemoVC") as? AddDefaultVerMemoVC else { return }
        nextVC.vm = DIContainer.shared.makeAddDefaultVerMemoVM()
        nextVC.vm.delegate = self
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        vm.fetchAllDataUsingUseCase { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
}

//MARK: - TableView 관련
extension MemoVC: UITableViewDataSource , UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.groupedItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoCell") as? MemoCell else {
            return UITableViewCell()
        }

        let item = vm.groupedItems[indexPath.row]
        cell.memoTitleLabel.text = item.title
        cell.memoTitleLabel.numberOfLines = 0  // 여러 줄 지원

        if item.type == "check" {
            cell.imgView.image = UIImage(systemName: "checkmark.square")
            cell.imgView.tintColor = UIColor.fromHexString("A5CBF0")
        } else {
            cell.imgView.image = UIImage(systemName: "square.text.square")
            cell.imgView.tintColor = UIColor.fromHexString("ECBDBF")
        }

        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = vm.groupedItems[indexPath.row]

        if selectedItem.type == "check" {
            guard let nextVC = self.storyboard?.instantiateViewController(identifier: "MemoCheckVerDetailVC") as? MemoCheckVerDetailVC else { return }
            nextVC.vm = DIContainer.shared.makeMemoCheckVerDetailVM()
            nextVC.vm.titleText = selectedItem.title
            navigationController?.pushViewController(nextVC, animated: true)
        } else {
            guard let nextVC = self.storyboard?.instantiateViewController(identifier: "MemoDefaultVerDetailVC") as? MemoDefaultVerDetailVC else { return }
            nextVC.vm = DIContainer.shared.makeMemoDefaultVerDetailVM()
            // MemoItem을 설정 (첫 번째 아이템)
            if let firstMemo = selectedItem.items.first as? MemoItem {
                nextVC.vm.memoItem = firstMemo
            }
            navigationController?.pushViewController(nextVC, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemToDelete = vm.groupedItems[indexPath.row]

            // UseCase를 통한 삭제
            if itemToDelete.type == "check" {
                // 체크리스트 전체 삭제
                let result = vm.deleteAllCheckListsUsingUseCase(forTitle: itemToDelete.title)
                switch result {
                case .success:
                    vm.fetchAllDataUsingUseCase { [weak self] in
                        DispatchQueue.main.async {
                            self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                        }
                    }
                case .failure(let error):
                    print("삭제 실패: \(error)")
                }
            } else {
                // 메모 삭제
                if let firstMemo = itemToDelete.items.first as? MemoItem {
                    let result = vm.deleteMemoUsingUseCase(firstMemo)
                    switch result {
                    case .success:
                        vm.fetchAllDataUsingUseCase { [weak self] in
                            DispatchQueue.main.async {
                                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                            }
                        }
                    case .failure(let error):
                        print("삭제 실패: \(error)")
                    }
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "메모삭제"
    }
}

//MARK: - Delegate 관련
extension MemoVC: AddCheckVerMemoDelegate {
    func didSaveCheckVerMemoItems() {
        vm.fetchAllDataUsingUseCase { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

extension MemoVC: AddDefaultVerMemoDelegate {
    func didSaveDefaultVerMemoItems() {
        vm.fetchAllDataUsingUseCase { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}
