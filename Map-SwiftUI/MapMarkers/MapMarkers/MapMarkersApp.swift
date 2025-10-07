// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit

@main
struct MapMarkersApp: App {
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

class AppDelegate: NSObject, UIApplicationDelegate, GEMSdkDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        let token = "YOUR_TOKEN"
        
        let success = GEMSdk.shared().initSdk(token)
        
        if success {
            
            GEMSdk.shared().delegate = self
        }
        
        return true
    }
    
    // MARK: - GEMSdkDelegate
    
    func onConnectionStatusUpdated(_ connected: Bool) {
        
        print("AppDelegate: onConnectionStatusUpdated:", connected)
    }
}
