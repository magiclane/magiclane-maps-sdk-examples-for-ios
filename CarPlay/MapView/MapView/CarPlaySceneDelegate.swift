// Copyright (C) 2019-2023, Magic Lane B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of Magic Lane
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with Magic Lane.

import UIKit
import CarPlay

@available(iOS 13.0, *)
class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate
{
    var cpWindow: CPWindow?
    
    // MARK: - Scene Lifecycle
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions)
    {
    }
    
    func sceneDidDisconnect(_ scene: UIScene)
    {
    }
    
    // MARK: - CarPlay
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController, to window: CPWindow)
    {
        self.cpWindow = window
        
        CarPlayInterface.sharedInstance().didConnectCarInterfaceController(interfaceController: interfaceController, to: window)
    }
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnect interfaceController: CPInterfaceController, from window: CPWindow)
    {
        self.cpWindow = nil
    }
    
    // MARK: - UI Lifecycle
    
    func sceneDidBecomeActive(_ scene: UIScene)
    {
        CarPlayInterface.sharedInstance().sceneDidBecomeActive()
    }
    
    func sceneWillResignActive(_ scene: UIScene)
    {
    }
    
    func sceneWillEnterForeground(_ scene: UIScene)
    {
    }
    
    func sceneDidEnterBackground(_ scene: UIScene)
    {
        CarPlayInterface.sharedInstance().sceneDidEnterBackground()
    }
}

