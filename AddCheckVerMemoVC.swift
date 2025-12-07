//
//  AddCheckVerMeomVC.swift
//  NewCalendar
//
//  Created by 시모니 on 12/5/24.
//

import UIKit

class AddCheckVerMemoVC: UIViewController {
    
    var vm = AddCheckVerMemoVM()
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    private var activeTextFieldIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        titleTextField.delegate = self
        saveBtn.layer.cornerRadius = 10
        tableView.layer.cornerRadius = 10
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        // 키보드 노티피케이션 등록
        setupKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardNotifications()
    }
    
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
    
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let activeIndexPath = activeTextFieldIndexPath,
              let cell = tableView.cellForRow(at: activeIndexPath) as? AddCheckVerMemo_Cell,
              let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        
        // 활성화된 텍스트필드의 위치 계산
        let textFieldFrame = cell.textField.convert(cell.textField.bounds, to: view)
        let textFieldBottom = textFieldFrame.origin.y + textFieldFrame.height
        
        // 키보드에 가려지는 부분 계산
        let visibleHeight = view.frame.height - keyboardHeight
        
        if textFieldBottom > visibleHeight {
            let overlap = textFieldBottom - visibleHeight + 20 // 20은 여유 공간
            
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = -overlap
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // popUpWarning 메서드 제거 - UIViewController+Alert extension의 presentWarning 사용

    @IBAction func tapAddItem(_ sender: UIButton) {
        vm.checkListItems.append("")
        tableView.reloadData()
        // 새 셀이 추가되면 스크롤을 마지막으로 이동
        DispatchQueue.main.async {
            let lastIndexPath = IndexPath(row: self.vm.checkListItems.count - 1, section: 0)
            self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
        }
    }
    
    @IBAction func tapSaveBtn(_ sender: UIButton) {
        guard let title = titleTextField.text, !title.isEmpty else {
            presentWarning("제목이 비어있네요")
            return
        }
        
        for (_, cell) in tableView.visibleCells.enumerated() {
            guard let customCell = cell as? AddCheckVerMemo_Cell,
                  let name = customCell.textField.text, !name.isEmpty else {
                presentWarning("리스트에 빈칸을 모두 채워주세요")
                return
            }
            vm.checkListSetValue(title: title, name: name, isComplete: false, memoType: vm.memoType)
        }
        
        vm.coreDataManager.saveContext()
        vm.delegate?.didSaveCheckVerMemoItems()
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - 키보드 관련
extension AddCheckVerMemoVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // 셀 안의 텍스트필드인 경우 IndexPath 찾기
        if let cell = textField.superview?.superview as? AddCheckVerMemo_Cell,
           let indexPath = tableView.indexPath(for: cell) {
            activeTextFieldIndexPath = indexPath
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextFieldIndexPath = nil
    }
}

//MARK: - TableView 관련
extension AddCheckVerMemoVC: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.checkListItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddCheckVerMemo_Cell" ) as? AddCheckVerMemo_Cell else {
            return UITableViewCell()
        }
        // 셀의 텍스트필드 delegate 설정
        cell.textField.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            vm.checkListItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "삭제"
    }
    
}
