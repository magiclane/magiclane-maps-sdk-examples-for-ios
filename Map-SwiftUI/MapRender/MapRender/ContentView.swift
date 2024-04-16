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
    @State private var mapView = MapView()
    @State private var zoom = 54
    @State private var isRendering = true
    var body: some View {
        NavigationStack {
            mapView
                .mapRender(isRendering)
                .onAppear() {
                    goToPosition()
                }
                .padding(.top)
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
    
    func goToPosition() {
        mapView.centerOn(coordinates: .amsterdam, zoomLevel: zoom)
    }
}

#Preview {
    ContentView()
}

extension CoordinatesObject {
    static let amsterdam =
    CoordinatesObject.coordinates(withLatitude: 52.368447, longitude: 4.888229)
}

