//
//  AppVersionChecker.swift
//  NewCalendar
//
//  Created by Claude on 12/10/24.
//

import UIKit

class AppVersionChecker {

    static let shared = AppVersionChecker()

    private let appID = "6739255155"
    private let bundleID = "Simoni.Amadoo"

    private init() {}

    // MARK: - Public Methods

    /// 앱 버전 체크 및 업데이트 알림 표시
    func checkForUpdate(presentingViewController: UIViewController?) {
        guard let presentingVC = presentingViewController else {
            print("⚠️ AppVersionChecker: presentingViewController가 nil입니다.")
            return
        }

        fetchLatestVersion { [weak self] latestVersion in
            guard let self = self,
                  let latestVersion = latestVersion,
                  let currentVersion = self.getCurrentVersion() else {
                print("⚠️ AppVersionChecker: 버전 정보를 가져오지 못했습니다.")
                return
            }

            print("📱 현재 버전: \(currentVersion)")
            print("🆕 최신 버전: \(latestVersion)")

            if self.isUpdateAvailable(currentVersion: currentVersion, latestVersion: latestVersion) {
                DispatchQueue.main.async {
                    self.showUpdateAlert(on: presentingVC)
                }
            } else {
                print("✅ 최신 버전을 사용 중입니다.")
            }
        }
    }

    // MARK: - Private Methods

    /// iTunes Lookup API로 최신 버전 가져오기
    private func fetchLatestVersion(completion: @escaping (String?) -> Void) {
        let urlString = "https://itunes.apple.com/lookup?bundleId=\(bundleID)&country=kr"

        guard let url = URL(string: urlString) else {
            print("❌ AppVersionChecker: 잘못된 URL")
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ AppVersionChecker: API 호출 실패 - \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("❌ AppVersionChecker: 데이터 없음")
                completion(nil)
                return
            }

            do {
                // 디버깅: API 응답 전체 출력
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📡 API 응답: \(jsonString)")
                }

                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("📦 JSON 파싱 성공: \(json)")

                    if let results = json["results"] as? [[String: Any]] {
                        print("📋 Results 개수: \(results.count)")

                        if let firstResult = results.first {
                            print("🔍 첫 번째 결과: \(firstResult)")

                            if let version = firstResult["version"] as? String {
                                print("✅ 버전 발견: \(version)")
                                completion(version)
                            } else {
                                print("❌ version 키를 찾을 수 없음")
                                completion(nil)
                            }
                        } else {
                            print("⚠️ results 배열이 비어있음 (앱이 앱스토어에 등록되지 않았을 수 있음)")
                            completion(nil)
                        }
                    } else {
                        print("❌ results 키를 찾을 수 없음")
                        completion(nil)
                    }
                } else {
                    print("❌ AppVersionChecker: JSON 파싱 실패")
                    completion(nil)
                }
            } catch {
                print("❌ AppVersionChecker: JSON 디코딩 실패 - \(error.localizedDescription)")
                completion(nil)
            }
        }

        task.resume()
    }

    /// 현재 앱 버전 가져오기
    private func getCurrentVersion() -> String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    /// 버전 비교 (업데이트 필요 여부)
    private func isUpdateAvailable(currentVersion: String, latestVersion: String) -> Bool {
        let currentComponents = currentVersion.split(separator: ".").compactMap { Int($0) }
        let latestComponents = latestVersion.split(separator: ".").compactMap { Int($0) }

        // 버전 배열 길이를 맞춤 (예: 1.0 vs 1.0.1)
        let maxCount = max(currentComponents.count, latestComponents.count)
        var current = currentComponents
        var latest = latestComponents

        while current.count < maxCount {
            current.append(0)
        }
        while latest.count < maxCount {
            latest.append(0)
        }

        // 버전 비교
        for i in 0..<maxCount {
            if latest[i] > current[i] {
                return true
            } else if latest[i] < current[i] {
                return false
            }
        }

        return false
    }

    /// 업데이트 알림 표시
    private func showUpdateAlert(on viewController: UIViewController) {
        let alert = UIAlertController(
            title: "업데이트 안내",
            message: "새로운 버전이 있습니다.\n최신 버전으로 업데이트해주세요.",
            preferredStyle: .alert
        )

        // 업데이트 버튼
        let updateAction = UIAlertAction(title: "업데이트", style: .default) { [weak self] _ in
            self?.openAppStore()
        }

        // 나중에 버튼
        let laterAction = UIAlertAction(title: "나중에", style: .cancel, handler: nil)

        alert.addAction(updateAction)
        alert.addAction(laterAction)

        viewController.present(alert, animated: true, completion: nil)
    }

    /// 앱스토어 열기
    private func openAppStore() {
        let appStoreURL = "itms-apps://itunes.apple.com/app/id\(appID)"

        if let url = URL(string: appStoreURL) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("❌ AppVersionChecker: 앱스토어 URL을 열 수 없습니다.")
            }
        }
    }
}
