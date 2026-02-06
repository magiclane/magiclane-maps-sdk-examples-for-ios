// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var isAppActive = true
    var body: some View {
        MapReader { proxy in
            MapBase(initialPosition: .amsterdam, initialZoomLevel: 54)
                .mapCompass(false)
                .mapRender(isAppActive)
        }
        .ignoresSafeArea()
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                isAppActive = true
            case .background:
                isAppActive = false
            default:
                break
            }
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
