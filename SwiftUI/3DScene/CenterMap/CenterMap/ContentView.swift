// SPDX-FileCopyrightText: 2024-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit

struct ContentView: View {

    let location = CoordinatesObject.coordinates(
        withLatitude: 48.840827,
        longitude: 2.381899)

    var body: some View {
        MapReader { proxy in
            MapBase()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("", systemImage: "target") {

                            proxy.centerOn(coordinates: location, zoomLevel: 50, duration: 1000)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
