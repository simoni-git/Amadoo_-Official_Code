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

    var vm = MemoVM()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 10
        vm.fetchAndCombineData { [weak self] in
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
        nextVC.vm.delegate = self
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func tapAddDefaultVerMemo(_ sender: UIButton) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "AddDefaultVerMemoVC") as? AddDefaultVerMemoVC else { return }
        nextVC.vm.delegate = self
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        vm.fetchAndCombineData { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
    }
    
}

//MARK: - TableView 관련
extension MemoVC: UITableViewDataSource , UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.combinedItemTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoCell") as? MemoCell else {
            return UITableViewCell()
        }
        
        let title = vm.combinedItemTitles[indexPath.row]
        cell.memoTitleLabel.text = title
        
        if let items = vm.combinedItems[title] {
            if let firstItem = items.first {
                if firstItem is CheckList {
                    cell.imgView.image = UIImage(systemName: "checkmark.square")
                    cell.imgView.tintColor = UIColor.fromHexString("A5CBF0")
                    
                }
                else if firstItem is Memo {
                    cell.imgView.image = UIImage(systemName: "square.text.square")
                    cell.imgView.tintColor = UIColor.fromHexString("ECBDBF")
                }
            }
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTitle = vm.combinedItemTitles[indexPath.row]
        guard let items = vm.combinedItems[selectedTitle] else { return }
        
        if let firstItem = items.first {
            if firstItem is CheckList {
                guard let nextVC = self.storyboard?.instantiateViewController(identifier: "MemoCheckVerDetailVC") as? MemoCheckVerDetailVC else { return }
                nextVC.vm.items = items as? [CheckList] ?? []
                nextVC.vm.titleText = selectedTitle
                navigationController?.pushViewController(nextVC, animated: true)
            } else if firstItem is Memo {
                guard let nextVC = self.storyboard?.instantiateViewController(identifier: "MemoDefaultVerDetailVC") as? MemoDefaultVerDetailVC else { return }
                nextVC.vm.item = firstItem as? Memo
                navigationController?.pushViewController(nextVC, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let titleToDelete = vm.combinedItemTitles[indexPath.row]
            
            if let items = vm.combinedItems[titleToDelete] {
                for item in items {
                    vm.coreDataManager.context.delete(item)
                }
            }
            
            vm.combinedItems.removeValue(forKey: titleToDelete)
            vm.combinedItemTitles.remove(at: indexPath.row)
            vm.coreDataManager.saveContext()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "메모삭제"
    }
    
}

//MARK: - Delegate 관련
extension MemoVC: AddCheckVerMemoDelegate {
    func didSaveCheckVerMemoItems() {
        vm.fetchAndCombineData { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
}

extension MemoVC: AddDefaultVerMemoDelegate {
    func didSaveDefaultVerMemoItems() {
        vm.fetchAndCombineData { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
}
