// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
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
            ZStack() {
                MapBase(initialPosition: .amsterdam, initialZoomLevel: 56, content: {
                    MapMarker(title: "A", collections: collType1)
                    MapMarker(title: "A", collections: collType2)
                    MapMarker(title: "C", collections: collType3)
                })
                .mapCompass(false)
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
        
        if type == .triangle {
            
            if collType1.count > 0 {
                collType1.removeAll()
                return
            }
            
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
            collType1.append(markerCollection)
            
        } else if type == .circle {
            
            if collType2.count > 0 {
                collType2.removeAll()
                return
            }
            
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
            collType2.append(markerCollection)
            
        } else if type == .line {
            
            if collType3.count > 0 {
                collType3.removeAll()
                return
            }
            
            let markerCollection = MarkerCollectionObject.init(name: "My Line", type: .polyline);
            markerCollection.setInnerSize(0.8)
            markerCollection.setInnerColor(UIColor.yellow)
            markerCollection.setOuterSize(1.2)
            markerCollection.setOuterColor(UIColor.black)
            markerCollection.setFill(UIColor.yellow.withAlphaComponent(0.25))
            markerCollection.addMarker(
                MarkerObject.init(coordinates: [
                    .coordinates(withLatitude: 52.370934, longitude: 4.907082),
                    .coordinates(withLatitude: 52.370934, longitude: 4.875082),
                ])
            )
            collType3.append(markerCollection)
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
