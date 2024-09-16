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

