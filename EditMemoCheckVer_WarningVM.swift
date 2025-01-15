//
//  EditMemoCheckVer_WarningVM.swift
//  NewCalendar
//
//  Created by 시모니 on 1/15/25.
//

import UIKit
import CoreData

class EditMemoCheckVer_WarningVM {
    
    let coreDataManager = CoreDataManager.shared
    var titleText: String?
    var memoType: String = "check"
    var delegate: MemoCheckVerWarningDelegate?
    
    func checkListSetValue(title: String , name: String , isComplete: Bool , memoType: String) {
        let newItem = NSEntityDescription.insertNewObject(forEntityName: "CheckList", into: coreDataManager.context)
        newItem.setValue(title, forKey: "title")
        newItem.setValue(name, forKey: "name")
        newItem.setValue(false, forKey: "isComplete")
        newItem.setValue(memoType, forKey: "memoType")
    }
    
}
