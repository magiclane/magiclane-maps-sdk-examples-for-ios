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
            
            ApplicationContext.shared().activateDebugLogger()
        }
        
        NSLog("GEMKit init with success:%@", String(success))
        
        self.addSkipBackupAttribute()
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        if connectingSceneSession.role == .windowApplication
        {
            let sceneConfiguration = UISceneConfiguration(name: "Window Application Configuration", sessionRole: connectingSceneSession.role)
            sceneConfiguration.delegateClass = SceneDelegate.classForCoder()
            sceneConfiguration.storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            
            return sceneConfiguration
        }
        else if connectingSceneSession.role == .carTemplateApplication
        {
            let sceneConfiguration = UISceneConfiguration(name: "CarPlay Configuration", sessionRole: connectingSceneSession.role)
            sceneConfiguration.delegateClass = CarPlaySceneDelegate.classForCoder()
            
            return sceneConfiguration
        }
        
        let sceneConfiguration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        
        return sceneConfiguration
        
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
        // https://www.generalmagic.com/developers/?pg=projects
        //
        
        let string = "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiIyYTI2MDA0Zi0zYjE0LTRkMTYtOWY1Ny1kMDY1NDg1NGZjM2UiLCJleHAiOjE2MTk3NDA4MDAsImlzcyI6IkdlbmVyYWwgTWFnaWMiLCJqdGkiOiI2YjNkYjQwZS1kNjdkLTQ5OGQtOTc4Ny1mZmVkMWVkNzUyMTUiLCJuYmYiOjE2MTcyOTg0MDB9.4UTLU14EoIQw6HZt7wXuxkNIRgRjV1Nk813ueisbxXYQH8qcp1zIlhrRkfc63UnK4xp72dVdvPMSMP1ttagUxw"
        
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

