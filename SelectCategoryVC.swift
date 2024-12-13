//
//  SelectCategoryVC.swift
//  NewCalendar
//
//  Created by 시모니 on 11/19/24.
//

import UIKit
import CoreData

protocol SelectCategoryVCDelegate: AnyObject {
    func didSelectCategoryColor(_ colorHex: String)
    func didSelectCategoryName(_ name: String)
}

class SelectCategoryVC: UIViewController, EditCategoryVCDelegate {
    func didUpdateCategory() {
        fetchCategories()
        tableView.reloadData()
    }
    
    @IBOutlet weak var tableView: UITableView!
    var delegate: SelectCategoryVCDelegate?
    var categories: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        fetchCategories()
    }
    
    private func fetchCategories() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Category")
        
        do {
            categories = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            
        }
    }
    
    private func popUpWarning(_ ment: String) {
        guard let warningVC = self.storyboard?.instantiateViewController(identifier: "WarningVC") as? WarningVC else {return}
        warningVC.warningLabelText = ment
        warningVC.modalPresentationStyle = .overCurrentContext
        present(warningVC, animated: true)
    }
    
    @IBAction func tapExClamationMarkBtn(_ sender: UIButton) {
        popUpWarning("편집창에서 원하는 카테고리 이름과 색상을 선택하실 수 있습니다")
        
    }
    
}

//MARK: - TableVIew 관련
extension SelectCategoryVC: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectCategoryCell") as? SelectCategoryCell else {
            return UITableViewCell()
        }
        let category = categories[indexPath.row]
        let categoryName = category.value(forKey: "name") as? String ?? "Unknown"
        let colorCode = category.value(forKey: "color") as? String ?? "#808080"
        
        DispatchQueue.main.async {
            cell.categoryLabel.text = categoryName
            cell.colorView.backgroundColor = UIColor.fromHexString(colorCode)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = categories[indexPath.row]
        let colorCode = selectedCategory.value(forKey: "color") as? String ?? "#808080"
        let categoryName = selectedCategory.value(forKey: "name") as? String ?? "할 일"
        delegate?.didSelectCategoryColor(colorCode)
        delegate?.didSelectCategoryName(categoryName)
        dismiss(animated: true, completion: nil)
    }
    
}

