// SPDX-FileCopyrightText: 2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Adapted from FeatureMap (Engine/MapPOIMarkerDescriptor.swift).
//
// One value per ACSI campsite. The two-way icon split is driven by `isBookable`
// (the `bookable` flag in the regenerated campsites.geojson) — exactly how
// eurocampings.co.uk colours its map markers: green = bookable, red = not.

import Foundation
import CoreLocation

/// The two marker styles, mirroring eurocampings' green/red pins.
enum CampsiteStyle: Hashable {
    case bookable
    case notBookable
}

struct CampsiteMarkerDescriptor: Identifiable, Sendable {
    let id: Int            // campsiteId
    let name: String
    let country: String?
    let reviewScore: Double?
    let stars: Int?
    let isBookable: Bool
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var style: CampsiteStyle { isBookable ? .bookable : .notBookable }

    /// Short detail line shown under the name in the list sheet.
    var subtitle: String? {
        var parts: [String] = []
        if let stars, stars > 0 { parts.append(String(repeating: "★", count: stars)) }
        if let reviewScore, reviewScore > 0 { parts.append(String(format: "%.1f", reviewScore)) }
        if let country { parts.append(country) }
        parts.append(isBookable ? "Bookable" : "Info only")
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    /// Marker name carried into the SDK. Encoded as JSON so the existing
    /// `MarkerInfo` parser recovers id / name / detail straight from
    /// `MarkerObject.getName()`.
    var markerName: String {
        var object: [String: Any] = ["id": id, "name": name, "bookable": isBookable]
        if let subtitle { object["address"] = subtitle }
        guard let data = try? JSONSerialization.data(withJSONObject: object),
              let json = String(data: data, encoding: .utf8) else {
            return name
        }
        return json
    }
}
