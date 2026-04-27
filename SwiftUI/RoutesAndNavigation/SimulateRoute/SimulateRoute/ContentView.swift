// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit

struct ContentView: View {
    @StateObject private var model = SimulateRouteModel()

    var body: some View {
        MapReader { proxy in
            ZStack(alignment: .top) {
                MapBase {
                    if model.isSimulating, let mainRoute = model.mainRoute {
                        MapRoute(
                            routes: [mainRoute],
                            bubbleSummary: false,
                            animationDuration: -1
                        )
                    } else {
                        if !model.presentedRoutes.isEmpty {
                            MapRoute(
                                routes: model.presentedRoutes,
                                bubbleSummary: true,
                                animationDuration: 800
                            )
                        }
                    }
                }
                .didSelectRoutes { routes, point in
                    
                    guard let route = routes.first else { return }
                    model.routeSelected(proxy, route: route)
                }
                .ignoresSafeArea()
                .onAppear {
                    model.setupFollowPositionPreferences(proxy)
                }

                // Overlay content respects safe area
                VStack {
                    // Navigation panel (shown during simulation)
                    if model.isSimulating {
                        NavigationPanelView(
                            model: model,
                            onStop: { model.stopSimulation(proxy) }
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
                    }
                }
            }
            .toolbar(model.isSimulating ? .hidden : .visible, for: .navigationBar)
            .toolbar {
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
                        model.startSimulation(proxy)
                    }
                    .disabled(model.mainRoute == nil)
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .navigationTitle("Simulate Route")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentView()
}
