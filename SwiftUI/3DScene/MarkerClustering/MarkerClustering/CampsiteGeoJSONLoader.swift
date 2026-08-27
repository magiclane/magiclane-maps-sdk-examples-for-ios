// SPDX-FileCopyrightText: 2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Parses the bundled campsites.geojson (regenerated from the ACSI API with the
// full field set) into CampsiteMarkerDescriptor values. Only the fields the map
// needs are decoded; the decoder ignores the rest (description, images, geo, …).

import Foundation

enum CampsiteGeoJSONLoader {

    static func loadFromBundle(resource: String = "campsites",
                               extension ext: String = "geojson") -> [CampsiteMarkerDescriptor] {
        guard let url = Bundle.main.url(forResource: resource, withExtension: ext),
              let data = try? Data(contentsOf: url) else {
            return []
        }
        return parse(data)
    }

    static func parse(_ data: Data) -> [CampsiteMarkerDescriptor] {
        guard let decoded = try? JSONDecoder().decode(FeatureCollection.self, from: data) else {
            return []
        }
        return decoded.features.compactMap { feature in
            guard feature.geometry.coordinates.count >= 2 else { return nil }
            let longitude = feature.geometry.coordinates[0]
            let latitude = feature.geometry.coordinates[1]
            let p = feature.properties
            return CampsiteMarkerDescriptor(
                id: p.campsiteId,
                name: p.name,
                country: p.country,
                reviewScore: p.reviewScore,
                stars: p.stars,
                isBookable: p.bookable ?? false,
                latitude: latitude,
                longitude: longitude
            )
        }
    }

    // MARK: - GeoJSON model (only the fields we use)

    private struct FeatureCollection: Decodable {
        let features: [Feature]
    }

    private struct Feature: Decodable {
        let geometry: Geometry
        let properties: Properties
    }

    private struct Geometry: Decodable {
        let coordinates: [Double]
    }

    private struct Properties: Decodable {
        let campsiteId: Int
        let name: String
        let country: String?
        let reviewScore: Double?
        let stars: Int?
        let bookable: Bool?
    }
}
