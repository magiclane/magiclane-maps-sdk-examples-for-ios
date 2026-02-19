// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit

struct ContentView: View {
    
    var body: some View {
        MapReader { proxy in
            MapBase()
                .mapCompass(false)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("", systemImage: "location") {
                            
                            goToUserPosition(proxy)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button("", systemImage: "location.fill") {
                            
                            defaultPositionTracker(proxy)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button("", systemImage: "car.fill") {
                            
                            carPositionTracker(proxy)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button("", systemImage: "airplane") {
                            
                            planePositionTracker(proxy)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button("", systemImage: "circle.fill") {
                            
                            imagePositionTracker(proxy)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .ignoresSafeArea()
        }
    }
    
    func defaultPositionTracker(_ proxy: MapProxy) {

        proxy.mapViewController?.setPositionTrackerScaleFactor(1)
        proxy.mapViewController?.setDefaultPositionTracker()
    }

    func carPositionTracker(_ proxy: MapProxy) {

        let fileName = "car"

        if let urlMtl = Bundle.main.url(forResource: fileName, withExtension: "mtl") {

            if let material = NSData.init(contentsOf: urlMtl) as Data? {

                if let urlObj = Bundle.main.url(forResource: fileName, withExtension: "obj") {

                    if let object = NSData.init(contentsOf: urlObj) as Data? {

                        proxy.mapViewController?.setPositionTrackerScaleFactor(1)
                        proxy.mapViewController?.customizePositionTracker(object, material: material)
                    }
                }
            }
        }
    }

    func planePositionTracker(_ proxy: MapProxy) {

        let fileName = "plane"

        if let urlMtl = Bundle.main.url(forResource: fileName, withExtension: "mtl") {

            if let material = NSData.init(contentsOf: urlMtl) as Data? {

                if let urlObj = Bundle.main.url(forResource: fileName, withExtension: "obj") {

                    if let object = NSData.init(contentsOf: urlObj) as Data? {

                        proxy.mapViewController?.setPositionTrackerScaleFactor(1)
                        proxy.mapViewController?.customizePositionTracker(object, material: material)
                    }
                }
            }
        }
    }
    
    func imagePositionTracker(_ proxy: MapProxy) {
        guard let image = UIImage.init(named: "DotRay") else { return }
        if let data = image.pngData() {
            proxy.mapViewController?.setPositionTrackerScaleFactor(2)
            proxy.mapViewController?.customizePositionTracker(data)
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
