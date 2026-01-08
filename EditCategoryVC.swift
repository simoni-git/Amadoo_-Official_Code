//
//  EditCategoryVC.swift
//  NewCalendar
//
//  Created by 시모니 on 11/18/24.
//

import UIKit

protocol EditCategoryVCDelegate: AnyObject {
    func didUpdateCategory()
}

protocol AddForSelectCategoryVCDelegate: AnyObject {
    func updateCategory()
}

class EditCategoryVC: UIViewController {

    var vm: EditCategoryVM!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var subView: UIView!
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
        setupTextField()
        setupGestures()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(categoryDeleted),
            name: NSNotification.Name("DeleteCategory"),
            object: nil
        )
    }
    // MARK: - Setup
    
    private func configure() {
        configureUI()
        initializeColorButtons()
        
        if vm.isEditMode == true {
            saveBtn.backgroundColor = .lightGray
            fetchEditTarget()
        }
    }
    
    private func configureUI() {
        subView.applyStandardCornerRadius()
        saveBtn.applyStandardCornerRadius()
        [colorBtn1, colorBtn2, colorBtn3, colorBtn4, colorBtn5, colorBtn6, colorBtn7, colorBtn8]
            .forEach { $0?.applyStandardCornerRadius() }
    }
    
    private func setupTextField() {
        categoryTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Color Button Management
    private func initializeColorButtons() {
        colorButtons = [colorBtn1, colorBtn2, colorBtn3, colorBtn4, colorBtn5, colorBtn6, colorBtn7, colorBtn8]
        colorButtons.forEach { $0.alpha = 0.1 }
    }
    
    private func updateButtonSelection(selectedButton: UIButton) {
        colorButtons.forEach { $0.alpha = 0.1 }
        selectedButton.alpha = 1.0
        
        guard let index = colorButtons.firstIndex(of: selectedButton) else { return }
        
        vm.selectColorName = vm.colors[index].name
        vm.selectColorCode = vm.colors[index].code
        
        updateSaveButtonState()
    }
    
    // MARK: - Edit Mode
    private func fetchEditTarget() {
        // 이미 originCategoryName과 originSelectColor가 설정된 상태로 호출됨
        guard let name = vm.originCategoryName, let color = vm.originSelectColor else {
            print("맞는 카테고리 정보가 없습니다")
            return
        }

        categoryTextField.text = name
        updateColorSelection(for: color)
    }
    
    // MARK: - State Management
    private func updateSaveButtonState() {
        let hasChanges = hasAnyChanges()
        saveBtn.backgroundColor = hasChanges ? .black : .lightGray
    }
    
    private func hasAnyChanges() -> Bool {
        guard vm.isEditMode == true else { return true }
        
        let nameChanged = categoryTextField.text != vm.originCategoryName
        let colorChanged = vm.selectColorCode != vm.originSelectColor
        
        return nameChanged || colorChanged
    }
    
    // MARK: - Validation
    private func validateInput() -> (isValid: Bool, message: String?) {
        guard let categoryName = categoryTextField.text, !categoryName.isEmpty else {
            return (false, "카테고리를 작성해 주세요")
        }
        
        guard let selectColor = vm.selectColorCode, !selectColor.isEmpty else {
            return (false, "색상을 선택해 주세요")
        }
        
        if vm.isEditMode == true {
            return validateEditMode(categoryName: categoryName, selectColor: selectColor)
        } else {
            return validateAddMode(categoryName: categoryName, selectColor: selectColor)
        }
    }
    
    private func validateAddMode(categoryName: String, selectColor: String) -> (Bool, String?) {
        if vm.isCategoryNameExists(categoryName: categoryName) {
            return (false, "이미 사용 중인 카테고리 이름입니다")
        }
        
        if vm.isColorExists(selectColor: selectColor) {
            return (false, "이미 사용 중인 색상입니다")
        }
        
        return (true, nil)
    }
    
    private func validateEditMode(categoryName: String, selectColor: String) -> (Bool, String?) {
        let isNameChanged = categoryName != vm.originCategoryName
        let isColorChanged = selectColor != vm.originSelectColor
        
        let isNameExists = isNameChanged && vm.isCategoryNameExists(categoryName: categoryName)
        let isColorExists = isColorChanged && vm.isColorExists(selectColor: selectColor)
        
        if isNameExists && isColorExists {
            return (false, "중복된 조합입니다")
        } else if isNameExists {
            return (false, "이미 사용 중인 카테고리 이름입니다.")
        } else if isColorExists {
            return (false, "이미 사용 중인 색상입니다")
        }
        
        return (true, nil)
    }
    
    // MARK: - Save Actions
    private func performSave(categoryName: String, selectColor: String) {
        if vm.isAddMode == true {
            saveNewCategory(categoryName: categoryName, selectColor: selectColor)
        } else if vm.isEditMode == true {
            updateCategory(categoryName: categoryName, selectColor: selectColor)
        } else {
            saveNewCategory(categoryName: categoryName, selectColor: selectColor)
        }
    }
    
    private func saveNewCategory(categoryName: String, selectColor: String) {
        // UseCase를 통한 카테고리 저장
        let result = vm.saveCategoryUsingUseCase(name: categoryName, color: selectColor)
        switch result {
        case .success:
            if vm.isAddMode == true {
                vm.addForSelectCategoryVCDelegate?.updateCategory()
                dismiss(animated: true)
            } else {
                vm.delegate?.didUpdateCategory()
                navigationController?.popViewController(animated: true)
            }
        case .failure:
            showAlert(title: "오류", message: "저장 중 오류가 발생했습니다.")
        }
    }

    private func updateCategory(categoryName: String, selectColor: String) {
        // UseCase를 통한 카테고리 수정
        let result = vm.updateCategoryUsingUseCase(name: categoryName, color: selectColor)
        switch result {
        case .success:
            vm.delegate?.didUpdateCategory()
            navigationController?.popViewController(animated: true)
        case .failure:
            showAlert(title: "오류", message: "저장 중 오류가 발생했습니다.")
        }
    }
    
    // MARK: - UI Helpers
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    // popUpWarning 메서드 제거 - UIViewController+Alert extension의 presentWarning 사용

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    private func updateColorSelection(for colorCode: String) {
        guard let index = vm.colors.firstIndex(where: { $0.code == colorCode }) else { return }
        
        let selectedButton = colorButtons[index]
        updateButtonSelection(selectedButton: selectedButton)
    }
    
    private func selectButtonForColorCode() {
        if let index = vm.colors.firstIndex(where: { $0.code == vm.selectColorCode }) {
            let selectedButton = colorButtons[index]
            updateButtonSelection(selectedButton: selectedButton)
        }
    }
    // MARK: - Actions
    @IBAction func tapColorButton(_ sender: UIButton) {
        updateButtonSelection(selectedButton: sender)
    }
    
    @IBAction func tapSaveBtn(_ sender: UIButton) {
        let validation = validateInput()
        
        guard validation.isValid else {
            if let message = validation.message {
                presentWarning(message)
            }
            return
        }
        
        guard let categoryName = categoryTextField.text,
              let selectColor = vm.selectColorCode else { return }
        
        performSave(categoryName: categoryName, selectColor: selectColor)
    }
    
    @IBAction func tapDeleteBtn(_ sender: UIBarButtonItem) {
        guard let editCategory_DeleteVC = self.storyboard?.instantiateViewController(identifier: "CategoryDeletePopupVC") as? CategoryDeletePopupVC else { return }

        editCategory_DeleteVC.vm = DIContainer.shared.makeCategoryDeletePopupVM()
        editCategory_DeleteVC.vm.categoryName = vm.originCategoryName
        editCategory_DeleteVC.vm.selectColor = vm.originSelectColor
        editCategory_DeleteVC.modalPresentationStyle = .overCurrentContext
        present(editCategory_DeleteVC, animated: true)
    }
    
    //MARK: - @objc
  
    @objc private func categoryDeleted() {
        navigationController?.popViewController(animated: true)
    }

   
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - TextField 관련
extension EditCategoryVC: UITextFieldDelegate {
    @objc func textFieldDidChange(_ sender: Any?) {
        vm.categoryName = categoryTextField.text
        updateSaveButtonState()
    }
    
}
