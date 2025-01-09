# 🗓️아마두 - 캘린더앱[일정관리, 메모관리]

## 🔨사용기술
- Swift
- Storyboard
- MVC > MVVM 변환중


## 🔨사용기술 주요코드
    func configure(with events: [(title: String, color: UIColor, isPeriod: Bool, isStart: Bool, isEnd: Bool, startDate: Date, endDate: Date)], for date: Date) {
        dutyStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let sortedEvents = events.sorted { (lhs, rhs) -> Bool in
            if lhs.isPeriod != rhs.isPeriod {
                return lhs.isPeriod && !rhs.isPeriod
            }
            return lhs.title < rhs.title
        }
        
        var eventLabels: [UILabel?] = Array(repeating: nil, count: maxDisplayEvents)
        var usedIndexes: Set<Int> = Set(DateCell.occupiedIndexesByDate[date]?.keys.map { Int($0) } ?? [])
        
        for event in sortedEvents {
            let title = event.title
            let startDate = event.startDate
            let endDate = event.endDate
            var assignedIndex: Int = -1
            
            for i in 0..<maxDisplayEvents {
                var isConflict = false
                
                for day in stride(from: startDate, through: endDate, by: 86400) { 
                    if let occupiedTitle = DateCell.occupiedIndexesByDate[day]?[i], occupiedTitle != title {
                        isConflict = true
                        break
                    }
                }
                
                if !isConflict {
                    assignedIndex = i
                    break
                }
            }
            
            guard assignedIndex != -1 else { continue }
            
            for day in stride(from: startDate, through: endDate, by: 86400) {
                if DateCell.occupiedIndexesByDate[day] == nil {
                    DateCell.occupiedIndexesByDate[day] = [:]
                }
                DateCell.occupiedIndexesByDate[day]?[assignedIndex] = title
            }
            
            usedIndexes.insert(assignedIndex)
            
            let label = UILabel()
            if event.isPeriod && !event.isStart {
                label.text = ""
            } else {
                label.text = title
            }
            
            DispatchQueue.main.async {
                label.backgroundColor = event.color
                label.textAlignment = .center
                label.font = UIFont.systemFont(ofSize: 10)
                label.textColor = .white
                label.clipsToBounds = true
                label.layer.cornerRadius = 5
            }
            
            if event.isStart && event.isEnd {
                label.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            } else if event.isStart {
                label.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            } else if event.isEnd {
                label.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            } else {
                label.layer.maskedCorners = []
            }
            
            eventLabels[assignedIndex] = label
        }
        
        for i in 0..<maxDisplayEvents {
            if let label = eventLabels[i] {
                dutyStackView.addArrangedSubview(label)
            } else {
                let emptyLabel = UILabel()
                emptyLabel.text = ""
                emptyLabel.backgroundColor = .clear
                dutyStackView.addArrangedSubview(emptyLabel)
            }
        }
    }
⬆️ 해당 날짜에 일정을 셀에 나타내는 코드

    private func fetchAndCombineData() {
        let checkListFetch: NSFetchRequest<CheckList> = CheckList.fetchRequest()
        let memoFetch: NSFetchRequest<Memo> = Memo.fetchRequest()
        
        do {
            let checkListItems = try context.fetch(checkListFetch)
            let memoItems = try context.fetch(memoFetch)
            combinedItems = [:]
            
            for item in checkListItems {
                let key = item.title ?? "Untitled"
                if combinedItems[key] == nil {
                    combinedItems[key] = []
                }
                combinedItems[key]?.append(item)
            }
            
            for item in memoItems {
                let key = item.title ?? "Untitled"
                if combinedItems[key] == nil {
                    combinedItems[key] = []
                }
                combinedItems[key]?.append(item)
            }
            
            combinedItemTitles = Array(combinedItems.keys).sorted()
            tableView.reloadData()
        } catch {
            
        }
    }
⬆️ 서로 다른 Entity의 데이터를 하나로 합쳐 테이블뷰 데이터소스로 사용하여 메모를 표현

## 🔍앱의 주요기능
- 사용자의 일정을 추가하여 달력에 표시
- 달력에 나타나는 일정의 색깔을 사용자가 커스텀 가능
- 체크리스트 형식과 일반 메모형식의 메모관리



## 👨‍💻프로젝트를 계획한 이유
- 공부를 시작한지 얼마 안됬을 때 캘린더 앱을 만들어 본적이 있으나 퀄리티가 높지 않았지만,
  공부를 해오면서 퀄리티를 높여 다시한번 만들어 보고 싶었습니다.

- 캘린더라는 앱의 특성상 많은 층의 사용자들이 사용할 수 있고, 이를 통해 많은 피드백을 받아
  피드백을 수용하여 고쳐나감으로 써 앱을 점차 업그레이드 시켜 나가기에 좋다고 생각했습니다.



## 🤓배포과정에서 느낀점
- StoryBoard 를 통하여 대부분의 뷰를 만들고 그대로 사용했으나,
  Code 를 사용하여 달력의 셀 구성을 작성해 보면서 Code 로 뷰를 그리는
  방법을 배웠습니다.
- 각 다른 주제의 여러가지 데이터를 저장하는 과정에서 CoreData 를 사용하였고
  다수의 Entity 를 활용하였습니다. 이 과정에서 필요한 데이터를 가져올 때 
  해당 Entity와 그에 맞는 조건을 활용하여 데이터를 가져오는 방법을 배웠습니다.

