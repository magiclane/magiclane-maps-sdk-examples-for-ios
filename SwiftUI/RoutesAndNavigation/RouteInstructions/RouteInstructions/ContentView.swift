// SPDX-FileCopyrightText: 2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
@preconcurrency import GEMKit

struct ContentView: View {

    @State private var navigationContext: NavigationContext?
    @State private var trafficContext: TrafficContext?
    
    @State private var presentedRoutes: [RouteObject] = []
    @State private var mainRoute: RouteObject?
    
    @State private var isCalculating: Bool = false
    @State private var showInstructions: Bool = false
    @State private var selectedItem: InstructionItem?

    var body: some View {
        MapReader { proxy in
            MapBase {
                
                MapRoute(routes: presentedRoutes)
            }
            .ignoresSafeArea()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("", systemImage: "list.bullet") {
                        showInstructions = true
                    }
                    .disabled(mainRoute == nil)
                    .buttonStyle(.borderedProminent)
                }
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
            .onChange(of: showInstructions) { newValue in
                if !newValue, let item = selectedItem {
                    selectedItem = nil
                    if let instruction = item.routeInstruction {
                        proxy.mapViewController?.center(onRouteInstruction: instruction, zoomLevel: -1, animationDuration: 2600)
                    } else if let event = item.routeTrafficEvent {
                        proxy.mapViewController?.center(onRouteTrafficEvent: event, zoomLevel: -1, animationDuration: 2000)
                    }
                }
            }
        }
        .navigationTitle("Route Instructions")
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea()
        .navigationDestination(isPresented: $showInstructions) {
            if let route = mainRoute {
                RouteInstructionsView(
                    route: route,
                    selectedItem: $selectedItem,
                    showInstructions: $showInstructions
                )
            }
        }
    }

    // MARK: - Route Calculation

    func calculateRoute(_ proxy: MapProxy) {

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

                mainRoute = results.first
                presentedRoutes = results
            }

            isCalculating = false
        })
    }

    func clearRoute(_ proxy: MapProxy) {

        mainRoute = nil
        presentedRoutes = []
        proxy.removeAllRoutes()
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
