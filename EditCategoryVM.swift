//
//  EditCategoryVM.swift
//  NewCalendar
//
//  Created by 시모니 on 1/9/25.
//

import UIKit
import CoreData

class EditCategoryVM {
    
    var delegate: EditCategoryVCDelegate?
    var addForSelectCategoryVCDelegate: AddForSelectCategoryVCDelegate?
    var selectColorCode: String? = ""
    var selectColorName: String? = ""
    var categoryName: String? = ""
    var originCategoryName: String?
    var originSelectColor: String?
    var isEditMode: Bool = false
    var isAddMode: Bool = false
    let coreDataManager = CoreDataManager.shared
    
    let colors = [
        (name: "프렌치로즈", code: "ECBDBF"),
        (name: "라이트오렌지", code: "FFB124"),
        (name: "머스타드옐로우", code: "DBC557"),
        (name: "에메랄드그린", code: "8FBC91"),
        (name: "스카이블루", code: "A5CBF0"),
        (name: "다크블루", code: "446592"),
        (name: "소프트바이올렛", code: "A495C6"),
        (name: "파스텔브라운", code: "BBA79C")
    ]
    
    func saveCategory(categoryName: String, selectColor: String) {
        let entity = NSEntityDescription.entity(forEntityName: "Category", in: coreDataManager.context)
        let newCategory = NSManagedObject(entity: entity!, insertInto: coreDataManager.context)
        newCategory.setValue(categoryName, forKey: "name")
        newCategory.setValue(selectColor, forKey: "color")
        newCategory.setValue(false, forKey: "isDefault")
        coreDataManager.saveContext()
        // CloudKit 동기화 추가
            checkAndSync()
    }
    
    func fetchCategory(name: String? , color: String?) -> (name: String , color: String)? {
        guard let name = originCategoryName , let color = originSelectColor else {return nil}
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Category")
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "name == %@", name),
            NSPredicate(format: "color == %@", color),
        ])
        
        do {
            let fetchResults = try coreDataManager.context.fetch(fetchRequest)
            if let target = fetchResults.first as? NSManagedObject,
               let name = target.value(forKey: "name") as? String,
               let color = target.value(forKey: "color") as? String {
                return (name: name, color: color)
            }
        } catch {
            print("Error fetching category: \(error)")
        }
        
        return nil
    }
    
    func isCategoryNameExists(categoryName: String) -> Bool {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Category")
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "name == %@", categoryName),
            NSPredicate(format: "name != %@", originCategoryName ?? "")
        ])
        
        do {
            let fetchResults = try coreDataManager.context.fetch(fetchRequest)
            return !fetchResults.isEmpty
        } catch {
            
            return false
        }
    }
    
    func isColorExists(selectColor: String) -> Bool {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Category")
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "color == %@", selectColor),
            NSPredicate(format: "color != %@", originSelectColor ?? "")
        ])
        
        do {
            let fetchResults = try coreDataManager.context.fetch(fetchRequest)
            return !fetchResults.isEmpty
        } catch {
            
            return false
        }
    }
    
    // CloudKit 동기화 체크 함수 추가
    private func checkAndSync() {
        if NetworkSyncManager.shared.getCurrentNetworkStatus() {
            CloudKitSyncManager.shared.checkAccountStatus { isAvailable in
                if isAvailable {
                    print("카테고리가 CloudKit에 동기화됩니다")
                } else {
                    print("iCloud 계정 확인 필요")
                }
            }
        } else {
            print("오프라인 상태 - 네트워크 연결 시 자동 동기화됩니다")
        }
    }
   
}
