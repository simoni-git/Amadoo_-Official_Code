//
//  EditCategoryVC.swift
//  NewCalendar
//
//  Created by 시모니 on 11/18/24.
//

import UIKit

class CategoryVC: UIViewController {

    var vm: CategoryVM!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addCategoryBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        configure()
    }
    
    private func configure() {
        addCategoryBtn.applyStandardCornerRadius()
        tableView.applyStandardCornerRadius()
        vm.fetchCategoriesUsingUseCase { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(updateCategory), name: NSNotification.Name("DeleteCategory"), object: nil)
    }

    @IBAction func tapAddCategoryBtn(_ sender: UIButton) {
        guard let editCategoryVC = storyboard?.instantiateViewController(identifier: "EditCategoryVC") as? EditCategoryVC else { return }
        editCategoryVC.vm = DIContainer.shared.makeEditCategoryVM()
        editCategoryVC.vm.delegate = self
        navigationController?.pushViewController(editCategoryVC, animated: true)
    }

    @objc func updateCategory() {
        vm.fetchCategoriesUsingUseCase { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        // 불필요한 카테고리 정리 (CloudKit 동기화로 재생성될 수 있음)
        (UIApplication.shared.delegate as? AppDelegate)?.cleanupInvalidCategories()

        // 약간의 딜레이 후 카테고리 fetch (정리가 먼저 완료되도록)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.vm.fetchCategoriesUsingUseCase { [weak self] in
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
}

//MARK: - TableView 관련
extension CategoryVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.categoryList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as? CategoryCell else {
            return UITableViewCell()
        }
        let category = vm.categoryList[indexPath.row]

        DispatchQueue.main.async {
            cell.categoryLabel.text = category.name
            cell.colorView.backgroundColor = UIColor.fromHexString(category.color)
            cell.colorView.layer.cornerRadius = 10
            cell.colorView.layer.masksToBounds = true
            cell.selectionStyle = .none
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = vm.categoryList[indexPath.row]

        if category.isDefault {
            let alert = UIAlertController(title: "알림", message: "기본 카테고리는 수정할 수 없습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        guard let editCategoryVC = self.storyboard?.instantiateViewController(identifier: "EditCategoryVC") as? EditCategoryVC else { return }

        editCategoryVC.vm = DIContainer.shared.makeEditCategoryVM()
        editCategoryVC.vm.originCategoryName = category.name
        editCategoryVC.vm.originSelectColor = category.color
        editCategoryVC.vm.isEditMode = true
        editCategoryVC.vm.delegate = self
        editCategoryVC.navigationItem.rightBarButtonItem?.isHidden = false

        navigationController?.pushViewController(editCategoryVC, animated: true)
    }
}

//MARK: - EditCategoryVC - Delegate
extension CategoryVC: EditCategoryVCDelegate {
    func didUpdateCategory() {
        vm.fetchCategoriesUsingUseCase { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

