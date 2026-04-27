// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit

struct ContentView: View {
    @State private var navigationContext: NavigationContext?
    @State private var trafficContext: TrafficContext?
    @State private var isCalculating: Bool = false
    @State private var edgeInsets: UIEdgeInsets?
    @State private var calculatedRoutes: [RouteObject] = []

    var body: some View {
        MapReader { proxy in
            ZStack {
                MapBase{
                    MapRoute(
                        routes: calculatedRoutes,
                        traffic: trafficContext,
                        animationDuration: 800
                    )
                }
                .ignoresSafeArea(edges: [.bottom, .horizontal])

                // visually indicate the edge area padding after route is presented
                if let insets = edgeInsets {
                    EdgeAreaOverlay(insets: insets)
                        .ignoresSafeArea(edges: [.bottom, .horizontal])
                        .allowsHitTesting(false)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("", systemImage: "point.topleft.down.curvedto.point.bottomright.up") {
                        calculateRoute(proxy)
                    }
                    .disabled(isCalculating)
                    .buttonStyle(.borderedProminent)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("", systemImage: "clear") {
                        clearRoute(proxy)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .navigationTitle("Calculate Route")
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea()
    }

    func calculateRoute(_ proxy: MapProxy) {

        guard let mapViewController = proxy.mapViewController else { return }

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

        if trafficContext == nil {

            trafficContext = TrafficContext()
            trafficContext?.setUseTraffic(.useOnline)
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

        navigationContext?.calculateRoute(withWaypoints: waypoints, completionHandler: { results in

            NSLog("Found %d routes.", results.count)

            for route in results {
                if let timeDuration = route.getTimeDistance() {
                    let time = timeDuration.getTotalTimeFormatted() + timeDuration.getTotalTimeUnitFormatted()
                    let distance = timeDuration.getTotalDistanceFormatted() + timeDuration.getTotalDistanceUnitFormatted()
                    NSLog("route time:%@, distance:%@", time, distance)
                }
            }

            if !results.isEmpty {

                let scale = UIScreen.main.scale
                let insets = UIEdgeInsets(
                    top: 120 * scale, left: 70 * scale,
                    bottom: 70 * scale, right: 70 * scale)

                edgeInsets = insets

                mapViewController.setEdgeAreaInsets(insets)
                mapViewController.presentRoutes(results, withTraffic: trafficContext, showSummary: true, animationDuration: 1600)
            }

            isCalculating = false
        })
    }

    func clearRoute(_ proxy: MapProxy) {

        guard let mapViewController = proxy.mapViewController else { return }

        edgeInsets = nil
        mapViewController.removeAllRoutes()
    }
}

// MARK: - Edge Area Overlay

struct EdgeAreaOverlay: View {
    let insets: UIEdgeInsets

    var body: some View {
        GeometryReader { geometry in
            let scale = UIScreen.main.scale
            let top = insets.top / scale
            let left = insets.left / scale
            let bottom = insets.bottom / scale
            let right = insets.right / scale

            let color = Color.red.opacity(0.2)

            // Top
            color
                .frame(width: geometry.size.width, height: top)
                .position(x: geometry.size.width / 2, y: top / 2)

            // Bottom
            color
                .frame(width: geometry.size.width, height: bottom)
                .position(x: geometry.size.width / 2, y: geometry.size.height - bottom / 2)

            // Left
            color
                .frame(width: left, height: geometry.size.height - top - bottom)
                .position(x: left / 2, y: top + (geometry.size.height - top - bottom) / 2)

            // Right
            color
                .frame(width: right, height: geometry.size.height - top - bottom)
                .position(x: geometry.size.width - right / 2, y: top + (geometry.size.height - top - bottom) / 2)
        }
    }
}

#Preview {
    ContentView()
}
