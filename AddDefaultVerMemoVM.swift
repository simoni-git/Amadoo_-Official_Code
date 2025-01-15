//
//  AddDefaultVerMemoVM.swift
//  NewCalendar
//
//  Created by 시모니 on 1/15/25.
//

import UIKit
import CoreData

class AddDefaultVerMemoVM {
    
    let coreDataManager = CoreDataManager.shared
    var memoType: String = "default"
    var delegate: AddDefaultVerMemoDelegate?
    var editModeTitleTextFieldText: String?
    var editModeMemoTextViewText: String?
    var isEditMode = false
    
    func memoSetValue(title: String , memoText: String , memoType: String) {
        let newMemoItem = NSEntityDescription.insertNewObject(forEntityName: "Memo", into: coreDataManager.context)
        newMemoItem.setValue(title, forKey: "title")
        newMemoItem.setValue(memoText, forKey: "memoText")
        newMemoItem.setValue(memoType, forKey: "memoType")
    }
    
}
