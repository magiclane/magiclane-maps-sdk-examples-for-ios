// SPDX-FileCopyrightText: 2024-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit

@main
struct GeojsonMapApp: App {
    @UIApplicationDelegateAdaptor var delegate: AppDelegate

    let activeNotif = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
    let backgrNotif = NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onReceive(activeNotif) { (_) in
                    print("UIApplication: active")
                    GEMSdk.shared().appDidBecomeActive()
                }
                .onReceive(backgrNotif) { (_) in
                    print("UIApplication: background")
                    GEMSdk.shared().appDidEnterBackground()
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, GEMSdkDelegate, GEMSdkExceptions {

    func application(
        _ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        let token = "" // YOUR_TOKEN

        let parameters = GEMSdkParameters.init(exceptions: self)
        parameters.activationToken = token

        let _ = GEMSdk.shared().initSdk(with: parameters) { code in

            print("AppDelegate: GEMKit init phase finished, code:\(code.rawValue)")

            if code == .kNoError {

                GEMSdk.shared().delegate = self
            }
        }

        return true
    }

    // MARK: - GEMSdkDelegate

    func onConnectionStatusUpdated(_ connected: Bool) {

        print("AppDelegate: onConnectionStatusUpdated:", connected)
    }

    // MARK: - GEMSdkExceptions

    func onSdkActivationDetails(_ reason: ActivationAboutToExpireType, remainingTime remainingTimeInSeconds: Int) {

        print("AppDelegate: activation expiring: \(remainingTimeInSeconds)s remaining")
    }
}

