// SPDX-FileCopyrightText: 2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit

struct ContentView: View {
    @State private var navigationContext: NavigationContext?
    @State private var trafficContext: TrafficContext?
    @State private var isCalculating: Bool = false
    @State var isVisible: Bool = true
    @State var mapConfiguration: MapRouteConfiguration = MapRouteConfiguration.init()
    
    var body: some View {
        MapReader { proxy in
            ZStack {
                MapBase{
                    MapRoute(configuration: mapConfiguration)
                }
                .mapCompassSize(38)
                .mapCompass(isVisible)
                .mapEdgeInsets(adjustRouteInsets())
                .didSelectRoutes({ routes, touchPoint in
                    guard let route = routes.first else { return }
                    routeSelected(proxy, route: route)
                })
                .ignoresSafeArea(edges: [.bottom, .horizontal])
                
                // visually indicate the edge area padding after route is presented
                EdgeAreaOverlay(insets: adjustRouteInsets())
                    .ignoresSafeArea(edges: [.bottom, .horizontal])
                    .allowsHitTesting(false)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("", systemImage: "safari") {
                        isVisible.toggle()
                    }
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
        }            
        .navigationTitle("Calculate Route")
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea()
    }

    func calculateRoute(_ proxy: MapProxy) {

        if trafficContext == nil {

            trafficContext = TrafficContext()
            trafficContext?.setUseTraffic(.useOnline)
        }

        if navigationContext == nil {

            let preferences = RoutePreferencesObject()
            preferences.setTransportMode(.car)
            preferences.setRouteType(.fastest)
            preferences.setAvoidMotorways(false)
            preferences.setAvoidTollRoads(false)
            preferences.setAvoidFerries(false)
            preferences.setAvoidUnpavedRoads(true)
            preferences.setAvoidTraffic(true)

            navigationContext = NavigationContext(preferences: preferences)
        }
        
        let waypoints = [
            LandmarkObject.landmark(
                withName: "Departure",
                location: CoordinatesObject.coordinates(withLatitude: 52.44391, longitude: 13.28910)),
            LandmarkObject.landmark(
                withName: "Destination",
                location: CoordinatesObject.coordinates(withLatitude: 52.59283, longitude: 13.50746))
        ]

        mapConfiguration.routes = []
        
        isCalculating = true
        navigationContext?.calculateRoute(withWaypoints: waypoints, completionHandler: { results in

            NSLog("Found %d routes.", results.count)

            for route in results {
                if let timeDuration = route.getTimeDistance() {
                    let time = timeDuration.getTotalTimeFormatted() + timeDuration.getTotalTimeUnitFormatted()
                    let distance = timeDuration.getTotalDistanceFormatted() + timeDuration.getTotalDistanceUnitFormatted()
                    NSLog("route time:%@, distance:%@", time, distance)
                }
                
                let trafficEvents = route.getTrafficEvents()                
                for event in trafficEvents {
                    NSLog("route traffic event delay:%d(sec.) length:%d(m)", event.getDelay(), event.getLength())
                }
            }

            mapConfiguration.routes = results
            mapConfiguration.bubbleSummary = true
            isCalculating = false
        })
    }
    
    func adjustRouteInsets() -> UIEdgeInsets {
        if mapConfiguration.routes.isEmpty {
            return .zero
        }
        let scale = UIScreen.main.scale
        let insets = UIEdgeInsets(
            top: 120 * scale, left: 60 * scale,
            bottom: 70 * scale, right: 60 * scale)
        return insets
    }
    
    func routeSelected(_ proxy: MapProxy, route: RouteObject) {
        proxy.setMain(route: route)
    }

    func clearRoute(_ proxy: MapProxy) {        
        isCalculating = false
        mapConfiguration.routes = []
        navigationContext?.cancelCalculateRoute()
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
    NavigationStack {
        ContentView()
    }
}
