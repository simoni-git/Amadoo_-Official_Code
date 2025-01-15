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
        vm.checkListSetValue(title: title, name: name, isComplete: false, memoType: vm.memoType)
        vm.coreDataManager.saveContext()
        vm.delegate?.didSaveMemoItem()
        dismiss(animated: true, completion: nil)
    }
 
}
