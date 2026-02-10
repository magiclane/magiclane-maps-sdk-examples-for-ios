// Copyright (C) 2019-2024, Magic Lane B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of Magic Lane
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with Magic Lane.

import SwiftUI
import GEMKit

@main
struct DestinationApp: App {
    @UIApplicationDelegateAdaptor var delegate: AppDelegate
    
    let activeNotif = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
    let backgrNotif = NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
    
    var body: some Scene {
        WindowGroup {
            ContentView(transModel: AppManager.shared.transferModel)
                .onReceive(activeNotif) { (_) in
                    print("UIApplication: active")
                }
                .onReceive(backgrNotif) { (_) in
                    print("UIApplication: background")
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        let token = ""
        
        let success = GEMSdk.shared().initCoreSdk(token) // sdk offline all the time
        
        if success {
            
            AppManager.shared.prepareServices()
        }
        
        return true
    }
}


