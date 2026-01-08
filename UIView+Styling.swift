//
//  UIView+Styling.swift
//  NewCalendar
//
//  Created by Claude Code on 12/8/24.
//

import UIKit

/// UIView에 스타일링 관련 편의 메서드 추가
extension UIView {

    /// 표준 corner radius 적용 (10)
    func applyStandardCornerRadius() {
        layer.cornerRadius = Constants.UI.standardCornerRadius
        layer.masksToBounds = true
    }

    /// 작은 corner radius 적용 (8)
    func applySmallCornerRadius() {
        layer.cornerRadius = Constants.UI.smallCornerRadius
        layer.masksToBounds = true
    }

    /// 커스텀 corner radius 적용
    /// - Parameter radius: 적용할 corner radius 값
    func applyCornerRadius(_ radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
}

/// UIViewController에 Sheet 프레젠테이션 관련 편의 메서드 추가
extension UIViewController {

    /// Medium detent sheet으로 ViewController 표시
    /// - Parameters:
    ///   - viewController: 표시할 ViewController
    ///   - showGrabber: Grabber 표시 여부 (기본값: true)
    func presentAsSheet(_ viewController: UIViewController, showGrabber: Bool = true) {
        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = showGrabber
        }
        viewController.modalPresentationStyle = .pageSheet
        present(viewController, animated: true)
    }

    /// Custom detents sheet으로 ViewController 표시
    /// - Parameters:
    ///   - viewController: 표시할 ViewController
    ///   - detents: Sheet의 detent 배열
    ///   - showGrabber: Grabber 표시 여부 (기본값: true)
    func presentAsSheet(
        _ viewController: UIViewController,
        detents: [UISheetPresentationController.Detent],
        showGrabber: Bool = true
    ) {
        if let sheet = viewController.sheetPresentationController {
            sheet.detents = detents
            sheet.prefersGrabberVisible = showGrabber
        }
        viewController.modalPresentationStyle = .pageSheet
        present(viewController, animated: true)
    }
}
