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
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        MapReader { proxy in
            MapBase()
                .mapStyle(getStyleFollowingOS())
                .onAppear() {
                    goToPosition(proxy)
                    // applyCustomMapStyle(proxy)
                }
                .ignoresSafeArea()
        }
    }
    
    func goToPosition(_ proxy: MapProxy) {
        proxy.centerOn(coordinates: .amsterdam, zoomLevel: zoom)
    }
    
    func getStyleFollowingOS() -> Int {
        return colorScheme == .dark ?
        MapStyleIdentifiers.night.rawValue :
        MapStyleIdentifiers.day.rawValue
    }
    
    func applyCustomMapStyle(_ proxy: MapProxy) {
        guard let url = Bundle.main.url(forResource: "CustomMapStyle", withExtension: "style") else { return }
        if let data = NSData.init(contentsOf: url) as Data? {
            proxy.setMapStyle(data: data, smoothTransition: true)
        }
    }
}

#Preview {
    ContentView()
}

extension CoordinatesObject {
    static let amsterdam =
    CoordinatesObject.coordinates(withLatitude: 52.368447, longitude: 4.888229)
}
