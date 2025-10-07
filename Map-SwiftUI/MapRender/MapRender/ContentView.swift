// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

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

