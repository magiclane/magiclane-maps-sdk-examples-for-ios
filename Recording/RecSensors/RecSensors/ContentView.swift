// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit

struct ContentView: View {
    @ObservedObject var model: RecordModel
    var body: some View {
        ZStack() {
            MapReader { proxy in
                MapBase()
                    .mapCompass(false)
                    .onAppear() {
                        goToUserPosition(proxy, request: false)
                    }
                    .ignoresSafeArea()            
                VStack() {
                    HStack() {
                        Spacer()
                        Button() {
                            startPauseRecording()
                        } label: {
                            VStack {
                                Text("Rec")
                                    .font(.headline)
                                    .foregroundStyle(model.isRecAvailable ? .primary : .secondary)                                    
                            }
                            .frame(width: 70, height: 70)
                            .background(model.recordingSensorsState == .recording ? .red : .white)
                            .clipShape(Capsule())
                        }
                        .disabled(!model.isRecAvailable)
                    }
                    Spacer()
                    HStack {
                        Button() {
                            goToUserPosition(proxy)
                        } label: {
                            Text("My Position")
                                .font(.headline)
                                .padding()
                                .background(Color.white)
                                .clipShape(Capsule())
                        }
                        Spacer()
                        Button() {
                            drawRecPath(proxy)
                        } label: {
                            Text("Rec Path")
                                .font(.headline)
                                .padding()
                                .background(Color.white)
                                .clipShape(Capsule())
                        }
                        .disabled(model.lastRecPath == nil)
                    }
                }
                .shadow(color:.gray, radius: 10)
                .padding()
            }
        }
    }
    
    func goToUserPosition(_ proxy: MapProxy, request: Bool = true) {
        if request {
            AppManager.shared.requestLocationPermission()
        }
        proxy.startFollowingPosition(duration: 0, zoomLevel: 70, viewAngle: 0)
    }
    
    func startPauseRecording() {
        AppManager.shared.recordingModel.cycleState()
    }
    
    func drawRecPath(_ proxy: MapProxy) {        
        guard let path = model.lastRecPath else { return }
        guard let mapViewController = proxy.mapViewController else { return }
        
        let collection = MarkerCollectionObject(name: "recordedPath", type: .polyline)
        collection.addMarker(MarkerObject(coordinates: path.getCoordinates()))
        
        let renderSettings = MarkerCollectionRenderSettingsObject.init()
        renderSettings.polylineInnerColor = UIColor.orange
        renderSettings.polylineOuterColor = UIColor.systemRed.withAlphaComponent(0.8)
        renderSettings.polylineInnerSize = 1.1
        renderSettings.polylineOuterSize = 0.5
        
        mapViewController.addMarker(collection, renderSettingsObject: renderSettings)
    }
}

#Preview {
    ContentView(model: RecordModel.init())        
}

extension CoordinatesObject {
    static let basel =
    CoordinatesObject.coordinates(withLatitude: 48.538413, longitude: 7.600080)
}
