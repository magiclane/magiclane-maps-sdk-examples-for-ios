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
                .onAppear {
                    applyCustomMapStyle(proxy)
                }
                .ignoresSafeArea()
        }
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
