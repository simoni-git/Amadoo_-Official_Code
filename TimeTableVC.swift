//
//  TimeTableVC.swift
//  NewCalendar
//
//  Created by 시모니의 맥북 on 11/21/25.
//

import UIKit

class TimeTableVC: UIViewController {
    
    @IBOutlet weak var optionBtn: UIButton!
    @IBOutlet weak var dayStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var timeStackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    
    // 시간 범위
    let startHour = 9
    let endHour = 21
    
    // 시간 배열
    var hours: [Int] {
        return Array(startHour...endHour)
    }
    
    // 셀 높이
    let cellHeight: CGFloat = 60
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        setupTimeLabels()
        updateScrollViewHeight()
        setupCollectionView()
    }
    
    func setupTimeLabels() {
        // 기존 라벨 제거
        timeStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Distribution을 Fill로 변경
        timeStackView.distribution = .fillEqually
        timeStackView.spacing = 0
        timeStackView.backgroundColor = .systemGray6
        // 새로운 시간 라벨 추가
        for hour in hours {
            let label = UILabel()
            label.text = String(format: "%02d:00", hour)
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 12)
            label.textColor = .black
            label.translatesAutoresizingMaskIntoConstraints = false
            
            timeStackView.addArrangedSubview(label)
            
            // 각 라벨의 높이를 정확히 cellHeight로 설정
            NSLayoutConstraint.activate([
                label.heightAnchor.constraint(equalToConstant: cellHeight)
            ])
        }
    }
    
  
    // 스크롤뷰 높이 업데이트
    func updateScrollViewHeight() {
        let totalHeight = cellHeight * CGFloat(hours.count)
        scrollViewHeightConstraint.constant = totalHeight
    }
    
    // 컬렉션뷰 설정
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self,
                                forCellWithReuseIdentifier: "Cell")
    }
    
    @IBAction func tapOptionBtn(_ sender: UIButton) {
        // 시작시간 + 끝시간 설정
    }
    
}

extension TimeTableVC: UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7 * hours.count // 7 × 13 = 91개
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeTableCell",
                                                      for: indexPath)
        cell.backgroundColor = .white
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.systemGray4.cgColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // dayStackView의 실제 너비를 기준으로 계산
        let cellWidth = dayStackView.bounds.width / 8
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
