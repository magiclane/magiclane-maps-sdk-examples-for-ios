// Copyright (C) 2019-2024, Magic Lane B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of Magic Lane
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with Magic Lane.

import UIKit
import Foundation
import GEMKit

class LiveDataSourceController: NSObject, DataSourceContextDelegate, PositionContextDelegate {
    
    var positionContext: PositionContext?
    var dataSourceContext: DataSourceContext?
    
    // MARK: - Init
    
    override init() {
        super.init()
        
        self.dataSourceContext = DataSourceContext.init()
        self.positionContext = PositionContext.init(context: self.dataSourceContext!)
    }
    
    // MARK: - PositionContextDelegate
    
    func positionContext(_ positionContext: PositionContext, didUpdatePosition position: PositionObject) {
        
    }
    
    // MARK: - Utils
    
    func createDefaultConfiguration() -> DataSourceConfigurationObject {
        
        let configuration = DataSourceConfigurationObject.init()
        
        configuration.setPositionAccuracy(.whenMoving)
        configuration.setPositionDistanceFilter(0)
        configuration.setPositionActivity(.other)
        configuration.setAllowBackgroundLocationUpdates(true)
        
        return configuration
    }
    
    func startLiveSensors() {
        
        guard let context = self.dataSourceContext else { return }
        
        print("LiveDataSourceController: startLiveSensors")
        
        context.start()
        
        if context.delegate == nil {
            
            let configuration = self.createDefaultConfiguration()
            context.setConfiguration(configuration, for: .improvedPosition)
            context.delegate = self
            
            if let positionContext = self.positionContext {
                
                positionContext.delegate = self
                positionContext.startUpdatingPositionDelegate(.improvedPosition)
            }
        }
    }
    
    func stopLiveSensors() {
        
        guard let context = self.dataSourceContext else { return }
        
        print("LiveDataSourceController: stopLiveSensors")
        
        context.stop()
        context.delegate = nil
        
        if let positionContext = self.positionContext {
            
            positionContext.delegate = nil
            positionContext.stopUpdatingPositionDelegate()
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
