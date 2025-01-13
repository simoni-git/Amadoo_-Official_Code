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
    
    func fetchCategories(completion: @escaping () -> Void) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Category")
        
        do {
            categories = try context.fetch(fetchRequest)
        } catch {
            
        }
        
        completion()
    }
    
}
