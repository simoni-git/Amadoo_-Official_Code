//
//  EditMemoCheckVer_WarningVC.swift
//  NewCalendar
//
//  Created by 시모니 on 12/6/24.
//

import UIKit

class EditMemoCheckVer_WarningVC: UIViewController {
    
    var vm = EditMemoCheckVer_WarningVM()
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var mentLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var okBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DIContainer.shared.injectEditMemoCheckVer_WarningVM(vm)
        configure()

    }
    
    private func configure() {
        subView.layer.cornerRadius = 10
        okBtn.layer.cornerRadius = 10
    }
    
    @IBAction func tapOkBtn(_ sender: UIButton) {
        guard let title = vm.titleText, let name = textField.text, !name.isEmpty else {
            return
        }
        // UseCase를 통한 체크리스트 항목 저장
        if let result = vm.saveCheckListUsingUseCase(title: title, name: name, isComplete: false) {
            switch result {
            case .success:
                vm.delegate?.didSaveMemoItem()
                dismiss(animated: true, completion: nil)
            case .failure:
                break
            }
        }
    }
 
}
