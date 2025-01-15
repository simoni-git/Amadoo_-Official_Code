//
//  MemoCheckVerDetailVM.swift
//  NewCalendar
//
//  Created by 시모니 on 1/15/25.
//

import UIKit
import CoreData

class MemoCheckVerDetailVM {
    
    let coreDataManager = CoreDataManager.shared
    var items: [CheckList] = []
    var titleText: String?
    var memoType: String = "check"
    
    func fetchData(completion: @escaping () -> Void) {
        let fetchRequest: NSFetchRequest<CheckList> = CheckList.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", titleText ?? "")
        
        do {
            items = try coreDataManager.context.fetch(fetchRequest)
            completion()
        } catch {
            print(error)
        }
    }
}
