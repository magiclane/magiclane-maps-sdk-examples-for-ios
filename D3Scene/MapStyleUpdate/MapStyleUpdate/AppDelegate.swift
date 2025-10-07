// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import UIKit
import GEMKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, GEMSdkDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let token = self.getProjectApiToken()
        
        let success = GEMSdk.shared().initSdk(token)
        
        NSLog("GEMKit init with success:%@", String(success))
        
        if success {
            
            GEMSdk.shared().delegate = self
        }
        
        self.addSkipBackupAttribute()
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Project API Token
    
    func getProjectApiToken() -> String {
        
        //
        // Project API token is available at:
        //
        // https://developer.magiclane.com/api/projects
        //
        
        let string = "YOUR_TOKEN"
        
        return string
    }
    
    func addSkipBackupAttribute() {
        
        let fileManager = FileManager.default
        
        let documentsURL = fileManager.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
        
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
    
    // MARK: - GEMSdkDelegate
    
    func shouldUpdateMapStyle(for status: ContentStoreOnlineSupportStatus) -> Bool {
        
        let value = false // turn off automatic update
        
        return value
    }
}

