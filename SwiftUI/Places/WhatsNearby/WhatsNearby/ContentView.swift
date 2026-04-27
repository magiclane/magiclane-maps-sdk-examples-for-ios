// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit

struct ContentView: View {

    let searchContext = SearchContext.init()
    private let defaultHighlightId = 10

    @State private var selectedLandmark: LandmarkObject?
    @State private var nearbyLandmarks: [LandmarkObject] = []
    @State private var labelText = "Select a point on the map and tap the button in the top right to search around it"

    var body: some View {
        MapReader { proxy in
            ZStack(alignment: .bottom) {
                MapBase(initialPosition: .amsterdam, initialZoomLevel: 70) {
                    MapLandmark(
                        landmarks: nearbyLandmarks,
                        renderSettings: getGroupSettings(),
                        highlightId: defaultHighlightId,
                        animationDuration: 800
                    )
                }
                .didSelectLandmarks { landmarks, touchPoint, isLongTouch in
                    guard let landmark = landmarks.first else { return }
                    processSelection(landmark: landmark, proxy: proxy)
                }
                .didSelectStreets { streets, touchPoint, isLongTouch in
                    guard let street = streets.first else { return }
                    processSelection(landmark: street, proxy: proxy)
                }
                .ignoresSafeArea()

                Text(labelText)
                    .font(.system(size: 16, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .frame(height: 70)
                    .background(Color(UIColor.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: 1.4)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
            }
            .navigationTitle("What's Nearby")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        cleanMap(proxy: proxy)
                    } label: {
                        Image(systemName: "clear")
                    }
                    .buttonStyle(.borderedProminent)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        searchNearby()
                    } label: {
                        Image(systemName: "mappin.and.ellipse")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }

    // MARK: - Search

    private func searchNearby() {
        guard let landmark = selectedLandmark else { return }

        searchContext.searchAround(withLocation: landmark.getCoordinates()) { results in
            nearbyLandmarks = results
        }
    }

    // MARK: - Utils

    private func processSelection(landmark: LandmarkObject, proxy: MapProxy) {
        cleanMap(proxy: proxy)
        selectedLandmark = landmark

        let name = landmark.getLandmarkName()
        let description = landmark.getLandmarkDescription()
        labelText = "  \(name)\n  \(description)"

        let settings = HighlightRenderSettings.init()
        settings.showPin = true
        proxy.present(highlights: [landmark], settings: settings, highlightId: Int(defaultHighlightId))
    }

    private func cleanMap(proxy: MapProxy) {
        proxy.removeAllHighlights()
        nearbyLandmarks = []
        selectedLandmark = nil
        labelText = "Select a point on the map and tap the button in the top right to search around it"
    }

    private func getGroupSettings() -> HighlightRenderSettings {
        let settings = HighlightRenderSettings.init()
        settings.options = Int32(HighlightOption.group.rawValue)
        settings.showPin = true
        settings.imageSize = 7
        return settings
    }
}

#Preview {
    ContentView()
}

extension CoordinatesObject {
    static let amsterdam = CoordinatesObject.coordinates(withLatitude: 52.368447, longitude: 4.888229)
}
