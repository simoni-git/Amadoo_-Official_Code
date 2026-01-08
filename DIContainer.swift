//
//  DIContainer.swift
//  NewCalendar
//
//  Core - 의존성 주입 컨테이너
//

import Foundation

/// 의존성 주입 컨테이너
/// 모든 의존성을 중앙에서 관리하고 주입합니다.
final class DIContainer {

    // MARK: - Singleton

    static let shared = DIContainer()

    private init() {}

    // MARK: - Core Data Provider

    lazy var contextProvider: CoreDataContextProviding = {
        return CoreDataContextProvider.shared
    }()

    // MARK: - App Group Sync

    /// AppGroupSyncable 의존성 설정 (AppDelegate에서 호출)
    func setAppGroupSync(_ sync: AppGroupSyncable) {
        CoreDataContextProvider.shared.setAppGroupSync(sync)
    }

    // MARK: - Services

    lazy var networkService: NetworkServiceProtocol = {
        return NetworkMonitorService()
    }()

    lazy var syncService: SyncServiceProtocol = {
        return CloudKitSyncService(networkService: networkService)
    }()

    lazy var notificationService: NotificationServiceProtocol = {
        return UserNotificationManager.shared
    }()

    // MARK: - Repositories

    lazy var scheduleRepository: ScheduleRepositoryProtocol = {
        return CoreDataScheduleRepository(contextProvider: contextProvider)
    }()

    lazy var categoryRepository: CategoryRepositoryProtocol = {
        return CoreDataCategoryRepository(contextProvider: contextProvider)
    }()

    lazy var timeTableRepository: TimeTableRepositoryProtocol = {
        return CoreDataTimeTableRepository(contextProvider: contextProvider)
    }()

    lazy var memoRepository: MemoRepositoryProtocol = {
        return CoreDataMemoRepository(contextProvider: contextProvider)
    }()

    // MARK: - Schedule UseCases

    func makeFetchSchedulesUseCase() -> FetchSchedulesUseCaseProtocol {
        return FetchSchedulesUseCase(repository: scheduleRepository)
    }

    func makeSaveScheduleUseCase() -> SaveScheduleUseCaseProtocol {
        return SaveScheduleUseCase(repository: scheduleRepository, syncService: syncService)
    }

    func makeDeleteScheduleUseCase() -> DeleteScheduleUseCaseProtocol {
        return DeleteScheduleUseCase(repository: scheduleRepository, syncService: syncService)
    }

    // MARK: - Category UseCases

    func makeFetchCategoriesUseCase() -> FetchCategoriesUseCaseProtocol {
        return FetchCategoriesUseCase(repository: categoryRepository)
    }

    func makeSaveCategoryUseCase() -> SaveCategoryUseCaseProtocol {
        return SaveCategoryUseCase(repository: categoryRepository, syncService: syncService)
    }

    func makeDeleteCategoryUseCase() -> DeleteCategoryUseCaseProtocol {
        return DeleteCategoryUseCase(repository: categoryRepository, syncService: syncService)
    }

    // MARK: - TimeTable UseCases

    func makeFetchTimeTableUseCase() -> FetchTimeTableUseCaseProtocol {
        return FetchTimeTableUseCase(repository: timeTableRepository)
    }

    func makeSaveTimeTableUseCase() -> SaveTimeTableUseCaseProtocol {
        return SaveTimeTableUseCase(repository: timeTableRepository, syncService: syncService)
    }

    func makeDeleteTimeTableUseCase() -> DeleteTimeTableUseCaseProtocol {
        return DeleteTimeTableUseCase(repository: timeTableRepository, syncService: syncService)
    }

    // MARK: - Memo UseCases

    func makeFetchMemoUseCase() -> FetchMemoUseCaseProtocol {
        return FetchMemoUseCase(repository: memoRepository)
    }

    func makeSaveMemoUseCase() -> SaveMemoUseCaseProtocol {
        return SaveMemoUseCase(repository: memoRepository, syncService: syncService)
    }

    func makeDeleteMemoUseCase() -> DeleteMemoUseCaseProtocol {
        return DeleteMemoUseCase(repository: memoRepository, syncService: syncService)
    }
}

// MARK: - ViewModel Factory Extension

extension DIContainer {

    // MARK: - Calendar ViewModels Factory

    /// CalendarVM 생성
    func makeCalendarVM() -> CalendarVM {
        return CalendarVM(
            fetchSchedulesUseCase: makeFetchSchedulesUseCase(),
            fetchCategoriesUseCase: makeFetchCategoriesUseCase(),
            saveCategoryUseCase: makeSaveCategoryUseCase(),
            notificationService: notificationService
        )
    }

    /// AddDutyVM 생성
    func makeAddDutyVM() -> AddDutyVM {
        return AddDutyVM(
            saveScheduleUseCase: makeSaveScheduleUseCase(),
            deleteScheduleUseCase: makeDeleteScheduleUseCase(),
            fetchCategoriesUseCase: makeFetchCategoriesUseCase(),
            notificationService: notificationService
        )
    }

    /// DetailDutyVM 생성
    func makeDetailDutyVM() -> DetailDutyVM {
        return DetailDutyVM(
            fetchSchedulesUseCase: makeFetchSchedulesUseCase(),
            deleteScheduleUseCase: makeDeleteScheduleUseCase(),
            notificationService: notificationService
        )
    }

    // MARK: - Category ViewModels Factory

    /// CategoryVM 생성
    func makeCategoryVM() -> CategoryVM {
        return CategoryVM(
            fetchCategoriesUseCase: makeFetchCategoriesUseCase(),
            deleteCategoryUseCase: makeDeleteCategoryUseCase()
        )
    }

    /// EditCategoryVM 생성
    func makeEditCategoryVM() -> EditCategoryVM {
        return EditCategoryVM(
            saveCategoryUseCase: makeSaveCategoryUseCase(),
            fetchCategoriesUseCase: makeFetchCategoriesUseCase()
        )
    }

    /// SelectCategoryVM 생성
    func makeSelectCategoryVM() -> SelectCategoryVM {
        return SelectCategoryVM(
            fetchCategoriesUseCase: makeFetchCategoriesUseCase()
        )
    }

    /// CategoryDeletePopupVM 생성
    func makeCategoryDeletePopupVM() -> CategoryDeletePopupVM {
        return CategoryDeletePopupVM(
            deleteCategoryUseCase: makeDeleteCategoryUseCase()
        )
    }

    // MARK: - TimeTable ViewModels Factory

    /// TimeTableVM 생성
    func makeTimeTableVM() -> TimeTableVM {
        return TimeTableVM(
            fetchTimeTableUseCase: makeFetchTimeTableUseCase(),
            deleteTimeTableUseCase: makeDeleteTimeTableUseCase()
        )
    }

    /// AddTimeVM 생성
    func makeAddTimeVM(selectedHour: Int, minimumHour: Int, maximumHour: Int, dayOfWeek: Int) -> AddTimeVM {
        return AddTimeVM(
            selectedHour: selectedHour,
            minimumHour: minimumHour,
            maximumHour: maximumHour,
            dayOfWeek: dayOfWeek,
            saveTimeTableUseCase: makeSaveTimeTableUseCase(),
            fetchTimeTableUseCase: makeFetchTimeTableUseCase()
        )
    }

    /// EditTimeVM 생성
    func makeEditTimeVM(timetable: TimeTableItem, minimumHour: Int, maximumHour: Int) -> EditTimeVM {
        return EditTimeVM(
            timetable: timetable,
            minimumHour: minimumHour,
            maximumHour: maximumHour,
            saveTimeTableUseCase: makeSaveTimeTableUseCase(),
            deleteTimeTableUseCase: makeDeleteTimeTableUseCase(),
            fetchTimeTableUseCase: makeFetchTimeTableUseCase()
        )
    }

    // MARK: - Memo ViewModels Factory

    /// MemoVM 생성
    func makeMemoVM() -> MemoVM {
        return MemoVM(
            fetchMemoUseCase: makeFetchMemoUseCase(),
            deleteMemoUseCase: makeDeleteMemoUseCase()
        )
    }

    /// AddDefaultVerMemoVM 생성
    func makeAddDefaultVerMemoVM() -> AddDefaultVerMemoVM {
        return AddDefaultVerMemoVM(
            saveMemoUseCase: makeSaveMemoUseCase()
        )
    }

    /// AddCheckVerMemoVM 생성
    func makeAddCheckVerMemoVM() -> AddCheckVerMemoVM {
        return AddCheckVerMemoVM(
            saveMemoUseCase: makeSaveMemoUseCase()
        )
    }

    /// MemoDefaultVerDetailVM 생성
    func makeMemoDefaultVerDetailVM() -> MemoDefaultVerDetailVM {
        return MemoDefaultVerDetailVM(
            deleteMemoUseCase: makeDeleteMemoUseCase()
        )
    }

    /// MemoCheckVerDetailVM 생성
    func makeMemoCheckVerDetailVM() -> MemoCheckVerDetailVM {
        return MemoCheckVerDetailVM(
            fetchMemoUseCase: makeFetchMemoUseCase(),
            saveMemoUseCase: makeSaveMemoUseCase(),
            deleteMemoUseCase: makeDeleteMemoUseCase()
        )
    }

    /// EditMemoCheckVer_WarningVM 생성
    func makeEditMemoCheckVer_WarningVM() -> EditMemoCheckVer_WarningVM {
        return EditMemoCheckVer_WarningVM(
            saveMemoUseCase: makeSaveMemoUseCase(),
            deleteMemoUseCase: makeDeleteMemoUseCase()
        )
    }
}
