// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import UIKit
import GEMKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
        -> Bool
    {
        let token = self.getProjectApiToken()

        let success = GEMSdk.shared().initSdk(token)

        NSLog("GEMKit init with success:%@", String(success))

        self.addSkipBackupAttribute()

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    // MARK: - Project API Token

    func getProjectApiToken() -> String {

        //
        // Project API token is available at:
        //
        // https://developer.magiclane.com/api/projects
        //

        let token = "" // YOUR_TOKEN

        return token
    }

    func addSkipBackupAttribute() {

        let fileManager = FileManager.default

        let documentsURL = fileManager.urls(
            for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)

        if let documentPath = documentsURL.first {

            var file = documentPath

            do {
                var resource = URLResourceValues()
                resource.isExcludedFromBackup = true

                try file.setResourceValues(resource)

            } catch {
                print(error)
            }
        }
    }
}
