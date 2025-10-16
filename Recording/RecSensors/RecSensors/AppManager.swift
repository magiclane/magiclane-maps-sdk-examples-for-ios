// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import GEMKit

class AppManager: NSObject, CLLocationManagerDelegate, SensorsRecordingControllerDelegate {
    
    static let shared = AppManager.init()
    
    var locationManager: CLLocationManager?
    var liveDSController: LiveDataSourceController?    
    var sensorsLog: SensorsRecordingController?
    
    let recordingModel = RecordModel.init()
    
    // MARK: - Prepare
    
    func prepareServices() {
        
        self.prepareLocation()
        self.prepareLiveData()
        self.prepareSensorsRecording()
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
    
    // MARK: - Sensors Recording
    
    func prepareSensorsRecording() {
        
        guard let liveController = self.liveDSController else { return }
        
        guard let liveDataSource = liveController.dataSourceContext else { return }
        
        guard self.sensorsLog == nil else { return }
        
        self.sensorsLog = SensorsRecordingController.init()
        self.sensorsLog?.prepareRecorder(with: liveDataSource)
        self.sensorsLog?.delegate = self
    }
    
    func setSensorsRecording(state: RequestRecordingState, completionHandler: ((_ status: RecorderStatus) -> Void)? = nil) {
        
        guard let sensorsLog = self.sensorsLog else { return }
        
        sensorsLog.setRecording(state: state) { status, code in
            
            if let handler = completionHandler {
                
                handler(status)
            }
        }
    }
    
    func isRecorderOn() -> Bool {
        
        guard let sensorsLog = self.sensorsLog else { return false }
        
        return sensorsLog.getStatus() == .recording
    }
    
    func destroySensorsRecording() {
        
        guard let sensorsLog = self.sensorsLog else { return }
        
        sensorsLog.destroyRecorder()
        self.sensorsLog = nil
    }
    
    // MARK: - SensorsRecordingControllerDelegate
    
    func sensorsRecordingController(_ recorderContext: RecorderContext, recordingStatusChanged status: RecorderStatus) {
        
        print("AppManager: sensorsRecordingController, status changed:\(status.rawValue)")
        
        self.recordingModel.refreshStatus(status: status)        
    }
    
    func sensorsRecordingController(_ recorderContext: RecorderContext, recordingCompleted path: String, code: SDKErrorCode) {
        
        print("AppManager: sensorsRecordingController recordingCompleted, path:\(path), error:\(code)")
    }
    
    // MARK: - Location Manager
    
    func prepareLocation() {
        
        self.locationManager = CLLocationManager.init()
        self.locationManager!.delegate = self
    }
    
    func isLocationGranted() -> Bool {
        
        guard let locationManager = self.locationManager else { return false }
        
        return locationManager.authorizationStatus == .authorizedWhenInUse
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
            
            self.recordingModel.isRecAvailable = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // print("testing: new location")
    }
}
