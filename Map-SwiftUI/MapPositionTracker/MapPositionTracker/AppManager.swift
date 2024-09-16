// Copyright (C) 2019-2024, Magic Lane B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of Magic Lane
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with Magic Lane.

import GEMKit

class AppManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = AppManager.init()
    
    var locationManager: CLLocationManager?
    var liveDSController: LiveDataSourceController?
    
    // MARK: - Prepare
    
    func prepareServices() {
        
        self.prepareLocation()
        self.prepareLiveData()
    }
    
    // MARK: - Live Sensors
    
    func prepareLiveData() {
        
        guard self.liveDSController == nil else { return }
        
        self.liveDSController = LiveDataSourceController.init()
    }
    
    func startLiveSensors() {
        
        guard let controller = self.liveDSController else { return }
        
        print("AppManager: startLiveSensors")
        
        controller.startLiveSensors()
    }
    
    func stopLiveSensors() {
        
        guard let controller = self.liveDSController else { return }
        
        print("AppManager: stopLiveSensors")
        
        controller.stopLiveSensors()
    }
    
    // MARK: - Location Manager
    
    func prepareLocation() {
        
        self.locationManager = CLLocationManager.init()
        self.locationManager!.delegate = self
    }
    
    func requestLocationPermission() {
        
        guard let locationManager = self.locationManager else { return }
        
        if locationManager.authorizationStatus == .notDetermined {
            
            locationManager.requestWhenInUseAuthorization()
            
        } else {
            
            self.startUpdatingLocation()
        }
    }
    
    func startUpdatingLocation() {
        
        guard let locationManager = self.locationManager else { return }
        
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        let granted = manager.authorizationStatus == .authorizedWhenInUse
        
        if granted {
            
            self.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // print("testing: new location")
    }
}
