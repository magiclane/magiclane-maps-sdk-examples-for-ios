// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: BSD-3-Clause
//
// Contact Magic Lane at <info@magiclane.com> for commercial licensing options.

import SwiftUI
import GEMKit

struct ContentView: View {
    @State private var zoom = 74
    var body: some View {
        MapReader { proxy in
            MapBase()
                .didSelectStreets { streets, touchPoint, isLongTouch in
                    proxy.present(highlights: streets, settings: getRenderSettings())
                }
                .didSelectLandmarks { landmarks, touchPoint, isLongTouch in
                    proxy.present(highlights: landmarks, settings: getRenderSettings())
                }
                .didSelectOverlays { overlays, touchPoint, isLongTouch in
                    print("didSelectOverlays")   
                }
                .didSelectTrafficEvents { events, touchPoint, isLongTouch in
                    print("didSelectTrafficEvents")
                }
                .onAppear() {
                    goToPosition(proxy)
                }
                .ignoresSafeArea()
        }
    }
    
    func getRenderSettings() -> HighlightRenderSettings {
        let settings = HighlightRenderSettings.init()
        settings.imageSize = 7
        settings.textSize = 4
        settings.textColor = UIColor.black
        return settings
    }
    
    func goToPosition(_ proxy: MapProxy) {
        proxy.centerOn(coordinates: .amsterdam, zoomLevel: zoom)
    }
}

#Preview {
    ContentView()
}

extension CoordinatesObject {
    static let amsterdam =
    CoordinatesObject.coordinates(withLatitude: 52.368447, longitude: 4.888229)
}

