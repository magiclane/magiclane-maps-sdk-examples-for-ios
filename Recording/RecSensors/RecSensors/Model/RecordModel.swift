// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import Foundation
import GEMKit
import AVFoundation
import Combine

class RecordModel: ObservableObject {
    
    @Published var recordingSensorsState: RecorderStatus = .stopped
    @Published var isRecAvailable: Bool = false
    @Published var lastRecPath: PathObject? = nil
    
    var timerHandle: AnyCancellable? = nil
    @Published var timerSeconds: Int = 0

    func refreshStatus(status: RecorderStatus) {        
        guard status != self.recordingSensorsState else { return }        
        if status == .recording {
            startTimer()
        } else {
            stopTimer()
        }        
        recordingSensorsState = status
    }
    
    func startTimer() {
        guard timerHandle == nil else { return }
        timerHandle = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { [self] date in
                withAnimation(.easeInOut(duration: 0.5)) {
                    timerSeconds += 1
                }
            })        
    }
    
    private func stopTimer() {
        guard let timer = timerHandle else { return }
        timer.cancel()
        timerHandle = nil        
    }
    
    func pausePressed() {
        let state = AppManager.shared.sensorsLog?.getStatus()
        if state == .recording {            
            AppManager.shared.setSensorsRecording(state: .pause)
        }        
    }
    
    func resumePressed() {
        let state = AppManager.shared.sensorsLog?.getStatus()        
        if state == .paused {            
            AppManager.shared.setSensorsRecording(state: .resume)
        }
    }
    
    func startPressed() {
        let state = AppManager.shared.sensorsLog?.getStatus()        
        if state == .stopped {            
            AppManager.shared.setSensorsRecording(state: .record)
        }
    }
    
    func stopPressed() {
        let state = AppManager.shared.sensorsLog?.getStatus()        
        if state == .recording || state == .paused {            
            AppManager.shared.setSensorsRecording(state: .stop)
        }
    }
    
    func cycleState() {
        guard AppManager.shared.isLocationGranted() else { return }
        let state = AppManager.shared.sensorsLog?.getStatus()        
        if state == .stopped {
            startPressed()
            resetPath()
        } else if state == .recording {
            stopPressed()
            createPath()
        }
    }
    
    func createPath() {
        self.lastRecPath = AppManager.shared.sensorsLog?.createPath()        
    }
    
    func resetPath() {
        self.lastRecPath = nil
    }
}
