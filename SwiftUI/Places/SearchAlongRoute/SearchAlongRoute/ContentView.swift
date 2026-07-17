// SPDX-FileCopyrightText: 2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit

struct ContentView: View {

    private let defaultHighlightId = 10

    @State private var navigationContext: NavigationContext?
    @State private var searchContext: SearchContext?
    @State private var mainRoute: RouteObject?
    @State private var searchResultLandmarks: [LandmarkObject] = []
    @State private var isCalculating = false
    @State private var mapConfiguration = MapRouteConfiguration.init()
    
    var body: some View {
        MapReader { proxy in
            MapBase {
                MapRoute(configuration: mapConfiguration)
                MapLandmark(
                    landmarks: searchResultLandmarks,
                    renderSettings: getHighlightSettings(),
                    highlightId: defaultHighlightId,
                    animationDuration: -1
                )
            }
            .didSelectRoutes { routes, point in
                guard let route = routes.first else { return }
                mainRoute = route
                proxy.setMain(route: route)
            }
            .mapEdgeInsets(UIEdgeInsets(top: 30, left: 40, bottom: 30, right: 40))
            .ignoresSafeArea()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("", systemImage: "point.topleft.down.curvedto.point.bottomright.up") {
                        calculateRoute(proxy)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isCalculating)
                    .allowsHitTesting(!isCalculating)                    
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("", systemImage: "clear") {
                        clearAll(proxy)
                    }
                    .buttonStyle(.borderedProminent)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("", systemImage: "magnifyingglass") {
                        searchAlongRoute(proxy)
                    }
                    .disabled(mainRoute == nil)
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .navigationTitle("Search Along Route")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Route

    private func calculateRoute(_ proxy: MapProxy) {

        if navigationContext == nil {
            let preferences = RoutePreferencesObject()
            preferences.setTransportMode(.car)
            preferences.setRouteType(.fastest)
            preferences.setAvoidMotorways(false)
            preferences.setAvoidTollRoads(false)
            preferences.setAvoidFerries(false)
            preferences.setAvoidUnpavedRoads(true)
            navigationContext = NavigationContext(preferences: preferences)
        }

        let waypoints = [
            LandmarkObject.landmark(
                withName: "San Francisco",
                location: CoordinatesObject.coordinates(withLatitude: 37.77903, longitude: -122.41991)),
            LandmarkObject.landmark(
                withName: "San Jose",
                location: CoordinatesObject.coordinates(withLatitude: 37.33619, longitude: -121.89058))
        ]

        isCalculating = true

        // let state = navigationContext?.isCalculatingRoute()
        // print("isCalculatingRoute:\(state, default: "")")

        navigationContext?.calculateRoute(withWaypoints: waypoints) { results in
            Task { @MainActor in
                mapConfiguration.bubbleSummary = results.count > 0
                mapConfiguration.routes = results

                for route in results {
                    if let td = route.getTimeDistance() {
                        let time = td.getTotalTimeFormatted() + td.getTotalTimeUnitFormatted()
                        let distance = td.getTotalDistanceFormatted() + td.getTotalDistanceUnitFormatted()
                        NSLog("route time:%@, distance:%@", time, distance)
                    }
                }

                if !results.isEmpty {
                    mainRoute = results.first
                }

                isCalculating = false
            }
        }
    }

    // MARK: - Search

    private func searchAlongRoute(_ proxy: MapProxy) {
        guard let route = mainRoute else { return }

        if searchContext == nil {
            searchContext = SearchContext()
            searchContext?.setMaxMatches(40)
            searchContext?.setSearchMapPOIs(true)
            searchContext?.setSearchAddresses(true)
        }

        searchContext?.searchAlong(withRoute: route, query: "Gas station") { results in
            searchResultLandmarks = results
        }
    }

    // MARK: - Utils

    private func clearAll(_ proxy: MapProxy) {
        proxy.mapViewController?.removeAllRoutes()
        searchResultLandmarks = []
        mapConfiguration.routes.removeAll()
        mainRoute = nil        
    }

    private func getHighlightSettings() -> HighlightRenderSettings {
        let settings = HighlightRenderSettings()
        settings.imageSize = 7
        settings.options = Int32(HighlightOption.group.rawValue)
        return settings
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
