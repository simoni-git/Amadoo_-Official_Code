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
    
    
    
    
    
    
    //MARK: CoreData 관련
    var context: NSManagedObjectContext {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }
        return app.persistentContainer.viewContext
    }
    
    func fetchCategories(completion: @escaping () -> Void) {
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Category")
        
        do {
            categories = try context.fetch(fetchRequest)
            completion()
        } catch {
            
        }
    }
}
