# 🗓️ 아마두 (Amadoo)
> **캘린더, 시간표, 메모를 한 곳에서 관리하는 올인원 앱**

![Swift](https://img.shields.io/badge/Swift-5.0-orange) ![iOS](https://img.shields.io/badge/iOS-14.0+-blue) ![MVVM](https://img.shields.io/badge/Architecture-MVVM-green) ![CoreData](https://img.shields.io/badge/Database-CoreData-red) ![CloudKit](https://img.shields.io/badge/Sync-CloudKit-blue)

<p align="center">
  <img src="ScreenShots/Simulator Screenshot - iPhone 16 Pro Max - 2025-11-11 at 01.24.32.png" width="250">
  <img src="ScreenShots/Simulator Screenshot - iPhone 16 Pro Max - 2025-12-02 at 00.05.28.png" width="250">
  <img src="ScreenShots/Simulator Screenshot - iPhone 16 Pro Max - 2025-12-01 at 22.07.13.png" width="250">
</p>

## 📖 프로젝트 소개

아마두는 **캘린더**, **시간표**, **메모 관리**를 하나로 통합한 iOS 올인원 앱입니다.  
일정이 많은 직장인과 학생들을 위해 설계되었으며, 커스터마이징 가능한 일정 색상과 체크리스트 기능으로 개인화된 일정 관리 경험을 제공합니다. CloudKit을 통한 멀티 디바이스 동기화를 지원합니다.

### 💡 개발 배경

- **v1.0 → v1.4.5 지속적 진화**: 초기 학습용 프로젝트를 실사용자 피드백 기반으로 7회 업데이트
- **실사용자 피드백 기반 개선**: App Store 배포 후 사용자 요구사항을 반영한 지속적인 기능 개선
- **기술 스택 업그레이드**: MVC → MVVM, 하드코딩 → CoreData, 로컬 저장 → CloudKit 동기화
- **올인원 통합 솔루션**: 캘린더 + 시간표 + 메모를 하나의 앱에서 관리

---

## ✨ 주요 기능

| 기능 | 설명 |
|------|------|
| 📅 **커스텀 일정 관리** | 원하는 색상으로 일정을 달력에 직관적으로 표시 |
| ⏰ **시간표 관리** | 학생과 직장인을 위한 주간 시간표 기능  |
| ✏️ **일정 수정** | 등록된 일정을 언제든지 자유롭게 수정 가능 |
| ✅ **이중 메모 시스템** | 체크리스트형 + 일반형 메모를 하나의 앱에서 관리 |
| 🔔 **스마트 알림** | 매일 아침 당일 일정을 자동으로 알림 제공 |
| ☁️ **멀티 디바이스 동기화** | CloudKit으로 여러 기기에서 실시간 일정 동기화 |
| 🔍 **날짜 빠른 검색** | 원하는 날짜를 검색하여 해당 월로 즉시 이동 |

---

## 🛠 Tech Stack

### **Core Technologies**
- **Swift** - iOS 네이티브 개발
- **UIKit** - Storyboard + Code 기반 UI
- **Auto Layout** - 반응형 UI 구현

### **Architecture & Patterns**
- **MVVM** - View와 비즈니스 로직 분리
- **CoreData** - 로컬 데이터 영구 저장
- **CloudKit** - 멀티 디바이스 데이터 동기화

### **Key Features**
- **Multi-Entity Management** - CheckList, Memo, Schedule, Timetable 등 다중 Entity 활용
- **Custom Calendar Cell** - 코드 기반 복잡한 캘린더 셀 렌더링
- **Timetable Grid System** - CollectionView 기반 주간 시간표 구현
- **Dynamic Data Binding** - 실시간 데이터 변경 반영
- **Cloud Synchronization** - NSPersistentCloudKitContainer 기반 자동 동기화

---

## 🎯 기술적 도전과 해결

### 1️⃣ **달력 UI 유연성 확보**

**배경**  
사용자별 다양한 UI 요구사항 대응 필요

**문제**  
- Storyboard 기반 개발의 한계점 직면
- 디자인 변경 시마다 Storyboard 수정 필요
- 사용자 피드백 빠른 반영 어려움

**해결**
```swift
// Storyboard → 코드 기반 Custom Cell로 전환
class CalendarCell: UICollectionViewCell {
    // 동적으로 일정을 배치하는 StackView
    private let dutyStackView = UIStackView()
    
    func configure(with events: [...]) {
        // 런타임에 UI 구성 변경 가능
        dutyStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        // 일정 충돌 방지 알고리즘 적용
        // ...
    }
}
```

**성과**  
✅ 사용자 요청 반영 속도 대폭 개선  
✅ UI 커스터마이징 자유도 향상

---

### 2️⃣ **복잡한 데이터 구조 단순화**

**배경**  
체크리스트와 일반 메모의 서로 다른 특성

**문제**  
- 초기: CheckList와 Memo 두 개의 Entity 사용
- 코드 복잡성 증가 및 중복 로직 발생
- 데이터 통합 관리의 어려움

**해결**
```swift
// 두 Entity를 하나로 통합하여 관리
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
✅ 코드 가독성 향상  
✅ 유지보수성 개선  
✅ 단일 데이터 소스로 통합 관리

---

### 3️⃣ **알림 시스템 신뢰성 확보**

**배경**  
사용자의 일정 놓침 방지가 핵심 가치

**문제**  
- v1.4 초기: 새벽 시간 앱 실행 시 당일 알림 누락
- 사용자 신뢰도 하락 위험

**해결**
```swift
// 시간 조건부 알림 로직 구현
func scheduleNotifications() {
    let now = Date()
    let calendar = Calendar.current
    
    // 현재 시간이 새벽이면 당일 알림도 포함
    if calendar.component(.hour, from: now) < 6 {
        // 당일 일정 알림 추가
        scheduleNotificationForToday()
    }
    
    // 다음 날 알림 스케줄링
    scheduleNotificationForTomorrow()
}
```

**성과**  
✅ v1.4.1에서 알림 신뢰도 100% 달성  
✅ 사용자 불만 제로화

---

### 4️⃣ **멀티 디바이스 동기화 구현**

**배경**  
사용자들의 여러 기기에서 일정 동기화 요구

**문제**  
- 로컬 CoreData만으로는 디바이스 간 데이터 공유 불가
- 데이터 충돌 및 중복 처리 필요
- 네트워크 상태 및 iCloud 계정 상태에 따른 동기화 실패 처리
- 빈번한 동기화로 인한 성능 저하 위험

**해결**
```swift
class CloudKitSyncManager {
    static let shared = CloudKitSyncManager()
    private let container = CKContainer.default()
    private var lastNotificationTime: Date = Date(timeIntervalSince1970: 0)
    
    // iCloud 계정 상태를 상세하게 확인
    func checkDetailedAccountStatus(completion: @escaping (CloudKitStatus, String?) -> Void) {
        container.accountStatus { status, error in
            switch status {
            case .available:
                // 용량 체크도 함께 진행
                self.checkiCloudQuota { hasSpace in
                    if hasSpace {
                        completion(.available, nil)
                    } else {
                        completion(.quotaExceeded, "iCloud 저장 공간이 부족합니다")
                    }
                }
            case .noAccount:
                completion(.noAccount, "iCloud 계정이 설정되지 않았습니다")
            // ...
            }
        }
    }
    
    // 원격 변경사항 감지 및 중복 알림 방지
    @objc private func handleRemoteChange(_ notification: Notification) {
        let now = Date()
        
        // 마지막 알림으로부터 2초 이내면 무시 (디바운싱)
        if now.timeIntervalSince(lastNotificationTime) < 2.0 {
            return
        }
        
        lastNotificationTime = now
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .cloudKitDataUpdated, object: nil)
        }
    }
    
    // 네트워크 상태 확인 후 동기화
    func syncIfNetworkAvailable() {
        if NetworkSyncManager.shared.getCurrentNetworkStatus() {
            checkAccountStatus { isAvailable in
                if isAvailable {
                    self.triggerSync()
                }
            }
        }
    }
}
```

**성과**  
✅ 하나의 Apple 계정으로 모든 기기에서 일정 동기화  
✅ iCloud 계정 상태 및 용량 체크로 오류 사전 방지  
✅ 디바운싱 로직으로 불필요한 동기화 요청 방지  
✅ 네트워크 상태 확인으로 안정적인 동기화  
✅ 다음 프로젝트 회고에서 언급했던 기능 직접 구현

---

### 5️⃣ **사용자 경험 개선 - 날짜 검색 기능**

**배경**  
멀리 떨어진 날짜로 이동 시 불편함

**문제**  
- 월 단위 스와이프로 이동 시 시간 소요
- 특정 날짜 찾기 위한 반복 작업

**해결**
```swift
// 날짜 검색 기능 구현
func searchAndNavigateToDate(_ targetDate: Date) {
    let calendar = Calendar.current
    let targetMonth = calendar.component(.month, from: targetDate)
    let targetYear = calendar.component(.year, from: targetDate)
    
    // 해당 월로 즉시 이동
    calendarView.scrollToDate(targetDate, animated: true)
    loadSchedules(for: targetDate)
}
```

**성과**  
✅ 원하는 날짜로 즉시 이동 가능  
✅ 사용자 조작 횟수 대폭 감소

---

### 6️⃣ **시간표 기능 구현** (NEW)

**배경**  
학생과 직장인의 주간 일정 관리 요구

**문제**  
- 캘린더만으로는 반복되는 주간 일정 확인이 불편
- 시간대별 일정 시각화 필요
- 요일별 시간 블록 관리 요구

**해결**
```swift
// CollectionView 기반 시간표 그리드 시스템
class TimetableViewController: UIViewController {
    private let timeSlots = ["09:00", "10:00", "11:00", ...] // 시간대
    private let weekdays = ["월", "화", "수", "목", "금"] // 요일
    
    func collectionView(_ collectionView: UICollectionView, 
                       cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 시간대와 요일에 따른 셀 구성
        let cell = collectionView.dequeueReusableCell(...)
        let schedule = getTimetableData(for: indexPath)
        cell.configure(with: schedule)
        return cell
    }
}
```

**성과**  
✅ 한눈에 보이는 주간 시간표 제공  
✅ 직장인과 학생 모두를 위한 올인원 앱으로 진화  
✅ 반복 일정 관리 편의성 대폭 향상

---

## 🔄 버전 히스토리

### 💡 핵심 가치
- **사용자 중심 개발**: 단순한 기능 구현을 넘어 실제 사용자의 문제를 해결
- **지속적 개선**: 7회 연속 업데이트로 입증된 피드백 반영 역량
- **완성도 높은 실행력**: 개인 프로젝트를 실제 서비스 수준으로 완성
- **올인원 솔루션**: 캘린더, 시간표, 메모를 하나의 앱에 통합

---

### v1.4.5 (Latest) - 시간표 기능 추가

**추가 기능**  
- 주간 시간표 관리 시스템
- 요일별/시간대별 일정 등록
- 시간표 전용 UI 및 그리드 레이아웃

**기술 구현**  
- CollectionView 기반 시간표 그리드
- Timetable Entity 추가
- 시간대별 데이터 필터링 로직

**결과**  
✅ 직장인과 학생을 위한 올인원 앱으로 진화  
✅ 주간 반복 일정 관리 편의성 향상  
✅ 캘린더 + 시간표 + 메모 통합 솔루션 완성

---

### v1.4.3 - 멀티 디바이스 동기화

**추가 기능**  
- CloudKit 기반 멀티 디바이스 동기화
- iCloud 계정 상태 및 저장 공간 체크
- 날짜 검색 기능으로 빠른 달력 이동

**기술 구현**  
- NSPersistentCloudKitContainer 활용
- 디바운싱 로직으로 성능 최적화
- 네트워크 상태 확인 및 에러 핸들링

**결과**  
✅ 하나의 Apple 계정으로 여러 기기에서 일정 동기화  
✅ iCloud 계정 미설정 시 사용자에게 명확한 안내  
✅ 사용자 편의성 대폭 향상

---

### v1.4.1 - 안정성 개선

**문제**  
새벽 시간대 앱 실행 시 당일 알림 누락 발생

**해결**  
시간 조건부 로직으로 완전 해결

**결과**  
✅ 알림 신뢰도 100% 달성

---

### v1.4 - 알림 시스템

**추가 기능**  
매일 아침 일정 알림 기능 구현

**기술 스택**  
UserNotifications 프레임워크 활용

---

### v1.3 - 핵심 기능 확장

**사용자 요청**  
일정 편집 기능 추가 (요청 1순위)

**기술 구현**  
- CoreData 수정 로직 구현
- View 재활용으로 코드 효율성 증대

---

### v1.2 - 편의성 강화

**추가 기능**  
카테고리 즉시 생성 기능

**기술 구현**  
- View 재활용 패턴
- Delegate 패턴 활용

---

### v1.1 - 사용성 개선

**문제**  
일정 등록 과정이 복잡하다는 사용자 피드백

**해결**  
일정 추가 단계 50% 단축

**결과**  
✅ 사용자 만족도 향상

---

### v1.0.0 - 초기 출시

- 기본 캘린더 기능
- 일정 추가/삭제
- 메모 관리 기능

---

## 💭 회고 (Retrospective)

### 잘한 점 ✅

- **실사용자 중심 개발**: App Store 배포 후 7회 연속 업데이트로 실제 사용자 문제 해결
- **기술적 성장**: Storyboard → 코드 기반 UI, CoreData → CloudKit 동기화까지 단계적 발전
- **완성도 높은 실행력**: 알림 신뢰도 100% 달성, 멀티 디바이스 동기화 구현 등 실제 서비스 수준 완성
- **체계적 문제 해결**: 각 버전마다 명확한 문제 정의 → 해결 → 검증 프로세스
- **올인원 솔루션 완성**: 캘린더, 시간표, 메모를 하나의 앱에 통합하여 사용자 편의성 극대화
- **다양한 사용자층 확보**: 직장인, 학생 등 일정이 많은 모든 사용자를 위한 범용 앱으로 발전

### 아쉬운 점 📝

- Storyboard 중심 개발로 협업 시 충돌 가능성
- 테스트 코드 부재로 리팩토링 시 불안감
- CloudKit 동기화 충돌 시나리오에 대한 추가 테스트 필요
- 시간표 기능의 더 세밀한 시간 단위 설정 필요

### 다음 프로젝트에 적용할 점 🎯

- SwiftUI로 전환하여 선언형 UI 경험
- Unit Test 도입으로 안정성 강화
- Widget 기능 추가로 접근성 향상
- 시간표 커스터마이징 옵션 확대 (색상, 시간 간격 등)
- CloudKit 충돌 해결 전략 고도화

---

## 🔗 Links

- **GitHub Repository**: [simoni-git/Amadoo_-Official_Code](https://github.com/simoni-git/Amadoo_-Official_Code)
- **App Store**: [https://apps.apple.com/kr/app/%EC%95%84%EB%A7%88%EB%91%90-%EC%9D%BC%EC%A0%95%EA%B4%80%EB%A6%AC-%EB%A9%94%EB%AA%A8%EA%B4%80%EB%A6%AC-%ED%95%84%EC%88%98%EC%95%B1/id6739255155]

---

## 👤 Author

**고민수 (Minsu Go)**
- 📧 Email: gms5889@naver.com
- 💼 GitHub: [@simoni-git](https://github.com/simoni-git)
- 📝 Blog: [네이버 블로그](https://blog.naver.com/gms5889)

---

