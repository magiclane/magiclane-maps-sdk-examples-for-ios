// SPDX-FileCopyrightText: 1995-2025 Magic Lane Intellectual Property B.V. <info@magiclane.com>
// SPDX-License-Identifier: LicenseRef-MagicLane-Proprietary
//
// Magic Lane Intellectual Property B.V, its affiliates and licensors retain all 
// intellectual property and proprietary rights in and to this material, related
// documentation and any modifications thereto. Any use, reproduction,
// disclosure or distribution of this material and related documentation
// without an express license agreement from Magic Lane Intellectual Property B.V. 
// or its affiliates is strictly prohibited.

import UIKit
import GEMKit
import Foundation
import AVFoundation
import Photos
import CoreMotion

protocol SensorsRecordingControllerDelegate: NSObject {
    
    func sensorsRecordingController(_ recorderContext: RecorderContext, recordingStatusChanged status: RecorderStatus);
    func sensorsRecordingController(_ recorderContext: RecorderContext, recordingCompleted path: String, code: SDKErrorCode);
}

enum RequestRecordingState: Int {
    
    case stop, record, pause, resume
}

class SensorsRecordingController: NSObject, RecorderContextDelegate {
    
    var recorderContext: RecorderContext?
    var recorderConfiguration: RecorderConfigurationObject?
    
    weak var delegate: SensorsRecordingControllerDelegate?
    
    var startRecordingCode: SDKErrorCode = .kNoError
    var stopDelegateCompletion: ((Bool) -> Void)?
    
    let minDurationSeconds: UInt = 5 // seconds    
    var logBookmarks: LogBookmarksContext? = nil    
    let sensorsFolderName = "sensors"
    
    // MARK: - Prepare
    
    func prepareRecorder(with context: DataSourceContext) {
        
        guard self.recorderContext == nil else { return }
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        if let documentsPath = paths.first {
            
            let folderPath = documentsPath.appendingPathComponent(sensorsFolderName).path
            
            self.recorderConfiguration = RecorderConfigurationObject.init(folderPath: folderPath, context: context)
            self.recorderConfiguration!.setDeviceModel("Apple: iPhone")
            self.recorderConfiguration!.setMinDurationSeconds(self.minDurationSeconds)
            
            self.recorderConfiguration!.setDataType(.position)            
            
            let keyAllRec = self.recorderConfiguration!.kKeepAllRecordings
            self.recorderConfiguration!.setKeepMinSeconds(keyAllRec)
            
            let keyInfiniteRec = self.recorderConfiguration!.kInfiniteRecording
            self.recorderConfiguration!.setChunkDurationSeconds(keyInfiniteRec)
            
            self.recorderContext = RecorderContext.init(configuration: self.recorderConfiguration!)
            self.recorderContext!.delegate = self
            
            self.logBookmarks = LogBookmarksContext.init(folderPath: folderPath)
            
            print("SensorsRecordingController: prepareRecorder")
        }
    }
    
    // MARK: - Destroy
    
    func destroyRecorder() {
        
        guard self.recorderContext != nil else { return }
        
        if self.isRecorderOn() {
            
            self.stopDelegateCompletion = { [weak self] (finished) -> Void in
                
                guard let strongSelf = self else { return }
                
                if finished {
                    
                    strongSelf.reset()
                }
            }
            
            self.setRecording(state: .stop) { status, code in }
            
        } else {
            
            self.reset()
        }
    }
    
    func reset() {
        
        guard self.recorderContext != nil else { return }
        
        self.recorderContext!.delegate = nil
        self.recorderConfiguration = nil
        self.recorderContext = nil
        
        self.delegate = nil
        
        print("SensorsRecordingController: destroyRecorder done")
    }
    
    // MARK: - Properties
    
    func isAllow() -> Bool {
        
        return true // by default all the time; previous it was a settings
    }
    
    func isAudioAllow() -> Bool {
        
        if self.isAllow() {
            
            if self.isMicrophonePermissionAllow() {
                
                return true
            }
        }
        
        return false
    }
    
    func isMicrophonePermissionAllow() -> Bool {
        
        let status = AVAudioSession.sharedInstance().recordPermission
        
        let isGranted = (status == .granted)
        
        return isGranted
    }
    
    func setRecording(state: RequestRecordingState, completion: @escaping (_ status: RecorderStatus, _ code: SDKErrorCode) -> Void ) {
        
        guard self.recorderContext != nil else { return }
        
        let isRecorderOn = self.isRecorderOn()
        
        if state == .record && !isRecorderOn {
            
            let code = self.startRecording()
            
            if code == .kNoError {
                
                completion(.recording, code)
                
            } else if code == .kNoDiskSpace {
                
                self.destroyRecorder()
                
                completion(.stopped, code)
                
            } else {
                
                completion(.stopped, code)
            }
        }
        
        if state == .pause && isRecorderOn {
            
            let code = self.pauseRecording()
            
            self.stopAudioRecording()
            
            if code == .kNoError {
                
                completion(.paused, code)
            }
        }
        
        if state == .resume && isRecorderPaused() {
            
            let code = self.resumeRecording()
            
            if code == .kNoError {
                
                completion(.resuming, code)
            }
        }
        
        let isRecorderOff = self.isRecorderOff()
        
        if state == .stop && !isRecorderOff {
            
            self.stopAudioRecording()
            
            let code = self.stopRecording()
            
            completion(.stopped, code)
        }
    }
    
    private func startRecording() -> SDKErrorCode {
        
        guard self.recorderContext != nil else { return SDKErrorCode.kNotSupported }
        
        guard self.isAllow() else { return SDKErrorCode.kNotSupported }
        
        self.startRecordingCode = self.recorderContext!.startRecording()
        
        return self.startRecordingCode
    }
    
    private func stopRecording() -> SDKErrorCode {
        
        guard self.recorderContext != nil else { return .kGeneral }
        
        print("SensorsRecordingController: stopRecording")
        
        let code = self.recorderContext!.stopRecording()
        
        return code
    }
    
    private func pauseRecording() -> SDKErrorCode {
        
        guard self.recorderContext != nil else { return .kGeneral }
        
        print("SensorsRecordingController: pauseRecording")
        
        let code = self.recorderContext!.pauseRecording()
        
        return code
    }
    
    private func resumeRecording() -> SDKErrorCode {
        
        guard self.recorderContext != nil else { return .kGeneral }
        
        print("SensorsRecordingController: resumeRecording")
        
        let code = self.recorderContext!.resumeRecording()
        
        return code
    }
    
    func startAudioRecording() -> Void {
        
        guard self.recorderContext != nil else { return }
        
        self.recorderContext!.startAudioRecording()
    }
    
    func stopAudioRecording() -> Void {
        
        guard self.recorderContext != nil else { return }
        
        self.recorderContext!.stopAudioRecording()
    }
    
    func isAudioRecording() -> Bool {
        
        guard self.recorderContext != nil else { return false }
        
        return self.recorderContext!.isAudioRecording()
    }
    
    func isRecorderOn() -> Bool {
        
        guard self.recorderContext != nil else { return false }
        
        let state = self.recorderContext!.getStatus()
        
        let value = (state == .recording)
        
        return value
    }
  
    func isRecorderOff() -> Bool {
        
        guard self.recorderContext != nil else { return true }
        
        let state = self.recorderContext!.getStatus()
        
        let value = (state == .stopped)
        
        return value
    }
    
    func isRecorderPaused() -> Bool {
        
        guard self.recorderContext != nil else { return true }
        
        let state = self.recorderContext!.getStatus()
        
        let value = (state == .paused)
        
        return value
    }
    
    func getStatus() -> RecorderStatus {
                
        guard let recorderContext = self.recorderContext else { return .stopped }
        
        let status = recorderContext.getStatus()
        
        return status
    }       
    
    // MARK: - RecorderContextDelegate
    
    func recorderContext(_ recorderContext: RecorderContext, recordingStatusChanged status: RecorderStatus) {
        
        var statusString = ""
        
        switch status {
            
        case .stopped:
            statusString = "stopped"
            
        case .stopping:
            statusString = "stopping"
            
        case .starting:
            statusString = "starting"
            
        case .recording:
            statusString = "recording"
            
        case .restarting:
            statusString = "restarting"
            
        case .pausing:
            statusString = "pausing"
            
        case .paused:
            statusString = "paused"
            
        case .resuming:
            statusString = "resuming"
            
        default:
            break
        }
        
        print("SensorsRecordingController: recordingStatusChanged:\(statusString)")
        
        if let delegate = self.delegate {
            
            delegate.sensorsRecordingController(recorderContext, recordingStatusChanged: status)
        }
        
        if status == .stopped {
            
            if let handler = self.stopDelegateCompletion {
                
                handler(true)
            }
            
            self.stopDelegateCompletion = nil
        }
    }
    
    func recorderContext(_ recorderContext: RecorderContext, recordingCompleted path: String, code: SDKErrorCode) {
        
        print("SensorsRecordingController: recordingCompleted, filePath:\(path)")
        
        if let delegate = self.delegate {
            
            delegate.sensorsRecordingController(recorderContext, recordingCompleted: path, code: code)
        }
    }
    
    // MARK: - Utils
    
    func createPath() -> PathObject? {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        if let documentsPath = paths.first {
            
            let folderPath = documentsPath.appendingPathComponent(sensorsFolderName).path
            
            let logBookmarks = LogBookmarksContext.init(folderPath: folderPath)
            
            if let filePath = logBookmarks.getLogs().last {
                
                let coordinates = logBookmarks.getRoute(filePath)
                
                if coordinates.count > 2 {
                    
                    let pathObject = PathObject(coordinates: coordinates)
                    
                    return pathObject
                }
            }
        }
        
        return nil
    }
    
    func checkRecordedFiles() {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        if let documentsPath = paths.first {
            
            let folderPath = documentsPath.appendingPathComponent(sensorsFolderName).path
            
            let logBookmarks = LogBookmarksContext.init(folderPath: folderPath)
            
            let paths = logBookmarks.getLogs()
            
            print("SensorsRecordingController: log files count:%d", paths.count)
            
            for filePath in paths {
                
                print("SensorsRecordingController: log at:%@", filePath)
            }
        }
    }  
}

