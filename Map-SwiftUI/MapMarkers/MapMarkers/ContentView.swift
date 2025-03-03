// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: BSD-3-Clause
//
// Contact Magic Lane at <info@magiclane.com> for commercial licensing options.

import SwiftUI
import GEMKit

enum ShapeType: Int { case triangle, circle, line } 

struct ContentView: View {    
    var body: some View {
        MapReader { proxy in
            ZStack() {
                MapBase()
                    .mapEdgeInsets(getInsets())
                    .onAppear() {
                        proxy.centerOn(coordinates: .amsterdam, zoomLevel: 56)
                    }
                    .ignoresSafeArea()
                HStack() {
                    ShapeButton(type: .triangle) { type in                        
                        refreshMarkerCollections(proxy, .triangle)
                    }
                    ShapeButton(type: .circle) { type in
                        refreshMarkerCollections(proxy, .circle)                        
                    }
                    ShapeButton(type: .line) { type in
                        refreshMarkerCollections(proxy, .line)                        
                    }
                    Spacer()
                }
            }
        }
    }
    
    func getInsets() -> UIEdgeInsets {        
        let offset = UIScreen.main.scale * 60
        return UIEdgeInsets.init(top: offset, left: offset, bottom: offset, right: offset)
    }
    
    func refreshMarkerCollections(_ proxy: MapProxy, _ type: ShapeType) {
        
        guard let mapViewController = proxy.mapViewController else { return }
        
        for markerCollection in mapViewController.getAvailableMarkers() {
            if type == .triangle, markerCollection.getName() == "My Triangle" {
                mapViewController.removeMarker(markerCollection)
                return
            }
            if type == .circle, markerCollection.getName() == "My Circle" {
                mapViewController.removeMarker(markerCollection)
                return
            }
            if type == .line, markerCollection.getName() == "My Line" {
                mapViewController.removeMarker(markerCollection)
                return
            }
        }
        
        if type == .triangle {
            
            let markerCollection = MarkerCollectionObject.init(name: "My Triangle", type: .polygon);
            markerCollection.setInnerSize(0.8)
            markerCollection.setInnerColor(UIColor.yellow)
            markerCollection.setOuterSize(1.2)
            markerCollection.setOuterColor(UIColor.black)
            markerCollection.setFill(UIColor.yellow.withAlphaComponent(0.25))
            markerCollection.addMarker(
                MarkerObject.init(coordinates: [
                    .coordinates(withLatitude: 52.390934, longitude: 4.896882),
                    .coordinates(withLatitude: 52.379934, longitude: 4.875082),
                    .coordinates(withLatitude: 52.379934, longitude: 4.896882),
                ])
            )
            mapViewController.addMarker(markerCollection, animationDuration: 2000)    
            
        } else if type == .circle {
            
            let markerCollection = MarkerCollectionObject.init(name: "My Circle", type: .polygon);
            markerCollection.setInnerSize(0.8)
            markerCollection.setInnerColor(UIColor.yellow)
            markerCollection.setOuterSize(1.2)
            markerCollection.setOuterColor(UIColor.black)
            markerCollection.setFill(UIColor.yellow.withAlphaComponent(0.25))
            markerCollection.addMarker(
                MarkerObject.init(circleCenter: 
                        .coordinates(withLatitude: 52.379934, longitude: 4.896882),  radius: 800)
            )
            mapViewController.addMarker(markerCollection, animationDuration: 2000)
            
        } else if type == .line {
            
            let markerCollection = MarkerCollectionObject.init(name: "My Line", type: .polyline);
            markerCollection.setInnerSize(0.8)
            markerCollection.setInnerColor(UIColor.yellow)
            markerCollection.setOuterSize(1.2)
            markerCollection.setOuterColor(UIColor.black)
            markerCollection.setFill(UIColor.yellow.withAlphaComponent(0.25))
            markerCollection.addMarker(
                MarkerObject.init(coordinates: [
                    .coordinates(withLatitude: 52.370934, longitude: 4.908082),
                    .coordinates(withLatitude: 52.362834, longitude: 4.889082),
                ])
            )
            mapViewController.addMarker(markerCollection, animationDuration: 2000)
        }
    }    
    
    
    @ViewBuilder
    private func ShapeButton(type: ShapeType, onPress: @escaping (_ type: ShapeType) -> Void) -> some View {
        Button {
            onPress(type)
        } label: {
            VStack(alignment: .leading) {
                Image(systemName: getIconeName(type))
                    .font(.system(size: 32, weight: .semibold))
                    .frame(width: 60, height: 60)
                    .foregroundStyle(.blue)
                    .background(.background)
                    .clipShape(Circle())
                    .shadow(color: .gray, radius: 3)
                Spacer()
            }
            .padding(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func getIconeName(_ type: ShapeType) -> String {
        switch type { 
        case .triangle: return "triangle"
        case .circle: return "circle"
        case .line: return "line.diagonal"
        }
    }
}

#Preview {
    ContentView()
}

extension CoordinatesObject {
    static let amsterdam = CoordinatesObject.coordinates(withLatitude: 52.368447, longitude: 4.888229)    
}
