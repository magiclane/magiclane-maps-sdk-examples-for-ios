// SPDX-FileCopyrightText: 2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit

struct ContentView: View {

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        MapReader { proxy in
            MapBase()
                .mapStyle(getStyleFollowingOS())
                .mapCompassFollowInterfaceStyle(true)
                .ignoresSafeArea()
        }
    }

    func getStyleFollowingOS() -> Int {
        return colorScheme == .dark ? MapStyleIdentifiers.night.rawValue : MapStyleIdentifiers.day.rawValue
    }
}

#Preview {
    ContentView()
}
