//
//  EditCategory_DeleteVC.swift
//  NewCalendar
//
//  Created by 시모니 on 11/18/24.
//

import UIKit

class CategoryDeletePopupVC: UIViewController {

    var vm: CategoryDeletePopupVM!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()

    }
    
    private func configure() {
        subView.layer.cornerRadius = 10
        cancelBtn.layer.cornerRadius = 10
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = UIColor.black.cgColor
        deleteBtn.layer.cornerRadius = 10
        
    }

    @IBAction func tapCancelBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func tapDeleteBtn(_ sender: UIButton) {
        guard vm.categoryName != nil, vm.selectColor != nil else {
            print("Error: 카테고리 이름 또는 색상 코드가 없습니다.")
            return
        }

        // UseCase를 통한 삭제
        if let result = vm.deleteCategoryUsingUseCase() {
            switch result {
            case .success:
                print("카테고리 삭제 완료")
            case .failure(let error):
                print("카테고리 삭제 실패: \(error)")
            }
        }

        NotificationCenter.default.post(name: NSNotification.Name("DeleteCategory"), object: nil)
        dismiss(animated: true)
    }
    
}
