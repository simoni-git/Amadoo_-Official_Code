# 🗓️ 아마두 (Amadoo)
> **캘린더, 시간표, 메모를 한 곳에서 관리하는 올인원 앱**

![Swift](https://img.shields.io/badge/Swift-5.0-orange) ![iOS](https://img.shields.io/badge/iOS-15.0+-blue) ![MVVM](https://img.shields.io/badge/Architecture-MVVM-green) ![CoreData](https://img.shields.io/badge/Database-CoreData-red) ![CloudKit](https://img.shields.io/badge/Sync-CloudKit-blue)

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

- **v1.0 → v1.4.6 지속적 진화**: 초기 학습용 프로젝트를 실사용자 피드백 기반으로 8회 업데이트
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
| 📱 **홈 화면 위젯** | 캘린더 위젯과 시간표 위젯으로 앱 실행 없이 일정 확인 |

---

## 🛠 Tech Stack

### **Core Technologies**
- **Swift** - iOS 네이티브 개발
- **UIKit** - Storyboard + Code 기반 UI
- **SwiftUI** - 위젯 개발
- **Auto Layout** - 반응형 UI 구현

### **Architecture & Patterns**
- **MVVM** - View와 비즈니스 로직 분리 (총 16개 ViewModel)
- **CoreData** - 로컬 데이터 영구 저장
- **CloudKit** - 멀티 디바이스 데이터 동기화

### **Key Features**
- **Multi-Entity Management** - CheckList, Memo, Schedule, Timetable 등 5개 Entity 활용
- **Custom Calendar Cell** - 코드 기반 복잡한 캘린더 셀 렌더링
- **Timetable Grid System** - CollectionView 기반 주간 시간표 구현
- **Dynamic Data Binding** - 실시간 데이터 변경 반영
- **Cloud Synchronization** - NSPersistentCloudKitContainer 기반 자동 동기화
- **WidgetKit Integration** - 홈 화면 위젯으로 빠른 일정 확인
- **App Groups** - 메인 앱 ↔ 위젯 간 데이터 공유

### **프로젝트 규모**
- 코드 라인: 약 6,967줄의 Swift 코드
- 화면 수: 20개 이상의 ViewController
- 데이터 모델: 5개의 CoreData Entity
- 위젯: 2개 (달력, 시간표)
- 외부 의존성: 없음 (순수 iOS SDK만 사용)

---

## 🎯 기술적 도전과 해결

### 1️⃣ **달력 셀 성능 최적화 - 캐싱 메커니즘**

**배경**  
기간 일정(Period Schedule)을 달력에 효율적으로 렌더링해야 함

**문제**  
- 기간 일정(예: 3월 1일~3월 10일)을 달력에 표시할 때, 각 날짜 셀마다 중복 계산이 발생하여 성능 저하
- 달력 42셀을 렌더링할 때 O(n²) 시간 복잡도

**해결**
```swift
class DateCell: UICollectionViewCell {
    // 날짜별로 어떤 인덱스(0~3)에 어떤 일정이 배치되었는지 캐싱
    static var occupiedIndexesByDate: [Date: [Int: String]] = [:]
    private let maxDisplayEvents = 4

    // 날짜 범위를 한 번만 계산하여 재사용 (성능 최적화)
    private func dateRange(from startDate: Date, to endDate: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = DateHelper.shared.startOfDay(for: startDate)
        let end = DateHelper.shared.startOfDay(for: endDate)

        while currentDate <= end {
            dates.append(currentDate)
            guard let nextDate = DateHelper.shared.date(byAddingDays: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }

        return dates
    }

    func configure(with events: [...], for date: Date) {
        // 날짜 범위를 미리 계산 (성능 최적화)
        let dateRangeArray = dateRange(from: startDate, to: endDate)

        for i in 0..<maxDisplayEvents {
            var isConflict = false

            // 캐시를 확인하여 충돌 체크
            for day in dateRangeArray {
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

        // 인덱스 캐싱 (다음 셀에서 재사용)
        for day in dateRangeArray {
            if DateCell.occupiedIndexesByDate[day] == nil {
                DateCell.occupiedIndexesByDate[day] = [:]
            }
            DateCell.occupiedIndexesByDate[day]?[assignedIndex] = title
        }
    }
}
```

**성과**  
✅ `occupiedIndexesByDate` 정적 딕셔너리로 각 날짜별 인덱스 캐싱  
✅ O(n²) → O(n) 시간 복잡도 개선  
✅ CollectionView 성능 최적화로 대량 데이터 렌더링 개선

---

### 2️⃣ **App Group을 통한 위젯-앱 데이터 동기화**

**배경**  
메인 앱의 CoreData 변경사항을 위젯이 실시간으로 읽을 수 있도록 동기화

**문제**  
- iOS에서 앱과 위젯은 별도의 샌드박스에서 실행되어 데이터를 직접 공유할 수 없음
- 데이터 추가/수정/삭제를 모두 동기화해야 함

**해결**
```swift
// AppDelegate.swift - 메인 앱
class AppDelegate: UIResponder, UIApplicationDelegate {

    func syncDataToAppGroup() {
        DispatchQueue.global(qos: .background).async {
            self.copyDataToSharedContainer()
        }
    }

    /// 엔티티 동기화 (추가/수정/삭제 모두 처리)
    private func syncEntity(entityName: String,
                           from sourceContext: NSManagedObjectContext,
                           to destinationContext: NSManagedObjectContext) {
        // 1. 소스(메인 앱)의 모든 데이터 가져오기
        let sourceFetch = NSFetchRequest<NSManagedObject>(entityName: entityName)
        guard let sourceObjects = try? sourceContext.fetch(sourceFetch) else {
            return
        }

        // 2. 대상(공유 저장소)의 모든 데이터 가져오기
        let destFetch = NSFetchRequest<NSManagedObject>(entityName: entityName)
        guard let destObjects = try? destinationContext.fetch(destFetch) else {
            return
        }

        // 3. 소스의 각 항목을 대상에 복사 (추가/수정)
        for sourceObject in sourceObjects {
            self.copyEntity(sourceObject, to: destinationContext)
        }

        // 4. 대상에만 있고 소스에 없는 항목 삭제 (삭제된 항목 제거)
        for destObject in destObjects {
            let predicate = self.createUniquePredicate(for: destObject)
            let checkFetch = NSFetchRequest<NSManagedObject>(entityName: entityName)
            checkFetch.predicate = predicate

            if let matches = try? sourceContext.fetch(checkFetch), matches.isEmpty {
                destinationContext.delete(destObject)
                print("🗑️ 삭제 동기화: \(entityName)")
            }
        }
    }
}

// WidgetDataManager.swift - 위젯
final class WidgetDataManager {
    static let shared = WidgetDataManager()
    private let appGroupIdentifier = "group.Simoni.Amadoo"

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NewCalendar")

        // App Group의 공유 디렉토리 URL 설정
        if let storeURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        )?.appendingPathComponent("NewCalendar.sqlite") {

            let storeDescription = NSPersistentStoreDescription(url: storeURL)
            container.persistentStoreDescriptions = [storeDescription]
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("❌ Widget Core Data 로드 실패: \(error)")
            }
        }

        return container
    }()
}
```

**성과**  
✅ App Groups를 활용한 프로세스 간 데이터 공유  
✅ `syncEntity` 메서드로 추가/수정/삭제 자동 동기화  
✅ iOS App Extension 아키텍처 이해 및 CoreData 동기화 로직 설계

---

### 3️⃣ **CloudKit 동기화 관리 및 디바운싱**

**배경**  
CloudKit 원격 변경사항을 감지하고, 과도한 알림을 방지

**문제**  
- CloudKit에서 여러 변경사항이 짧은 시간에 연속으로 전달되어 UI가 깜빡이고 성능 저하 발생
- 불필요한 UI 업데이트 반복

**해결**
```swift
class CloudKitSyncManager {
    static let shared = CloudKitSyncManager()
    private let container = CKContainer.default()
    private let coreDataManager = CoreDataManager.shared
    private var lastNotificationTime: Date = Date(timeIntervalSince1970: 0)

    // 원격 변경사항 감지 설정
    private func setupRemoteChangeNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRemoteChange),
            name: .NSPersistentStoreRemoteChange,
            object: coreDataManager.persistentContainer.persistentStoreCoordinator
        )
    }

    @objc private func handleRemoteChange(_ notification: Notification) {
        let now = Date()

        // 마지막 알림으로부터 2초 이내면 무시 (디바운싱)
        if now.timeIntervalSince(lastNotificationTime) < 2.0 {
            print("CloudKit 변경 감지 - 너무 빈번함, 무시")
            return
        }

        lastNotificationTime = now
        print("CloudKit에서 데이터 변경 감지됨")

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .cloudKitDataUpdated, object: nil)
        }
    }

    // CloudKit 계정 상태 상세 확인
    func checkDetailedAccountStatus(completion: @escaping (CloudKitStatus, String?) -> Void) {
        container.accountStatus { status, error in
            DispatchQueue.main.async {
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
                case .restricted:
                    completion(.restricted, "iCloud 사용이 제한되어 있습니다")
                case .couldNotDetermine:
                    completion(.unknown, "iCloud 상태를 확인할 수 없습니다")
                @unknown default:
                    completion(.unknown, "알 수 없는 오류가 발생했습니다")
                }
            }
        }
    }
}
```

**성과**  
✅ 마지막 알림 시간 추적으로 2초 이내 중복 알림 무시 (디바운싱)  
✅ 불필요한 UI 업데이트 방지 및 네트워크 효율성 개선  
✅ iCloud 계정 상태 및 용량 체크로 오류 사전 방지

---

### 4️⃣ **SwiftUI 위젯 구현 - 기간 일정 시각화**

**배경**  
위젯의 제한된 공간에서 기간 일정을 연속된 막대로 자연스럽게 표현

**문제**  
- 기간 일정(예: 3일간 여행)을 위젯에서 연결된 막대로 표시해야 함
- 시작일/중간일/종료일 구분 필요

**해결**
```swift
// MARK: - Schedule Block
struct ScheduleBlock: View {
    let schedule: ScheduleData
    let width: CGFloat

    var body: some View {
        Group {
            if schedule.isPeriod {
                // 기간 일정: 컬럼 전체 너비 사용 (연결되어 보이도록)
                if schedule.isStart {
                    // 시작일: 제목 표시, 좌측만 둥근 모서리, 우측은 직선
                    Text(schedule.title)
                        .font(.system(size: 8))
                        .lineLimit(1)
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .background(Color.fromHex(schedule.color))
                        .cornerRadius(3, corners: [.topLeft, .bottomLeft])
                } else if schedule.isEnd {
                    // 종료일: 제목 없음, 우측만 둥근 모서리, 좌측은 직선
                    Color.fromHex(schedule.color)
                        .cornerRadius(3, corners: [.topRight, .bottomRight])
                } else {
                    // 중간일: 제목 없음, 모서리 없이 직선 (막대 연결)
                    Color.fromHex(schedule.color)
                }
            } else {
                // 단일 일정: 전체 모서리 둥글게
                Text(schedule.title)
                    .font(.system(size: 8))
                    .lineLimit(1)
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .background(Color.fromHex(schedule.color))
                    .cornerRadius(3)
            }
        }
        .frame(width: width, height: 16, alignment: .leading)
    }
}

// 특정 모서리만 둥글게 만드는 커스텀 Shape
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
```

**성과**  
✅ `isStart`, `isEnd` 플래그로 코너 라운딩 조건부 적용  
✅ 시작일에만 제목 표시, 중간~끝은 색상 막대만 표시하여 연결감 구현  
✅ 커스텀 Shape를 활용한 세밀한 UI 제어

---

### 5️⃣ **일정 알림 자동 스케줄링**

**배경**  
사용자에게 매일 오전 7시에 일정 개수를 알려주는 알림 시스템

**문제**  
- 이미 지나간 시간에는 알림을 등록하지 않아야 함
- 7일치 알림을 효율적으로 관리해야 함

**해결**
```swift
class UserNotificationManager {
    static let shared = UserNotificationManager()

    func updateNotification() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests() // 기존 알림 제거

        let now = Date()
        let calendar = Calendar.current

        // 오늘 오전 7시
        guard let today7AM = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: now) else {
            print("❌ Error: Unable to create 7AM time for today")
            return
        }

        // 오늘 포함 7일 동안 반복
        for i in 0...6 {
            let content = UNMutableNotificationContent()

            // i일 후의 날짜 계산
            let triggerDate = calendar.date(byAdding: .day, value: i, to: now) ?? now

            // 해당 날짜의 오전 7시 설정
            var triggerDateComponents = calendar.dateComponents([.year, .month, .day], from: triggerDate)
            triggerDateComponents.hour = 7
            triggerDateComponents.minute = 0
            triggerDateComponents.second = 0

            // 해당 날짜의 일정 개수 확인 (CoreData 쿼리)
            let itemCount = fetchItemCount(for: triggerDate)

            content.title = "아마두"
            content.body = "오늘은 \(itemCount)개의 일정이 있군요! \n새로운 하루, 새로운 기회!"
            content.sound = .default

            let trigger: UNNotificationTrigger?

            if i == 0 {
                // 오늘의 알림: 오전 7시 이전이면 등록, 이후면 등록 안 함
                if now < today7AM {
                    trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
                    print("오늘 오전 7시 알림 등록 예정")
                } else {
                    trigger = nil
                    print("오늘 오전 7시가 이미 지나서 알림을 등록하지 않음")
                }
            } else {
                // 내일부터 6일간 알림 등록
                trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
                print("\(i)일 후 오전 7시 알림 등록 예정")
            }

            // 트리거가 nil이 아닐 때만 알림 추가
            if let validTrigger = trigger {
                let request = UNNotificationRequest(identifier: "day\(i)_notification", content: content, trigger: validTrigger)

                notificationCenter.add(request) { error in
                    if let error = error {
                        print("\(i)일 후 알림 등록 실패: \(error.localizedDescription)")
                    } else {
                        print("\(i)일 후 알림 등록 성공")
                    }
                }
            }
        }
    }

    // CoreData에서 특정 날짜의 일정 개수 가져오기
    func fetchItemCount(for date: Date) -> Int {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Schedule")
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        fetchRequest.predicate = NSPredicate(format: "date == %@", startOfDay as CVarArg)

        do {
            let results = try context.fetch(fetchRequest)
            return results.count
        } catch {
            print("일정 개수 가져오기 실패: \(error.localizedDescription)")
            return 0
        }
    }
}
```

**성과**  
✅ 오늘 7시가 이미 지났는지 확인하고 조건부로 알림 등록  
✅ 7일치 알림을 한 번에 예약하여 매일 코드 실행 불필요  
✅ CoreData 쿼리를 통한 실시간 일정 개수 계산

---

## 🔄 버전 히스토리

### 💡 핵심 가치
- **사용자 중심 개발**: 단순한 기능 구현을 넘어 실제 사용자의 문제를 해결
- **지속적 개선**: 8회 연속 업데이트로 입증된 피드백 반영 역량
- **완성도 높은 실행력**: 개인 프로젝트를 실제 서비스 수준으로 완성
- **올인원 솔루션**: 캘린더, 시간표, 메모를 하나의 앱에 통합

---

### v1.4.6 (Latest) - 홈 화면 위젯

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

- **실사용자 중심 개발**: App Store 배포 후 8회 연속 업데이트로 실제 사용자 문제 해결
- **기술적 성장**: Storyboard → 코드 기반 UI, CoreData → CloudKit 동기화, UIKit → SwiftUI 위젯까지 단계적 발전
- **완성도 높은 실행력**: 알림 신뢰도 100% 달성, 멀티 디바이스 동기화 구현, 홈 화면 위젯 제공 등 실제 서비스 수준 완성
- **체계적 문제 해결**: 각 버전마다 명확한 문제 정의 → 해결 → 검증 프로세스
- **올인원 솔루션 완성**: 캘린더, 시간표, 메모, 위젯을 하나의 앱에 통합하여 사용자 편의성 극대화
- **다양한 사용자층 확보**: 직장인, 학생 등 일정이 많은 모든 사용자를 위한 범용 앱으로 발전

### 아쉬운 점 📝

- Storyboard 중심 개발로 협업 시 충돌 가능성
- 테스트 코드 부재로 리팩토링 시 불안감
- CloudKit 동기화 충돌 시나리오에 대한 추가 테스트 필요
- 시간표 기능의 더 세밀한 시간 단위 설정 필요

### 다음 프로젝트에 적용할 점 🎯

- SwiftUI로 전환하여 선언형 UI 경험
- Unit Test 도입으로 안정성 강화
- 위젯 다양화 (다양한 크기, 인터랙티브 위젯)
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
