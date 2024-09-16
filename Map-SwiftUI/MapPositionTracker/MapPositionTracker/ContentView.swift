// Copyright (C) 2019-2024, Magic Lane B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of Magic Lane
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with Magic Lane.

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
