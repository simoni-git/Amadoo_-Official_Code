//
//  MemoDefaultVerDetailVC.swift
//  NewCalendar
//
//  Created by 시모니 on 12/7/24.
//

import UIKit

class MemoDefaultVerDetailVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    var items: Memo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let item = items {
            configure(with: item)
        }
        editBtn.layer.cornerRadius = 10
    }
    
    private func configure(with item: Memo) {
        if let title = item.title {
            titleLabel.text = "제목: \(title)"
        } else {
            titleLabel.text = "제목 없음"
        }
        editBtn.layer.cornerRadius = 10
        memoLabel.text = item.memoText ?? "메모 내용 없음"
    }
    
    @IBAction func tapEditBtn(_ sender: UIButton) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "AddDefaultVerMemoVC") as? AddDefaultVerMemoVC else { return }
        nextVC.editModeTitleTextFieldText = items?.title ?? "제목없음"
        nextVC.editModeMemoTextViewText = items?.memoText ?? "내용없음"
        nextVC.isEditMode = true
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
}
