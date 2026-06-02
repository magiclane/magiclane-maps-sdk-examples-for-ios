// SPDX-FileCopyrightText: 2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit

struct Place: Identifiable {
    let id = UUID()
    let image: UIImage
    let title: String
    let details: String
    let distance: String
    let lmk: LandmarkObject
}

struct ContentView: View {

    let context = SearchContext.init()
    private let defaultHighlightId = 10

    @State private var searchQuery = ""
    @State private var results: [Place] = []
    @State private var selectedItem: Place?
    @State private var isSearching: Bool = false

    @FocusState private var searchFocused: Bool

    @Environment(\.displayScale) private var displayScale

    var body: some View {
        MapReader { proxy in

            ZStack {
                MapBase(initialPosition: .amsterdam, initialZoomLevel: 64)
                    .mapCompass(false)
                    .ignoresSafeArea()

                if searchFocused {

                    List(results) { place in

                        HStack {

                            Image(uiImage: place.image)
                                .frame(width: 40, height: 40)

                            VStack(alignment: .leading) {
                                Text(place.title)
                                    .font(.headline)
                                Text(place.details)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Text(place.distance)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            proxy.centerOn(coordinates: place.lmk.getCoordinates(), duration: 1200)
                            proxy.present(highlights: [place.lmk], settings: getRenderSettings())
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedItem = place
                                searchFocused = false
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search Text")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchQuery, placement: .automatic)
            .searchFocused($searchFocused)
            .onChange(of: searchQuery) { oldValue, newValue in

                performSearch(proxy)
            }
        }
    }

    private func performSearch(_ proxy: MapProxy) {
        proxy.removeAllHighlights()
        proxy.centerOn(coordinates: .amsterdam, zoomLevel: 60)
        results.removeAll()
        isSearching = true

        context.setMaxMatches(40)
        context.setSearchMapPOIs(true)
        context.setSearchAddresses(true)

        // Location Hint support: narrow the search area to a specific radius
        context.setLocationHint(
            RectangleGeographicAreaObject(
                location: .amsterdam,
                horizontalRadius: 2000, verticalRadius: 2000))

        context.search(withQuery: searchQuery, location: .amsterdam) { response in
            isSearching = false

            results = response.map { item in
                return Place(
                    image: item.getLandmarkImage(CGSize(width: 40 * displayScale, height: 40 * displayScale)) ?? UIImage(),
                    title: item.getLandmarkName(),
                    details: item.getLandmarkDescription(),
                    distance: item.getLandmarkDistanceFormatted(withLocation: .amsterdam) + item.getLandmarkDistanceUnitFormatted(withLocation: .amsterdam),
                    lmk: item)
            }
        }
    }

    func getRenderSettings() -> HighlightRenderSettings {
        let settings = HighlightRenderSettings.init()
        settings.showPin = true
        settings.imageSize = 7

        return settings
    }
}

#Preview {
    ContentView()
}

extension CoordinatesObject {
    static let amsterdam = CoordinatesObject.coordinates(withLatitude: 52.368447, longitude: 4.888229)
}
