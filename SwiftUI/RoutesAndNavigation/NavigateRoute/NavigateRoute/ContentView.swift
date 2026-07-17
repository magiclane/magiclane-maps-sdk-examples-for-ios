// SPDX-FileCopyrightText: 2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit

struct ContentView: View {
    @StateObject private var model = NavigateRouteModel()

    var body: some View {
        MapReader { proxy in
            ZStack(alignment: .top) {
                MapBase(initialPosition: .milano, initialZoomLevel: 70) {
                    MapRoute(configuration: model.mapConfiguration)
                }
                .mapEdgeInsets(adjustRouteInsets())
                .didSelectLandmarks { landmarks, point, longTouch in
                    
                    guard let landmark = landmarks.first else { return }
                    model.landmarkSelected(proxy, landmark: landmark)
                }
                .didSelectRoutes { routes, point in
                    
                    guard let route = routes.first else { return }
                    
                    model.routeSelected(proxy, route: route)
                }
                .didSelectStreets { streets, point, longTouch in
                    
                    guard let street = streets.first else { return }
                    model.landmarkSelected(proxy, landmark: street)
                }
                .ignoresSafeArea()
                .onAppear {
                    model.setupDataSource()
                    model.setupLocation()
                    model.setupFollowPositionPreferences(proxy)
                }
                .onChange(of: model.isLocationAvailable) { available in
                    if available {
                        model.onLocationBecameAvailable(proxy)
                    }
                }

                // Overlay content respects safe area
                VStack {
                    // Navigation panel (shown during navigation)
                    if model.isNavigating {
                        NavigationPanelView(
                            model: model,
                            onStop: { model.stopNavigation(proxy) }
                        )
                        .padding(.horizontal, 10)
                        .padding(.top, 5)
                    }

                    Spacer()

                    // Bottom label
                    if model.showLabel {
                        Text(model.labelText)
                            .font(.system(size: 20, weight: .bold))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.blue, lineWidth: 1.4)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.horizontal, 10)
                            .padding(.bottom, 10)
                            .onTapGesture {
                                model.startFollowLocation(proxy)
                            }
                    }
                }
            }
            .toolbar(model.isNavigating ? .hidden : .visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("", systemImage: model.isLocationAvailable ? "location" : "location.slash") {
                        if model.isLocationAvailable {
                            model.startFollowLocation(proxy)
                        } else {
                            model.requestLocationPermission()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("", systemImage: "point.topleft.down.curvedto.point.bottomright.up") {
                        model.calculateRoute(proxy)
                    }
                    .disabled(model.isCalculating)
                    .buttonStyle(.borderedProminent)
                }

                ToolbarItem(placement: .topBarTrailing) {

                    Button("", systemImage: "clear") {
                        model.clearRoute(proxy)
                    }
                    .buttonStyle(.borderedProminent)
                }

                ToolbarItem(placement: .topBarTrailing) {

                    Button("", systemImage: "play") {
                        model.startNavigation(proxy)
                    }
                    .disabled(model.mapConfiguration.routes.count == 0)
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .navigationTitle("Navigate Route")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func adjustRouteInsets() -> UIEdgeInsets {
        let scale = UIScreen.main.scale
        let insets = UIEdgeInsets(
            top: 60 * scale, left: 60 * scale,
            bottom: 60 * scale, right: 60 * scale)
        return insets
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}

extension CoordinatesObject {
    static let milano = CoordinatesObject.coordinates(withLatitude: 45.462514, longitude: 9.188443)
}
