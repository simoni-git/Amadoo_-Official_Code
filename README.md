# 🗓️ 아마두 (Amadoo)
> **캘린더, 시간표, 메모를 한 곳에서 관리하는 올인원 앱**

![Swift](https://img.shields.io/badge/Swift-5.0-orange) ![iOS](https://img.shields.io/badge/iOS-15.0+-blue) ![Architecture](https://img.shields.io/badge/Architecture-Clean+MVVM-green) ![CoreData](https://img.shields.io/badge/Database-CoreData-red) ![CloudKit](https://img.shields.io/badge/Sync-CloudKit-blue) ![DI](https://img.shields.io/badge/DI-DIContainer-purple)

<p align="center">
  <img src="ScreenShots/Simulator Screenshot - iPhone 16 Pro Max - 2025-11-11 at 01.24.32.png" width="200">
  <img src="ScreenShots/Simulator Screenshot - iPhone 16 Pro Max - 2025-12-02 at 00.05.28.png" width="200">
</p>
<p align="center">
  <img src="ScreenShots/Simulator Screenshot - iPhone 16 Pro Max - 2025-12-01 at 22.07.13.png" width="200">
  <img src="ScreenShots/Simulator Screenshot - iPhone 16 Plus - 2025-12-10 at 01.31.57.png" width="200">
</p>

## 📖 프로젝트 소개

아마두는 **캘린더**, **시간표**, **메모 관리**를 하나로 통합한 iOS 올인원 앱입니다.
일정이 많은 직장인과 학생들을 위해 설계되었으며, 커스터마이징 가능한 일정 색상과 체크리스트 기능으로 개인화된 일정 관리 경험을 제공합니다. CloudKit을 통한 멀티 디바이스 동기화를 지원합니다.

### 💡 개발 배경

- **v1.0 → v1.5.0 지속적 진화**: 초기 학습용 프로젝트를 실사용자 피드백 기반으로 9회 업데이트
- **Clean Architecture 도입**: 유지보수성과 테스트 용이성을 위한 아키텍처 전면 리팩토링
- **실사용자 피드백 기반 개선**: App Store 배포 후 사용자 요구사항을 반영한 지속적인 기능 개선
- **기술 스택 업그레이드**: MVC → MVVM → Clean Architecture + MVVM
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
| 📱 **홈 화면 위젯** | 캘린더 위젯과 시간표 위젯으로 앱 실행 없이 일정 확인 |

---

## 🏗️ 아키텍처

### Clean Architecture + MVVM

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌──────────────┐         ┌──────────────┐                  │
│  │ViewController│ ─────── │  ViewModel   │                  │
│  │    (View)    │         │              │                  │
│  └──────────────┘         └───────┬──────┘                  │
└───────────────────────────────────┼─────────────────────────┘
                                    │ UseCase 호출
┌───────────────────────────────────┼─────────────────────────┐
│                     Domain Layer  │                          │
│  ┌──────────────┐         ┌───────┴──────┐                  │
│  │    Entity    │         │   UseCase    │                  │
│  │ (도메인 모델) │         │ (비즈니스 로직)│                  │
│  └──────────────┘         └───────┬──────┘                  │
│                                   │ Repository Protocol      │
└───────────────────────────────────┼─────────────────────────┘
                                    │
┌───────────────────────────────────┼─────────────────────────┐
│                      Data Layer   │                          │
│                          ┌────────┴───────┐                  │
│                          │   Repository   │                  │
│                          │   (CoreData)   │                  │
│                          └────────────────┘                  │
└─────────────────────────────────────────────────────────────┘
```

### 아키텍처 선택 이유

| 장점 | 설명 |
|------|------|
| **테스트 용이성** | UseCase와 Repository를 Mock으로 교체하여 단위 테스트 가능 |
| **유지보수성** | 각 레이어가 독립적이어서 변경 영향 범위 최소화 |
| **확장성** | 새 기능 추가 시 기존 코드 수정 없이 확장 가능 |
| **의존성 역전** | 고수준 모듈이 저수준 모듈에 의존하지 않음 |

### 레이어별 구성

| Layer | 구성요소 | 파일 예시 |
|-------|---------|----------|
| **Presentation** | VC + VM (16개) | `CalendarVC`, `CalendarVM` |
| **Domain** | Entity (5개) | `ScheduleItem`, `CategoryItem`, `MemoItem`, `CheckListItem`, `TimeTableItem` |
| **Domain** | UseCase (12개) | `FetchSchedulesUseCase`, `SaveScheduleUseCase`, `DeleteScheduleUseCase` |
| **Domain** | Protocol | `ScheduleRepositoryProtocol`, `CategoryRepositoryProtocol` |
| **Data** | Repository (4개) | `CoreDataScheduleRepository`, `CoreDataCategoryRepository` |
| **Core** | DI Container | `DIContainer` |

### 의존성 주입 (Dependency Injection)

```swift
// DIContainer.swift - 모든 의존성을 중앙에서 관리
final class DIContainer {
    static let shared = DIContainer()

    // UseCase Factory Methods
    func makeFetchSchedulesUseCase() -> FetchSchedulesUseCaseProtocol {
        return FetchSchedulesUseCase(
            repository: makeScheduleRepository(),
            syncService: makeSyncService()
        )
    }

    // ViewModel 의존성 주입
    func injectCalendarVM(_ vm: CalendarVM) {
        vm.injectDependencies(
            fetchSchedulesUseCase: makeFetchSchedulesUseCase(),
            fetchCategoriesUseCase: makeFetchCategoriesUseCase(),
            saveCategoryUseCase: makeSaveCategoryUseCase()
        )
    }
}
```

---

## 🛠 Tech Stack

### **Core Technologies**
| 기술 | 용도 |
|------|------|
| **Swift 5** | iOS 네이티브 개발 |
| **UIKit** | Storyboard + Code 기반 UI |
| **SwiftUI** | 위젯 개발 |
| **Auto Layout** | 반응형 UI 구현 |

### **Architecture & Patterns**
| 패턴 | 적용 |
|------|------|
| **Clean Architecture** | Domain/Data/Presentation 레이어 분리 |
| **MVVM** | View와 비즈니스 로직 분리 (16개 ViewModel) |
| **Repository Pattern** | 데이터 레이어 추상화 |
| **Dependency Injection** | DIContainer를 통한 의존성 관리 |
| **Protocol-Oriented** | 테스트 가능한 인터페이스 설계 |

### **Data & Sync**
| 기술 | 용도 |
|------|------|
| **CoreData** | 로컬 데이터 영구 저장 |
| **CloudKit** | 멀티 디바이스 데이터 동기화 |
| **App Groups** | 메인 앱 ↔ 위젯 데이터 공유 |

### **Modern UIKit**
| 기술 | 용도 |
|------|------|
| **DiffableDataSource** | 효율적인 컬렉션/테이블뷰 데이터 관리 |
| **Compositional Layout** | 유연한 컬렉션뷰 레이아웃 |
| **WidgetKit** | 홈 화면 위젯 |

### **프로젝트 규모**
| 항목 | 수치 |
|------|------|
| **코드 라인** | 약 7,000줄의 Swift 코드 |
| **화면 수** | 20개 이상의 ViewController |
| **ViewModel** | 16개 |
| **UseCase** | 12개 |
| **Repository** | 4개 |
| **Entity** | 5개의 도메인 모델 |
| **위젯** | 2개 (달력, 시간표) |
| **Unit Tests** | UseCase 단위 테스트 |
| **외부 의존성** | 없음 (순수 iOS SDK만 사용) |

---

## 📂 폴더 구조

```
NewCalendar/
├── Core/
│   └── DI/
│       └── DIContainer.swift          # 의존성 주입 컨테이너
├── Domain/
│   ├── Entities/                      # 도메인 모델
│   │   ├── ScheduleItem.swift
│   │   ├── CategoryItem.swift
│   │   ├── MemoItem.swift
│   │   ├── CheckListItem.swift
│   │   └── TimeTableItem.swift
│   ├── UseCases/                      # 비즈니스 로직
│   │   ├── Schedule/
│   │   ├── Category/
│   │   ├── Memo/
│   │   └── TimeTable/
│   └── Protocols/                     # Repository 인터페이스
├── Data/
│   ├── Repositories/                  # CoreData 구현체
│   └── Mappers/                       # Entity ↔ CoreData 변환
├── Calendar/
│   ├── VC/                            # ViewControllers
│   └── VM/                            # ViewModels
├── Category/
│   ├── VC/
│   └── VM/
├── Memo/
│   ├── VC/
│   └── VM/
├── TimeTable/
│   ├── VC/
│   └── VM/
└── Services/
    ├── CloudKitSyncManager.swift
    ├── UserNotificationManager.swift
    └── NetworkSyncManager.swift
```

---

## 🎯 기술적 도전과 해결

### 1️⃣ **Clean Architecture 마이그레이션**

**배경**
기존 MVC/MVVM 구조에서 ViewModel이 CoreData에 직접 의존하여 테스트와 유지보수가 어려움

**문제**
- ViewModel에서 `CoreDataManager.shared` 직접 호출
- `NSManagedObject`가 Presentation 레이어까지 노출
- 단위 테스트 작성 불가능

**해결**
```swift
// Before: ViewModel이 CoreData에 직접 의존
class CalendarVM {
    func fetchSchedules() {
        let context = CoreDataManager.shared.context
        let request = NSFetchRequest<NSManagedObject>(entityName: "Schedule")
        savedEvents = try? context.fetch(request)  // NSManagedObject 직접 사용
    }
}

// After: UseCase를 통한 추상화
class CalendarVM {
    private var fetchSchedulesUseCase: FetchSchedulesUseCaseProtocol?

    func injectDependencies(fetchSchedulesUseCase: FetchSchedulesUseCaseProtocol, ...) {
        self.fetchSchedulesUseCase = fetchSchedulesUseCase
    }

    func fetchSchedules() {
        schedules = fetchSchedulesUseCase?.execute() ?? []  // Domain Entity 사용
    }
}

// Domain Entity - CoreData와 완전히 분리
struct ScheduleItem: Hashable {
    let id: UUID
    let title: String
    let date: Date
    let startDay: Date
    let endDay: Date
    let buttonType: DutyType
    let categoryColor: String
}
```

**성과**
✅ 39개 파일 리팩토링, 1,384줄 레거시 코드 제거
✅ ViewModel이 Domain Entity만 의존하여 테스트 가능
✅ Repository를 Mock으로 교체하여 단위 테스트 작성 가능

---

### 2️⃣ **DiffableDataSource를 활용한 캘린더 최적화**

**배경**
기간 일정(Period Schedule)을 달력에 효율적으로 렌더링해야 함

**문제**
- `reloadData()` 호출 시 전체 셀이 깜빡임
- 기간 일정의 인덱스 계산 중복으로 O(n²) 시간 복잡도

**해결**
```swift
// DiffableDataSource + Hashable Entity
class CalendarVC: UIViewController {
    private var dataSource: UICollectionViewDiffableDataSource<Section, CalendarDateItem>!

    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CalendarDateItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(generateCalendarItems(), toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

// 캐싱을 통한 성능 최적화
class DateCell: UICollectionViewCell {
    static var occupiedIndexesByDate: [Date: [Int: String]] = [:]

    func configure(with events: [...], for date: Date) {
        // 캐시를 확인하여 충돌 체크 - O(1)
        if let occupiedTitle = DateCell.occupiedIndexesByDate[day]?[i] { ... }
    }
}
```

**성과**
✅ O(n²) → O(n) 시간 복잡도 개선
✅ 변경된 셀만 애니메이션으로 부드러운 UI
✅ 대량 데이터에서도 60fps 유지

---

### 3️⃣ **App Group을 통한 위젯-앱 데이터 동기화**

**배경**
메인 앱의 CoreData 변경사항을 위젯이 실시간으로 읽을 수 있도록 동기화

**문제**
- iOS에서 앱과 위젯은 별도의 샌드박스에서 실행되어 데이터를 직접 공유할 수 없음
- 데이터 추가/수정/삭제를 모두 동기화해야 함

**해결**
```swift
// AppDelegate.swift - 메인 앱
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// 엔티티 동기화 (추가/수정/삭제 모두 처리)
    private func syncEntity(entityName: String,
                           from sourceContext: NSManagedObjectContext,
                           to destinationContext: NSManagedObjectContext) {
        // 1. 소스(메인 앱)의 모든 데이터 가져오기
        let sourceObjects = try? sourceContext.fetch(sourceFetch)

        // 2. 소스의 각 항목을 대상에 복사 (추가/수정)
        for sourceObject in sourceObjects {
            self.copyEntity(sourceObject, to: destinationContext)
        }

        // 3. 대상에만 있고 소스에 없는 항목 삭제
        for destObject in destObjects {
            if sourceContext에 없으면 {
                destinationContext.delete(destObject)
            }
        }
    }
}

// WidgetDataManager.swift - 위젯
final class WidgetDataManager {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NewCalendar")
        // App Group의 공유 디렉토리 사용
        let storeURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.Simoni.Amadoo"
        )?.appendingPathComponent("NewCalendar.sqlite")
        ...
    }()
}
```

**성과**
✅ App Groups를 활용한 프로세스 간 데이터 공유
✅ 추가/수정/삭제 자동 동기화
✅ 위젯 타임라인 자동 갱신

---

### 4️⃣ **CloudKit 동기화 및 디바운싱**

**배경**
CloudKit 원격 변경사항을 감지하고, 과도한 알림을 방지

**문제**
- CloudKit에서 여러 변경사항이 짧은 시간에 연속으로 전달
- 불필요한 UI 업데이트 반복

**해결**
```swift
class CloudKitSyncManager {
    private var lastNotificationTime: Date = Date(timeIntervalSince1970: 0)

    @objc private func handleRemoteChange(_ notification: Notification) {
        let now = Date()

        // 마지막 알림으로부터 2초 이내면 무시 (디바운싱)
        if now.timeIntervalSince(lastNotificationTime) < 2.0 {
            return
        }

        lastNotificationTime = now
        NotificationCenter.default.post(name: .cloudKitDataUpdated, object: nil)
    }
}
```

**성과**
✅ 2초 디바운싱으로 중복 알림 제거
✅ UI 깜빡임 방지 및 성능 최적화

---

### 5️⃣ **Protocol 기반 테스트 가능한 설계**

**배경**
UseCase와 Repository를 테스트 가능하게 설계

**해결**
```swift
// Protocol 정의
protocol FetchSchedulesUseCaseProtocol {
    func execute() -> [ScheduleItem]
    func execute(for date: Date) -> [ScheduleItem]
}

// 실제 구현
final class FetchSchedulesUseCase: FetchSchedulesUseCaseProtocol {
    private let repository: ScheduleRepositoryProtocol

    func execute() -> [ScheduleItem] {
        return repository.fetchAll()
    }
}

// Mock 구현 (테스트용)
final class MockFetchSchedulesUseCase: FetchSchedulesUseCaseProtocol {
    var mockSchedules: [ScheduleItem] = []

    func execute() -> [ScheduleItem] {
        return mockSchedules
    }
}

// Unit Test
class ScheduleUseCaseTests: XCTestCase {
    func testFetchSchedules() {
        let mockRepository = MockScheduleRepository()
        let useCase = FetchSchedulesUseCase(repository: mockRepository)

        let result = useCase.execute()

        XCTAssertEqual(result.count, expectedCount)
    }
}
```

**성과**
✅ UseCase 단위 테스트 작성 가능
✅ Repository를 Mock으로 교체하여 독립적 테스트
✅ 의존성 역전 원칙(DIP) 준수

---

## 🔄 버전 히스토리

### 💡 핵심 가치
- **사용자 중심 개발**: 단순한 기능 구현을 넘어 실제 사용자의 문제를 해결
- **지속적 개선**: 9회 연속 업데이트로 입증된 피드백 반영 역량
- **기술적 성장**: MVC → MVVM → Clean Architecture로 단계적 아키텍처 발전
- **완성도 높은 실행력**: 개인 프로젝트를 실제 서비스 수준으로 완성

---

### v1.5.0 (Latest) - Clean Architecture 리팩토링

**주요 변경**
- Clean Architecture + MVVM 패턴 전면 도입
- DIContainer를 통한 의존성 주입 구현
- Domain Layer 분리 (Entity, UseCase, Repository Protocol)
- 레거시 CoreData 직접 접근 코드 완전 제거

**기술 구현**
- 12개 UseCase 구현 (Schedule 3, Category 3, Memo 3, TimeTable 3)
- 4개 Repository 구현 (CoreData 추상화)
- 5개 Domain Entity 정의
- Protocol 기반 테스트 가능한 설계
- DiffableDataSource 전면 적용

**결과**
✅ 39개 파일 리팩토링, 1,384줄 레거시 코드 제거
✅ 단위 테스트 작성 가능한 구조
✅ 유지보수성 및 확장성 대폭 향상

---

### v1.4.6 - 홈 화면 위젯

**추가 기능**
- 캘린더 위젯: 이번 주 7일의 일정 요약을 홈 화면에서 바로 확인
- 시간표 위젯: 월~금 시간표 전체를 위젯으로 표시
- Deep Link (amadoo://): 위젯에서 앱의 특정 화면으로 이동

**기술 구현**
- WidgetKit 프레임워크 활용
- SwiftUI 기반 위젯 UI 구현
- App Group Container를 통한 CoreData 공유
- Timeline Provider로 위젯 데이터 자동 갱신

**결과**
✅ 앱 실행 없이 홈 화면에서 일정 즉시 확인
✅ 사용자 접근성 및 편의성 대폭 향상
✅ UIKit 기반 앱에 SwiftUI 위젯 성공적 통합

---

### v1.4.5 - 시간표 기능 추가

**추가 기능**
- 주간 시간표 관리 시스템
- 요일별/시간대별 일정 등록
- 시간표 전용 UI 및 그리드 레이아웃

**기술 구현**
- CollectionView Compositional Layout 기반 시간표 그리드
- Timetable Entity 추가
- 시간대별 데이터 필터링 로직

**결과**
✅ 직장인과 학생을 위한 올인원 앱으로 진화
✅ 주간 반복 일정 관리 편의성 향상

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
✅ 사용자 편의성 대폭 향상

---

### v1.4.1 - 안정성 개선

**문제**: 새벽 시간대 앱 실행 시 당일 알림 누락 발생
**해결**: 시간 조건부 로직으로 완전 해결
**결과**: ✅ 알림 신뢰도 100% 달성

---

### v1.4 - 알림 시스템

**추가 기능**: 매일 아침 일정 알림 기능 구현
**기술 스택**: UserNotifications 프레임워크 활용

---

### v1.3 - 핵심 기능 확장

**사용자 요청**: 일정 편집 기능 추가 (요청 1순위)
**기술 구현**: CoreData 수정 로직 구현, View 재활용으로 코드 효율성 증대

---

### v1.2 - 편의성 강화

**추가 기능**: 카테고리 즉시 생성 기능
**기술 구현**: View 재활용 패턴, Delegate 패턴 활용

---

### v1.1 - 사용성 개선

**문제**: 일정 등록 과정이 복잡하다는 사용자 피드백
**해결**: 일정 추가 단계 50% 단축
**결과**: ✅ 사용자 만족도 향상

---

### v1.0.0 - 초기 출시

- 기본 캘린더 기능
- 일정 추가/삭제
- 메모 관리 기능

---

## 💭 회고 (Retrospective)

### 잘한 점 ✅

- **아키텍처 진화**: MVC → MVVM → Clean Architecture + MVVM으로 단계적 발전
- **실사용자 중심 개발**: App Store 배포 후 9회 연속 업데이트로 실제 사용자 문제 해결
- **테스트 가능한 설계**: Protocol 기반 설계로 단위 테스트 작성 가능한 구조 구축
- **기술적 성장**: CoreData → CloudKit 동기화, UIKit → SwiftUI 위젯까지 기술 스택 확장
- **완성도 높은 실행력**: 알림 신뢰도 100% 달성, 멀티 디바이스 동기화 구현
- **올인원 솔루션 완성**: 캘린더, 시간표, 메모, 위젯을 하나의 앱에 통합

### 아쉬운 점 📝

- Storyboard 중심 개발로 협업 시 충돌 가능성
- 테스트 커버리지 확대 필요
- CloudKit 동기화 충돌 시나리오에 대한 추가 테스트 필요

### 다음 프로젝트에 적용할 점 🎯

- SwiftUI로 전환하여 선언형 UI 경험
- TDD 방식 도입으로 테스트 커버리지 향상
- Combine/async-await를 활용한 반응형 프로그래밍
- 위젯 다양화 (인터랙티브 위젯)

---

## 🔗 Links

- **GitHub Repository**: [simoni-git/Amadoo_-Official_Code](https://github.com/simoni-git/Amadoo_-Official_Code)
- **App Store**: [아마두 - 일정관리 메모관리 필수앱](https://apps.apple.com/kr/app/%EC%95%84%EB%A7%88%EB%91%90-%EC%9D%BC%EC%A0%95%EA%B4%80%EB%A6%AC-%EB%A9%94%EB%AA%A8%EA%B4%80%EB%A6%AC-%ED%95%84%EC%88%98%EC%95%B1/id6739255155)

---

## 👤 Author

**고민수 (Minsu Go)**
- 📧 Email: gms5889@naver.com
- 💼 GitHub: [@simoni-git](https://github.com/simoni-git)
- 📝 Blog: [네이버 블로그](https://blog.naver.com/gms5889)
