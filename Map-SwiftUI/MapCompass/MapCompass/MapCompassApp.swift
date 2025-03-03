// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: BSD-3-Clause
//
// Contact Magic Lane at <info@magiclane.com> for commercial licensing options.

import SwiftUI
import GEMKit

@main
struct MapCompassApp: App {
    @UIApplicationDelegateAdaptor var delegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
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

