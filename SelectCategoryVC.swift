//
//  SelectCategoryVC.swift
//  NewCalendar
//
//  Created by 시모니 on 11/19/24.
//

import UIKit

protocol SelectCategoryVCDelegate: AnyObject {
    func didSelectCategoryColor(_ colorHex: String)
    func didSelectCategoryName(_ name: String)
}

class SelectCategoryVC: UIViewController {

    var vm = SelectCategoryVM()
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        DIContainer.shared.injectSelectCategoryVM(vm)
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

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

//MARK: - TableView 관련
extension SelectCategoryVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.categoryList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectCategoryCell") as? SelectCategoryCell else {
            return UITableViewCell()
        }
        let category = vm.categoryList[indexPath.row]

        DispatchQueue.main.async {
            cell.categoryLabel.text = category.name
            cell.colorView.layer.cornerRadius = 10
            cell.colorView.backgroundColor = UIColor.fromHexString(category.color)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = vm.categoryList[indexPath.row]
        vm.delegate?.didSelectCategoryColor(selectedCategory.color)
        vm.delegate?.didSelectCategoryName(selectedCategory.name)
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - Delegate관련
extension SelectCategoryVC: AddForSelectCategoryVCDelegate {
    func updateCategory() {
        vm.fetchCategoriesUsingUseCase { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

extension SelectCategoryVC: EditCategoryVCDelegate {
    func didUpdateCategory() {
        vm.fetchCategoriesUsingUseCase { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}
