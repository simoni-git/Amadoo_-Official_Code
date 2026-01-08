//
//  AddDutyDateCell.swift
//  NewCalendar
//
//  Created by 시모니 on 10/15/24.
//

import UIKit

class AddDutyDateCell: UICollectionViewCell {

    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var dateLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = nil
        subView.backgroundColor = .clear
    }

    // MARK: - Configure with SelectableDateItem (DiffableDataSource용)

    func configure(with item: SelectableDateItem) {
        // 날짜 표시 (현재 월인 경우에만)
        if item.isCurrentMonth {
            dateLabel.text = "\(Calendar.current.component(.day, from: item.date))"
        } else {
            dateLabel.text = nil
        }

        // 서브뷰 스타일
        subView.layer.cornerRadius = 8

        // 선택 상태에 따른 배경색
        if item.isSelected || item.isInRange {
            subView.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.2)
        } else {
            subView.backgroundColor = .clear
        }
    }
}
