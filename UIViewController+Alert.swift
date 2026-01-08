//
//  UIViewController+Alert.swift
//  NewCalendar
//
//  Created by Claude Code on 12/8/24.
//

import UIKit

/// UIViewController에 알림 관련 편의 메서드 추가
extension UIViewController {

    /// Warning 팝업을 표시하는 메서드
    /// - Parameter message: 표시할 경고 메시지
    ///
    /// 이전에 AddDutyVC, EditCategoryVC, AddCheckVerMemoVC, AddDefaultVerMemoVC에서 중복 정의되었던 메서드
    func presentWarning(_ message: String) {
        guard let warningVC = self.storyboard?.instantiateViewController(
            identifier: Constants.StoryboardID.warningVC
        ) as? WarningVC else {
            print("❌ Error: Unable to instantiate WarningVC")
            return
        }

        warningVC.warningLabelText = message
        warningVC.modalPresentationStyle = .overCurrentContext
        present(warningVC, animated: true)
    }
}
