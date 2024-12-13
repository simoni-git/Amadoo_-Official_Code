//
//  MemoVC.swift
//  NewCalendar
//
//  Created by 시모니 on 12/5/24.
//

import UIKit
import CoreData

protocol AddCheckVerMemoDelegate: AnyObject {
    func didSaveCheckVerMemoItems()
}

protocol AddDefaultVerMemoDelegate: AnyObject {
    func didSaveDefaultVerMemoItems()
}

class MemoVC: UIViewController {
    
    var context: NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("앱 델리게이트를 찾을 수 없습니다.")
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    @IBOutlet weak var tableView: UITableView!
    var combinedItems: [String: [NSManagedObject]] = [:]
    var combinedItemTitles: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 10
        fetchAndCombineData()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    @IBAction func tapAddCheckVerMemo(_ sender: UIButton) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "AddCheckVerMemoVC") as? AddCheckVerMemoVC else { return }
        nextVC.delegate = self
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func tapAddDefaultVerMemo(_ sender: UIButton) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "AddDefaultVerMemoVC") as? AddDefaultVerMemoVC else { return }
        nextVC.delegate = self
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchAndCombineData()
        
    }
    
    //MARK: - CoreData 관련
    private func saveContext() {
        do {
            try context.save()
        } catch {
            
        }
    }
    
    private func fetchAndCombineData() {
        let checkListFetch: NSFetchRequest<CheckList> = CheckList.fetchRequest()
        let memoFetch: NSFetchRequest<Memo> = Memo.fetchRequest()
        
        do {
            let checkListItems = try context.fetch(checkListFetch)
            let memoItems = try context.fetch(memoFetch)
            combinedItems = [:]
            
            for item in checkListItems {
                let key = item.title ?? "Untitled"
                if combinedItems[key] == nil {
                    combinedItems[key] = []
                }
                combinedItems[key]?.append(item)
            }
            
            for item in memoItems {
                let key = item.title ?? "Untitled"
                if combinedItems[key] == nil {
                    combinedItems[key] = []
                }
                combinedItems[key]?.append(item)
            }
            
            combinedItemTitles = Array(combinedItems.keys).sorted()
            tableView.reloadData()
        } catch {
            
        }
    }
    
}

//MARK: - TableView 관련
extension MemoVC: UITableViewDataSource , UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return combinedItemTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoCell") as? MemoCell else {
            return UITableViewCell()
        }
        
        let title = combinedItemTitles[indexPath.row]
        cell.memoTitleLabel.text = title
        
        if let items = combinedItems[title] {
            if let firstItem = items.first {
                // 첫 번째 항목이 CheckList라면 star 이미지 설정
                if firstItem is CheckList {
                    cell.imgView.image = UIImage(systemName: "checkmark.square")
                    cell.imgView.tintColor = UIColor(hex: "A5CBF0")
                }
                // 첫 번째 항목이 Memo라면 star.fill 이미지 설정
                else if firstItem is Memo {
                    cell.imgView.image = UIImage(systemName: "square.text.square")
                    cell.imgView.tintColor = UIColor(hex: "ECBDBF")
                }
            }
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTitle = combinedItemTitles[indexPath.row]
        guard let items = combinedItems[selectedTitle] else { return }
        
        if let firstItem = items.first {
            if firstItem is CheckList {
                guard let nextVC = self.storyboard?.instantiateViewController(identifier: "MemoCheckVerDetailVC") as? MemoCheckVerDetailVC else { return }
                nextVC.items = items as? [CheckList] ?? []
                nextVC.titleText = selectedTitle
                navigationController?.pushViewController(nextVC, animated: true)
            } else if firstItem is Memo {
                guard let nextVC = self.storyboard?.instantiateViewController(identifier: "MemoDefaultVerDetailVC") as? MemoDefaultVerDetailVC else { return }
                nextVC.items = firstItem as? Memo
                navigationController?.pushViewController(nextVC, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let titleToDelete = combinedItemTitles[indexPath.row]
            
            if let items = combinedItems[titleToDelete] {
                for item in items {
                    context.delete(item)
                }
            }
            
            combinedItems.removeValue(forKey: titleToDelete)
            combinedItemTitles.remove(at: indexPath.row)
            saveContext()
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
        fetchAndCombineData()
        
    }
    
}

extension MemoVC: AddDefaultVerMemoDelegate {
    func didSaveDefaultVerMemoItems() {
        fetchAndCombineData()
        
    }
    
}
