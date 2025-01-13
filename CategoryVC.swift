//
//  EditCategoryVC.swift
//  NewCalendar
//
//  Created by 시모니 on 11/18/24.
//

import UIKit
import CoreData

class CategoryVC: UIViewController {
    
    var vm = CategoryVM()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addCategoryBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        configure()
    }
    
    private func configure() {
        addCategoryBtn.layer.cornerRadius = 10
        tableView.layer.cornerRadius = 10
        vm.fetchCategories { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateCategory), name: NSNotification.Name("DeleteCategory"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(popUpView), name: NSNotification.Name("PopUpCategoryVC"), object: nil)
    }
    
    @IBAction func tapAddCategoryBtn(_ sender: UIButton) {
        guard let editCategoryVC = storyboard?.instantiateViewController(identifier: "EditCategoryVC") as? EditCategoryVC else { return }
        editCategoryVC.vm.delegate = self
        navigationController?.pushViewController(editCategoryVC, animated: true)
    }
    
    @objc func updateCategory() {
        vm.fetchCategories { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
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
    
    override func viewWillAppear(_ animated: Bool) {
        vm.fetchCategories { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
}

//MARK: - TableView 관련
extension CategoryVC: UITableViewDataSource , UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as? CategoryCell else {
            return UITableViewCell()
        }
        let category = vm.categories[indexPath.row]
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
        let category = vm.categories[indexPath.row]
        let categoryName = category.value(forKey: "name") as? String ?? "Unknown"
        let colorCode = category.value(forKey: "color") as? String ?? "#808080"
        
        editCategoryVC.vm.originCategoryName = categoryName
        editCategoryVC.vm.originSelectColor = colorCode
        editCategoryVC.vm.isEditMode = true
        editCategoryVC.vm.delegate = self
        editCategoryVC.navigationItem.rightBarButtonItem?.isHidden = false
        
        navigationController?.pushViewController(editCategoryVC, animated: true)
    }
    
}

//MARK: - EditCategoryVC - Delegate
extension CategoryVC: EditCategoryVCDelegate {
    func didUpdateCategory() {
        vm.fetchCategories{ [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

