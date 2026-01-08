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

    override func prepareForReuse() {
        super.prepareForReuse()
        // 기존 border 레이어 제거
        layer.sublayers?.forEach { layer in
            if layer.name == "topBorder" || layer.name == "leftBorder" || layer.name == "rightBorder" {
                layer.removeFromSuperlayer()
            }
        }
        backgroundColor = .white
        titleLabel.text = ""
        layer.borderWidth = 0
    }

    // MARK: - Configure with TimeSlotItem (DiffableDataSource용)

    func configure(with item: TimeSlotItem) {
        // 기존 border 레이어 제거
        layer.sublayers?.forEach { layer in
            if layer.name == "topBorder" || layer.name == "leftBorder" || layer.name == "rightBorder" {
                layer.removeFromSuperlayer()
            }
        }

        // 기본 스타일
        backgroundColor = .white
        titleLabel.text = ""
        layer.borderWidth = 0

        if let timetable = item.timetable {
            // 시간표가 있는 경우 - 배경색 설정
            backgroundColor = UIColor.fromHexString(timetable.color)

            // 첫 번째 셀인 경우 제목 표시
            if item.isFirstSlotOfSubject {
                titleLabel.text = timetable.title
                titleLabel.numberOfLines = 0
                titleLabel.font = .systemFont(ofSize: 10)
                titleLabel.textAlignment = .center
                titleLabel.textColor = .black
            }
        } else {
            // 시간표가 없는 경우 - 1시간 단위 선 추가
            if item.minute == 0 {
                addTopBorder()
            }
            addLeftRightBorders()
        }
    }

    private func addTopBorder() {
        let topBorder = CALayer()
        topBorder.name = "topBorder"
        topBorder.backgroundColor = UIColor.systemGray4.cgColor
        topBorder.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 0.5)
        layer.addSublayer(topBorder)
    }

    private func addLeftRightBorders() {
        let leftBorder = CALayer()
        leftBorder.name = "leftBorder"
        leftBorder.backgroundColor = UIColor.systemGray4.cgColor
        leftBorder.frame = CGRect(x: 0, y: 0, width: 0.5, height: bounds.height)
        layer.addSublayer(leftBorder)

        let rightBorder = CALayer()
        rightBorder.name = "rightBorder"
        rightBorder.backgroundColor = UIColor.systemGray4.cgColor
        rightBorder.frame = CGRect(x: bounds.width - 0.5, y: 0, width: 0.5, height: bounds.height)
        layer.addSublayer(rightBorder)
    }
}
