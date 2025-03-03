// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: BSD-3-Clause
//
// Contact Magic Lane at <info@magiclane.com> for commercial licensing options.

import SwiftUI
import GEMKit

struct ContentView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass    
        
    var body: some View {
        MapReader { proxy in
            MapBase()
                .mapCompass(true)
                .mapCompassSize(40)
                .mapCompassInsets(getInsets())
                .mapCompassFollowInterfaceStyle(true)                
                .didTapCompass { mode in
                    print("tap compass")
                }
                .onAppear() {
                    goToPosition(proxy)
                }
                .ignoresSafeArea()
        }
    }
    
    func goToPosition(_ proxy: MapProxy) {
        proxy.centerOn(coordinates: .basel, zoomLevel: 56)
    }
    
    func getInsets() -> UIEdgeInsets {        
        if horizontalSizeClass == .compact, verticalSizeClass == .regular {            
            return UIEdgeInsets.init(top: -40, left: 0, bottom: 0, right: 20) 
        }
        return UIEdgeInsets.init(top: 15, left: 0, bottom: 0, right: -40)
    }
    
}

#Preview {
    ContentView()    
}

extension CoordinatesObject {
    static let basel = CoordinatesObject.coordinates(withLatitude: 47.538413, 
                                                     longitude: 7.600080)
}
