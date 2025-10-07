// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

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
