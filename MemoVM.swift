//
//  MemoVM.swift
//  NewCalendar
//
//  Created by 시모니 on 1/15/25.
//

import UIKit
import CoreData

class MemoVM {
    var combinedItems: [String: [NSManagedObject]] = [:]
    var combinedItemTitles: [String] = []
    let coreDataManager = CoreDataManager.shared
    
    func fetchAndCombineData(completion: @escaping () -> Void) {
        let checkListFetch: NSFetchRequest<CheckList> = CheckList.fetchRequest()
        let memoFetch: NSFetchRequest<Memo> = Memo.fetchRequest()
        
        do {
            let checkListItems = try coreDataManager.context.fetch(checkListFetch)
            let memoItems = try coreDataManager.context.fetch(memoFetch)
            combinedItems = [:]
            
            for item in checkListItems {
                let key = item.title ?? "Untitled"
                if combinedItems[key] == nil {
                    combinedItems[key] = []
                }
                combinedItems[key]?.append(item)
            }
            
            for item in memoItems {
                let key = item.title ?? "Untitled"
                if combinedItems[key] == nil {
                    combinedItems[key] = []
                }
                combinedItems[key]?.append(item)
            }
            
            combinedItemTitles = Array(combinedItems.keys).sorted()
            completion()
        } catch {
            print(error)
        }
    }
}
