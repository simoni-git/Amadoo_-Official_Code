//
//  EditCategory_DeleteVM.swift
//  NewCalendar
//
//  Created by 시모니 on 1/14/25.
//

import UIKit
import CoreData

class EditCategory_DeleteVM {
    
    var categoryName: String?
    var selectColor: String?
    
    
    //MARK: CoreData 관련
    var context: NSManagedObjectContext {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }
        return app.persistentContainer.viewContext
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            
        }
    }
    
}
