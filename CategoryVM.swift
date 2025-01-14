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
            categories = try coreDataManager.context.fetch(fetchRequest)
        } catch {
            
        }
        
        completion()
    }
    
}
