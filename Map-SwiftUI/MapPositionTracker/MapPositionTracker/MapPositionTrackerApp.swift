// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: BSD-3-Clause
//
// Contact Magic Lane at <info@magiclane.com> for commercial licensing options.

import SwiftUI
import GEMKit
import CoreLocation

@main
struct MapPositionTrackerApp: App {
    @UIApplicationDelegateAdaptor var delegate: AppDelegate
    
    let activeNotif = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
    let backgrNotif = NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onReceive(activeNotif) { (_) in
                    print("UIApplication: active")
                    AppManager.shared.startLiveSensors()
                }
                .onReceive(backgrNotif) { (_) in
                    print("UIApplication: background")
                    AppManager.shared.stopLiveSensors()
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, GEMSdkDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        let token = "YOUR_TOKEN"
        
        let success = GEMSdk.shared().initSdk(token)
        
        if success {
            
            GEMSdk.shared().delegate = self
            
            AppManager.shared.prepareServices()
        }
        
        return true
    }
    
    // MARK: - GEMSdkDelegate
    
    func onConnectionStatusUpdated(_ connected: Bool) {
        
        print("AppDelegate: onConnectionStatusUpdated:", connected)
    }
}


