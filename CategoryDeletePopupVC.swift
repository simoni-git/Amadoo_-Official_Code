//
//  EditCategory_DeleteVC.swift
//  NewCalendar
//
//  Created by 시모니 on 11/18/24.
//

import UIKit
import CoreData

class CategoryDeletePopupVC: UIViewController {
    
    var vm = CategoryDeletePopupVM()
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
    }
    
    private func configure() {
        subView.layer.cornerRadius = 10
        cancelBtn.layer.cornerRadius = 10
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = UIColor.black.cgColor
        deleteBtn.layer.cornerRadius = 10
        
    }

    @IBAction func tapCancelBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func tapDeleteBtn(_ sender: UIButton) {
        guard let categoryName = vm.categoryName, let selectColor = vm.selectColor else {
            print("Error: 카테고리 이름 또는 색상 코드가 없습니다.")
            return
        }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Category")
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "name == %@", categoryName),
            NSPredicate(format: "color == %@", selectColor)
        ])
        
        do {
            let fetchResults = try vm.coreDataManager.context.fetch(fetchRequest)
            
            if let objectToDelete = fetchResults.first as? NSManagedObject {
                vm.coreDataManager.context.delete(objectToDelete)
                vm.coreDataManager.saveContext()
                if NetworkSyncManager.shared.getCurrentNetworkStatus() {
                    CloudKitSyncManager.shared.checkAccountStatus { isAvailable in
                        if isAvailable {
                            print("카테고리 삭제가 CloudKit에 동기화됩니다")
                        } else {
                            print("iCloud 계정 확인 필요")
                        }
                    }
                }
            } else {
                
            }
        } catch {
            
        }
        NotificationCenter.default.post(name: NSNotification.Name("DeleteCategory"), object: nil)
        dismiss(animated: true)
    }
    
}
