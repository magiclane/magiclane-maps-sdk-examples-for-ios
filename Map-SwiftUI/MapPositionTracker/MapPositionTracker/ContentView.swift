// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit

struct ContentView: View {
    var body: some View {
        MapReader { proxy in
            ZStack(alignment: .bottom) {
                MapBase()
                    .mapCompass(false)
                    .onAppear() {
                        setCustomPositionTracker(proxy)
                    }
                    .ignoresSafeArea()
                VStack() {
                    Button() {
                        goToUserPosition(proxy)
                    } label: {
                        Text("My Position")
                            .font(.headline)
                            .padding()
                            .background(Color.white)
                            .clipShape(Capsule())
                    }
                }
                .shadow(color:.gray, radius: 10)
                .padding()
            }
        }
    }
    
    func setCustomPositionTracker(_ proxy: MapProxy) {
        guard let image = UIImage.init(named: "DotRay") else { return }
        if let data = image.pngData() {
            proxy.mapViewController?.customizePositionTracker(data)
            proxy.mapViewController?.setPositionTrackerScaleFactor(1.6)
            
            let point = CGPoint.init(x: 0.5, y: 0.5) // center screen
            proxy.mapViewController?.setFollowPositionCameraFocus(point)
        }
    }
    
    func goToUserPosition(_ proxy: MapProxy) {
        AppManager.shared.requestLocationPermission()
        proxy.startFollowingPosition(duration: 0, zoomLevel: 70, viewAngle: 0)
    }
}

#Preview {
    ContentView()        
}

extension CoordinatesObject {
    static let basel =
    CoordinatesObject.coordinates(withLatitude: 48.538413, longitude: 7.600080)
}
