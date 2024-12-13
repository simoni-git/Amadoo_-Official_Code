//
//  WarningVC.swift
//  NewCalendar
//
//  Created by 시모니 on 11/27/24.
//

import UIKit

class WarningVC: UIViewController {
    
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var okBtn: UIButton!
    var warningLabelText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
    }
    
    private func configure() {
        warningLabel.text = self.warningLabelText
        subView.layer.cornerRadius = 10
        okBtn.layer.cornerRadius = 10
    }
    
    @IBAction func tapOkBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}
