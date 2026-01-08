//
//  CoreDataMemoRepository.swift
//  NewCalendar
//
//  Data Layer - Memo Repository 구현체
//

import Foundation
import CoreData

/// Memo Repository CoreData 구현체
final class CoreDataMemoRepository: MemoRepositoryProtocol {

    private let contextProvider: CoreDataContextProviding

    init(contextProvider: CoreDataContextProviding = CoreDataContextProvider.shared) {
        self.contextProvider = contextProvider
    }

    // MARK: - Memo Fetch

    func fetchAllMemos() -> [MemoItem] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Memo")

        do {
            let results = try contextProvider.context.fetch(request)
            return MemoMapper.toDomainList(results)
        } catch {
            print("❌ Memo fetchAll error: \(error)")
            return []
        }
    }

    // MARK: - Memo Save

    func saveMemo(_ memo: MemoItem) -> Result<MemoItem, Error> {
        let context = contextProvider.context

        _ = MemoMapper.toManagedObject(memo, context: context)

        do {
            try context.save()
            print("✅ Memo 저장 성공: \(memo.title)")
            return .success(memo)
        } catch {
            print("❌ Memo 저장 실패: \(error)")
            return .failure(error)
        }
    }

    // MARK: - Memo Update

    func updateMemo(_ memo: MemoItem) -> Result<MemoItem, Error> {
        let context = contextProvider.context
        let request = NSFetchRequest<NSManagedObject>(entityName: "Memo")

        request.predicate = NSPredicate(format: "title == %@", memo.title)

        do {
            let results = try context.fetch(request)
            if let existingObject = results.first {
                MemoMapper.update(existingObject, with: memo)
                try context.save()
                print("✅ Memo 수정 성공: \(memo.title)")
                return .success(memo)
            } else {
                return .failure(NSError(domain: "CoreDataMemoRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Memo not found"]))
            }
        } catch {
            print("❌ Memo 수정 실패: \(error)")
            return .failure(error)
        }
    }

    // MARK: - Memo Delete

    func deleteMemo(_ memo: MemoItem) -> Result<Void, Error> {
        let context = contextProvider.context
        let request = NSFetchRequest<NSManagedObject>(entityName: "Memo")

        request.predicate = NSPredicate(format: "title == %@", memo.title)

        do {
            let results = try context.fetch(request)
            for object in results {
                context.delete(object)
            }
            try context.save()
            print("✅ Memo 삭제 성공: \(memo.title)")
            return .success(())
        } catch {
            print("❌ Memo 삭제 실패: \(error)")
            return .failure(error)
        }
    }

    // MARK: - CheckList Fetch

    func fetchAllCheckLists() -> [CheckListItem] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CheckList")

        do {
            let results = try contextProvider.context.fetch(request)
            return CheckListMapper.toDomainList(results)
        } catch {
            print("❌ CheckList fetchAll error: \(error)")
            return []
        }
    }

    func fetchCheckLists(forTitle title: String) -> [CheckListItem] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CheckList")
        request.predicate = NSPredicate(format: "title == %@", title)

        do {
            let results = try contextProvider.context.fetch(request)
            return CheckListMapper.toDomainList(results)
        } catch {
            print("❌ CheckList fetch for title error: \(error)")
            return []
        }
    }

    // MARK: - CheckList Save

    func saveCheckList(_ checkList: CheckListItem) -> Result<CheckListItem, Error> {
        let context = contextProvider.context

        _ = CheckListMapper.toManagedObject(checkList, context: context)

        do {
            try context.save()
            print("✅ CheckList 저장 성공: \(checkList.title) - \(checkList.name ?? "")")
            return .success(checkList)
        } catch {
            print("❌ CheckList 저장 실패: \(error)")
            return .failure(error)
        }
    }

    // MARK: - CheckList Update

    func updateCheckList(_ checkList: CheckListItem) -> Result<CheckListItem, Error> {
        let context = contextProvider.context
        let request = NSFetchRequest<NSManagedObject>(entityName: "CheckList")

        request.predicate = NSPredicate(format: "title == %@ AND name == %@", checkList.title, checkList.name ?? "")

        do {
            let results = try context.fetch(request)
            if let existingObject = results.first {
                CheckListMapper.update(existingObject, with: checkList)
                try context.save()
                print("✅ CheckList 수정 성공: \(checkList.title) - \(checkList.name ?? "")")
                return .success(checkList)
            } else {
                return .failure(NSError(domain: "CoreDataMemoRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "CheckList not found"]))
            }
        } catch {
            print("❌ CheckList 수정 실패: \(error)")
            return .failure(error)
        }
    }

    // MARK: - CheckList Delete

    func deleteCheckList(_ checkList: CheckListItem) -> Result<Void, Error> {
        let context = contextProvider.context
        let request = NSFetchRequest<NSManagedObject>(entityName: "CheckList")

        request.predicate = NSPredicate(format: "title == %@ AND name == %@", checkList.title, checkList.name ?? "")

        do {
            let results = try context.fetch(request)
            for object in results {
                context.delete(object)
            }
            try context.save()
            print("✅ CheckList 삭제 성공: \(checkList.title) - \(checkList.name ?? "")")
            return .success(())
        } catch {
            print("❌ CheckList 삭제 실패: \(error)")
            return .failure(error)
        }
    }

    func deleteAllCheckLists(forTitle title: String) -> Result<Void, Error> {
        let context = contextProvider.context
        let request = NSFetchRequest<NSManagedObject>(entityName: "CheckList")

        request.predicate = NSPredicate(format: "title == %@", title)

        do {
            let results = try context.fetch(request)
            for object in results {
                context.delete(object)
            }
            try context.save()
            print("✅ CheckList 전체 삭제 성공: \(title) (\(results.count)개)")
            return .success(())
        } catch {
            print("❌ CheckList 전체 삭제 실패: \(error)")
            return .failure(error)
        }
    }

    // MARK: - Combined Fetch

    func fetchAllGroupedByTitle() -> [(title: String, type: String, items: [Any])] {
        let memos = fetchAllMemos()
        let checkLists = fetchAllCheckLists()

        var result: [(title: String, type: String, items: [Any])] = []

        // 메모 추가
        for memo in memos {
            result.append((title: memo.title, type: memo.memoType, items: [memo]))
        }

        // 체크리스트 그룹화
        var checkListGroups: [String: [CheckListItem]] = [:]
        for checkList in checkLists {
            if checkListGroups[checkList.title] == nil {
                checkListGroups[checkList.title] = []
            }
            checkListGroups[checkList.title]?.append(checkList)
        }

        for (title, items) in checkListGroups {
            let type = items.first?.memoType ?? "checkVer"
            result.append((title: title, type: type, items: items))
        }

        return result
    }
}
