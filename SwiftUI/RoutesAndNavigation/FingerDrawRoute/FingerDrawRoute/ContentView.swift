// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit

struct ContentView: View {
    @State var drawPathOn: Bool = false
    @State var routeCalculated: Bool = false
    @State private var showStatusLabel: Bool = false

    @State var navigationContext: NavigationContext?
    @State var routeTransportMode: RouteTransportMode = .bicycle
    @State private var routeStatus: RouteStatus = .uninitialized
    @State private var markerCollections: [MarkerCollectionObject] = []

    @State var gpxFileURL: URL?

    @State var refreshTitleMenuId: UUID = UUID()

    var body: some View {
        MapReader { proxy in
            ZStack(alignment: .leading) {
                MapBase()
                    .onAppear {
                        proxy.centerOn(coordinates: .milano, zoomLevel: 70)
                    }
                    .ignoresSafeArea(edges: [.bottom, .horizontal])

                if drawPathOn == false {
                    VStack {
                        Button {
                            routeCalculated ? clearRoute(proxy) : drawPath(proxy)
                        } label: {

                            VStack {

                                if routeCalculated {
                                    Text("Clear")
                                        .font(.title2)
                                        .padding(.horizontal)
                                } else {
                                    Image(systemName: "hand.draw")
                                        .font(.system(size: 32, weight: .semibold))
                                }
                            }
                            .frame(minWidth: 70, minHeight: 70)
                            .foregroundStyle(.primary)
                            .background(.background)
                            .clipShape(Capsule())
                            .shadow(color: .gray, radius: 3)
                            .padding()
                        }
                        .buttonStyle(PlainButtonStyle())

                        Spacer()
                    }
                }

                VStack {

                    Spacer()

                    // Route status Label
                    if showStatusLabel {
                        HStack {
                            Text(statusText)
                                .font(.system(size: 24, weight: .semibold))
                                .frame(maxWidth: .infinity)

                            Button(action: {
                                handlePencilButtonTap(proxy: proxy)
                            }) {
                                Image(systemName: "pencil.and.outline")
                                    .font(.system(size: 26, weight: .semibold))
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(
                                        Color.black,
                                        Color.orange,
                                        Color.clear
                                    )
                                    .frame(width: 50, height: 50)
                            }
                            .padding(.trailing, 10)
                        }
                        .padding(.horizontal)
                        .frame(height: 60)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemBackground)))
                        .padding(.horizontal, 15)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .title, content: {

                    Menu(content: {
                        Button("Bike") {

                            refreshTitleMenuId = UUID()
                            routeTransportMode = .bicycle
                        }
                        Button("Pedestrian") {

                            refreshTitleMenuId = UUID()
                            routeTransportMode = .pedestrian
                        }
                    }, label: {

                        HStack {
                            Text(routeTransportMode == .bicycle ? "Bike Route" : "Pedestrian Route")

                            Image(systemName: "chevron.down.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        }
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray5)))
                    })
                    .id(refreshTitleMenuId)
                })

                ToolbarItem(placement: .topBarTrailing, content: {

                    if let url = gpxFileURL {
                        ShareLink(item: url) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                })
            }
        }
    }

    var statusText: String {
        switch routeStatus {
        case .calculating:
            return "Calculating"
        case .uninitialized:
            return "Uninitialized"
        case .waitingInternetConnection:
            return "Waiting Internet Connection"
        case .ready:
            return "Ready"
        case .error:
            return "Error"
        default:
            return ""
        }
    }

    func createNavigationContext() -> NavigationContext {

        guard navigationContext == nil else { return navigationContext! }

        let preferences = RoutePreferencesObject.init()
        preferences.setRouteType(.fastest)
        preferences.setIgnoreRestrictionsOverTrack(true)
        preferences.setAccurateTrackMatch(false)  // only for track data
        preferences.setTransportMode(routeTransportMode)

        navigationContext = NavigationContext.init(preferences: preferences)

        return navigationContext!
    }

    func drawPath(_ proxy: MapProxy) {

        guard let mapViewController = proxy.mapViewController else { return }

        mapViewController.removeAllRoutes()
        mapViewController.removeAllMarkers()

        mapViewController.hideCompass()
        mapViewController.view.layer.borderWidth = 16
        mapViewController.view.layer.borderColor = UIColor.gray.withAlphaComponent(0.26).cgColor

        mapViewController.setTouchViewBehaviour(.fingerDraw) { marker in

            mapViewController.showCompass()
            mapViewController.view.layer.borderWidth = 0
            mapViewController.view.layer.borderColor = nil

            markerCollections = mapViewController.getAvailableMarkers()

            mapViewController.setTouchViewBehaviour(.default)

            showStatusLabel = true

            if let coordinates = marker?.getCoordinates(), !coordinates.isEmpty {

                let path = PathObject.init(coordinates: coordinates)

                createShareRoute(path: path)

                if let lmk = RouteBookmarksObject.setWaypointTrackData(path) {

                    calculateRoute(proxy, waypoints: [lmk])
                }
            }
        }

        drawPathOn = true
    }

    func clearRoute(_ proxy: MapProxy) {

        guard let mapViewController = proxy.mapViewController else { return }

        markerCollections.removeAll()

        if let navigationContext = navigationContext {
            navigationContext.cancelCalculateRoute()
            self.navigationContext = nil
        }

        showStatusLabel = false
        routeCalculated = false
        routeStatus = .uninitialized
        gpxFileURL = nil

        mapViewController.showCompass()
        mapViewController.setTouchViewBehaviour(.default)

        mapViewController.removeAllMarkers()
        mapViewController.removeAllRoutes()
    }

    func createShareRoute(path: PathObject) {

        guard let data = path.export(as: .gpx) else { return }
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        let name = "Track.gpx"

        let fileURL = documentsURL.appendingPathComponent(name)

        let success = FileManager.default.createFile(atPath: fileURL.path, contents: data)

        if success {

            self.gpxFileURL = fileURL
        }
    }

    func handlePencilButtonTap(proxy: MapProxy) {
        guard let mapViewController = proxy.mapViewController else { return }

        if mapViewController.getAvailableMarkers().isEmpty {
            if let collection = markerCollections.first {
                mapViewController.addMarker(collection)
            }
        } else {
            mapViewController.removeAllMarkers()
        }
    }

    func calculateRoute(_ proxy: MapProxy, waypoints: [LandmarkObject]) {

        guard let mapViewController = proxy.mapViewController else { return }

        let navigationContext = createNavigationContext()

        navigationContext.calculateRoute(withWaypoints: waypoints) { routeStatus in

            self.routeStatus = routeStatus

        } completionHandler: { results, code in

            if let route = results.first {

                let scale = UIScreen.main.scale
                let insets = UIEdgeInsets.init(
                    top: 120 * scale, left: 60 * scale,
                    bottom: 120 * scale, right: 60 * scale)
                mapViewController.setEdgeAreaInsets(insets)
                mapViewController.presentRoutes(results, withTraffic: nil, showSummary: true, animationDuration: 1600)

                let preferences = mapViewController.getPreferences()
                if let settings = preferences.getRenderSettings(route) {
                    settings.textSize = 3.6
                    settings.imageSize = 3.6
                    preferences.setRenderSettings(settings, route: route)
                }
            }

            routeCalculated = true
            drawPathOn = false
        }
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
