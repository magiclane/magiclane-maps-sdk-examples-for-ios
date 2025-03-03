// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: BSD-3-Clause
//
// Contact Magic Lane at <info@magiclane.com> for commercial licensing options.

import UIKit
import Foundation
import GEMKit

class LiveDataSourceController: NSObject, PositionContextDelegate {
    
    var positionContext: PositionContext?
    var dataSourceContext: DataSourceContext?
    
    // MARK: - Init
    
    override init() {
        
        super.init()
        
        self.dataSourceContext = DataSourceContext.init()
        
        self.positionContext = PositionContext.init(context: self.dataSourceContext!)
    }
    
    deinit {
    }
    
    // MARK: - PositionContextDelegate
    
    func positionContext(_ positionContext: PositionContext, didUpdatePosition position: PositionObject) {
        
    }
    
    // MARK: - Utils
    
    func createDefaultConfiguration() -> DataSourceConfigurationObject {
        
        let configuration = DataSourceConfigurationObject.init()
        
        configuration.setPositionAccuracy(.whenMoving)
        configuration.setPositionDistanceFilter(0)
        configuration.setPositionActivity(.automotive)
        configuration.setPausesLocationUpdatesAutomatically(false)
        
        return configuration
    }
    
    func startLiveSensors() {
        
        guard let context = self.dataSourceContext else { return }
        
        print("LiveDataSourceController: startLiveSensors")
        
        context.start()
        
        if context.delegate == nil {
            
            let configuration = self.createDefaultConfiguration()
            context.setConfiguration(configuration, for: .position)
            
            self.startLiveSensorsDelegateNotification()
        }
    }
    
    func updateLiveConfiguration(withBackgroundSupport: Bool) {
        
        guard let context = self.dataSourceContext else { return }
        
        let configuration = self.createDefaultConfiguration()
        
        if withBackgroundSupport {
            
            configuration.setAllowBackgroundLocationUpdates(true)
            
        } else {
            
            configuration.setAllowBackgroundLocationUpdates(false)
        }
        
        context.setConfiguration(configuration, for: .position)
    }
    
    func stopLiveSensors() {
        
        guard let context = self.dataSourceContext else { return }
        
        print("LiveDataSourceController: stopLiveSensors")
        
        context.stop()
        
        context.delegate = nil
        
        self.stopLiveSensorsDelegateNotification()
    }
    
    func startLiveSensorsDelegateNotification() {
        
        // guard let context = self.dataSourceContext else { return }
        
        print("LiveDataSourceController: startLiveSensorsDelegateNotification")
        
        // context.startDelegateNotification(with: .mountInformation)
        
        if self.positionContext != nil {
            
            self.positionContext!.delegate = self
            self.positionContext!.startUpdatingPositionDelegate(.improvedPosition)
        }
    }
    
    func stopLiveSensorsDelegateNotification() {
        
        // guard let context = self.dataSourceContext else { return }
        
        print("LiveDataSourceController: stopLiveSensorsDelegateNotification")
        
        // context.stopDelegateNotification(with: .mountInformation)
        
        if self.positionContext != nil {
            
            self.positionContext!.delegate = nil
            self.positionContext!.stopUpdatingPositionDelegate()
        }
    }
    
    func destroyLiveSensors() {
        
        print("LiveDataSourceController: destroyLiveSensors")
        
        if self.positionContext != nil {
            
            self.positionContext!.delegate = nil
            self.positionContext!.clean()
            self.positionContext = nil
        }
        
        if self.dataSourceContext != nil {
            
            self.dataSourceContext!.delegate = nil
            self.dataSourceContext = nil
        }
    }
}
