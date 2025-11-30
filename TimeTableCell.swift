//
//  TimeTableCell.swift
//  NewCalendar
//
//  Created by 시모니의 맥북 on 11/24/25.
//

import UIKit

class TimeTableCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
           super.awakeFromNib()
           titleLabel.numberOfLines = 0
           titleLabel.adjustsFontSizeToFitWidth = true
           titleLabel.minimumScaleFactor = 0.7
       }
    
}
