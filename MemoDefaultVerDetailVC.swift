//
//  MemoDefaultVerDetailVC.swift
//  NewCalendar
//
//  Created by 시모니 on 12/7/24.
//

import UIKit

class MemoDefaultVerDetailVC: UIViewController {
    
    var vm = MemoDefaultVerDetailVM()
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var editBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
    }
    
    private func configure() {
        if let title = vm.item?.title {
            titleLabel.text = "제목: \(title)"
        } else {
            titleLabel.text = "제목 없음"
        }
        editBtn.layer.cornerRadius = 10
        memoLabel.text = vm.item?.memoText ?? "메모 내용 없음"
    }
    
    @IBAction func tapEditBtn(_ sender: UIButton) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "AddDefaultVerMemoVC") as? AddDefaultVerMemoVC else { return }
        nextVC.vm.editModeTitleTextFieldText = vm.item?.title ?? "제목없음"
        nextVC.vm.editModeMemoTextViewText = vm.item?.memoText ?? "내용없음"
        nextVC.vm.isEditMode = true
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
}
