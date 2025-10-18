# 🗓️ 아마두 (Amadoo)

> **일정과 메모를 한 곳에서 관리하는 스마트 캘린더**

![Swift](https://img.shields.io/badge/Swift-5.0-orange) ![iOS](https://img.shields.io/badge/iOS-14.0+-blue) ![MVVM](https://img.shields.io/badge/Architecture-MVVM-green) ![CoreData](https://img.shields.io/badge/Database-CoreData-red)

<p align="center">
  <img src="screenshots/1.png" width="250">
  <img src="screenshots/2.png" width="250">
  <img src="screenshots/3.png" width="250">
</p>

<p align="center">
  <img src="screenshots/4.png" width="250">
  <img src="screenshots/5.png" width="250">
  <img src="screenshots/6.png" width="250">
</p>

## 📖 프로젝트 소개

아마두는 **일정 관리**와 **메모 관리**를 하나로 통합한 iOS 캘린더 앱입니다.  
커스터마이징 가능한 일정 색상과 체크리스트 기능으로 개인화된 일정 관리 경험을 제공합니다.

### 💡 개발 배경

- **v1.0 → v1.4.1 리뉴얼**: 초기 학습용 프로젝트를 1년 후 완전히 재구현
- **실사용자 피드백 기반 개선**: App Store 배포 후 4회 업데이트
- **기술 스택 업그레이드**: MVC → MVVM, 하드코딩 → CoreData

---

## ✨ 주요 기능

| 기능 | 설명 |
|------|------|
| 📅 **커스텀 일정 관리** | 색상별로 구분된 일정을 캘린더에 직관적으로 표시 |
| 🎨 **일정 색상 커스터마이징** | 사용자가 원하는 색상으로 일정 카테고리 구분 |
| ✅ **체크리스트 메모** | To-Do 형식의 체크리스트와 일반 메모 동시 지원 |
| 📱 **기간 일정 표시** | 여러 날짜에 걸친 일정을 시각적으로 연결하여 표시 |

---

## 🛠 Tech Stack

### **Core Technologies**
- **Swift** - iOS 네이티브 개발
- **UIKit** - Storyboard + Code 기반 UI
- **Auto Layout** - 반응형 UI 구현

### **Architecture & Patterns**
- **MVVM** - View와 비즈니스 로직 분리
- **CoreData** - 로컬 데이터 영구 저장

### **Key Features**
- **Multi-Entity Management** - CheckList, Memo, Schedule 등 다중 Entity 활용
- **Custom Calendar Cell** - 코드 기반 복잡한 캘린더 셀 렌더링
- **Dynamic Data Binding** - 실시간 데이터 변경 반영

---

## 🎯 기술적 도전과 해결

### 1️⃣ **복잡한 캘린더 UI 구현**

**문제**  
- 한 셀에 여러 일정을 겹치지 않게 표시
- 기간 일정의 시작/중간/끝을 시각적으로 구분
- 일정 충돌 방지 알고리즘 필요

**해결**
```swift
// 일정 충돌 감지 및 자동 배치 알고리즘
var assignedIndex: Int = -1

for i in 0..<maxDisplayEvents {
    var isConflict = false
    
    // 기간 내 모든 날짜에서 충돌 확인
    for day in stride(from: startDate, through: endDate, by: 86400) {
        if let occupiedTitle = DateCell.occupiedIndexesByDate[day]?[i], 
           occupiedTitle != title {
            isConflict = true
            break
        }
    }
    
    if !isConflict {
        assignedIndex = i
        break
    }
}
```

**성과**
- 최대 5개까지 일정을 겹치지 않게 자동 배치
- 기간 일정의 둥근 모서리 처리로 시각적 연속성 표현

### 2️⃣ **다중 Entity 데이터 통합 관리**

**문제**  
- CheckList와 Memo는 서로 다른 Entity
- 하나의 테이블뷰에서 두 종류의 데이터를 함께 표시 필요

**해결**
```swift
private func fetchAndCombineData() {
    let checkListItems = try context.fetch(checkListFetch)
    let memoItems = try context.fetch(memoFetch)
    
    // Dictionary로 제목별 그룹화
    combinedItems = [:]
    
    for item in checkListItems {
        let key = item.title ?? "Untitled"
        combinedItems[key]?.append(item)
    }
    
    for item in memoItems {
        let key = item.title ?? "Untitled"
        combinedItems[key]?.append(item)
    }
}
```

**성과**
- 단일 데이터 소스로 두 종류의 메모 통합 관리
- 제목별 그룹화로 직관적인 메모 구조 제공

### 3️⃣ **Storyboard → Code 전환 경험**

**배경**  
- 초기에는 Storyboard 중심 개발
- 복잡한 캘린더 셀은 코드로 직접 구현 필요

**학습 내용**
- Auto Layout을 프로그래밍 방식으로 작성
- UIStackView를 활용한 동적 뷰 구성
- 코드 기반 UI의 유연성과 재사용성 경험

---

## 🚀 Getting Started

### Requirements
- iOS 14.0+
- Xcode 13.0+
- Swift 5.0+

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/simoni-git/Amadoo_-Official_Code.git
cd Amadoo_-Official_Code
```

2. **Open project**
```bash
open Amadoo.xcodeproj
```

3. **Build and Run**
- Xcode에서 `Cmd + R`로 실행

---

## 📂 Project Structure

```
Amadoo/
├── Models/
│   ├── CheckList.swift      # 체크리스트 Entity
│   ├── Memo.swift            # 메모 Entity
│   └── Schedule.swift        # 일정 Entity
├── Views/
│   ├── CalendarCell.swift    # 커스텀 캘린더 셀
│   └── MemoCell.swift        # 메모 테이블뷰 셀
├── ViewModels/
│   ├── CalendarViewModel.swift
│   └── MemoViewModel.swift
├── Controllers/
│   ├── CalendarViewController.swift
│   └── MemoViewController.swift
└── CoreData/
    └── AmadooDataModel.xcdatamodeld
```

---

## 🔄 버전 히스토리

### v1.4.1 (Latest)
- 일정 색상 커스터마이징 기능 추가
- CoreData 성능 최적화
- UI/UX 개선

### v1.0.0
- 기본 캘린더 기능 구현
- 일정 추가/수정/삭제
- 메모 관리 기능

---

## 💭 회고 (Retrospective)

### 잘한 점 ✅
- **리팩토링 경험**: 1년 전 코드를 완전히 재구현하며 성장 확인
- **실사용자 피드백 반영**: App Store 배포 후 4회 업데이트로 지속적 개선
- **복잡한 UI 로직 구현**: 캘린더 셀의 일정 충돌 방지 알고리즘 성공적 구현
- **CoreData 심화 학습**: 다중 Entity 관리 및 복잡한 쿼리 활용

### 아쉬운 점 📝
- Storyboard 중심 개발로 협업 시 충돌 가능성
- 테스트 코드 부재로 리팩토링 시 불안감
- 일정 알림 기능 미구현

### 다음 프로젝트에 적용할 점 🎯
- SwiftUI로 전환하여 선언형 UI 경험
- Unit Test 도입으로 안정성 강화
- CloudKit 연동으로 멀티 디바이스 동기화

---

## 🔗 Links

- **GitHub Repository**: [simoni-git/Amadoo_-Official_Code](https://github.com/simoni-git/Amadoo_-Official_Code)
- **App Store**: [다운로드 링크 추가]

---

## 👤 Author

**고민수 (Minsu Go)**
- 📧 Email: gms5889@naver.com
- 💼 GitHub: [@simoni-git](https://github.com/simoni-git)
- 📝 Blog: [네이버 블로그](https://blog.naver.com/gms5889)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
