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
    @IBOutlet weak var timeStackViewWidthConstaint: NSLayoutConstraint!
    
    private let startHourKey = "TimeTable_StartHour"
    private let endHourKey = "TimeTable_EndHour"
    
    // 시간 범위 - UserDefaults에서 불러오기
    var startHour: Int {
        get {
            let saved = UserDefaults.standard.integer(forKey: startHourKey)
            return saved != 0 ? saved : 9 // 저장된 값이 없으면 기본값 9
        }
        set {
            UserDefaults.standard.set(newValue, forKey: startHourKey)
        }
    }
    
    var endHour: Int {
        get {
            let saved = UserDefaults.standard.integer(forKey: endHourKey)
            return saved != 0 ? saved : 21 // 저장된 값이 없으면 기본값 21
        }
        set {
            UserDefaults.standard.set(newValue, forKey: endHourKey)
        }
    }
    
    // Picker에서 선택된 임시 값
    private var tempStartHour = 9
    private var tempEndHour = 21
    
    // 시간 배열
    var hours: [Int] {
        return Array(startHour...endHour)
    }
    
    var cellHeight: CGFloat {
        let dayLabelWidth = dayStackView.bounds.width / 6
        return dayLabelWidth * 1.5
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        setupTimeLabels()
        loadSavedTimeRange()
        // 롱프레스 제스처 추가
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // timeStackView 너비를 dayStackView 기준으로 설정
        let dayLabelWidth = dayStackView.bounds.width / 6
        timeStackViewWidthConstaint.constant = dayLabelWidth
        
        // cellHeight로 계산 (고정 공식 사용)
        scrollViewHeightConstraint.constant = cellHeight * CGFloat(hours.count)
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    
    // 저장된 시간 범위 불러오기
    func loadSavedTimeRange() {
        // 첫 실행 시 기본값 저장
        if UserDefaults.standard.object(forKey: startHourKey) == nil {
            UserDefaults.standard.set(9, forKey: startHourKey)
        }
        if UserDefaults.standard.object(forKey: endHourKey) == nil {
            UserDefaults.standard.set(21, forKey: endHourKey)
        }
        
        print("불러온 시간 범위: \(startHour):00 ~ \(endHour):00")
    }
    
    func setupTimeLabels() {
        // 기존 라벨 제거
        timeStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // StackView 설정
        timeStackView.axis = .vertical
        timeStackView.alignment = .fill
        timeStackView.distribution = .fillEqually
        timeStackView.spacing = 0
        
        // 새로운 시간 라벨 추가
        for hour in hours {
            // 컨테이너 뷰 생성
            let containerView = UIView()
            containerView.backgroundColor = UIColor.fromHexString("E6DFF1")
            containerView.layer.borderWidth = 0.5
            containerView.layer.borderColor = UIColor.systemGray4.cgColor
            
            // 라벨 생성
            let label = UILabel()
            label.text = String(format: "%02d:00", hour)
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 12)
            label.textColor = .black
            label.translatesAutoresizingMaskIntoConstraints = false
            
            containerView.addSubview(label)
            
            // 라벨을 상단에 배치
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
                label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
            ])
            
            timeStackView.addArrangedSubview(containerView)
        }
    }
    
    @IBAction func tapOptionBtn(_ sender: UIButton) {
        showTimeRangePicker()
    }
    
    
    func showTimeRangePicker() {
        let alert = UIAlertController(title: "시간 범위 설정",
                                      message: "\n\n\n\n\n\n\n\n\n",
                                      preferredStyle: .alert)
        
        // 임시 값 초기화
        tempStartHour = startHour
        tempEndHour = endHour
        
        // 배경색 파란색으로 변경
        if let firstSubview = alert.view.subviews.first,
           let alertContentView = firstSubview.subviews.first {
            alertContentView.backgroundColor = UIColor.fromHexString("F8EDE3")
        }
        
        // 타이틀 색상 변경 (선택사항)
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        let attributedTitle = NSAttributedString(string: "시간 범위 설정", attributes: titleAttributes)
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        
        // 레이블 추가 - 위치 조정
        let startLabel = UILabel(frame: CGRect(x: 35, y: 55, width: 80, height: 25))
        startLabel.text = "시작 시간"
        startLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        startLabel.textAlignment = .center
        startLabel.textColor = .black // 파란 배경에 흰색 글씨
        
        let endLabel = UILabel(frame: CGRect(x: 155, y: 55, width: 80, height: 25))
        endLabel.text = "종료 시간"
        endLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        endLabel.textAlignment = .center
        endLabel.textColor = .black // 파란 배경에 흰색 글씨
        
        // Picker View 생성 - 위치 아래로 이동
        let pickerFrame = CGRect(x: 10, y: 85, width: 250, height: 140)
        let pickerView = UIPickerView(frame: pickerFrame)
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = .clear
        
        // 현재 값으로 초기 선택
        pickerView.selectRow(startHour, inComponent: 0, animated: false)
        pickerView.selectRow(endHour, inComponent: 1, animated: false)
        
        // 레이블과 Picker 모두 추가
        alert.view.addSubview(startLabel)
        alert.view.addSubview(endLabel)
        alert.view.addSubview(pickerView)
        
        // 적용 버튼 - 검정색 텍스트
        let applyAction = UIAlertAction(title: "적용하기", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            // 최소 9시간 차이 검증
            let timeDiff = self.tempEndHour - self.tempStartHour
            
            if timeDiff < 9 {
                self.showErrorAlert(message: "시작 시간과 종료 시간의 차이는\n최소 9시간 이상이어야 합니다")
                return
            }
            
            self.updateTimeRange(start: self.tempStartHour, end: self.tempEndHour)
        }
        applyAction.setValue(UIColor.black, forKey: "titleTextColor")
        alert.addAction(applyAction)
        
        // 취소 버튼 - 검정색 텍스트
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        cancelAction.setValue(UIColor.black, forKey: "titleTextColor")
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    // 에러 알럿도 업데이트 (선택사항)
    func showErrorAlert(message: String? = nil) {
        let alert = UIAlertController(title: "오류",
                                      message: message ?? "올바른 시간 범위를 입력해주세요",
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default)
        okAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
    
    func updateTimeRange(start: Int, end: Int) {
        startHour = start
        endHour = end
        
        // 1. 시간 라벨 업데이트
        setupTimeLabels()
        
        // 2. 강제 레이아웃 업데이트
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        // 3. 스크롤뷰 높이 다시 계산
        let dayLabelWidth = dayStackView.bounds.width / 6
        timeStackViewWidthConstaint.constant = dayLabelWidth
        scrollViewHeightConstraint.constant = cellHeight * CGFloat(hours.count)
        
        // 4. 컬렉션뷰 완전 새로고침
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
        
        // 5. 다시 한번 레이아웃
        view.layoutIfNeeded()
    }
    
    func showErrorAlert() {
        let alert = UIAlertController(title: "오류",
                                      message: "시작 시간은 종료 시간보다 작아야 합니다",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    //MARK: - @objc func
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        // began 상태에서만 실행 (중복 방지)
        guard gesture.state == .began else { return }
        
        let location = gesture.location(in: collectionView)
        
        if let indexPath = collectionView.indexPathForItem(at: location) {
            let row = indexPath.item / 5  // 시간 인덱스
            let column = indexPath.item % 5  // 요일 인덱스
            let hour = hours[row]
            let day = ["월", "화", "수", "목", "금", "토", "일"][column]
            
            print("눌린 셀: \(indexPath.item)번째")
            print("위치: \(day)요일 \(hour):00")
            
            // ViewModel 생성 (시간 범위 전달)
                    let nextVM = AddTimeVM(selectedHour: hour, minimumHour: startHour, maximumHour: endHour)
            
            guard let nextVC = self.storyboard?.instantiateViewController(identifier: "AddTimeVC") as? AddTimeVC else { return }
            nextVC.vm = nextVM
            present(nextVC, animated: true)
           
        }
    }
    
}
//MARK: - CollectionView
extension TimeTableVC: UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5 * hours.count
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
        
        let width = floor(collectionView.bounds.width / 5)  // floor 유지!
        let height = timeStackView.bounds.height / CGFloat(hours.count)
        
        return CGSize(width: width, height: height)
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

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension TimeTableVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            // 시작 시간: 0 ~ 15 (최대 24-9)
            return 16
        } else {
            // 종료 시간: 시작시간+9 ~ 24
            return 25
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return String(format: "%02d:00", row)
        } else {
            return String(format: "%02d:00", row)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            // 시작 시간 선택
            tempStartHour = row
            
            // 종료 시간이 시작시간+9보다 작으면 자동 조정
            if tempEndHour < tempStartHour + 9 {
                tempEndHour = tempStartHour + 9
                pickerView.selectRow(tempEndHour, inComponent: 1, animated: true)
            }
            
            // 종료 시간 컴포넌트 리로드
            pickerView.reloadComponent(1)
            
        } else {
            // 종료 시간 선택
            tempEndHour = row
            
            // 최소 9시간 차이 유지
            if tempEndHour < tempStartHour + 9 {
                tempEndHour = tempStartHour + 9
                pickerView.selectRow(tempEndHour, inComponent: 1, animated: true)
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 100
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20)
        
        if component == 0 {
            label.text = String(format: "%02d:00", row)
        } else {
            label.text = String(format: "%02d:00", row)
            
            // 선택 불가능한 시간은 회색으로 표시
            if row < tempStartHour + 9 {
                label.textColor = .lightGray
            } else {
                label.textColor = .black
            }
        }
        
        return label
    }
}
