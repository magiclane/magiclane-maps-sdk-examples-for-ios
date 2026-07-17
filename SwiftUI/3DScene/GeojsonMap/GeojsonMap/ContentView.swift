// SPDX-FileCopyrightText: 2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isLoaded = false
    @State private var markerSelection: MarkerSelection?
    @State private var presentationDetent: PresentationDetent = .medium
    @State private var coffeeCollections: [MarkerCollectionObject] = []
    @State private var coffeeRenderSettings: MarkerCollectionRenderSettingsObject?

    var body: some View {
        MapReader { proxy in
            ZStack(alignment: .bottomTrailing) {
                MapBase(initialPosition: .paris, initialZoomLevel: 46, content: {
                    MapMarker(title: "Coffee",
                              collections: coffeeCollections,
                              renderSettings: coffeeRenderSettings)
                })
                .mapCompass(false)
                .mapStyle(getStyleFollowingOS())
                .didSelectMarkers { markers, touchPoint, isLongTouch in
                    handleSelectedMarkers(markers)
                }

                if !isLoaded {
                    Button {
                        loadFile(proxy)
                        isLoaded = true
                    } label: {
                        Image(systemName: "cup.and.heat.waves")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color(red: 217/255, green: 149/255, blue: 88/255))
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 32)
                }
            }
            .sheet(item: $markerSelection,
                   onDismiss: {
                   }) { selection in
                MarkersListView(
                    markers: selection.markers,
                    detent: $presentationDetent,
                    onSelect: { marker in
                        if let mapViewController = proxy.mapViewController {
                            centerMap(on: marker, mapViewController: mapViewController)
                        }
                        presentationDetent = .height(190)
                    },
                    onDismiss: { markerSelection = nil }
                )
            }
        }
        .ignoresSafeArea()
    }

    func getStyleFollowingOS() -> Int {
        return colorScheme == .dark ? MapStyleIdentifiers.night.rawValue : MapStyleIdentifiers.day.rawValue
    }
    
    func loadFile(_ proxy: MapProxy) {

        guard let mapViewController = proxy.mapViewController else { return }

        guard let url = Bundle.main.url(forResource: "paris_coffee",
                                        withExtension: "geojson") else { return }

        let bubbleSize = CGSize(width: 44, height: 44)

        let redColor = UIColor(red: 220/255, green: 53/255, blue: 53/255, alpha: 0.9)
        let orangeColor = UIColor(red: 217/255, green: 149/255, blue: 88/255, alpha: 0.9)

        let strokeWidth: CGFloat = 2
        let bubbleRect = CGRect(origin: .zero, size: bubbleSize)
            .insetBy(dx: strokeWidth / 2.0, dy: strokeWidth / 2.0)

        let bubbleRenderer = UIGraphicsImageRenderer(size: bubbleSize)

        let clusterBubbleImage = bubbleRenderer.image { context in

            let cg = context.cgContext

            // Inset the cluster ellipse so its drop shadow has room to
            // render inside the 44pt canvas without being clipped.
            let shadowedRect = bubbleRect.insetBy(dx: 3, dy: 3)

            cg.saveGState()
            cg.setShadow(offset: CGSize(width: 0, height: 1.5),
                         blur: 3,
                         color: UIColor.black.withAlphaComponent(0.35).cgColor)

            redColor.setFill()
            cg.fillEllipse(in: shadowedRect)

            cg.restoreGState()

            UIColor.white.setStroke()
            cg.setLineWidth(strokeWidth)
            cg.strokeEllipse(in: shadowedRect)
        }

        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        let imgSymbol = UIImage(systemName: "cup.and.heat.waves", withConfiguration: config)?
            .withTintColor(.black, renderingMode: .alwaysOriginal)

        let bubbleImage = bubbleRenderer.image { context in

            let cg = context.cgContext

            // Same inset trick as the cluster bubble so the drop shadow
            // has room to render inside the 44pt canvas.
            let shadowedRect = bubbleRect.insetBy(dx: 3, dy: 3)

            cg.saveGState()
            cg.setShadow(offset: CGSize(width: 0, height: 1.5),
                         blur: 3,
                         color: UIColor.black.withAlphaComponent(0.35).cgColor)

            orangeColor.setFill()
            cg.fillEllipse(in: shadowedRect)

            cg.restoreGState()

            UIColor.white.setStroke()
            cg.setLineWidth(strokeWidth)
            cg.strokeEllipse(in: shadowedRect)

            if let image = imgSymbol {

                let tentOrigin = CGPoint(x: (bubbleSize.width - image.size.width) / 2.0,
                                         y: (bubbleSize.height - image.size.height) / 2.0)

                image.draw(at: tentOrigin)
            }
        }

        let renderSettings = MarkerCollectionRenderSettingsObject()
        renderSettings.buildPointsGroupConfig = true

        renderSettings.pointImage = bubbleImage
        renderSettings.imageSize = 7

        renderSettings.lowDensityPointsGroupImage = clusterBubbleImage
        renderSettings.mediumDensityPointsGroupImage = clusterBubbleImage
        renderSettings.highDensityPointsGroupImage = clusterBubbleImage

        renderSettings.labelGroupTextColor = .white
        renderSettings.labelGroupTextSize = NSNumber(value: 2.4)
        renderSettings.pointsGroupingZoomLevel = 66

        renderSettings.labelingMode = NSNumber(value: MarkerLabelingMode.group.rawValue
                                               | MarkerLabelingMode.groupCenter.rawValue
                                               | MarkerLabelingMode.textCentered.rawValue)

        var code: SDKErrorCode = .kNoError

        let collections = mapViewController.getMarkerCollection(fromGeoJson: url.path,
                                                                filters: nil,
                                                                prefix: nil,
                                                                importPolygonAsArea: false,
                                                                code: &code)

        print("testing: getMarkerCollectionFromGeoJso collections:\(collections.count) code:\(code.rawValue)")

        coffeeRenderSettings = renderSettings
        coffeeCollections = collections
    }

    func handleSelectedMarkers(_ markers: [MarkerMatchObject]) {

        print("testing: handleSelectedMarkers markers count:\(markers.count)")

        guard let match = markers.first else { return }

        guard let marker = match.getMarker() else { return }

        guard let collection = match.getMarkerCollection() else { return }

        var pointsGroupComponentsSize = 0 
        
        let identifier = marker.getId()
        var list: [MarkerObject] = []
        if let head = collection.getPointsGroupHead(identifier) {
            list.append(head)
            pointsGroupComponentsSize += 1
        }
        let elements = collection.getPointsGroupComponents(identifier)
        list.append(contentsOf: elements)
        pointsGroupComponentsSize += elements.count
        
        var seenIds = Set<Int>()
        var collected: [MarkerInfo] = []
        for component in list {            
            appendMarker(component, into: &collected, seenIds: &seenIds)
        }

        presentationDetent = .medium
        markerSelection = MarkerSelection(markers: collected)
        
        print("testing: didSelectMarkers count:\(pointsGroupComponentsSize)")
    }

    private func appendMarker(_ marker: MarkerObject,
                              into list: inout [MarkerInfo],
                              seenIds: inout Set<Int>) {

        let id = marker.getId()

        guard !seenIds.contains(id) else { return }

        seenIds.insert(id)

        list.append(MarkerInfo(marker: marker))
    }

    private func centerMap(on marker: MarkerInfo, mapViewController: MapViewController) {

        guard let latitude = marker.latitude, let longitude = marker.longitude else { return }

        let coordinate = CoordinatesObject.coordinates(withLatitude: latitude, longitude: longitude)

        mapViewController.center(onCoordinates: coordinate, zoomLevel: 70, animationDuration: 0.4)
    }
}

// MARK: - Marker list presentation

struct MarkerSelection: Identifiable {

    // Constant identity so .sheet(item:) updates the existing sheet in
    // place when a new cluster is tapped, instead of dismissing the
    // current sheet and re-presenting (which would reset the detent
    // back to the largest one in the array).
    let id = "selection"
    let markers: [MarkerInfo]
}

struct MarkerInfo: Identifiable {

    let id: Int
    let name: String
    let address: String?
    let latitude: Double?
    let longitude: Double?

    init(marker: MarkerObject) {

        self.id = marker.getId()

        let properties = MarkerInfo.parseProperties(from: marker.getName())
        self.name = properties.name
        self.address = properties.address

        let coordinate = marker.getCoordinates().first
        self.latitude = coordinate?.latitude
        self.longitude = coordinate?.longitude
    }

    var displayName: String {

        name.isEmpty ? "Marker #\(id)" : name
    }

    var coordinateText: String? {

        guard let latitude, let longitude else { return nil }

        return String(format: "%.5f, %.5f", latitude, longitude)
    }

    /// Marker names returned by the SDK are stringified GeoJSON `properties`
    /// objects of the form `{"properties":{"name":"...","address":"..."}}`.
    /// Parse them defensively and fall back to the raw string when the payload
    /// isn't valid JSON.
    private static func parseProperties(from raw: String) -> (name: String, address: String?) {

        guard let data = raw.data(using: .utf8),
              let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {

            return (raw, nil)
        }

        // The payload is sometimes wrapped in a `properties` key, sometimes not.
        let properties = (root["properties"] as? [String: Any]) ?? root

        let name = (properties["name"] as? String) ?? ""
        let address = properties["address"] as? String

        return (name, address?.isEmpty == true ? nil : address)
    }
}

struct MarkersListView: View {

    let markers: [MarkerInfo]
    @Binding var detent: PresentationDetent
    let onSelect: (MarkerInfo) -> Void
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            List(markers) { marker in
                Button {
                    onSelect(marker)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {

                        Text(marker.displayName)
                            .font(.headline)
                            .foregroundColor(.primary)

                        if let address = marker.address {

                            Text(address)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }

                        if let coordinateText = marker.coordinateText {

                            Text(coordinateText)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Markers (\(markers.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done", action: onDismiss)
                }
            }
        }
        .presentationDetents([.height(190), .medium, .large], selection: $detent)
        .presentationBackgroundInteraction(.enabled(upThrough: .medium))
    }
}

#Preview {
    ContentView()
}

extension CoordinatesObject {
    static let paris =
    CoordinatesObject.coordinates(withLatitude: 48.852546, longitude: 2.345789)
}
