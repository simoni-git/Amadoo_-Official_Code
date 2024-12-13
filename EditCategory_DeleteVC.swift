//
//  EditCategory_DeleteVC.swift
//  NewCalendar
//
//  Created by 시모니 on 11/18/24.
//

import UIKit
import CoreData

class EditCategory_DeleteVC: UIViewController {
    
    var context: NSManagedObjectContext {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }
        return app.persistentContainer.viewContext
    }
    
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    var categoryName: String?
    var selectColor: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
    }
    
    private func configure() {
        subView.layer.cornerRadius = 10
        cancelBtn.layer.cornerRadius = 10
        deleteBtn.layer.cornerRadius = 10
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            
        }
    }
    
    @IBAction func tapCancelBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func tapDeleteBtn(_ sender: UIButton) {
        guard let categoryName = categoryName, let selectColor = selectColor else {
            print("Error: 카테고리 이름 또는 색상 코드가 없습니다.")
            return
        }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Category")
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "name == %@", categoryName),
            NSPredicate(format: "color == %@", selectColor)
        ])
        
        do {
            let fetchResults = try context.fetch(fetchRequest)
            
            if let objectToDelete = fetchResults.first as? NSManagedObject {
                context.delete(objectToDelete)
                saveContext()
            } else {
                
            }
        } catch {
            
        }
        NotificationCenter.default.post(name: NSNotification.Name("DeleteCategory"), object: nil)
        dismiss(animated: true)
    }
    
}
