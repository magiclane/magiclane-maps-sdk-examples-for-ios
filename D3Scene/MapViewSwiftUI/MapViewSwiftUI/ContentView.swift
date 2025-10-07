// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI

struct ContentView: View {
    @State private var showingMap = false
    @State private var mapView = MapView.init()
    
    var body: some View {
        VStack {
            Button(showingMap ? "Hide Map": "Show Map") {
                withAnimation(.easeIn(duration: 0.16)) {
                    showingMap.toggle()
                }
            }
            .font(.title)
            .padding()
            
            if showingMap {
                mapView
                    .onAppear() {
                        mapView.mapRepresentable.mapViewController.startRender()
                    }
                    .onDisappear() {
                        mapView.mapRepresentable.mapViewController.stopRender()
                    }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 12")
    }
}
