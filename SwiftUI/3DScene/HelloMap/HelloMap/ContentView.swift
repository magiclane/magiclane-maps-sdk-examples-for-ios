// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit

struct ContentView: View {
    var body: some View {
        MapReader { proxy in
            MapBase()
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
