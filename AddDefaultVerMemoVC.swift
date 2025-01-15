//
//  AddDefaultVerMemoVC.swift
//  NewCalendar
//
//  Created by 시모니 on 12/6/24.
//

import UIKit
import CoreData

class AddDefaultVerMemoVC: UIViewController {
 
    var vm = AddDefaultVerMemoVM()
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var registerBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
        
    }
    
    private func configure() {
        titleTextField.layer.cornerRadius = 10
        memoTextView.layer.cornerRadius = 10
        registerBtn.layer.cornerRadius = 10
        if vm.isEditMode == true {
            DispatchQueue.main.async { [weak self] in
                self?.titleTextField.text = self?.vm.editModeTitleTextFieldText
                self?.memoTextView.text = self?.vm.editModeMemoTextViewText
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func popUpWarning(_ ment: String) {
        guard let warningVC = self.storyboard?.instantiateViewController(identifier: "WarningVC") as? WarningVC else {return}
        warningVC.warningLabelText = ment
        warningVC.modalPresentationStyle = .overCurrentContext
        present(warningVC, animated: true)
    }
    
    @IBAction func tapRegisterBtn(_ sender: UIButton) {
        if vm.isEditMode == false {
            guard let title = titleTextField.text , let memoText = memoTextView.text , !title.isEmpty && !memoText.isEmpty else {
                popUpWarning("제목과 메모글을 모두 작성해 주세요")
                return
            }
            vm.memoSetValue(title: title, memoText: memoText, memoType: vm.memoType)
            vm.coreDataManager.saveContext()
            vm.delegate?.didSaveDefaultVerMemoItems()
            navigationController?.popViewController(animated: true)
            
        } else {
            guard let editTitle = vm.editModeTitleTextFieldText,
                  let editMemoText = vm.editModeMemoTextViewText,
                  let title = titleTextField.text,
                  let memoText = memoTextView.text else {
                return
            }
            
            if editTitle != title || editMemoText != memoText {
                let fetchRequest: NSFetchRequest<Memo> = Memo.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "title == %@ AND memoText == %@", editTitle, editMemoText)
                
                do {
                    let result = try vm.coreDataManager.context.fetch(fetchRequest)
                    if let memoToEdit = result.first {
                        memoToEdit.title = title
                        memoToEdit.memoText = memoText
                        vm.coreDataManager.saveContext()
                        vm.delegate?.didSaveDefaultVerMemoItems()
                        navigationController?.popToRootViewController(animated: true)
                        
                    } else {
                        popUpWarning("편집할 메모를 찾을 수 없습니다.")
                    }
                } catch {
                    
                }
            } else {
                popUpWarning("변경된 부분이 없는 것 같아요")
            }
        }
    }
   
}
