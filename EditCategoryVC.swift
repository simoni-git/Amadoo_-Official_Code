//
//  EditCategoryVC.swift
//  NewCalendar
//
//  Created by 시모니 on 11/18/24.
//

import UIKit
import CoreData

protocol EditCategoryVCDelegate: AnyObject {
    func didUpdateCategory()
}

protocol AddForSelectCategoryVCDelegate: AnyObject {
    func updateCategory()
}

class EditCategoryVC: UIViewController {
    
    var vm = EditCategoryVM()
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var colorBtn1: UIButton!
    @IBOutlet weak var colorBtn2: UIButton!
    @IBOutlet weak var colorBtn3: UIButton!
    @IBOutlet weak var colorBtn4: UIButton!
    @IBOutlet weak var colorBtn5: UIButton!
    @IBOutlet weak var colorBtn6: UIButton!
    @IBOutlet weak var colorBtn7: UIButton!
    @IBOutlet weak var colorBtn8: UIButton!
    
    var colorButtons: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        self.categoryTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    private func configure() {
        subView.layer.cornerRadius = 10
        saveBtn.layer.cornerRadius = 10
        let buttons = [colorBtn1, colorBtn2, colorBtn3, colorBtn4, colorBtn5, colorBtn6, colorBtn7, colorBtn8]
        buttons.forEach { $0?.layer.cornerRadius = 10 }
        initializeColorButtons()
        
        if vm.isEditMode == true {
            saveBtn.backgroundColor = .lightGray
            fetchEditTarget()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func initializeColorButtons() {
        colorButtons = [colorBtn1, colorBtn2, colorBtn3, colorBtn4, colorBtn5, colorBtn6, colorBtn7, colorBtn8]
        colorButtons.forEach { $0.alpha = 0.1 }
    }
    
    private func updateButtonSelection(selectedButton: UIButton) {
        colorButtons.forEach { $0.alpha = 0.1 }
        selectedButton.alpha = 1.0
        
        if let index = colorButtons.firstIndex(of: selectedButton) {
            vm.selectColorName = vm.colors[index].name
            vm.selectColorCode = vm.colors[index].code
            
            if vm.isEditMode == true {
                if vm.originSelectColor != vm.selectColorCode {
                    saveBtn.backgroundColor = .black
                } else {
                    saveBtn.backgroundColor = .lightGray
                }
            }
            
            DispatchQueue.main.async {
                self.colorLabel.text = self.vm.selectColorName
            }
        }
    }
    
    private func selectButtonForColorCode() {
        if let index = vm.colors.firstIndex(where: { $0.code == vm.selectColorCode }) {
            let selectedButton = colorButtons[index]
            updateButtonSelection(selectedButton: selectedButton)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func fetchEditTarget() {
        guard let result = vm.fetchCategory(name: vm.originCategoryName, color: vm.originSelectColor) else {
            print("맞는 카테고리정보가 없습니다")
            return
        }
        categoryTextField.text = result.name
        vm.originCategoryName = result.name
        vm.originSelectColor = result.color
        updateColorSelection(for: result.color)
    }
    
    private func updateColorSelection(for colorCode: String) {
        if let index = vm.colors.firstIndex(where: { $0.code == colorCode }) {
            let selectedButton = colorButtons[index]
            let selectedColorName = vm.colors[index].name
            let selectedColorCode = vm.colors[index].code
            
            updateButtonSelection(selectedButton: selectedButton)
            self.vm.selectColorName = selectedColorName
            self.vm.selectColorCode = selectedColorCode
            
            DispatchQueue.main.async {
                self.colorLabel.text = selectedColorName
            }
        }
    }
    
    private func popUpWarning(_ ment: String) {
        guard let warningVC = self.storyboard?.instantiateViewController(identifier: "WarningVC") as? WarningVC else {return}
        warningVC.warningLabelText = ment
        warningVC.modalPresentationStyle = .overCurrentContext
        present(warningVC, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func tapColorButton(_ sender: UIButton) {
        updateButtonSelection(selectedButton: sender)
    }
    
    @IBAction func tapSaveBtn(_ sender: UIButton) {
        guard let categoryName = self.categoryTextField.text , !categoryName.isEmpty else {
            popUpWarning("카테고리를 작성해 주세요")
            return
        }
        
        guard let selectColor = self.vm.selectColorCode, !selectColor.isEmpty else {
            popUpWarning("색상을 선택해 주세요")
            return
        }
        
        if vm.isAddMode == true {
            if vm.isCategoryNameExists(categoryName: categoryName) {
                popUpWarning("이미 사용 중인 카테고리 이름입니다")
                return
            }
            
            if vm.isColorExists(selectColor: selectColor) {
                popUpWarning("이미 사용 중인 색상입니다")
                return
            }
            
            vm.saveCategory(categoryName: categoryName, selectColor: selectColor)
            vm.addForSelectCategoryVCDelegate?.updateCategory()
            dismiss(animated: true)
            return
        }
        
        if vm.isEditMode == true {
            let isNameChanged = categoryName != vm.originCategoryName
            let isColorChanged = selectColor != vm.originSelectColor
            
            let isNameExists = isNameChanged && vm.isCategoryNameExists(categoryName: categoryName)
            let isColorExists = isColorChanged && vm.isColorExists(selectColor: selectColor)
            
            if isNameExists && isColorExists {
                popUpWarning("중복된 조합입니다")
                return
            } else if isNameExists {
                popUpWarning("이미 사용 중인 카테고리 이름입니다.")
                return
            } else if isColorExists {
                popUpWarning("이미 사용 중인 색상입니다")
                return
            }
            
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Category")
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "name == %@", vm.originCategoryName ?? ""),
                NSPredicate(format: "color == %@", vm.originSelectColor ?? "")
            ])
            
            do {
                let fetchResults = try vm.coreDataManager.context.fetch(fetchRequest)
                if let target = fetchResults.first as? NSManagedObject {
                    if isNameChanged {
                        target.setValue(categoryName, forKey: "name")
                    }
                    if isColorChanged {
                        target.setValue(selectColor, forKey: "color")
                    }
                    
                    try vm.coreDataManager.context.save()
                    vm.delegate?.didUpdateCategory()
                    navigationController?.popViewController(animated: true)
                } else {
                    showAlert(title: "오류", message: "수정할 카테고리를 찾을 수 없습니다.")
                }
            } catch {
                
            }
            
        } else {
            
            if vm.isCategoryNameExists(categoryName: categoryName) {
                popUpWarning("이미 사용 중인 카테고리 이름입니다")
                return
            }
            
            if vm.isColorExists(selectColor: selectColor) {
                popUpWarning("이미 사용 중인 색상입니다")
                return
            }
            
            vm.saveCategory(categoryName: categoryName, selectColor: selectColor)
            vm.delegate?.didUpdateCategory()
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func tapDeleteBtn(_ sender: UIBarButtonItem) {
        guard let editCategory_DeleteVC = self.storyboard?.instantiateViewController(identifier: "EditCategory_DeleteVC") as? EditCategory_DeleteVC else { return }
        
        editCategory_DeleteVC.vm.categoryName = vm.originCategoryName
        editCategory_DeleteVC.vm.selectColor = vm.originSelectColor
        editCategory_DeleteVC.modalPresentationStyle = .overCurrentContext
        present(editCategory_DeleteVC, animated: true)
    }
    
}

//MARK: - TextField 관련
extension EditCategoryVC: UITextFieldDelegate {
    
    @objc func textFieldDidChange(_ sender: Any?) {
        if categoryTextField.text != vm.originCategoryName || vm.originSelectColor != vm.selectColorCode {
            vm.categoryName = categoryTextField.text
            DispatchQueue.main.async {
                self.saveBtn.backgroundColor = .black
            }
        } else {
            DispatchQueue.main.async {
                self.saveBtn.backgroundColor = .lightGray
            }
        }
    }
    
}
