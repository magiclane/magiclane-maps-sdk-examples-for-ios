// Copyright (C) 2019-2024, Magic Lane B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of Magic Lane
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with Magic Lane.

import GEMKit
import CoreLocation
import CoreBluetooth
import os

enum InfoType: UInt8 {
    
    case idTurn
    case instructionDetails
    case turnDistance
    case eta
    case remainingTime
    case remainingDist
    case cleanup
}

class AppManager: NSObject, CLLocationManagerDelegate, NavigationContextDelegate {
    
    static let shared = AppManager.init()
    
    var peripheralManager: CBPeripheralManager?
    var transferCharacteristic: CBMutableCharacteristic?
    var connectedCentral: CBCentral?
    var dataToSend = Data()
    var sendDataIndex: Int = 0
    var currentInfoType: InfoType = .instructionDetails
    var pendingData: [(type: InfoType, data: Data)] = []
    
    var previousInstructionIndex: Int = -1
    
    var previousTurnId: Int = -1
    var previousEta: String = ""
    var previousRemainingDist: String = ""
    var previousRemainingTime: String = ""
    var previousInstructionDetails: String = ""
    var previousTurnDistance: String = ""
    
    var transferModel = TransferDataModel.init()
    
    var locationManager: CLLocationManager?
    var liveDSController: LiveDataSourceController?
    var navigationContext: NavigationContext?
    var soundContext: SoundContext?
    var alarmContext: AlarmContext?
    var navigationModel = NavigationModel.init()
    
    
    // MARK: - Prepare
    
    func prepareServices() {
        
        self.preparePeripheral()
        self.prepareLocation()
        self.prepareLiveData()
    }
    
    // MARK: - Live Sensors
    
    func preparePeripheral() {
        
        guard self.peripheralManager == nil else { return }
        
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionShowPowerAlertKey: true])
    }
    
    func startAdvertising() {
        
        guard let peripheralManager = self.peripheralManager else { return }
        
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [TransferService.serviceUUID]])
    }
    
    func stopAdvertising() {
        
        guard let peripheralManager = self.peripheralManager else { return }
        
        peripheralManager.stopAdvertising()
    }
    
    func prepareLiveData() {
        
        guard self.liveDSController == nil else { return }
        
        self.liveDSController = LiveDataSourceController.init()
    }
    
    func prepareSound() {
        
        guard self.soundContext == nil else { return }
        
        self.soundContext = SoundContext.init()
        self.soundContext?.setUseTtsWithCompletionHandler({ success in })
    }
    
    func prepareAlarms() {
        
        guard self.alarmContext == nil else { return }
        
        self.alarmContext = AlarmContext.init()
        self.alarmContext?.setAlarmDistance(500)
        self.alarmContext?.setMonitorWithoutRoute(false)
        
        self.alarmContext?.registerSafetyCameraNotifications(completionHandler: { success in
            
            print("AlarmContext: registerSafetyCamera with success:\(success)")
        })
        
        self.alarmContext?.registerSocialReportNotifications(completionHandler: { success in
            
            print("AlarmContext: registerSocialReport with success:\(success)")
        })
    }
    
    func startLiveSensors() {
        
        guard let controller = self.liveDSController else { return }
        
        controller.startLiveSensors()
    }
    
    func stopLiveSensors() {
        
        guard let controller = self.liveDSController else { return }
        
        controller.stopLiveSensors()
    }
    
    // MARK: - Location Manager
    
    func prepareLocation() {
        
        self.locationManager = CLLocationManager.init()
        self.locationManager!.delegate = self
        self.locationManager!.allowsBackgroundLocationUpdates = true
        
        self.requestLocationPermission()
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
        
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        if manager.authorizationStatus == .authorizedWhenInUse {
            
            self.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // print("testing: new location")
    }
    
    // MARK: - Simulation
    
    func startRouteSimulation(completion: @escaping (_ mainRoute: RouteObject) -> Void) {
        
        guard self.navigationContext == nil else { return }
        
        let preferences = RoutePreferencesObject.init()
        preferences.setTransportMode(.car)
        preferences.setRouteType(.fastest)
        preferences.setBuildConnections(true, maxLengthM: 250)
        
        let traffic = TrafficContext.init()
        traffic.setUseTraffic(.useOffline) // roadblocks
        
        self.navigationContext = NavigationContext.init(preferences: preferences)
        self.navigationContext?.delegate = self
        
        let departure = LandmarkObject.landmark(withName: "Amsterdam 1",
                                                location: CoordinatesObject.coordinates(withLatitude: 52.368934, longitude: 4.870522))
        
        let destination = LandmarkObject.landmark(withName: "Amsterdam 2",
                                                  location: CoordinatesObject.coordinates(withLatitude: 52.358800, longitude: 4.850988))
        
        self.navigationContext?.calculateRoute(withWaypoints: [departure, destination], completionHandler: { [weak self] (results: [RouteObject]) in
            
            guard let strongSelf = self else { return }
            
            guard let navigationContext = strongSelf.navigationContext else { return }
            
            print("Found \(results.count) routes")
            
            for route in results {
                
                if let timeDuration = route.getTimeDistance() {
                    
                    let time     = timeDuration.getTotalTimeFormatted() + timeDuration.getTotalTimeUnitFormatted()
                    let distance = timeDuration.getTotalDistanceFormatted() + timeDuration.getTotalDistanceUnitFormatted()
                    
                    print("route time:\(time), distance:\(distance)")
                }
            }
            
            if let route = results.first {
                
                navigationContext.simulate(withRoute: route, speedMultiplier: 1.0) { success in
                    
                    if success {
                        
                        strongSelf.navigationModel.isNavigationActive = true
                        
                        if let route = navigationContext.getNavigationRoute() {
                            
                            completion(route)
                        }
                        
                    } else {
                        
                        strongSelf.navigationContext = nil
                    }
                }
                
            } else {
                
                strongSelf.navigationContext = nil
            }
        })
    }
    
    func stopRouteSimulation() {
        
        guard let navigationContext = self.navigationContext else { return }
        
        if navigationContext.isSimulationActive() {
            
            navigationContext.cancelNavigateRoute()
        }
        
        self.navigationModel.clean()
        self.transferModel.clean()
        
        self.cleanPreviousInfo()
        
        self.pendingData.removeAll()
        
        self.navigationContext = nil
        
        if let data = "EOR".data(using: .utf8) {
            
            self.sendOperation(buffer: data, infoType: .cleanup)
        }
    }
    
    func isSimulationActive() -> Bool {
        
        guard let navigationContext = self.navigationContext else { return false }
        
        return navigationContext.isSimulationActive()
    }
    
    func cleanPreviousInfo() {
        
        self.previousInstructionIndex = -1
        self.previousTurnId = -1
        
        self.previousEta = ""
        self.previousRemainingTime = ""
        self.previousRemainingDist = ""
        self.previousInstructionDetails = ""
        self.previousTurnDistance = ""
    }
    
    func setRoadBlock() {
        
        guard let navigationContext = self.navigationContext else { return }
        
        let length = 200 //m
        
        navigationContext.setRoadBlockWithLength(length)
    }
    
    // MARK: - NavigationContextDelegate
    
    func navigationContext(_ navigationContext: NavigationContext, navigationStartedForRoute route: RouteObject) {
        
    }
    
    func navigationContext(_ navigationContext: NavigationContext, navigationRouteUpdated route: RouteObject) {
        
        self.cleanPreviousInfo()
        self.pendingData.removeAll()
    }
    
    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationDestinationReached waypoint: LandmarkObject) {
        
        self.stopRouteSimulation()
    }
    
    func navigationContext(_ navigationContext: NavigationContext, navigationInstructionUpdatedForRoute route: RouteObject, updatedEvents events: Int32) {
        
        if let turnInstruction = navigationContext.getNavigationInstruction() {
            
            if turnInstruction.getNavigationStatus() == .running {
                
                if turnInstruction.hasNextTurnInfo() {
                    
                    let index = turnInstruction.getInstructionIndex()
                    
                    if index != self.previousInstructionIndex {
                        
                        let instructionString = turnInstruction.getNextTurnInstructionFormatted()
                        
                        if instructionString != self.previousInstructionDetails {
                            
                            if let data = instructionString.data(using: .utf8) {
                                
                                self.sendOperation(buffer: data, infoType: .instructionDetails)
                                
                                self.previousInstructionDetails = instructionString
                            }
                        }
                    }
                    
                    let scale = UIScreen.main.scale
                    let size = CGSize.init(width: 60 * scale, height: 60 * scale)
                    var image = turnInstruction.getNextTurnImage(size,
                                                                 colorActiveInner: UIColor.white,
                                                                 colorActiveOuter: UIColor.black,
                                                                 colorInactiveInner: UIColor.lightGray,
                                                                 colorInactiveOuter: UIColor.lightGray)
                    
                    if image == nil {
                        image = UIImage.init()
                    }
                    
                    let distance  = turnInstruction.getDistanceToNextTurnFormatted()
                    let distanceUnit = turnInstruction.getDistanceToNextTurnUnitFormatted()
                    let instruction = turnInstruction.getNextTurnInstructionFormatted()
                    
                    let distanceString = distance + distanceUnit
                    
                    if previousTurnDistance != distanceString {
                        if let data = distanceString.data(using: .utf8) {
                            self.sendOperation(buffer: data, infoType: .turnDistance)
                            
                            self.previousTurnDistance = distanceString
                        }
                    }
                    
                    self.navigationModel.turnImage = image!
                    self.navigationModel.distance = distance
                    self.navigationModel.distanceUnit = distanceUnit
                    self.navigationModel.instruction = instruction
                }
                
                if let timeDistance = turnInstruction.getRemainingTravelTimeDistance() {
                    
                    let totalTime = timeDistance.getTotalTime()
                    let timeZone = self.getDestinationTimeZone(timeDistance: timeDistance, route: route)
                    
                    let etaText = self.getFormattedDateSinceNow(time: Double(totalTime), timeZone: timeZone)
                    
                    let rttText = self.getComponentsFormatted(time: Double(totalTime))
                    
                    let rtdText = timeDistance.getTotalDistanceFormatted() + " " + timeDistance.getTotalDistanceUnitFormatted()
                    
                    if etaText != self.previousEta {
                        
                        if let data = etaText.data(using: .utf8) {
                            
                            self.sendOperation(buffer: data, infoType: .eta)
                            
                            self.previousEta = etaText
                        }
                    }
                    
                    if rttText != self.previousRemainingTime {
                        
                        if let data = rttText.data(using: .utf8) {
                            
                            self.sendOperation(buffer: data, infoType: .remainingTime)
                            
                            self.previousRemainingTime = rttText
                        }
                    }
                    
                    if rtdText != self.previousRemainingDist {
                        
                        if let data = rtdText.data(using: .utf8) {
                            
                            self.sendOperation(buffer: data, infoType: .remainingDist)
                            
                            self.previousRemainingDist = rtdText
                        }
                    }
                }
                
                if let nextTurnDetails = turnInstruction.getNextTurnDetails() {
                    
                    let turnId64 = UInt8(nextTurnDetails.getTurnId64().rawValue)
                    
                    if Int(turnId64) != self.previousTurnId {
                        
                        var data = Data()
                        data.append(turnId64)
                        
                        self.sendOperation(buffer: data, infoType: .idTurn)
                        
                        self.previousTurnId = Int(turnId64)
                    }
                }
            }
        }
    }
    
    func getComponentsFormatted(time: Double) -> String {
        
        let value = max(61, time) // no seconds
        
        var unitsStyle = DateComponentsFormatter.UnitsStyle.short
        
        if time > 3600 + 60 { // 1h 1 min
            
            unitsStyle = .abbreviated
        }
        
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.allowedUnits = [.hour, .minute]
        dateComponentsFormatter.unitsStyle = unitsStyle
        
        if let text = dateComponentsFormatter.string(from: value) {
            
            return text
            
        } else {
            
            return ""
        }
    }
    
    func getFormattedDateSinceNow(time: Double, timeZone: TimeZone) -> String {
        
        let value = max(61, time) // no seconds
        let date = Date.init(timeIntervalSinceNow: value)
        
        let dateFormatter = DateFormatter.init()
        dateFormatter.locale = Locale.current
        dateFormatter.calendar = Calendar.current
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = timeZone
        
        let text = dateFormatter.string(from: date)
        
        return text
    }
    
    func getDestinationTimeZone(timeDistance: TimeDistanceObject, route: RouteObject) -> TimeZone {
        
        let waypoints = route.getWaypoints()
        
        guard let destinationLmk = waypoints.last else { return TimeZone.current }
        
        let time = TimeObject.init()
        time.setUniversalTime()
        
        let location = destinationLmk.getCoordinates()
        
        let result = TimezoneContext.sharedInstance().getOfflineTimezoneInfo(location, time: time)
        
        let status = result.getStatus()
        
        if status == .success {
            
            let timeZoneId = result.getTimezoneId()
            
            if timeZoneId.count > 0, let value = TimeZone(identifier: timeZoneId) {
                
                return value
            }
        }
        
        return TimeZone.current
    }
    
    // MARK: - Helper Methods

    /*
     *  Sends the next amount of data to the connected central
     */
    static var sendingEOM = false
    
    private func sendOperation(buffer: Data, infoType: InfoType) {
        
        if self.sendDataIndex == 0 {
            
            if self.pendingData.count > 0  {

                self.setPendingData(buffer: buffer, infoType: infoType)
                
                let firstPending = self.pendingData.removeFirst()
                self.dataToSend = firstPending.data
                self.currentInfoType = firstPending.type
                
                self.sendData(infoType: currentInfoType)
                
                return
            }
            
            self.dataToSend = buffer
            self.currentInfoType = infoType
            
            self.sendData(infoType: infoType)
            
        } else {
            
            self.setPendingData(buffer: buffer, infoType: infoType)
        }
    }
    
    private func setPendingData(buffer: Data, infoType: InfoType) {
        
        for index in 0..<self.pendingData.count {
            
            if self.pendingData[index].type == infoType {
                
                self.pendingData[index] = (infoType, buffer)
                
                return
            }
        }
        
        self.pendingData.append((infoType, buffer))
    }
    
    private func sendData(infoType: InfoType) {
        
        guard let transferCharacteristic = transferCharacteristic else { return }
        
        guard let subscribedCentrals = transferCharacteristic.subscribedCentrals, subscribedCentrals.count != 0 else {
            
//            if infoType != .position {
                
                self.setPendingData(buffer: self.dataToSend, infoType: infoType)
//            }
            
            self.sendDataIndex = 0
            self.dataToSend = Data()
            
            return
        }
        
        // First up, check if we're meant to be sending an EOM
        if AppManager.sendingEOM {
            // send it
            let didSend = self.peripheralManager!.updateValue("EOM".data(using: .utf8)!, for: transferCharacteristic, onSubscribedCentrals: nil)
            // Did it send?
            if didSend {
                
                self.refreshTransferInfo(type: infoType)
                // It did, so mark it as sent
                AppManager.sendingEOM = false
                self.dataToSend = Data()
                self.sendDataIndex = 0
                //os_log("Sent: EOM")
            }
            // It didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
            return
        }
        
        // We're not sending an EOM, so we're sending data
        // Is there any left to send?
        if sendDataIndex >= dataToSend.count {
            // No data left.  Do nothing
            return
        }
        
        // There's data left, so send until the callback fails, or we're done.
        var didSend = true
        while didSend {
            
            // Work out how big it should be
            var amountToSend = dataToSend.count - sendDataIndex
            
            if let mtu = connectedCentral?.maximumUpdateValueLength {
                
                amountToSend = min(amountToSend, mtu - 4)
            }
            
            // Copy out the data we want
            let chunk = dataToSend.subdata(in: sendDataIndex..<(sendDataIndex + amountToSend))
            
            var chunkWithInfo = Data()
            chunkWithInfo.append(infoType.rawValue)
            chunkWithInfo.append(chunk)
            
            // Send it
            didSend = self.peripheralManager!.updateValue(chunkWithInfo, for: transferCharacteristic, onSubscribedCentrals: nil)
            
            // If it didn't work, drop out and wait for the callback
            if !didSend {
                
                if sendDataIndex == 0 {
                    
                    self.setPendingData(buffer: dataToSend, infoType: infoType)
                }
                
                return
            }
            
            // let stringFromData = String(data: chunk, encoding: .utf8)
            // os_log("Sent %d bytes: %s", chunk.count, String(describing: stringFromData))
            // self.transferModel.bufferSize = String(format:"%d", chunk.count)
            
            // It did send, so update our index
            sendDataIndex += amountToSend
            // Was it the last one?
            if sendDataIndex >= dataToSend.count {
                // It was - send an EOM
                
                // Set this so if the send fails, we'll send it next time
                AppManager.sendingEOM = true
                
                //Send it
                let eomSent = self.peripheralManager!.updateValue("EOM".data(using: .utf8)!, for: transferCharacteristic, onSubscribedCentrals: nil)
                
                if eomSent {
                    
                    self.refreshTransferInfo(type: infoType)
                    // It sent; we're all done
                    AppManager.sendingEOM = false
                    self.dataToSend = Data()
                    self.sendDataIndex = 0
                    //os_log("Sent: EOM")
                }
                return
            }
        }
    }
    
    private func setupPeripheral() {
        
        // Build our service.
        
        // Start with the CBMutableCharacteristic.
        let transferCharacteristic = CBMutableCharacteristic(type: TransferService.characteristicUUID,
                                                         properties: [.notify, .writeWithoutResponse],
                                                         value: nil,
                                                         permissions: [.readable, .writeable])
        
        // Create a service from the characteristic.
        let transferService = CBMutableService(type: TransferService.serviceUUID, primary: true)
        
        // Add the characteristic to the service.
        transferService.characteristics = [transferCharacteristic]
        
        // And add it to the peripheral manager.
        self.peripheralManager!.add(transferService)
        
        // Save the characteristic for later.
        self.transferCharacteristic = transferCharacteristic

    }
    
    func refreshTransferInfo(type: InfoType) {
        let bytes = String(format: "%d", self.dataToSend.count)
        self.transferModel.bufferType = type
        switch type {
        case .idTurn:             self.transferModel.bufferSize[BufferSizeType.idTurn.rawValue] = bytes
        case .turnDistance:       self.transferModel.bufferSize[BufferSizeType.turnDistance.rawValue] = bytes
        case .instructionDetails: self.transferModel.bufferSize[BufferSizeType.instructionDetails.rawValue] = bytes
        case .eta:                self.transferModel.bufferSize[BufferSizeType.eta.rawValue] = bytes
        case .remainingTime:      self.transferModel.bufferSize[BufferSizeType.remainingTime.rawValue] = bytes
        case .remainingDist:      self.transferModel.bufferSize[BufferSizeType.remainingDist.rawValue] = bytes
        default: break
        }
    }
}

extension AppManager: CBPeripheralManagerDelegate {
    // implementations of the CBPeripheralManagerDelegate methods

    /*
     *  Required protocol method.  A full app should take care of all the possible states,
     *  but we're just waiting for to know when the CBPeripheralManager is ready
     *
     *  Starting from iOS 13.0, if the state is CBManagerStateUnauthorized, you
     *  are also required to check for the authorization state of the peripheral to ensure that
     *  your app is allowed to use bluetooth
     */
    internal func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        //advertisingSwitch.isEnabled = peripheral.state == .poweredOn
        
        switch peripheral.state {
        case .poweredOn:
            // ... so start working with the peripheral
            os_log("CBManager is powered on")
            setupPeripheral()
            startAdvertising()
        case .poweredOff:
            os_log("CBManager is not powered on")
            // In a real app, you'd deal with all the states accordingly
            return
        case .resetting:
            os_log("CBManager is resetting")
            // In a real app, you'd deal with all the states accordingly
            return
        case .unauthorized:
            // In a real app, you'd deal with all the states accordingly
            switch CBCentralManager.authorization {
            case .denied:
                os_log("You are not authorized to use Bluetooth")
            case .restricted:
                os_log("Bluetooth is restricted")
            default:
                os_log("Unexpected authorization")
            }
            return
        case .unknown:
            os_log("CBManager state is unknown")
            // In a real app, you'd deal with all the states accordingly
            return
        case .unsupported:
            os_log("Bluetooth is not supported on this device")
            // In a real app, you'd deal with all the states accordingly
            return
        @unknown default:
            os_log("A previously unknown peripheral manager state occurred")
            // In a real app, you'd deal with yet unknown cases that might occur in the future
            return
        }
    }

    /*
     *  Catch when someone subscribes to our characteristic, then start sending them data
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        os_log("Central subscribed to characteristic")
        
        self.transferModel.isConnected = true
        
//        let string = "Received data"
//
//        // Get the data
//        dataToSend = string.data(using: .utf8)!
        
        // Reset the index
        sendDataIndex = 0
        
        // save central
        connectedCentral = central
        
        // Start sending
        //sendData()
    }
    
    /*
     *  Recognize when the central unsubscribes
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        os_log("Central unsubscribed from characteristic")
        connectedCentral = nil
        self.transferModel.isConnected = false
    }
    
    /*
     *  This callback comes in when the PeripheralManager is ready to send the next chunk of data.
     *  This is to ensure that packets will arrive in the order they are sent
     */
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        // Start sending again
        
        if self.sendDataIndex == 0 {
            
            if self.pendingData.count > 0 {
                
                self.sendOperation(buffer: self.pendingData[0].data, infoType: self.pendingData[0].type)
            }
            
        } else {
            
            sendData(infoType: self.currentInfoType)
        }
    }
    
    /*
     * This callback comes in when the PeripheralManager received write to characteristics
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for aRequest in requests {
            guard let requestValue = aRequest.value,
                let stringFromData = String(data: requestValue, encoding: .utf8) else {
                    continue
            }
            
            os_log("Received write request of %d bytes: %s", requestValue.count, stringFromData)
            //self.textView.text = stringFromData
        }
    }
}
