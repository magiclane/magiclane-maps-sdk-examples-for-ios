// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit

struct ContentView: View {

    @Environment(\.displayScale) private var displayScale

    @State private var selectedLandmark: LandmarkObject?
    @State private var zoom = 74

    var body: some View {
        MapReader { proxy in
            ZStack(alignment: .bottom) {
                MapBase()
                    .didSelectStreets { streets, touchPoint, isLongTouch in
                        proxy.present(highlights: streets, settings: getRenderSettings())

                        selectedLandmark = streets.first
                    }
                    .didSelectLandmarks { landmarks, touchPoint, isLongTouch in
                        proxy.present(highlights: landmarks, settings: getRenderSettings())

                        selectedLandmark = landmarks.first
                    }
                    .didSelectOverlays { overlays, touchPoint, isLongTouch in
                        print("didSelectOverlays")
                    }
                    .didSelectTrafficEvents { events, touchPoint, isLongTouch in
                        print("didSelectTrafficEvents")
                    }
                    .onAppear {
                        goToPosition(proxy)
                    }
                    .ignoresSafeArea()

                if let selectedLandmark = selectedLandmark {

                    HStack {

                        Image(uiImage: getLandmarkImage(landmark: selectedLandmark))
                            .frame(width: 40, height: 40)

                        Text(selectedLandmark.getLandmarkName() + "\n" + selectedLandmark.getLandmarkDescription())

                        Spacer()
                    }
                    .padding(10)
                    .background(Rectangle().fill(.background))
                    .padding()
                }
            }
        }
    }

    func getRenderSettings() -> HighlightRenderSettings {
        let settings = HighlightRenderSettings.init()
        settings.showPin = true
        settings.imageSize = 7

        return settings
    }

    func getLandmarkImage(landmark: LandmarkObject) -> UIImage {

        let image = landmark.getLandmarkImage(CGSize(width: 40 * displayScale, height: 40 * displayScale)) ?? UIImage()

        return image
    }

    func goToPosition(_ proxy: MapProxy) {
        proxy.centerOn(coordinates: .amsterdam, zoomLevel: zoom)
    }
}

#Preview {
    ContentView()
}

extension CoordinatesObject {
    static let amsterdam =
        CoordinatesObject.coordinates(withLatitude: 52.368447, longitude: 4.888229)
}
