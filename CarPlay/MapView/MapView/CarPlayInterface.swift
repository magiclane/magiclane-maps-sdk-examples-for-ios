// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: BSD-3-Clause
//
// Contact Magic Lane at <info@magiclane.com> for commercial licensing options.

import UIKit
import CarPlay
import GEMKit

private let carPlayInterfaceSingleton = CarPlayInterface()

class CarPlayInterface: NSObject, CPInterfaceControllerDelegate, CPSessionConfigurationDelegate
{
    // MARK: - Variables
    
    var carWindow: CPWindow?
    var carInterfaceController: CPInterfaceController?
    var rootViewController: CPRootViewController?
    
    // MARK: - Singleton
    
    @objc class func sharedInstance() -> CarPlayInterface
    {
        return carPlayInterfaceSingleton
    }
    
    // MARK: - Init
    
    override init()
    {
        super.init()
    }
    
    // MARK: - Properties
    
    func getWindow() -> CPWindow?
    {
        return self.carWindow
    }
    
    func getInterfaceController() -> CPInterfaceController?
    {
        return self.carInterfaceController
    }
    
    func isConnected() -> Bool
    {
        let state: Bool = (self.carWindow != nil)
        
        return state
    }
    
    func didConnectCarInterfaceController(interfaceController: CPInterfaceController, to window: CPWindow)
    {
        self.carWindow = window
        self.carInterfaceController = interfaceController
        self.carInterfaceController?.delegate = self
        
        self.rootViewController = CPRootViewController.init()
        self.rootViewController!.view.frame = self.carWindow!.frame
        
        self.carWindow!.rootViewController = self.rootViewController
        
        if let template = self.rootViewController!.mapTemplate {
            
            self.carInterfaceController?.setRootTemplate(template, animated: false)
            
            self.rootViewController!.createMapView()
            
            if self.isSceneInBackground() == false {
                
                self.rootViewController!.startRender()
            }
        }
    }
    
    func sceneDidBecomeActive()
    {
        GEMSdk.shared().appDidBecomeActive()
        
        self.rootViewController!.startRender()
    }
        
    func sceneDidEnterBackground()
    {
        GEMSdk.shared().appDidEnterBackground()
        
        self.rootViewController!.stopRender()
    }
    
    func isSceneInBackground() -> Bool
    {
        var state: Bool = false
        
        if let window = self.getWindow()
        {
            if let scene = window.templateApplicationScene
            {
                let sceneState = scene.activationState;
                
                if sceneState == .background || sceneState == .unattached
                {
                    state = true
                }
            }
        }
        
        return state
    }
    
}

