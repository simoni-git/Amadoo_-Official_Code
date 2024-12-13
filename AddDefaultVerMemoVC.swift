//
//  AddDefaultVerMemoVC.swift
//  NewCalendar
//
//  Created by 시모니 on 12/6/24.
//

import UIKit
import CoreData

class AddDefaultVerMemoVC: UIViewController {
    
    var context: NSManagedObjectContext {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }
        return app.persistentContainer.viewContext
    }
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var registerBtn: UIButton!
    var memoType: String = "default"
    var delegate: AddDefaultVerMemoDelegate?
    
    var editModeTitleTextFieldText: String?
    var editModeMemoTextViewText: String?
    var isEditMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        if isEditMode == true {
            titleTextField.text = editModeTitleTextFieldText
            memoTextView.text = editModeMemoTextViewText
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
        
    }
    
    private func configure() {
        titleTextField.layer.cornerRadius = 10
        memoTextView.layer.cornerRadius = 10
        registerBtn.layer.cornerRadius = 10
    }
    
    private func popUpWarning(_ ment: String) {
        guard let warningVC = self.storyboard?.instantiateViewController(identifier: "WarningVC") as? WarningVC else {return}
        warningVC.warningLabelText = ment
        warningVC.modalPresentationStyle = .overCurrentContext
        present(warningVC, animated: true)
    }
    
    @IBAction func tapRegisterBtn(_ sender: UIButton) {
        if isEditMode == false {
            guard let title = titleTextField.text , let memoText = memoTextView.text , !title.isEmpty && !memoText.isEmpty else {
                popUpWarning("제목과 메모글을 모두 작성해 주세요")
                return
            }
            
            let newMemoItem = NSEntityDescription.insertNewObject(forEntityName: "Memo", into: context)
            newMemoItem.setValue(title, forKey: "title")
            newMemoItem.setValue(memoText, forKey: "memoText")
            newMemoItem.setValue(memoType, forKey: "memoType")
            saveContext()
            delegate?.didSaveDefaultVerMemoItems()
            navigationController?.popViewController(animated: true)
            
        } else {
            guard let editTitle = editModeTitleTextFieldText,
                  let editMemoText = editModeMemoTextViewText,
                  let title = titleTextField.text,
                  let memoText = memoTextView.text else {
                return
            }
            
            if editTitle != title || editMemoText != memoText {
                let fetchRequest: NSFetchRequest<Memo> = Memo.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "title == %@ AND memoText == %@", editTitle, editMemoText)
                
                do {
                    let result = try context.fetch(fetchRequest)
                    if let memoToEdit = result.first {
                        memoToEdit.title = title
                        memoToEdit.memoText = memoText
                        saveContext()
                        delegate?.didSaveDefaultVerMemoItems()
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
    
    // MARK: - CoreData 관련
    private func saveContext() {
        do {
            try context.save()
        } catch {
            
        }
    }
    
}
