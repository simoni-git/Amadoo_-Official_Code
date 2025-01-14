//
//  CoreDataManager.swift
//  NewCalendar
//
//  Created by 시모니 on 1/14/25.
//

import UIKit
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
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
