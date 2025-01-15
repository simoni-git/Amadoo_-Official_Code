//
//  AddCheckVerMemoVM.swift
//  NewCalendar
//
//  Created by 시모니 on 1/15/25.
//

import UIKit
import CoreData

class AddCheckVerMemoVM {
    
    let coreDataManager = CoreDataManager.shared
    var delegate: AddCheckVerMemoDelegate?
    var memoType: String = "check"
    var checkListItems: [String] = [""]
    
    func checkListSetValue(title: String , name: String , isComplete: Bool , memoType: String) {
        let newCheckListItem = NSEntityDescription.insertNewObject(forEntityName: "CheckList", into: coreDataManager.context)
        newCheckListItem.setValue(title, forKey: "title")
        newCheckListItem.setValue(name, forKey: "name")
        newCheckListItem.setValue(false, forKey: "isComplete")
        newCheckListItem.setValue(memoType, forKey: "memoType")
    }

}
