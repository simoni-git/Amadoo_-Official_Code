//
//  CategoryVM.swift
//  NewCalendar
//
//  Created by 시모니 on 1/9/25.
//

import UIKit
import CoreData

class CategoryVM {
    
    var categories: [NSManagedObject] = []
    let coreDataManager = CoreDataManager.shared
    
    func fetchCategories(completion: @escaping () -> Void) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Category")
        
        do {
            let allCategories = try coreDataManager.context.fetch(fetchRequest)
            
            // 유효하지 않은 카테고리 필터링 및 중복 제거
            let validCategories = allCategories.filter { category in
                let name = category.value(forKey: "name") as? String ?? ""
                let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                return !trimmedName.isEmpty &&
                       trimmedName != "Unknown" &&
                       trimmedName != "기본 카테고리" &&
                       !trimmedName.hasPrefix("마이그레이션")
            }
            
            // 이름별로 중복 제거 (가장 최근 것만 유지)
            var uniqueCategories: [String: NSManagedObject] = [:]
            
            for category in validCategories {
                let name = category.value(forKey: "name") as? String ?? ""
                if uniqueCategories[name] == nil {
                    uniqueCategories[name] = category
                } else {
                    // 중복된 카테고리 삭제
                    print("중복 카테고리 삭제: \(name)")
                    coreDataManager.context.delete(category)
                }
            }
            
            // 변경사항 저장
            if coreDataManager.context.hasChanges {
                try coreDataManager.context.save()
            }
            
            let finalCategories = Array(uniqueCategories.values)
            
            // "할 일"을 찾아서 맨 앞으로 이동
            var todoCategory: NSManagedObject?
            var otherCategories: [NSManagedObject] = []
            
            for category in finalCategories {
                let name = category.value(forKey: "name") as? String ?? ""
                if name == "할 일" {
                    todoCategory = category
                } else {
                    otherCategories.append(category)
                }
            }
            
            // 나머지 카테고리들은 이름 순으로 정렬
            otherCategories.sort { category1, category2 in
                let name1 = category1.value(forKey: "name") as? String ?? ""
                let name2 = category2.value(forKey: "name") as? String ?? ""
                return name1 < name2
            }
            
            // "할 일"을 맨 앞에 배치
            categories = []
            if let todo = todoCategory {
                categories.append(todo)
            }
            categories.append(contentsOf: otherCategories)
            
        } catch {
            print("카테고리 fetch 실패: \(error)")
            categories = []
        }
        
        completion()
    }
    
    // 중복 카테고리 정리 함수 (필요시 호출)
    func cleanupDuplicateCategories() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Category")
        
        do {
            let allCategories = try coreDataManager.context.fetch(fetchRequest)
            var categoryNames: Set<String> = []
            var toDelete: [NSManagedObject] = []
            
            for category in allCategories {
                let name = category.value(forKey: "name") as? String ?? ""
                let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // 유효하지 않은 카테고리이거나 중복인 경우 삭제 목록에 추가
                if trimmedName.isEmpty ||
                   trimmedName == "Unknown" ||
                   trimmedName.hasPrefix("마이그레이션") ||
                   categoryNames.contains(trimmedName) {
                    toDelete.append(category)
                } else {
                    categoryNames.insert(trimmedName)
                }
            }
            
            // 중복 및 유효하지 않은 카테고리 삭제
            for category in toDelete {
                coreDataManager.context.delete(category)
                print("삭제된 카테고리: \(category.value(forKey: "name") ?? "Unknown")")
            }
            
            if !toDelete.isEmpty {
                try coreDataManager.context.save()
                print("중복 카테고리 \(toDelete.count)개 정리 완료")
            }
            
        } catch {
            print("카테고리 정리 실패: \(error)")
        }
    }
}
