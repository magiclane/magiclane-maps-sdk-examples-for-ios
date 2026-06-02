// SPDX-FileCopyrightText: 2024-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit

struct ContentView: View {

    var body: some View {
        MapReader { proxy in
            MapBase()
                .mapCompass(true)
                .mapCompassSize(36)
                .mapCompassInsets(getInsets())
                .mapCompassFollowInterfaceStyle(true)
                .didTapCompass { mode in
                    print("tap compass")
                }
                .ignoresSafeArea()
        }
    }

    func getInsets() -> UIEdgeInsets {

        return UIEdgeInsets.init(top: 20, left: 0, bottom: 0, right: 18)
    }
}

#Preview {
    ContentView()
}
