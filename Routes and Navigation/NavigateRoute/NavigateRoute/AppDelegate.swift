// Copyright (C) 2019-2021, General Magic B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of General Magic
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with General Magic.

import UIKit
import GEMKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let token = self.getProjectApiToken()
        
        let success = ApplicationContext.shared().initSdk(token)
        
        if success {
            
            ApplicationContext.shared().setUnitSystem(.metric)
        }
        
        NSLog("GEMNativeKit init with success:%@", String(success))
        
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
        // https://www.generalmagic.com/api/projects
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
}

