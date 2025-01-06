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
    
    var context: NSManagedObjectContext {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }
        return app.persistentContainer.viewContext
    }
    
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
    
    var delegate: EditCategoryVCDelegate?
    var addForSelectCategoryVCDelegate: AddForSelectCategoryVCDelegate?
    var selectColor: String? = ""
    var selectColorLabel: String?
    var categoryName: String? = ""
    var originCategoryName: String?
    var originSelectColor: String?
    var isEditMode: Bool = false
    var isAddMode: Bool = false
    var colorButtons: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.categoryTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        configure()
        initializeColorButtons()
        if isEditMode == true {
            saveBtn.backgroundColor = .lightGray
            fetchEditTarget()
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func configure() {
        subView.layer.cornerRadius = 10
        saveBtn.layer.cornerRadius = 10
        let buttons = [colorBtn1, colorBtn2, colorBtn3, colorBtn4, colorBtn5, colorBtn6, colorBtn7, colorBtn8]
        buttons.forEach { $0?.layer.cornerRadius = 10 }
    }
    
    private func initializeColorButtons() {
        colorButtons = [colorBtn1, colorBtn2, colorBtn3, colorBtn4, colorBtn5, colorBtn6, colorBtn7, colorBtn8]
        colorButtons.forEach { $0.alpha = 0.1 }
    }
    
    private func updateButtonSelection(selectedButton: UIButton) {
        colorButtons.forEach { $0.alpha = 0.1 }
        selectedButton.alpha = 1.0
        
        let colors = [
            (name: "프렌치로즈", code: "ECBDBF"),
            (name: "라이트오렌지", code: "FFB124"),
            (name: "머스타드옐로우", code: "DBC557"),
            (name: "에메랄드그린", code: "8FBC91"),
            (name: "스카이블루", code: "A5CBF0"),
            (name: "다크블루", code: "446592"),
            (name: "소프트바이올렛", code: "A495C6"),
            (name: "파스텔브라운", code: "BBA79C")
        ]
        
        if let index = colorButtons.firstIndex(of: selectedButton) {
            selectColorLabel = colors[index].name
            selectColor = colors[index].code
            
            if isEditMode == true {
                if originSelectColor != selectColor {
                    saveBtn.backgroundColor = .black
                } else {
                    saveBtn.backgroundColor = .lightGray
                }
            }
            
            DispatchQueue.main.async {
                self.colorLabel.text = self.selectColorLabel
            }
        }
    }
    
    private func selectButtonForColorCode() {
        let colors = [
            (name: "프렌치로즈", code: "ECBDBF"),
            (name: "라이트오렌지", code: "FFB124"),
            (name: "머스타드옐로우", code: "DBC557"),
            (name: "에메랄드그린", code: "8FBC91"),
            (name: "스카이블루", code: "A5CBF0"),
            (name: "다크블루", code: "446592"),
            (name: "소프트바이올렛", code: "A495C6"),
            (name: "파스텔브라운", code: "BBA79C")
        ]
        
        if let index = colors.firstIndex(where: { $0.code == selectColor }) {
            let selectedButton = colorButtons[index]
            updateButtonSelection(selectedButton: selectedButton)
        }
    }
    
    private func saveCategory(categoryName: String, selectColor: String) {
        let entity = NSEntityDescription.entity(forEntityName: "Category", in: context)
        let newCategory = NSManagedObject(entity: entity!, insertInto: context)
        newCategory.setValue(categoryName, forKey: "name")
        newCategory.setValue(selectColor, forKey: "color")
        newCategory.setValue(false, forKey: "isDefault")
        saveContext()
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func fetchEditTarget() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Category")
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "name == %@", originCategoryName ?? ""),
            NSPredicate(format: "color == %@", originSelectColor ?? ""),
        ])
        
        do {
            let fetchResults = try context.fetch(fetchRequest)
            
            if let target = fetchResults.first as? NSManagedObject {
                if let name = target.value(forKey: "name") as? String {
                    categoryTextField.text = name
                    originCategoryName = name
                }
                
                if let colorCode = target.value(forKey: "color") as? String {
                    originSelectColor = colorCode
                    updateColorSelection(for: colorCode)
                }
            } else {
                
            }
        } catch {
            
        }
    }
    
    private func updateColorSelection(for colorCode: String) {
        let colors = [
            (name: "프렌치로즈", code: "ECBDBF"),
            (name: "라이트오렌지", code: "FFB124"),
            (name: "머스타드옐로우", code: "DBC557"),
            (name: "에메랄드그린", code: "8FBC91"),
            (name: "스카이블루", code: "A5CBF0"),
            (name: "다크블루", code: "446592"),
            (name: "소프트바이올렛", code: "A495C6"),
            (name: "파스텔브라운", code: "BBA79C")
        ]
        
        if let index = colors.firstIndex(where: { $0.code == colorCode }) {
            let selectedButton = colorButtons[index]
            let selectedColorName = colors[index].name
            let selectedColorCode = colors[index].code
            
            updateButtonSelection(selectedButton: selectedButton)
            DispatchQueue.main.async {
                self.colorLabel.text = selectedColorName
                self.selectColorLabel = selectedColorName
                self.selectColor = selectedColorCode
            }
        }
    }
    
    private func isCategoryNameExists(categoryName: String) -> Bool {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Category")
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "name == %@", categoryName),
            NSPredicate(format: "name != %@", originCategoryName ?? "")
        ])
        
        do {
            let fetchResults = try context.fetch(fetchRequest)
            return !fetchResults.isEmpty
        } catch {
            
            return false
        }
    }
    
    private func isColorExists(selectColor: String) -> Bool {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Category")
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "color == %@", selectColor),
            NSPredicate(format: "color != %@", originSelectColor ?? "")
        ])
        
        do {
            let fetchResults = try context.fetch(fetchRequest)
            return !fetchResults.isEmpty
        } catch {
            
            return false
        }
    }
    
    private func popUpWarning(_ ment: String) {
        guard let warningVC = self.storyboard?.instantiateViewController(identifier: "WarningVC") as? WarningVC else {return}
        warningVC.warningLabelText = ment
        warningVC.modalPresentationStyle = .overCurrentContext
        present(warningVC, animated: true)
    }
    
    @IBAction func tapColorButton(_ sender: UIButton) {
        updateButtonSelection(selectedButton: sender)
    }
    
    @IBAction func tapSaveBtn(_ sender: UIButton) {
        guard let categoryName = self.categoryTextField.text , !categoryName.isEmpty else {
            popUpWarning("카테고리를 작성해 주세요")
            return
        }
        
        guard let selectColor = self.selectColor, !selectColor.isEmpty else {
            popUpWarning("색상을 선택해 주세요")
            return
        }
        
        if isAddMode == true {
            if isCategoryNameExists(categoryName: categoryName) {
                popUpWarning("이미 사용 중인 카테고리 이름입니다")
                return
            }
            
            if isColorExists(selectColor: selectColor) {
                popUpWarning("이미 사용 중인 색상입니다")
                return
            }
            
            saveCategory(categoryName: categoryName, selectColor: selectColor)
            addForSelectCategoryVCDelegate?.updateCategory()
            dismiss(animated: true)
            return
        }
        
        if isEditMode == true {
            let isNameChanged = categoryName != originCategoryName
            let isColorChanged = selectColor != originSelectColor
            
            let isNameExists = isNameChanged && isCategoryNameExists(categoryName: categoryName)
            let isColorExists = isColorChanged && isColorExists(selectColor: selectColor)
            
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
                NSPredicate(format: "name == %@", originCategoryName ?? ""),
                NSPredicate(format: "color == %@", originSelectColor ?? "")
            ])
            
            do {
                let fetchResults = try context.fetch(fetchRequest)
                if let target = fetchResults.first as? NSManagedObject {
                    if isNameChanged {
                        target.setValue(categoryName, forKey: "name")
                    }
                    if isColorChanged {
                        target.setValue(selectColor, forKey: "color")
                    }
                    
                    try context.save()
                    delegate?.didUpdateCategory()
                    navigationController?.popViewController(animated: true)
                } else {
                    showAlert(title: "오류", message: "수정할 카테고리를 찾을 수 없습니다.")
                }
            } catch {
                
            }
            
        } else {
            
            if isCategoryNameExists(categoryName: categoryName) {
                popUpWarning("이미 사용 중인 카테고리 이름입니다")
                return
            }
            
            if isColorExists(selectColor: selectColor) {
                popUpWarning("이미 사용 중인 색상입니다")
                return
            }
            
            saveCategory(categoryName: categoryName, selectColor: selectColor)
            delegate?.didUpdateCategory()
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func tapDeleteBtn(_ sender: UIBarButtonItem) {
        guard let editCategory_DeleteVC = self.storyboard?.instantiateViewController(identifier: "EditCategory_DeleteVC") as? EditCategory_DeleteVC else { return }
        
        editCategory_DeleteVC.categoryName = originCategoryName
        editCategory_DeleteVC.selectColor = originSelectColor
        editCategory_DeleteVC.modalPresentationStyle = .overCurrentContext
        present(editCategory_DeleteVC, animated: true)
    }
    
}

//MARK: - TextField 관련
extension EditCategoryVC: UITextFieldDelegate {
    
    @objc func textFieldDidChange(_ sender: Any?) {
        if categoryTextField.text != originCategoryName || originSelectColor != selectColor {
            categoryName = categoryTextField.text
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
