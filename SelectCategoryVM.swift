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
            categories = try coreDataManager.context.fetch(fetchRequest)
            completion()
        } catch {
            
        }
    }
}
