//
//  MemoDefaultVerDetailVC.swift
//  NewCalendar
//
//  Created by 시모니 on 12/7/24.
//

import UIKit

class MemoDefaultVerDetailVC: UIViewController {

    var vm: MemoDefaultVerDetailVM!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var editBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()

    }
    
    private func configure() {
        if let title = vm.memoItem?.title {
            titleLabel.text = "제목: \(title)"
        } else {
            titleLabel.text = "제목 없음"
        }
        editBtn.layer.cornerRadius = 10
        memoTextView.text = vm.memoItem?.memoText ?? "메모 내용 없음"
        memoTextView.isEditable = false  // 편집 불가능
        memoTextView.isSelectable = true  // 선택 가능 (복사 등을 위해)
        memoTextView.layer.cornerRadius = 10
    }

    @IBAction func tapEditBtn(_ sender: UIButton) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "AddDefaultVerMemoVC") as? AddDefaultVerMemoVC else { return }
        nextVC.vm = DIContainer.shared.makeAddDefaultVerMemoVM()
        nextVC.vm.editModeTitleTextFieldText = vm.memoItem?.title ?? "제목없음"
        nextVC.vm.editModeMemoTextViewText = vm.memoItem?.memoText ?? "내용없음"
        nextVC.vm.isEditMode = true
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
}
