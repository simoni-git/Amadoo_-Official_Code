//
//  SceneDelegate.swift
//  NewCalendar
//
//  Created by 시모니 on 10/1/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }

        // 위젯에서 딥링크로 앱을 열었을 때 처리
        if let urlContext = connectionOptions.urlContexts.first {
            handleDeepLink(url: urlContext.url)
        }
    }

    // MARK: - Deep Link Handling
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        handleDeepLink(url: url)
    }

    private func handleDeepLink(url: URL) {
        guard url.scheme == "amadoo" else { return }

        // URL 형식: amadoo://timetable 또는 amadoo://calendar
        switch url.host {
        case "timetable":
            // 시간표 탭으로 이동
            navigateToTab(index: 0)  // 시간표가 0번째 탭이라고 가정

        case "calendar":
            // 달력 탭으로 이동
            navigateToTab(index: 1)  // 달력이 1번째 탭이라고 가정

        default:
            break
        }
    }

    private func navigateToTab(index: Int) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let tabBarController = window.rootViewController as? UITabBarController else {
            return
        }

        tabBarController.selectedIndex = index
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.

        // 앱 버전 체크
        if let windowScene = scene as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            AppVersionChecker.shared.checkForUpdate(presentingViewController: rootViewController)
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.

        // CloudKit 동기화로 인해 생성될 수 있는 불필요한 카테고리 정리
        (UIApplication.shared.delegate as? AppDelegate)?.cleanupInvalidCategories()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

