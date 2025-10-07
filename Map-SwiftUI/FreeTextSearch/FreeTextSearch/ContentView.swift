// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit

struct Place: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let details: String
    let lmk: LandmarkObject
}

struct ContentView: View {
    let context = SearchContext.init()
    private let defaultHighlightId = 10
    
    @State private var searchQuery = ""
    @State private var landmarks: [LandmarkObject] = []
    @State private var results: [Place] = []
    @State private var selectedItem: Place?
    @State private var isSearching: Bool = false    
    
    var body: some View {
        MapReader { proxy in
            VStack {
                HStack {
                    ProgressView()
                        .transition(.opacity)
                        .progressViewStyle(.circular)
                        .controlSize(.regular)
                        .opacity(isSearching ? 1 : 0)
                    
                    TextField("Search", text: $searchQuery, onCommit: {
                        performSearch(proxy)
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .frame(height: 50)                
                
                MapBase(initialPosition: .amsterdam, initialZoomLevel: 64) {
                    MapLandmark(landmarks: landmarks, renderSettings: getSettings(), 
                                highlightId: defaultHighlightId, animationDuration: 800)
                }
                .didSelectLandmarks({ landmarks, touchPoint, isLongTouch in
                    guard let coordinates = landmarks.first?.getCoordinates() else { return }
                    proxy.centerOn(coordinates: coordinates, duration: 1200)
                })
                .mapCompass(false)
                .mapEdgeInsets(getInsets())
                .frame(height: 300)
                
                List(results) { place in
                    VStack(alignment: .leading) {
                        Text(place.title)
                            .font(.headline)
                        Text(place.details)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        proxy.centerOn(coordinates: place.lmk.getCoordinates(), duration: 1200)
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedItem = place
                        }
                    }
                    .listRowBackground(
                        selectedItem == place ? Color.blue.opacity(0.2) : Color.clear
                    )
                }
                
                Button() {
                    selectedItem = nil
                    centerOnHighlightArea(proxy)
                } label: {
                    Text("Center Results")
                        .font(.headline)
                        .foregroundStyle(.blue)
                }
                .padding()
                .buttonStyle(PlainButtonStyle())
                .disabled(landmarks.count == 0)
            }
        }
        .padding(.horizontal, 15)
    }
    
    private func performSearch(_ proxy: MapProxy) {        
        proxy.removeAllHighlights()
        proxy.centerOn(coordinates: .amsterdam, zoomLevel: 60)
        landmarks.removeAll()
        results.removeAll()
        isSearching = true
        
        // Filter based on category:
        /*let categoriesContext = GenericCategoriesContext.init()
        guard let category = categoriesContext.getCategory(.parking) else { return }
        context.setCategory(category)*/
        
        // Location Hit support: narrow the search area to a specific radius
        context.setLocationHint(RectangleGeographicAreaObject(location: .amsterdam, 
                                                              horizontalRadius: 2000, verticalRadius: 2000))
        
        context.search(withQuery: searchQuery, location: .amsterdam) { response in
            isSearching = false
            for item in response {
                item.setImage(getImageObject()) // set custom pin image
                landmarks.append(item)
            }
            
            results = response.map { item in
                let coordinates = item.getCoordinates()
                return Place(
                    title: item.getLandmarkName(),
                    details:"Lat:\(coordinates.latitude), Lon:\(coordinates.longitude)",
                    lmk: item)
            }
        }
    }
    
    private func getSettings() -> HighlightRenderSettings {
        let settings = HighlightRenderSettings.init()
        settings.options = Int32(HighlightOption.showLandmark.rawValue | 
                                 HighlightOption.group.rawValue | 
                                 HighlightOption.selectable.rawValue)
        settings.textColor = UIColor.darkGray
        settings.textSize = 2.2
        settings.imageSize = 5.6
        return settings
    }
    
    private func getImageObject() -> ImageObject {
        if let image = UIImage.init(named: "MapPinDefault"),
           let data = image.pngData() {
            let object = ImageObject.init(dataBuffer: data, format: .png)
            return object
        }
        return ImageObject()
    }    
    
    func centerOnHighlightArea(_ proxy: MapProxy) {
        guard let mapViewController = proxy.mapViewController else { return }
        let list = mapViewController.getHighlight(Int32(defaultHighlightId))
        guard list.count > 0 else { return }
        guard let area = mapViewController.getHighlightArea(Int32(defaultHighlightId)) else { return }
        mapViewController.center(onArea: area, zoomLevel: -1, animationDuration: 1200)
    }
    
    func getInsets() -> UIEdgeInsets {
        let margin: CGFloat = 35
        let scale = UIScreen.main.scale
        return UIEdgeInsets.init(top: scale*margin, left: scale*margin,
                                 bottom: scale*margin, right: scale*margin)
    }
}

#Preview {
    ContentView()
}

extension CoordinatesObject {
    static let amsterdam = CoordinatesObject.coordinates(withLatitude: 52.368447, longitude: 4.888229)        
}

