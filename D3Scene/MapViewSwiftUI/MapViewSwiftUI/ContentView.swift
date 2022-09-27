// Copyright (C) 2019-2022, General Magic B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of General Magic
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with General Magic.

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
