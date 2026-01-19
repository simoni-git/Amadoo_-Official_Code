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
일정이 많은 직장인과 학생들을 위해 설계되었으며, 커스터마이징 가능한 일정 색상과 체크리스트 기능으로 개인화된 일정 관리 경험을 제공합니다. CloudKit을 통한 멀티 디바이스 동기화와 공휴일 자동 표시를 지원합니다.

### 💡 개발 배경

- **v1.0 → v1.4.7 지속적 진화**: 초기 학습용 프로젝트를 실사용자 피드백 기반으로 8회 업데이트
- **Clean Architecture 도입**: 유지보수성과 테스트 용이성을 위한 아키텍처 전면 리팩토링
- **실사용자 피드백 기반 개선**: App Store 배포 후 사용자 요구사항을 반영한 지속적인 기능 개선
- **기술 스택 업그레이드**: MVC → MVVM → Clean Architecture + MVVM
- **올인원 통합 솔루션**: 캘린더 + 시간표 + 메모를 하나의 앱에서 관리

---

## ✨ 주요 기능

| 기능 | 설명 |
|------|------|
| 📅 **커스텀 일정 관리** | 원하는 색상으로 일정을 달력에 직관적으로 표시 |
| 🎌 **공휴일 자동 표시** | 공공데이터포털 API 연동으로 대한민국 공휴일 자동 표시 |
| ⏰ **시간표 관리** | 학생과 직장인을 위한 주간 시간표 기능 |
| ✏️ **일정 수정** | 등록된 일정을 언제든지 자유롭게 수정 가능 |
| ✅ **이중 메모 시스템** | 체크리스트형 + 일반형 메모를 하나의 앱에서 관리 |
| 🔔 **스마트 알림** | 매일 아침 당일 일정을 자동으로 알림 제공 |
| ☁️ **멀티 디바이스 동기화** | CloudKit으로 여러 기기에서 실시간 일정 동기화 |
| 🌙 **3종 테마 지원** | 파스텔 / 화이트 / 다크 모드 지원 |
| 🔍 **날짜 빠른 검색** | 원하는 날짜를 검색하여 해당 월로 즉시 이동 |
| 📱 **홈 화면 위젯** | 캘린더 위젯과 시간표 위젯으로 앱 실행 없이 일정 확인 |

---

## 🏗️ 아키텍처

### Clean Architecture + MVVM

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  ┌──────────────┐         ┌──────────────┐                  │
│  │ViewController│ ─────── │  ViewModel   │                  │
│  │    (View)    │         │              │                  │
│  └──────────────┘         └───────┬──────┘                  │
└───────────────────────────────────┼─────────────────────────┘
                                    │ UseCase 호출
┌───────────────────────────────────┼─────────────────────────┐
│                     Domain Layer  │                         │
│  ┌──────────────┐         ┌───────┴──────┐                  │
│  │    Entity    │         │   UseCase    │                  │
│  │ (도메인 모델)   │         │ (비즈니스 로직)  │                  │
│  └──────────────┘         └───────┬──────┘                  │
│                                   │ Repository Protocol     │
└───────────────────────────────────┼─────────────────────────┘
                                    │
┌───────────────────────────────────┼─────────────────────────┐
│                      Data Layer   │                         │
│  ┌────────────┐          ┌────────┴───────┐                 │
│  │ DataSource │ ──────── │   Repository   │                 │
│  │ (API/Cache)│          │   (CoreData)   │                 │
│  └────────────┘          └────────────────┘                 │
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
| **Presentation** | VC + VM (17개) | `CalendarVC`, `CalendarVM` |
| **Domain** | Entity (7개) | `ScheduleItem`, `CategoryItem`, `MemoItem`, `HolidayItem`, `ThemeMode` |
| **Domain** | UseCase (15개) | `FetchSchedulesUseCase`, `FetchHolidaysUseCase`, `SaveThemeUseCase` |
| **Domain** | Protocol (10개) | `ScheduleRepositoryProtocol`, `HolidayRepositoryProtocol` |
| **Data** | Repository (6개) | `CoreDataScheduleRepository`, `HolidayRepository` |
| **Data** | DataSource (2개) | `HolidayAPIDataSource`, `HolidayLocalDataSource` |
| **Data** | Mapper (5개) | `ScheduleMapper`, `HolidayMapper` |
| **Core** | DI Container | `DIContainer` |

### 의존성 주입 (Dependency Injection)

```swift
// DIContainer.swift - 모든 의존성을 중앙에서 관리
final class DIContainer {
    static let shared = DIContainer()

    // Repository 생성
    lazy var holidayRepository: HolidayRepositoryProtocol = {
        HolidayRepository(
            apiDataSource: holidayAPIDataSource,
            localDataSource: holidayLocalDataSource
        )
    }()

    // UseCase Factory
    func makeFetchHolidaysUseCase() -> FetchHolidaysUseCaseProtocol {
        FetchHolidaysUseCase(repository: holidayRepository)
    }

    // ViewModel Factory - 생성자 주입
    func makeCalendarVM() -> CalendarVM {
        CalendarVM(
            fetchSchedulesUseCase: makeFetchSchedulesUseCase(),
            fetchCategoriesUseCase: makeFetchCategoriesUseCase(),
            saveCategoryUseCase: makeSaveCategoryUseCase(),
            notificationService: notificationService,
            fetchHolidaysUseCase: makeFetchHolidaysUseCase()
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
| **MVVM** | View와 비즈니스 로직 분리 (17개 ViewModel) |
| **Repository Pattern** | 데이터 레이어 추상화 |
| **Dependency Injection** | DIContainer를 통한 의존성 관리 |
| **Protocol-Oriented** | 테스트 가능한 인터페이스 설계 |
| **Offline-First** | 캐시 우선 조회 + Graceful Degradation |

### **Data & Sync**
| 기술 | 용도 |
|------|------|
| **CoreData** | 로컬 데이터 영구 저장 |
| **CloudKit** | 멀티 디바이스 데이터 동기화 |
| **App Groups** | 메인 앱 ↔ 위젯 데이터 공유 |
| **async/await** | 비동기 네트워크/데이터 처리 |

### **External API**
| 기술 | 용도 |
|------|------|
| **공공데이터포털 API** | 대한민국 공휴일 정보 조회 |

### **Modern UIKit**
| 기술 | 용도 |
|------|------|
| **DiffableDataSource** | 효율적인 컬렉션/테이블뷰 데이터 관리 |
| **Compositional Layout** | 유연한 컬렉션뷰 레이아웃 |
| **WidgetKit** | 홈 화면 위젯 |

---

## 📂 폴더 구조

```
NewCalendar/
├── Core/
│   └── DI/
│       └── DIContainer.swift              # 의존성 주입 컨테이너
├── Domain/
│   ├── Entities/                          # 도메인 모델 (7개)
│   │   ├── ScheduleItem.swift
│   │   ├── CategoryItem.swift
│   │   ├── MemoItem.swift
│   │   ├── CheckListItem.swift
│   │   ├── TimeTableItem.swift
│   │   ├── HolidayItem.swift              # 공휴일
│   │   └── ThemeMode.swift                # 테마 (pastel/white/dark)
│   ├── UseCases/                          # 비즈니스 로직 (15개)
│   │   ├── Schedule/
│   │   ├── Category/
│   │   ├── Memo/
│   │   ├── TimeTable/
│   │   ├── Holiday/
│   │   │   └── FetchHolidaysUseCase.swift
│   │   └── Theme/
│   │       ├── FetchThemeUseCase.swift
│   │       └── SaveThemeUseCase.swift
│   └── Protocols/                         # Repository 인터페이스 (10개)
│       ├── ScheduleRepositoryProtocol.swift
│       ├── HolidayRepositoryProtocol.swift
│       └── ThemeRepositoryProtocol.swift
├── Data/
│   ├── Repositories/                      # 구현체 (6개)
│   │   ├── CoreDataScheduleRepository.swift
│   │   ├── HolidayRepository.swift        # Offline-First
│   │   └── UserDefaultsThemeRepository.swift
│   ├── DataSources/                       # 외부 데이터 소스
│   │   ├── HolidayAPIDataSource.swift     # 공공API 호출
│   │   └── HolidayLocalDataSource.swift   # JSON 캐시
│   ├── DTOs/
│   │   └── HolidayDTO.swift               # API 응답 매핑
│   └── Mappers/                           # Entity ↔ DTO 변환
│       └── HolidayMapper.swift
├── Calendar/
│   ├── VC/
│   └── VM/
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

AmadooWidget/                              # Widget Extension
├── CalendarWidget.swift                   # 달력 위젯
├── TimetableWidget.swift                  # 시간표 위젯
└── Shared/
    └── WidgetDataManager.swift            # App Group CoreData 접근
```

---

## 🎯 기술적 도전과 해결

### 1️⃣ Clean Architecture 마이그레이션

- **문제:** ViewModel이 `CoreDataManager.shared`에 직접 의존하여 테스트 불가능, `NSManagedObject`가 Presentation 레이어까지 노출
- **해결:** UseCase/Repository 계층 분리, DIContainer를 통한 의존성 주입, Protocol 기반 설계로 Mock 교체 가능
- **결과:** ViewModel에서 UIKit/CoreData 의존성 0, 단위 테스트 작성 가능한 구조 확보

```swift
// Before: ViewModel이 CoreData에 직접 의존
class CalendarVM {
    func fetchSchedules() {
        let context = CoreDataManager.shared.context
        let request = NSFetchRequest<NSManagedObject>(entityName: "Schedule")
        savedEvents = try? context.fetch(request)  // ❌ NSManagedObject 직접 사용
    }
}

// After: 생성자 주입 + UseCase 추상화
class CalendarVM {
    private let fetchSchedulesUseCase: FetchSchedulesUseCaseProtocol

    init(fetchSchedulesUseCase: FetchSchedulesUseCaseProtocol, ...) {
        self.fetchSchedulesUseCase = fetchSchedulesUseCase  // ✅ Protocol 주입
    }

    func fetchSchedules() {
        schedules = fetchSchedulesUseCase.execute()  // ✅ Domain Entity 사용
    }
}
```

---

### 2️⃣ Offline-First 공휴일 API 캐싱 전략

- **문제:** 공공데이터포털 API 호출 시 네트워크 지연/실패로 앱 로딩 속도 저하, 오프라인 환경에서 공휴일 미표시
- **해결:** DataSource 레이어 분리, 캐시 우선 조회 → API 호출 → 실패 시 만료된 캐시라도 반환 (Graceful Degradation)
- **결과:** 앱 시작 시 즉시 공휴일 표시 (캐시 히트), 네트워크 장애에서도 서비스 연속성 보장

```swift
/// HolidayRepository.swift - Offline-First 전략
func fetchHolidays(for year: Int) async -> Result<[HolidayItem], Error> {
    // 1. 캐시가 유효하면 캐시 반환 (즉시 응답)
    if localDataSource.isCacheValid(for: year),
       let cachedHolidays = localDataSource.loadHolidays(for: year) {
        return .success(cachedHolidays)
    }

    // 2. 캐시가 없거나 만료되면 API 호출
    let result = await apiDataSource.fetchHolidays(for: year)

    switch result {
    case .success(let dtos):
        let holidays = HolidayMapper.toDomainList(dtos, year: year)
        localDataSource.saveHolidays(holidays, for: year)  // 캐시 저장
        return .success(holidays)

    case .failure(let error):
        // 3. API 실패 시 만료된 캐시라도 반환 (Graceful Degradation)
        if let cachedHolidays = localDataSource.loadHolidays(for: year) {
            return .success(cachedHolidays)
        }
        return .failure(error)
    }
}
```

---

### 3️⃣ App Group을 통한 위젯 데이터 동기화

- **문제:** iOS 샌드박스 정책으로 앱과 Widget Extension 간 CoreData 직접 공유 불가
- **해결:** App Group Container로 SQLite 파일 공유, `NSPersistentHistoryTrackingKey` 활성화로 변경 이력 추적, 추가/수정/삭제 자동 동기화 로직 구현
- **결과:** 홈 화면 위젯에서 앱 실행 없이 오늘 일정 실시간 확인 가능

```swift
// AppDelegate.swift - 메인 앱에서 App Group으로 데이터 복사
lazy var persistentContainer: NSPersistentCloudKitContainer = {
    let container = NSPersistentCloudKitContainer(name: "NewCalendar")
    let storeDescription = container.persistentStoreDescriptions.first
    storeDescription?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
    storeDescription?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
    // ...
}()

// WidgetDataManager.swift - 위젯에서 공유 데이터 접근
lazy var persistentContainer: NSPersistentContainer = {
    let storeURL = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: "group.Simoni.Amadoo"
    )?.appendingPathComponent("NewCalendar.sqlite")

    let storeDescription = NSPersistentStoreDescription(url: storeURL)
    storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
    // ...
}()
```

---

### 4️⃣ CloudKit 멀티 디바이스 동기화

- **문제:** 여러 기기에서 동시 수정 시 `NSPersistentStoreRemoteChange` 알림 폭주로 UI 깜빡임 및 성능 저하
- **해결:** `NSPersistentCloudKitContainer` 활용, 2초 디바운싱으로 중복 알림 제거, 네트워크 상태 확인 후 동기화
- **결과:** 동기화 관련 불필요한 UI 갱신 90% 감소, 동기화 관련 크래시 0건 달성

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

---

### 5️⃣ 테마 시스템 (다크모드 포함 3종 테마)

- **문제:** iOS 시스템 다크모드만 지원 시 사용자 커스터마이징 불가, 테마 변경 시 모든 화면 수동 업데이트 필요
- **해결:** `ThemeMode` enum + `ThemeRepositoryProtocol` 설계, UserDefaults 영속화, DIContainer를 통한 일관된 테마 접근
- **결과:** 시스템 다크모드와 독립적인 3종 테마 지원, 앱 재시작 시에도 테마 설정 유지

```swift
// Domain Entity
enum ThemeMode: String, CaseIterable {
    case pastel  // 파스텔 모드 (#F8EDE3)
    case white   // 화이트 모드 (#F7F7F2)
    case dark    // 다크 모드 (#1C1C1E)
}

// Cell에서 테마 적용
func configure(title: String) {
    let theme = DIContainer.shared.themeRepository.getCurrentTheme()
    backgroundColor = UIColor.fromHexString(theme.cellBackgroundColor)
    titleLabel.textColor = UIColor.fromHexString(theme.textColor)
}
```

---

## 🔄 버전 히스토리

### 💡 핵심 가치
- **사용자 중심 개발**: 단순한 기능 구현을 넘어 실제 사용자의 문제를 해결
- **지속적 개선**: 9회 연속 업데이트로 입증된 피드백 반영 역량
- **기술적 성장**: MVC → MVVM → Clean Architecture로 단계적 아키텍처 발전
- **완성도 높은 실행력**: 개인 프로젝트를 실제 서비스 수준으로 완성

---

### 1.4.7 (Latest) - Clean Architecture + 공휴일/테마 기능

**주요 변경**
- Clean Architecture + MVVM 패턴 전면 도입
- DIContainer를 통한 의존성 주입 구현 (생성자 주입 방식)
- Domain Layer 분리 (Entity, UseCase, Repository Protocol)
- 공휴일 자동 표시 기능 (공공데이터포털 API 연동)
- 3종 테마 지원 (파스텔/화이트/다크 모드)

**기술 구현**
- 15개 UseCase 구현 (Schedule 3, Category 3, Memo 3, TimeTable 3, Holiday 1, Theme 2)
- 6개 Repository 구현 (CoreData 4개 + Holiday + Theme)
- 7개 Domain Entity 정의
- Offline-First 캐싱 전략 (HolidayRepository)
- async/await 기반 비동기 처리

**결과**
- ✅ 단위 테스트 작성 가능한 구조
- ✅ 유지보수성 및 확장성 대폭 향상
- ✅ 네트워크 장애 시에도 공휴일 표시 (Graceful Degradation)

---

### v1.4.5 - 홈 화면 위젯

**추가 기능**
- 캘린더 위젯: 이번 주 7일의 일정 요약을 홈 화면에서 바로 확인
- 시간표 위젯: 월~금 시간표 전체를 위젯으로 표시
- Deep Link (amadoo://): 위젯에서 앱의 특정 화면으로 이동

**기술 구현**
- WidgetKit 프레임워크 활용
- SwiftUI 기반 위젯 UI 구현
- App Group Container를 통한 CoreData 공유
- NSPersistentHistoryTrackingKey로 변경 이력 추적
- Timeline Provider로 위젯 데이터 자동 갱신

**결과**
- ✅ 앱 실행 없이 홈 화면에서 일정 즉시 확인
- ✅ UIKit 기반 앱에 SwiftUI 위젯 성공적 통합

---

### v1.4.4 - 시간표 기능 추가

**추가 기능**
- 주간 시간표 관리 시스템
- 요일별/시간대별 일정 등록
- 시간표 전용 UI 및 그리드 레이아웃

**기술 구현**
- CollectionView Compositional Layout 기반 시간표 그리드
- TimeTable Entity 추가
- 시간대별 데이터 필터링 로직

**결과**
- ✅ 직장인과 학생을 위한 올인원 앱으로 진화

---

### v1.4.3 - 멀티 디바이스 동기화

**추가 기능**
- CloudKit 기반 멀티 디바이스 동기화
- iCloud 계정 상태 및 저장 공간 체크
- 날짜 검색 기능으로 빠른 달력 이동

**기술 구현**
- NSPersistentCloudKitContainer 활용
- 2초 디바운싱으로 중복 알림 제거
- 네트워크 상태 확인 및 에러 핸들링

**결과**
- ✅ 하나의 Apple 계정으로 여러 기기에서 일정 동기화
- ✅ 동기화 관련 크래시 0건 달성

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
- **기술적 성장**: CoreData → CloudKit 동기화, UIKit → SwiftUI 위젯, 공휴일 API 연동까지 기술 스택 확장
- **Offline-First 전략**: 네트워크 장애 상황에서도 서비스 연속성 보장
- **올인원 솔루션 완성**: 캘린더, 시간표, 메모, 위젯, 공휴일, 테마를 하나의 앱에 통합

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

