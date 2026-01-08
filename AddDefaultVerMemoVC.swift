//
//  AddDefaultVerMemoVC.swift
//  NewCalendar
//
//  Created by 시모니 on 12/6/24.
//

import UIKit

class AddDefaultVerMemoVC: UIViewController {
    
    var vm = AddDefaultVerMemoVM()
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var memoTextViewHeightConstraint: NSLayoutConstraint!
    
    private let halfScreenHeight = UIScreen.main.bounds.height / 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DIContainer.shared.injectAddDefaultVerMemoVM(vm)
        configure()
        setupKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardNotifications()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
        
    }
    
    private func configure() {
        titleTextField.layer.cornerRadius = 10
        memoTextView.layer.cornerRadius = 10
        registerBtn.layer.cornerRadius = 10
        memoTextViewHeightConstraint.constant = halfScreenHeight
        memoTextView.delegate = self
        
        if vm.isEditMode == true {
            DispatchQueue.main.async { [weak self] in
                self?.titleTextField.text = self?.vm.editModeTitleTextFieldText
                self?.memoTextView.text = self?.vm.editModeMemoTextViewText
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // 키보드 노티피케이션 설정
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // 키보드 노티피케이션 제거
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // 키보드가 올라올 때
    @objc private func keyboardWillShow(_ notification: Notification) {
        // memoTextView가 first responder일 때만 화면 이동
        guard memoTextView.isFirstResponder else { return }
        
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        let memoTextViewBottom = memoTextView.frame.origin.y + memoTextView.frame.height
        let visibleHeight = view.frame.height - keyboardHeight
        
        // 텍스트뷰 하단이 키보드에 가려지는 경우
        if memoTextViewBottom > visibleHeight {
            let overlap = memoTextViewBottom - visibleHeight + 20 // 20은 여유 공간
            
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = -overlap
            }
        }
    }
    
    // 키보드가 내려갈 때
    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }

    // popUpWarning 메서드 제거 - UIViewController+Alert extension의 presentWarning 사용

    @IBAction func tapRegisterBtn(_ sender: UIButton) {
        if vm.isEditMode == false {
            guard let title = titleTextField.text, let memoText = memoTextView.text, !title.isEmpty && !memoText.isEmpty else {
                presentWarning("제목과 메모글을 모두 작성해 주세요")
                return
            }
            // UseCase를 통한 메모 저장
            if let result = vm.saveMemoUsingUseCase(title: title, memoText: memoText) {
                switch result {
                case .success:
                    vm.delegate?.didSaveDefaultVerMemoItems()
                    navigationController?.popViewController(animated: true)
                case .failure:
                    presentWarning("저장에 실패했습니다.")
                }
            }
        } else {
            guard let editTitle = vm.editModeTitleTextFieldText,
                  let editMemoText = vm.editModeMemoTextViewText,
                  let title = titleTextField.text,
                  let memoText = memoTextView.text else {
                return
            }

            if editTitle != title || editMemoText != memoText {
                // UseCase를 통한 메모 수정
                if let result = vm.updateMemoUsingUseCase(title: title, memoText: memoText) {
                    switch result {
                    case .success:
                        vm.delegate?.didSaveDefaultVerMemoItems()
                        navigationController?.popToRootViewController(animated: true)
                    case .failure:
                        presentWarning("편집할 메모를 찾을 수 없습니다.")
                    }
                }
            } else {
                presentWarning("변경된 부분이 없는 것 같아요")
            }
        }
    }
    
}

// MARK: - UITextViewDelegate
extension AddDefaultVerMemoVC: UITextViewDelegate {
    
}
