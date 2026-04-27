// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit

enum ShapeType: Int { case triangle, circle, line }

struct ContentView: View {

    @State var collType1: [MarkerCollectionObject] = []
    @State var collType2: [MarkerCollectionObject] = []
    @State var collType3: [MarkerCollectionObject] = []

    var body: some View {
        MapReader { proxy in
            ZStack {
                MapBase(initialPosition: .amsterdam, initialZoomLevel: 56,
                        content: {
                    MapMarker(title: "A", collections: collType1)
                    MapMarker(title: "B", collections: collType2)
                    MapMarker(title: "C", collections: collType3)
                })
                .mapCompass(false)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("", systemImage: "triangle") {

                            refreshMarkerCollections(proxy, .triangle)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("", systemImage: "circle") {

                            refreshMarkerCollections(proxy, .circle)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("", systemImage: "line.diagonal") {

                            refreshMarkerCollections(proxy, .line)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button("", systemImage: "xmark.square") {

                            removeAllMarkers(proxy)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .ignoresSafeArea()
            }
        }
    }

    func refreshMarkerCollections(_ proxy: MapProxy, _ type: ShapeType) {

        if type == .triangle {

            if !collType1.isEmpty {
                collType1.removeAll()
                return
            }

            let markerCollection = MarkerCollectionObject.init(name: "My Triangle", type: .polygon)
            markerCollection.setInnerSize(0.8)
            markerCollection.setInnerColor(UIColor.yellow)
            markerCollection.setOuterSize(1.2)
            markerCollection.setOuterColor(UIColor.black)
            markerCollection.setFill(UIColor.yellow.withAlphaComponent(0.25))
            markerCollection.addMarker(
                MarkerObject.init(coordinates: [
                    .coordinates(withLatitude: 52.390934, longitude: 4.896882),
                    .coordinates(withLatitude: 52.379934, longitude: 4.875082),
                    .coordinates(withLatitude: 52.379934, longitude: 4.896882)
                ])
            )
            collType1.append(markerCollection)

        } else if type == .circle {

            if !collType2.isEmpty {
                collType2.removeAll()
                return
            }

            let markerCollection = MarkerCollectionObject.init(name: "My Circle", type: .polygon)
            markerCollection.setInnerSize(0.8)
            markerCollection.setInnerColor(UIColor.yellow)
            markerCollection.setOuterSize(1.2)
            markerCollection.setOuterColor(UIColor.black)
            markerCollection.setFill(UIColor.yellow.withAlphaComponent(0.25))
            markerCollection.addMarker(
                MarkerObject.init(
                    circleCenter:
                        .coordinates(withLatitude: 52.379934, longitude: 4.896882), radius: 800)
            )
            collType2.append(markerCollection)

        } else if type == .line {

            if !collType3.isEmpty {
                collType3.removeAll()
                return
            }

            let markerCollection = MarkerCollectionObject.init(name: "My Line", type: .polyline)
            markerCollection.setInnerSize(0.8)
            markerCollection.setInnerColor(UIColor.yellow)
            markerCollection.setOuterSize(1.2)
            markerCollection.setOuterColor(UIColor.black)
            markerCollection.setFill(UIColor.yellow.withAlphaComponent(0.25))
            markerCollection.addMarker(
                MarkerObject.init(coordinates: [
                    .coordinates(withLatitude: 52.370934, longitude: 4.907082),
                    .coordinates(withLatitude: 52.370934, longitude: 4.875082)
                ])
            )
            collType3.append(markerCollection)
        }
    }

    func removeAllMarkers(_ proxy: MapProxy) {

        collType1.removeAll()
        collType2.removeAll()
        collType3.removeAll()
    }
}

#Preview {
    ContentView()
}

extension CoordinatesObject {
    static let amsterdam = CoordinatesObject.coordinates(withLatitude: 52.368447, longitude: 4.888229)
}
