// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: BSD-3-Clause
//
// Contact Magic Lane at <info@magiclane.com> for commercial licensing options.

import SwiftUI
import GEMKit

struct ContentView: View {
    var body: some View {
        MapReader { proxy in
            MapBase(initialPosition: .amsterdam, 
                    initialZoomLevel: 54)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}

extension CoordinatesObject {
    static let amsterdam =
    CoordinatesObject.coordinates(withLatitude: 52.368447, 
                                  longitude: 4.888229)
}
