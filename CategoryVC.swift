//
//  EditCategoryVC.swift
//  NewCalendar
//
//  Created by 시모니 on 11/18/24.
//

import UIKit
import CoreData

class CategoryVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addCategoryBtn: UIButton!
    var categories: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        configure()
        fetchCategories()
        addDefaultCategoryIfNeeded()
        NotificationCenter.default.addObserver(self, selector: #selector(updateCategory), name: NSNotification.Name("DeleteCategory"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(popUpView), name: NSNotification.Name("PopUpCategoryVC"), object: nil)
    }
    
    private func configure() {
        addCategoryBtn.layer.cornerRadius = 10
        tableView.layer.cornerRadius = 10
    }
    
    private func addDefaultCategoryIfNeeded() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        request.predicate = NSPredicate(format: "isDefault == true")
        
        do {
            let result = try context.fetch(request)
            // 기본 카테고리가 없다면 추가
            if result.isEmpty {
                let entity = NSEntityDescription.entity(forEntityName: "Category", in: context)!
                let defaultCategory = NSManagedObject(entity: entity, insertInto: context)
                defaultCategory.setValue("할 일", forKey: "name")
                defaultCategory.setValue("#808080", forKey: "color") // 회색
                defaultCategory.setValue(true, forKey: "isDefault")
                
                try context.save()
                categories.append(defaultCategory)
                tableView.reloadData()
            }
        } catch {
            
        }
    }
    
    private func fetchCategories() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Category")
        
        do {
            categories = try context.fetch(fetchRequest)
        } catch {
            
        }
        
        tableView.reloadData()
    }
    
    @IBAction func tapAddCategoryBtn(_ sender: UIButton) {
        guard let editCategoryVC = storyboard?.instantiateViewController(identifier: "EditCategoryVC") as? EditCategoryVC else { return }
        editCategoryVC.delegate = self
        navigationController?.pushViewController(editCategoryVC, animated: true)
    }
    
    @objc func updateCategory() {
        fetchCategories()
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func popUpView() {
        if let selfView = navigationController?.viewControllers.first(where: { $0 is CategoryVC }) {
            navigationController?.popToViewController(selfView, animated: true)
        } else {
            return
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

//MARK: - TableView 관련
extension CategoryVC: UITableViewDataSource , UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as? CategoryCell else {
            return UITableViewCell()
        }
        let category = categories[indexPath.row]
        let categoryName = category.value(forKey: "name") as? String ?? "Unknown"
        let colorCode = category.value(forKey: "color") as? String ?? "#808080"
        
        DispatchQueue.main.async {
            cell.categoryLabel.text = categoryName
            cell.colorView.backgroundColor = UIColor.fromHexString(colorCode)
            cell.colorView.layer.cornerRadius = 10
            cell.colorView.layer.masksToBounds = true
            cell.selectionStyle = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let alert = UIAlertController(title: "알림", message: "기본 카테고리는 수정할 수 없습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard let editCategoryVC = self.storyboard?.instantiateViewController(identifier: "EditCategoryVC") as? EditCategoryVC else { return }
        let category = categories[indexPath.row]
        let categoryName = category.value(forKey: "name") as? String ?? "Unknown"
        let colorCode = category.value(forKey: "color") as? String ?? "#808080"
        
        editCategoryVC.originCategoryName = categoryName
        editCategoryVC.originSelectColor = colorCode
        editCategoryVC.isEditMode = true
        editCategoryVC.delegate = self
        editCategoryVC.navigationItem.rightBarButtonItem?.isHidden = false
        
        navigationController?.pushViewController(editCategoryVC, animated: true)
    }
    
}

//MARK: - EditCategoryVC - Delegate
extension CategoryVC: EditCategoryVCDelegate {
    func didUpdateCategory() {
        fetchCategories()
        tableView.reloadData()
    }
}

// MARK: - UIColor 관련
extension UIColor {
    static func fromHexString(_ hex: String) -> UIColor {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        guard hexString.count == 6 else { return .gray }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}
