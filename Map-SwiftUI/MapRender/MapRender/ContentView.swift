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
    @State private var zoom = 54
    @State private var isRendering = true
    var body: some View {
        NavigationStack {
            MapReader { proxy in
                MapBase()
                    .mapRender(isRendering)
                    .mapUserInteraction(isRendering)
                    .onAppear() {
                        goToPosition(proxy)
                        // enableMapLabelsContinuousRendering(proxy)
                    }
                    .ignoresSafeArea(.all, edges: .bottom)
                    .navigationTitle("GEMKit - SwiftUI")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(isRendering ? "RenderOff" : "RenderOn") {
                                isRendering.toggle()
                            }
                        }
                    }
            }
        }
    }
    
    func goToPosition(_ proxy: MapProxy) {
        proxy.centerOn(coordinates: .amsterdam, zoomLevel: zoom)
    }
    
    func enableMapLabelsContinuousRendering(_ proxy: MapProxy) {
        proxy.mapViewController?.getPreferences().setMapLabelsContinuousRendering(true)
    }
}

#Preview {
    ContentView()
}

extension CoordinatesObject {
    static let amsterdam =
    CoordinatesObject.coordinates(withLatitude: 52.368447, longitude: 4.888229)
}

