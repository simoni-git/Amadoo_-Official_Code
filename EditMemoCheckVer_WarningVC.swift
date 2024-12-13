//
//  EditMemoCheckVer_WarningVC.swift
//  NewCalendar
//
//  Created by 시모니 on 12/6/24.
//

import UIKit
import CoreData

class EditMemoCheckVer_WarningVC: UIViewController {
    
    var context: NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("앱 델리게이트를 찾을 수 없습니다.")
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var mentLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var okBtn: UIButton!
    
    var titleText: String?
    var delegate: MemoCheckVerWarningDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
    }
    
    private func configure() {
        subView.layer.cornerRadius = 10
        okBtn.layer.cornerRadius = 10
    }
    
    @IBAction func tapOkBtn(_ sender: UIButton) {
        guard let title = titleText, let name = textField.text, !name.isEmpty else {
            return
        }
        
        let newItem = NSEntityDescription.insertNewObject(forEntityName: "CheckList", into: context)
        newItem.setValue(title, forKey: "title")
        newItem.setValue(name, forKey: "name")
        newItem.setValue(false, forKey: "isComplete")
        newItem.setValue("check", forKey: "memoType")
        
        saveContext()
        delegate?.didSaveMemoItem()
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - CoreData 관련
    private func saveContext() {
        do {
            try context.save()
        } catch {
            
        }
    }
    
}
