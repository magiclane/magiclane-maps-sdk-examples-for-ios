// SPDX-FileCopyrightText: 2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.
//
// Marker clustering example. Loads campsites from a bundled GeoJSON and renders
// them with the two-collection clustering technique (see CampsitePOIRenderer):
// count "pill" bubbles at low zoom, green/red per-type pins once the clusters
// break apart. Tapping a cluster fits the map to its members, splitting it apart;
// tapping a pin centres the map on it and shows its info panel — at the bottom in
// portrait, bottom-left in landscape.

import SwiftUI
import GEMKit

struct ContentView: View {
    @State private var isLoaded = false
    @State private var isLoading = false
    @State private var selected: CampsiteInfo?
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private let renderer = CampsitePOIRenderer()

    var body: some View {
        MapReader { proxy in
            ZStack {
                MapBase(initialPosition: .unitedStates, initialZoomLevel: 12)
                    .mapCompass(false)
                    .didSelectMarkers { markers, _, _ in
                        handleSelection(markers, proxy: proxy)
                    }

                // Loading chip (top).
                if isLoading {
                    VStack {
                        LoadingChip()
                            .padding(.top, 12)
                        Spacer()
                    }
                }

                // "Load campsites" button (bottom), shown until loaded.
                if !isLoaded && !isLoading {
                    VStack {
                        Spacer()
                        Button {
                            loadCampsites(proxy)
                        } label: {
                            Label("Load campsites", systemImage: "mappin.and.ellipse")
                                .font(.headline)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(red: 12 / 255, green: 75 / 255, blue: 34 / 255))
                        .padding(.bottom, 32)
                    }
                }

                // Info panel: bottom (portrait) / bottom-left (landscape).
                if let selected {
                    let landscape = verticalSizeClass == .compact
                    VStack {
                        Spacer()
                        HStack(spacing: 0) {
                            CampsiteInfoCard(campsite: selected) {
                                self.selected = nil
                            }
                            .frame(maxWidth: landscape ? 360 : .infinity)
                            if landscape { Spacer(minLength: 0) }
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 12)
                    }
                }
            }
        }
        .ignoresSafeArea()
    }

    /// Parses the bundled GeoJSON off the main thread, then renders the two
    /// clustering layers.
    private func loadCampsites(_ proxy: MapProxy) {
        guard let mapViewController = proxy.mapViewController else { return }
        isLoading = true
        Task {
            let descriptors = await Task.detached(priority: .userInitiated) {
                CampsiteGeoJSONLoader.loadFromBundle()
            }.value
            renderer.syncPOIs(on: mapViewController, markers: descriptors)
            isLoaded = true
            isLoading = false
        }
    }

    /// A cluster tap (a `.coordinateGroup` match) fits the map to the cluster's
    /// members to split it apart; a single pin tap centres the map on it and shows
    /// its info card.
    private func handleSelection(_ markers: [MarkerMatchObject], proxy: MapProxy) {
        guard let mapViewController = proxy.mapViewController, !markers.isEmpty else { return }

        if markers.contains(where: { $0.getType() == .coordinateGroup }) {
            // Prefer the clustered layer (it carries buildPointsGroupConfig) for
            // enumerating the cluster's members; fall back to the group match.
            let clusteredMatch = markers.first {
                $0.getMarkerCollection()?.getName().hasSuffix("-clustered") == true
            } ?? markers.first { $0.getType() == .coordinateGroup }
            zoomIntoGroup(mapViewController, match: clusteredMatch)
            selected = nil
            return
        }

        // Otherwise a single campsite → centre on it and show its info card. Prefer
        // the match carrying our JSON metadata (the detail-layer pin).
        let chosen = markers.first { $0.getMarker()?.getName().contains("\"bookable\"") == true } ?? markers.first
        if let marker = chosen?.getMarker() {
            let info = CampsiteInfo(marker: marker)
            centerOn(info, proxy: proxy)
            selected = info
        }
    }

    /// Fits the map to the bounding box of the cluster's members to split it apart.
    private func zoomIntoGroup(_ mapViewController: MapViewController, match: MarkerMatchObject?) {
        guard let match, let marker = match.getMarker(), let collection = match.getMarkerCollection() else { return }

        var members: [MarkerObject] = []
        let head = collection.getPointsGroupHead(marker.getId()) ?? marker
        members.append(head)
        members.append(contentsOf: collection.getPointsGroupComponents(head.getId()))
        let coords = members.flatMap { $0.getCoordinates() }

        guard coords.count >= 2 else {
            if let center = coords.first ?? marker.getCoordinates().first {
                let target = min(mapViewController.getZoomLevel() + 8, 90)
                mapViewController.center(onCoordinates: center, zoomLevel: target, animationDuration: 0.45)
            }
            return
        }

        let lats = coords.map(\.latitude)
        let lons = coords.map(\.longitude)
        let latSpan = lats.max()! - lats.min()!
        let lonSpan = lons.max()! - lons.min()!

        // Fit the members' padded bounding box (zoomLevel -1 = auto-fit).
        let padLat = latSpan * 0.15 + 0.0005
        let padLon = lonSpan * 0.15 + 0.0005
        let area = RectangleGeographicAreaObject(
            minLatitude: lats.min()! - padLat,
            maxLatitude: lats.max()! + padLat,
            minLon: lons.min()! - padLon,
            maxLon: lons.max()! + padLon
        )
        mapViewController.center(onArea: area, zoomLevel: -1, animationDuration: 0.6)
    }

    /// Centres the map on a campsite, keeping the current zoom (`-1`).
    private func centerOn(_ campsite: CampsiteInfo, proxy: MapProxy) {
        guard let mapViewController = proxy.mapViewController,
              let latitude = campsite.latitude, let longitude = campsite.longitude else { return }
        mapViewController.center(
            onCoordinates: CoordinatesObject.coordinates(withLatitude: latitude, longitude: longitude),
            zoomLevel: -1,
            animationDuration: 0.45
        )
    }
}

// MARK: - Info card (bottom / bottom-left panel)

struct CampsiteInfoCard: View {

    let campsite: CampsiteInfo
    let onClose: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // eurocampings scheme: bookable = red, info-only = green.
            Circle()
                .fill(campsite.isBookable
                      ? Color(red: 221 / 255, green: 49 / 255, blue: 55 / 255)
                      : Color(red: 0 / 255, green: 114 / 255, blue: 40 / 255))
                .frame(width: 12, height: 12)
                .padding(.top, 5)

            VStack(alignment: .leading, spacing: 2) {
                Text(campsite.displayName)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(campsite.isBookable ? "Bookable" : "Info only")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let coordinateText = campsite.coordinateText {
                    Text(coordinateText)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }

            Spacer(minLength: 8)

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.body.weight(.semibold))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 6, y: 2)
        )
    }
}

// MARK: - Loading chip

struct LoadingChip: View {
    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
            Text("Loading campsites…")
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
        )
    }
}

// MARK: - Campsite model

struct CampsiteInfo: Identifiable {

    let id: Int
    let name: String
    let isBookable: Bool
    let latitude: Double?
    let longitude: Double?

    init(marker: MarkerObject) {
        self.id = marker.getId()

        let properties = CampsiteInfo.parseProperties(from: marker.getName())
        self.name = properties.name
        self.isBookable = properties.bookable

        let coordinate = marker.getCoordinates().first
        self.latitude = coordinate?.latitude
        self.longitude = coordinate?.longitude
    }

    var displayName: String {
        name.isEmpty ? "Campsite #\(id)" : name
    }

    var coordinateText: String? {
        guard let latitude, let longitude else { return nil }
        return String(format: "%.5f, %.5f", latitude, longitude)
    }

    /// Marker names are stringified JSON carrying id / name / bookable
    /// (see CampsiteMarkerDescriptor.markerName). Parse defensively and fall back
    /// to the raw string when the payload isn't valid JSON.
    private static func parseProperties(from raw: String) -> (name: String, bookable: Bool) {
        guard let data = raw.data(using: .utf8),
              let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return (raw, false)
        }
        let properties = (root["properties"] as? [String: Any]) ?? root
        let name = (properties["name"] as? String) ?? ""
        let bookable = (properties["bookable"] as? Bool) ?? false
        return (name, bookable)
    }
}

#Preview {
    ContentView()
}

extension CoordinatesObject {
    // Continental-US centre, so the whole campground spread is visible on load.
    static let unitedStates =
    CoordinatesObject.coordinates(withLatitude: 39.5, longitude: -98.35)
}
