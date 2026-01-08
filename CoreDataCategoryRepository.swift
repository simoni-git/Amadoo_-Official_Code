//
//  CoreDataCategoryRepository.swift
//  NewCalendar
//
//  Data Layer - Category Repository 구현체
//

import Foundation
import CoreData

/// Category Repository CoreData 구현체
final class CoreDataCategoryRepository: CategoryRepositoryProtocol {

    private let contextProvider: CoreDataContextProviding

    init(contextProvider: CoreDataContextProviding = CoreDataContextProvider.shared) {
        self.contextProvider = contextProvider
    }

    // MARK: - Fetch

    func fetchAll() -> [CategoryItem] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Category")

        do {
            let results = try contextProvider.context.fetch(request)
            let categories = CategoryMapper.toDomainList(results)

            // 유효한 카테고리만 필터링 및 정렬
            return categories
                .filter { $0.isValid }
                .sorted { category1, category2 in
                    // "할 일" 카테고리를 맨 앞으로
                    if category1.name == "할 일" { return true }
                    if category2.name == "할 일" { return false }
                    return category1.name < category2.name
                }
        } catch {
            print("❌ Category fetchAll error: \(error)")
            return []
        }
    }

    func fetchDefault() -> CategoryItem? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Category")
        request.predicate = NSPredicate(format: "isDefault == YES")

        do {
            let results = try contextProvider.context.fetch(request)
            if let first = results.first {
                return CategoryMapper.toDomain(first)
            }
            // 기본 카테고리가 없으면 "할 일" 카테고리 반환
            return fetchAll().first { $0.name == "할 일" }
        } catch {
            print("❌ Category fetchDefault error: \(error)")
            return nil
        }
    }

    // MARK: - Save

    func save(_ category: CategoryItem) -> Result<CategoryItem, Error> {
        let context = contextProvider.context

        _ = CategoryMapper.toManagedObject(category, context: context)

        do {
            try context.save()
            print("✅ Category 저장 성공: \(category.name)")
            return .success(category)
        } catch {
            print("❌ Category 저장 실패: \(error)")
            return .failure(error)
        }
    }

    // MARK: - Update

    func update(_ category: CategoryItem) -> Result<CategoryItem, Error> {
        let context = contextProvider.context
        let request = NSFetchRequest<NSManagedObject>(entityName: "Category")

        request.predicate = NSPredicate(format: "name == %@", category.name)

        do {
            let results = try context.fetch(request)
            if let existingObject = results.first {
                CategoryMapper.update(existingObject, with: category)
                try context.save()
                print("✅ Category 수정 성공: \(category.name)")
                return .success(category)
            } else {
                return .failure(NSError(domain: "CoreDataCategoryRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Category not found"]))
            }
        } catch {
            print("❌ Category 수정 실패: \(error)")
            return .failure(error)
        }
    }

    // MARK: - Delete

    func delete(_ category: CategoryItem) -> Result<Void, Error> {
        let context = contextProvider.context
        let request = NSFetchRequest<NSManagedObject>(entityName: "Category")

        request.predicate = NSPredicate(format: "name == %@ AND color == %@", category.name, category.color)

        do {
            let results = try context.fetch(request)
            for object in results {
                context.delete(object)
            }
            try context.save()
            print("✅ Category 삭제 성공: \(category.name)")
            return .success(())
        } catch {
            print("❌ Category 삭제 실패: \(error)")
            return .failure(error)
        }
    }

    // MARK: - Default Category

    func createDefaultCategoryIfNeeded() -> Result<CategoryItem?, Error> {
        let existingCategories = fetchAll()

        if existingCategories.isEmpty {
            let defaultCategory = CategoryItem.createDefault()
            let result = save(defaultCategory)

            switch result {
            case .success(let saved):
                print("✅ 기본 카테고리 생성됨: \(saved.name)")
                return .success(saved)
            case .failure(let error):
                return .failure(error)
            }
        }

        return .success(nil)
    }

    // MARK: - Count Schedules

    func countSchedules(withColor color: String) -> Int {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Schedule")
        request.predicate = NSPredicate(format: "categoryColor == %@", color)

        do {
            return try contextProvider.context.count(for: request)
        } catch {
            print("❌ Schedule count error: \(error)")
            return 0
        }
    }
}
