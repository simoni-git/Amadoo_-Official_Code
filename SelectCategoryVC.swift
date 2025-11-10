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

class SelectCategoryVC: UIViewController {
    
    var vm = SelectCategoryVM()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        vm.fetchCategories { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    private func popUpWarning(_ ment: String) {
        guard let warningVC = self.storyboard?.instantiateViewController(identifier: "WarningVC") as? WarningVC else {return}
        warningVC.warningLabelText = ment
        warningVC.modalPresentationStyle = .overCurrentContext
        present(warningVC, animated: true)
    }
    
    @IBAction func tapAddCategoryBtn(_ sender: UIButton) {
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "EditCategoryVC") as? EditCategoryVC else {return}
        nextVC.vm.addForSelectCategoryVCDelegate = self
        nextVC.vm.isAddMode = true
        present(nextVC, animated: true)
    }
    
}

//MARK: - TableVIew 관련
extension SelectCategoryVC: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectCategoryCell") as? SelectCategoryCell else {
            return UITableViewCell()
        }
        let category = vm.categories[indexPath.row]
        let categoryName = category.value(forKey: "name") as? String ?? "Unknown"
        let colorCode = category.value(forKey: "color") as? String ?? "#808080"
        
        DispatchQueue.main.async {
            cell.categoryLabel.text = categoryName
            cell.colorView.layer.cornerRadius = 10
            cell.colorView.backgroundColor = UIColor.fromHexString(colorCode)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = vm.categories[indexPath.row]
        let colorCode = selectedCategory.value(forKey: "color") as? String ?? "#808080"
        let categoryName = selectedCategory.value(forKey: "name") as? String ?? "할 일"
        vm.delegate?.didSelectCategoryColor(colorCode)
        vm.delegate?.didSelectCategoryName(categoryName)
        dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - Delegate관련
extension SelectCategoryVC: AddForSelectCategoryVCDelegate {
    func updateCategory() {
        vm.fetchCategories { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
}

extension SelectCategoryVC: EditCategoryVCDelegate {
    func didUpdateCategory() {
        vm.fetchCategories { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
}

