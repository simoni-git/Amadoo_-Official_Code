//
//  AddCheckVerMeomVC.swift
//  NewCalendar
//
//  Created by 시모니 on 12/5/24.
//

import UIKit
import CoreData

class AddCheckVerMemoVC: UIViewController {
    
    var context: NSManagedObjectContext {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }
        return app.persistentContainer.viewContext
    }
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: AddCheckVerMemoDelegate?
    var memoType: String = "check"
    var checkListItems: [String] = [""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        saveBtn.layer.cornerRadius = 10
        titleTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
        
    }
    
    private func popUpWarning(_ ment: String) {
        guard let warningVC = self.storyboard?.instantiateViewController(identifier: "WarningVC") as? WarningVC else {return}
        warningVC.warningLabelText = ment
        warningVC.modalPresentationStyle = .overCurrentContext
        present(warningVC, animated: true)
    }
    
    @IBAction func tapAddItem(_ sender: UIButton) {
        checkListItems.append("")
        tableView.reloadData()
    }
    
    
    @IBAction func tapSaveBtn(_ sender: UIButton) {
        guard let title = titleTextField.text, !title.isEmpty else {
            popUpWarning("제목이 비어있네요")
            return
        }
        
        for (_, cell) in tableView.visibleCells.enumerated() {
            guard let customCell = cell as? AddCheckVerMemo_Cell,
                  let name = customCell.textField.text, !name.isEmpty else {
                popUpWarning("리스트에 빈칸을 모두 채워주세요")
                return
            }
            
            let newCheckListItem = NSEntityDescription.insertNewObject(forEntityName: "CheckList", into: context)
            newCheckListItem.setValue(title, forKey: "title")
            newCheckListItem.setValue(name, forKey: "name")
            newCheckListItem.setValue(false, forKey: "isComplete")
            newCheckListItem.setValue(memoType, forKey: "memoType")
        }
        
        saveContext()
        delegate?.didSaveCheckVerMemoItems()
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - CoreData 저장 관련
    private func saveContext() {
        do {
            try context.save()
        } catch {
            
        }
    }
    
}

//MARK: - 키보드관련
extension AddCheckVerMemoVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

//MARK: - TableView 관련
extension AddCheckVerMemoVC: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkListItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddCheckVerMemo_Cell" ) as? AddCheckVerMemo_Cell else {
            return UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            checkListItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "삭제"
    }
    
}
