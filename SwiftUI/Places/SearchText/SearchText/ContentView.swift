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

    @State private var context: SearchContext?
    private let defaultHighlightId = 10

    @State private var searchQuery = ""
    @State private var results: [Place] = []
    @State private var selectedItem: Place?
    @State private var isSearching = false
    @State private var isShowingResults = false

    @FocusState private var searchFocused: Bool

    @Environment(\.displayScale) private var displayScale

    // Not tied to keyboard focus: scrolling the list dismisses the keyboard,
    // but the results must stay on screen until a result is picked or the query is cleared.
    private var showResultsPanel: Bool {
        isShowingResults && !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        MapReader { proxy in

            GeometryReader { geometry in

                ZStack(alignment: .top) {

                    MapBase(initialPosition: .amsterdam, initialZoomLevel: 64)
                        .onMapCreated { _ in
                            DispatchQueue.main.async {
                                prepareSearch()
                            }
                        }
                        .mapCompass(false)
                        .ignoresSafeArea()

                    // Results float over the map, so the map stays visible while typing.
                    if showResultsPanel {
                        resultsPanel(proxy, maxHeight: geometry.size.height * 0.42)
                            .padding(.horizontal, 12)
                            .padding(.top, 8)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .overlay(alignment: .bottom) {
                    if !showResultsPanel, !searchFocused, let place = selectedItem {
                        selectedCard(place, proxy)
                            .padding(.horizontal, 12)
                            .padding(.bottom, 8)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: showResultsPanel)
                .animation(.easeInOut(duration: 0.2), value: selectedItem?.id)
            }
            .navigationTitle("Search Text")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchQuery, placement: .automatic)
            .searchFocused($searchFocused)
            .onChange(of: searchQuery) { oldValue, newValue in
                isShowingResults = true
                performSearch(proxy)
            }
            .onChange(of: searchFocused) { oldValue, newValue in
                // Re-open the results when the search field is tapped again.
                if newValue { isShowingResults = true }
            }
        }
    }

    // MARK: - Results panel

    @ViewBuilder
    private func resultsPanel(_ proxy: MapProxy, maxHeight: CGFloat) -> some View {

        Group {
            if results.isEmpty {

                HStack(spacing: 10) {
                    if isSearching {
                        ProgressView()
                        Text("Searching…")
                    } else {
                        Image(systemName: "magnifyingglass")
                        Text("No results")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)

            } else {

                // Hug the content when it is short, scroll when it is taller than maxHeight.
                ViewThatFits(in: .vertical) {
                    resultRows(proxy)
                    ScrollView {
                        resultRows(proxy)
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
            }
        }
        .frame(maxHeight: maxHeight, alignment: .top)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 12, y: 4)
    }

    private func resultRows(_ proxy: MapProxy) -> some View {

        LazyVStack(spacing: 0) {
            ForEach(results) { place in

                Button {
                    select(place, proxy)
                } label: {
                    placeRow(place)
                }
                .buttonStyle(.plain)

                if place.id != results.last?.id {
                    Divider().padding(.leading, 60)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private func placeRow(_ place: Place) -> some View {

        HStack(spacing: 12) {

            Image(uiImage: place.image)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(place.title)
                    .font(.body.weight(.semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)

                if !place.details.isEmpty {
                    Text(place.details)
                        .font(.subheadline)
                        .foregroundColor(.secondary) // explicit gray, not the vibrancy-based hierarchical style
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            Text(place.distance)
                .font(.footnote.monospacedDigit())
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    // MARK: - Selected place

    private func selectedCard(_ place: Place, _ proxy: MapProxy) -> some View {

        HStack(alignment: .top, spacing: 12) {

            placeRow(place)
                .padding(.horizontal, -12) // placeRow already has its own padding

            Button {
                proxy.mapViewController?.removeHighlight(Int32(defaultHighlightId))
                selectedItem = nil
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .padding(.top, 10)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 12, y: 4)
    }

    private func select(_ place: Place, _ proxy: MapProxy) {

        proxy.present(highlights: [place.lmk], settings: getRenderSettings(), highlightId: defaultHighlightId)
        proxy.centerOn(coordinates: place.lmk.getCoordinates(), duration: 1200)

        selectedItem = place
        isShowingResults = false
        searchFocused = false
    }

    private func prepareSearch() {
        guard context == nil else { return }

        let searchContext = SearchContext.init()
        searchContext.setMaxMatches(40)
        searchContext.setSearchMapPOIs(true)
        searchContext.setSearchAddresses(true)

        context = searchContext
    }

    private func performSearch(_ proxy: MapProxy) {
        guard let context = self.context else { return }
        
        let query = searchQuery.trimmingCharacters(in: .whitespaces)

        guard !query.isEmpty else {
            context.cancelSearch()
            results = []
            isSearching = false
            return
        }

        guard let location = self.getMapCenterLocation(proxy) else { return }

        // Location Hint support: narrow the search area to a specific radius
        /*context.setLocationHint(
            RectangleGeographicAreaObject(
                location: .amsterdam,
                horizontalRadius: 2000, verticalRadius: 2000))*/

        isSearching = true
        
        context.search(withQuery: query, location: location) { response in
            
            // Ignore responses for a query the user has already changed.
            guard query == searchQuery.trimmingCharacters(in: .whitespaces) else { return }
            
            isSearching = false
            
            let size = CGSize(width: 30 * displayScale, height: 30 * displayScale)
            
            results = response.map { item in
                return Place(
                    image: item.getLandmarkImage(size) ?? UIImage(),
                    title: item.getLandmarkNameFormatted(),
                    details: getDetails(item),
                    distance: item.getLandmarkDistanceFormatted(withLocation: location) + item.getLandmarkDistanceUnitFormatted(withLocation: location),
                    lmk: item)
            }
        }
    }

    /// Address line for addresses; for POIs (often without address fields) fall back
    /// to the raw description, then to the category names.
    private func getDetails(_ landmark: LandmarkObject) -> String {
        let formatted = landmark.getLandmarkDescriptionFormatted()
        if !formatted.isEmpty { return formatted }

        let description = landmark.getLandmarkDescription()
        if !description.isEmpty { return description }

        return landmark.getCategories()
            .map { $0.getName() }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }

    func getMapCenterLocation(_ proxy: MapProxy) -> CoordinatesObject? {
        guard let mapViewController = proxy.mapViewController else { return nil}
        let scale = UIScreen.main.scale
        let center = mapViewController.view.center
        let point = CGPoint.init(x: center.x * scale, y: center.y * scale)
        let location = mapViewController.transformScreen(toWgs: point)
        
        return location
    }

    func getRenderSettings() -> HighlightRenderSettings {
        let settings = HighlightRenderSettings.init()
        settings.showPin = true
        settings.imageSize = 7

        return settings
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}

extension CoordinatesObject {
    static let amsterdam = CoordinatesObject.coordinates(withLatitude: 52.368447, longitude: 4.888229)
}
