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
    
    var centralManager: CBCentralManager!
    var discoveredPeripheral: CBPeripheral?
    var transferCharacteristic: CBCharacteristic?
    var transferModel = TransferDataModel.init()
    var data = Data()
    
    // MARK: - Prepare
    
    func prepareServices() {
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
    
    // MARK: - External Sensors

    
    func scanForPeripherals() {
        
        self.retrievePeripheral()
    }
    
    func cleanRoute() {
        
        self.transferModel.cleanRouteInfo()
    }
    
    // MARK: - Helper Methods

    /*
     * We will first check if we are already connected to our counterpart
     * Otherwise, scan for peripherals - specifically for our service's 128bit CBUUID
     */
    private func retrievePeripheral() {
        
        let connectedPeripherals: [CBPeripheral] = (centralManager.retrieveConnectedPeripherals(withServices: [TransferService.serviceUUID]))
        
        os_log("Found connected Peripherals with transfer service: %@", connectedPeripherals)
        
        if let connectedPeripheral = connectedPeripherals.last {
            os_log("Connecting to peripheral %@", connectedPeripheral)
            self.discoveredPeripheral = connectedPeripheral
            centralManager.connect(connectedPeripheral, options: nil)
        } else {
            // We were not connected to our counterpart, so start scanning
            centralManager.scanForPeripherals(withServices: [TransferService.serviceUUID],
                                               options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    /*
     *  Call this when things either go wrong, or you're done with the connection.
     *  This cancels any subscriptions if there are any, or straight disconnects if not.
     *  (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
     */
    private func cleanup() {
        // Don't do anything if we're not connected
        guard let discoveredPeripheral = discoveredPeripheral,
            case .connected = discoveredPeripheral.state else { return }
        
        for service in (discoveredPeripheral.services ?? [] as [CBService]) {
            for characteristic in (service.characteristics ?? [] as [CBCharacteristic]) {
                if characteristic.uuid == TransferService.characteristicUUID && characteristic.isNotifying {
                    // It is notifying, so unsubscribe
                    self.discoveredPeripheral?.setNotifyValue(false, for: characteristic)
                }
            }
        }
        
        // If we've gotten this far, we're connected, but we're not subscribed, so we just disconnect
        centralManager.cancelPeripheralConnection(discoveredPeripheral)
    }
    
    /*
     *  Write some test data to peripheral
     */
    private func writeData() {
    
        //        guard let discoveredPeripheral = discoveredPeripheral,
        //                let transferCharacteristic = transferCharacteristic
        //            else { return }
        
        // check to see if number of iterations completed and peripheral can accept more data
        //        while discoveredPeripheral.canSendWriteWithoutResponse {
        //
        //            let mtu = discoveredPeripheral.maximumWriteValueLength(for: .withoutResponse)
        //            var rawPacket = [UInt8]()
        //
        //            let bytesToCopy: size_t = min(mtu, data.count)
        //            data.copyBytes(to: &rawPacket, count: bytesToCopy)
        //            let packetData = Data(bytes: &rawPacket, count: bytesToCopy)
        //
        //            let stringFromData = String(data: packetData, encoding: .utf8)
        //            os_log("Writing %d bytes: %s", bytesToCopy, String(describing: stringFromData))
        //
        //            discoveredPeripheral.writeValue(packetData, for: transferCharacteristic, type: .withoutResponse)
        //        }
    }
}

extension AppManager: CBCentralManagerDelegate {
    // implementations of the CBCentralManagerDelegate methods

    /*
     *  centralManagerDidUpdateState is a required protocol method.
     *  Usually, you'd check for other states to make sure the current device supports LE, is powered on, etc.
     *  In this instance, we're just using it to wait for CBCentralManagerStatePoweredOn, which indicates
     *  the Central is ready to be used.
     */
    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {

        switch central.state {
        case .poweredOn:
            // ... so start working with the peripheral
            os_log("CBManager is powered on")
            retrievePeripheral()
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
            os_log("A previously unknown central manager state occurred")
            // In a real app, you'd deal with yet unknown cases that might occur in the future
            return
        }
    }

    /*
     *  This callback comes whenever a peripheral that is advertising the transfer serviceUUID is discovered.
     *  We check the RSSI, to make sure it's close enough that we're interested in it, and if it is,
     *  we start the connection process
     */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        
        // Reject if the signal strength is too low to attempt data transfer.
        // Change the minimum RSSI value depending on your app’s use case.
        guard RSSI.intValue >= -60
            else {
                os_log("Discovered perhiperal not in expected range, at %d", RSSI.intValue)
                return
        }
        
        os_log("Discovered %s at %d", String(describing: peripheral.name), RSSI.intValue)
        
        // Device is in range - have we already seen it?
        if discoveredPeripheral != peripheral {
            
            // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it.
            discoveredPeripheral = peripheral
            
            // And finally, connect to the peripheral.
            os_log("Connecting to perhiperal %@", peripheral)
            centralManager.connect(peripheral, options: nil)
        }
    }

    /*
     *  If the connection fails for whatever reason, we need to deal with it.
     */
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        os_log("Failed to connect to %@. %s", peripheral, String(describing: error))
        cleanup()
    }
    
    /*
     *  We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
     */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        os_log("Peripheral Connected")
        
        self.transferModel.isConnected = true
        
        // Stop scanning
        centralManager.stopScan()
        os_log("Scanning stopped")
        
        // set iteration info
        //connectionIterationsComplete += 1
        
        // Clear the data that we may already have
        data.removeAll(keepingCapacity: false)
        
        // Make sure we get the discovery callbacks
        peripheral.delegate = self
        
        // Search only for services that match our UUID
        peripheral.discoverServices([TransferService.serviceUUID])
    }
    
    /*
     *  Once the disconnection happens, we need to clean up our local copy of the peripheral
     */
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        os_log("Perhiperal Disconnected")
        discoveredPeripheral = nil
        
        self.transferModel.isConnected = false
        
        self.cleanRoute()
        
        // We're disconnected, so start scanning again
        //if connectionIterationsComplete < defaultIterations {
            retrievePeripheral()
//        } else {
//            os_log("Connection iterations completed")
//        }
    }

}

extension AppManager: CBPeripheralDelegate {
    // implementations of the CBPeripheralDelegate methods

    /*
     *  The peripheral letting us know when services have been invalidated.
     */
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        
        for service in invalidatedServices where service.uuid == TransferService.serviceUUID {
            os_log("Transfer service is invalidated - rediscover services")
            self.transferModel.isConnected = false
            peripheral.discoverServices([TransferService.serviceUUID])
        }
    }

    /*
     *  The Transfer Service was discovered
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            os_log("Error discovering services: %s", error.localizedDescription)
            cleanup()
            return
        }
        
        // Discover the characteristic we want...
        
        // Loop through the newly filled peripheral.services array, just in case there's more than one.
        guard let peripheralServices = peripheral.services else { return }
        for service in peripheralServices {
            peripheral.discoverCharacteristics([TransferService.characteristicUUID], for: service)
        }
    }
    
    /*
     *  The Transfer characteristic was discovered.
     *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // Deal with errors (if any).
        if let error = error {
            os_log("Error discovering characteristics: %s", error.localizedDescription)
            cleanup()
            return
        }
        
        // Again, we loop through the array, just in case and check if it's the right one
        guard let serviceCharacteristics = service.characteristics else { return }
        for characteristic in serviceCharacteristics where characteristic.uuid == TransferService.characteristicUUID {
            // If it is, subscribe to it
            transferCharacteristic = characteristic
            peripheral.setNotifyValue(true, for: characteristic)
        }
        
        // Once this is complete, we just need to wait for the data to come in.
    }
    
    /*
     *   This callback lets us know more data has arrived via notification on the characteristic
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // Deal with errors (if any)
        if let error = error {
            os_log("Error discovering characteristics: %s", error.localizedDescription)
            cleanup()
            return
        }
        
        guard var characteristicData = characteristic.value else { return }
        
        let stringFromData = String(data: characteristicData, encoding: .utf8)
        //os_log("Received %d bytes", characteristicData.count)
        
        // Have we received the end-of-message token?
        if let string = stringFromData, string == "EOM" && data.count > 1 {
            
            //os_log("Received %s", string)
            // End-of-message case: show the data.
            // Dispatch the text view update to the main queue for updating the UI, because
            // we don't know which thread this method will be called back on.
            
            guard let type: InfoType = InfoType.init(rawValue: data[0]) else { self.resetData(); return }
            data.removeFirst() // first is the type
            let receivedData = self.data
            self.resetData()
            
            let bytes = String(format: "%d", receivedData.count)
            
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
            
            if type == .instructionDetails {
                
                guard let intructionDetailsString = String(data: receivedData, encoding: .utf8) else { return }
                
                self.transferModel.instructionDetails = intructionDetailsString
                
                os_log("instructionDetails: %s", intructionDetailsString)
            }
            
            else if type == .turnDistance {
                
                guard let turnDistanceString = String(data: receivedData, encoding: .utf8) else { return }
                
                self.transferModel.turnDistance = turnDistanceString
                
                os_log("turnDistance: %s", turnDistanceString)
            }
            
            else if type == .idTurn {
                
                guard receivedData.count == 1 else { return }
                
                if let dataByte = receivedData.first {
                    
                    //let intByte = Int(dataByte)
                    
                    if let image = UIImage(named: String(format:"%d", Int(dataByte)))?.withRenderingMode(.automatic) {
                        
                        self.transferModel.turnImage = image
                    }
                    
                    os_log("turn64id: %d", dataByte)
                }
            }
            
            else if type == .eta {
                
                guard let etaString = String(data: receivedData, encoding: .utf8) else { return }
                
                self.transferModel.eta = etaString
                
                os_log("eta: %s", etaString)
            }
            
            else if type == .remainingTime {
                
                guard let rttString = String(data: receivedData, encoding: .utf8) else { return }
                
                self.transferModel.remainingTime = rttString
                
                os_log("rtt: %s", rttString)
            }
            
            else if type == .remainingDist {
                
                guard let rtdString = String(data: receivedData, encoding: .utf8) else { return }
                
                self.transferModel.remainingDist = rtdString
                
                os_log("rtd: %s", rtdString)
            }
            
            else if type == .cleanup {
                
                self.cleanRoute()
            }
            
            if type != .cleanup {
                self.transferModel.refreshInfoReady()
            } else {
                self.transferModel.isInfoReady = false
            }
            
        } else {
            
            // Otherwise, just append the data to what we have previously received.
            if self.data.isEmpty == false {
                characteristicData.removeFirst()
            }
            
            data.append(characteristicData)
        }
    }

    /*
     *  The peripheral letting us know whether our subscribe/unsubscribe happened or not
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        // Deal with errors (if any)
        if let error = error {
            os_log("Error changing notification state: %s", error.localizedDescription)
            return
        }
        
        // Exit if it's not the transfer characteristic
        guard characteristic.uuid == TransferService.characteristicUUID else { return }
        
        if characteristic.isNotifying {
            // Notification has started
            os_log("Notification began on %@", characteristic)
        } else {
            // Notification has stopped, so disconnect from the peripheral
            os_log("Notification stopped on %@. Disconnecting", characteristic)
            cleanup()
        }
    }
    
    /*
     *  This is called when peripheral is ready to accept more data when using write without response
     */
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        os_log("Peripheral is ready, send data")
        writeData()
    }
    
    func resetData() {
        
        self.data = Data()
    }
}

enum BufferSizeType: Int {
    case idTurn
    case instructionDetails
    case turnDistance
    case eta
    case remainingTime
    case remainingDist
    case cleanup
}

class TransferDataModel: ObservableObject {
    
    @Published var bufferSize: [String] = ["0", "0", "0",
                                           "0", "0", "0", "0"]
    var bufferType: InfoType = .idTurn
    var bufferUnit: String = "bytes"
    
    @Published var isConnected: Bool = false
    @Published var isInfoReady: Bool = false
    
    @Published var instructionDetails: String = ""
    @Published var turnDistance: String = ""
    @Published var eta: String = ""
    @Published var remainingTime: String = ""
    @Published var remainingDist: String = ""
    @Published var turnImage: UIImage?
    
    func cleanRouteInfo() {        
        self.isInfoReady = false
        self.turnImage = nil
        self.instructionDetails = ""
        self.turnDistance = ""
        self.eta = ""
        self.remainingTime = ""
        self.remainingDist = ""        
        self.bufferSize = ["0", "0", "0",
                           "0", "0", "0", "0"]
    }
    
    func refreshInfoReady() {
        
        var infoReady = true
        
        if turnImage == nil { infoReady = false }
        if turnDistance == "" { infoReady = false }
        if eta == "" { infoReady = false }
        if remainingTime == "" { infoReady = false }
        if remainingDist == "" { infoReady = false }
        
        isInfoReady = infoReady
    }
    
    init() {
    }
}
