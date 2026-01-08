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

    // MARK: - Services

    lazy var networkService: NetworkServiceProtocol = {
        return NetworkMonitorService()
    }()

    lazy var syncService: SyncServiceProtocol = {
        return CloudKitSyncService(networkService: networkService)
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

    // MARK: - Calendar ViewModels

    /// CalendarVM 의존성 주입
    func injectCalendarVM(_ vm: CalendarVM) {
        vm.injectDependencies(
            fetchSchedulesUseCase: makeFetchSchedulesUseCase(),
            fetchCategoriesUseCase: makeFetchCategoriesUseCase(),
            saveCategoryUseCase: makeSaveCategoryUseCase()
        )
    }

    /// AddDutyVM 의존성 주입
    func injectAddDutyVM(_ vm: AddDutyVM) {
        vm.injectDependencies(
            saveScheduleUseCase: makeSaveScheduleUseCase(),
            deleteScheduleUseCase: makeDeleteScheduleUseCase(),
            fetchCategoriesUseCase: makeFetchCategoriesUseCase()
        )
    }

    /// DetailDutyVM 의존성 주입
    func injectDetailDutyVM(_ vm: DetailDutyVM) {
        vm.injectDependencies(
            fetchSchedulesUseCase: makeFetchSchedulesUseCase(),
            deleteScheduleUseCase: makeDeleteScheduleUseCase()
        )
    }

    // MARK: - Category ViewModels

    /// CategoryVM 의존성 주입
    func injectCategoryVM(_ vm: CategoryVM) {
        vm.injectDependencies(
            fetchCategoriesUseCase: makeFetchCategoriesUseCase(),
            deleteCategoryUseCase: makeDeleteCategoryUseCase()
        )
    }

    /// EditCategoryVM 의존성 주입
    func injectEditCategoryVM(_ vm: EditCategoryVM) {
        vm.injectDependencies(
            saveCategoryUseCase: makeSaveCategoryUseCase(),
            fetchCategoriesUseCase: makeFetchCategoriesUseCase()
        )
    }

    /// SelectCategoryVM 의존성 주입
    func injectSelectCategoryVM(_ vm: SelectCategoryVM) {
        vm.injectDependencies(
            fetchCategoriesUseCase: makeFetchCategoriesUseCase()
        )
    }

    /// CategoryDeletePopupVM 의존성 주입
    func injectCategoryDeletePopupVM(_ vm: CategoryDeletePopupVM) {
        vm.injectDependencies(
            deleteCategoryUseCase: makeDeleteCategoryUseCase()
        )
    }

    // MARK: - TimeTable ViewModels

    /// TimeTableVM 의존성 주입
    func injectTimeTableVM(_ vm: TimeTableVM) {
        vm.injectDependencies(
            fetchTimeTableUseCase: makeFetchTimeTableUseCase(),
            deleteTimeTableUseCase: makeDeleteTimeTableUseCase()
        )
    }

    /// AddTimeVM 의존성 주입
    func injectAddTimeVM(_ vm: AddTimeVM) {
        vm.injectDependencies(
            saveTimeTableUseCase: makeSaveTimeTableUseCase(),
            fetchTimeTableUseCase: makeFetchTimeTableUseCase()
        )
    }

    /// EditTimeVM 의존성 주입
    func injectEditTimeVM(_ vm: EditTimeVM) {
        vm.injectDependencies(
            saveTimeTableUseCase: makeSaveTimeTableUseCase(),
            deleteTimeTableUseCase: makeDeleteTimeTableUseCase(),
            fetchTimeTableUseCase: makeFetchTimeTableUseCase()
        )
    }

    // MARK: - Memo ViewModels

    /// MemoVM 의존성 주입
    func injectMemoVM(_ vm: MemoVM) {
        vm.injectDependencies(
            fetchMemoUseCase: makeFetchMemoUseCase(),
            deleteMemoUseCase: makeDeleteMemoUseCase()
        )
    }

    /// AddDefaultVerMemoVM 의존성 주입
    func injectAddDefaultVerMemoVM(_ vm: AddDefaultVerMemoVM) {
        vm.injectDependencies(
            saveMemoUseCase: makeSaveMemoUseCase()
        )
    }

    /// AddCheckVerMemoVM 의존성 주입
    func injectAddCheckVerMemoVM(_ vm: AddCheckVerMemoVM) {
        vm.injectDependencies(
            saveMemoUseCase: makeSaveMemoUseCase()
        )
    }

    /// MemoDefaultVerDetailVM 의존성 주입
    func injectMemoDefaultVerDetailVM(_ vm: MemoDefaultVerDetailVM) {
        vm.injectDependencies(
            deleteMemoUseCase: makeDeleteMemoUseCase()
        )
    }

    /// MemoCheckVerDetailVM 의존성 주입
    func injectMemoCheckVerDetailVM(_ vm: MemoCheckVerDetailVM) {
        vm.injectDependencies(
            fetchMemoUseCase: makeFetchMemoUseCase(),
            saveMemoUseCase: makeSaveMemoUseCase(),
            deleteMemoUseCase: makeDeleteMemoUseCase()
        )
    }

    /// EditMemoCheckVer_WarningVM 의존성 주입
    func injectEditMemoCheckVer_WarningVM(_ vm: EditMemoCheckVer_WarningVM) {
        vm.injectDependencies(
            saveMemoUseCase: makeSaveMemoUseCase(),
            deleteMemoUseCase: makeDeleteMemoUseCase()
        )
    }
}
