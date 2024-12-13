//
//  MemoCheckVerDetail_Cell.swift
//  NewCalendar
//
//  Created by 시모니 on 12/6/24.
//

import UIKit

class MemoCheckVerDetail_Cell: UITableViewCell {
    
    @IBOutlet weak var completeBtn: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    func configureButton(isComplete: Bool) {
        if isComplete {
            completeBtn.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
            DispatchQueue.main.async {
                self.nameLabel.textColor = .gray
            }
        } else {
            completeBtn.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
            DispatchQueue.main.async {
                self.nameLabel.textColor = .black
            }
        }
    }
    
}
