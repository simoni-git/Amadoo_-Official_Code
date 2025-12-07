//
//  SelectCategoryVM.swift
//  NewCalendar
//
//  Created by 시모니 on 1/14/25.
//

import UIKit
import CoreData

class SelectCategoryVM {
    
    var delegate: SelectCategoryVCDelegate?
    var categories: [NSManagedObject] = []
    let coreDataManager = CoreDataManager.shared
    
    func fetchCategories(completion: @escaping () -> Void) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Category")
        
        do {
            let allCategories = try coreDataManager.context.fetch(fetchRequest)
            
            // "할 일"을 찾아서 맨 앞으로 이동 (CategoryVM과 동일한 로직)
            var todoCategory: NSManagedObject?
            var otherCategories: [NSManagedObject] = []
            
            for category in allCategories {
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
            
            completion()
        } catch {
            categories = []
            completion()
        }
    }
}
