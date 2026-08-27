// SPDX-FileCopyrightText: 2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Two-layer clustering renderer:
//
//   1. CLUSTER layer — all campsites, native grouping → density pills WITH the
//      count label. It has NO customMarkerSettings, because per-marker settings
//      carry no group-text fields and would suppress the cluster count.
//      Its loose (ungrouped) markers draw a transparent image.
//   2. DETAIL layer — the SAME full set of campsites, grouped at the SAME zoom
//      but with TRANSPARENT group images (so it shows nothing while clustered),
//      and customMarkerSettings to colour each loose marker green/red.
//
// Because both layers hold the SAME marker set and group at the SAME zoom, they
// make IDENTICAL group/loose decisions:
//   • below clusterZoom → cluster pills+counts visible; detail groups transparent,
//   • at/above clusterZoom → cluster loose transparent; detail loose = colour pins.
// A pill therefore never sits on top of a loose pin, and the count shows
// because it comes from the cluster layer.

import Foundation
import CoreLocation
import GEMKit
import UIKit

@MainActor
final class CampsitePOIRenderer {
    private let collectionName = "acsi-campsites"

    // Shared per-marker pins (created once → no per-callback native churn).
    private lazy var bookablePin: MarkerRenderSettingsObject = {
        let settings = MarkerRenderSettingsObject()
        settings.image = CampsiteMarkerIcons.makePin(bookable: true)
        settings.imageSize = 6.4
        return settings
    }()

    private lazy var notBookablePin: MarkerRenderSettingsObject = {
        let settings = MarkerRenderSettingsObject()
        settings.image = CampsiteMarkerIcons.makePin(bookable: false)
        settings.imageSize = 6.4
        return settings
    }()

    func syncPOIs(
        on mapViewController: MapViewController,
        markers: [CampsiteMarkerDescriptor],
        selectedPOIId: Int? = nil,
        clusterMaxZoom: Double = 6
    ) {
        // Tear down previous layers (mirrors Android's prefs.markers.clear()).
        mapViewController.removeAllMarkers()

        let baseMarkers: [CampsiteMarkerDescriptor]
        if let selectedPOIId {
            baseMarkers = markers.filter { $0.id != selectedPOIId }
        } else {
            baseMarkers = markers
        }

        let clusterZoom = MapZoomConverter.toMagicLaneZoom(clusterMaxZoom)

        // 1) Cluster layer — density pills + count label. No customMarkerSettings.
        let clustered = MarkerCollectionObject(name: "\(collectionName)-clustered", type: .point)
        for marker in baseMarkers {
            clustered.addMarker(markerObject(for: marker))
        }

        let clusterSettings = MarkerCollectionRenderSettingsObject()
        clusterSettings.imageSize = 5.8
        clusterSettings.labelTextSize = 0
        clusterSettings.labelGroupTextColor = .white
        clusterSettings.labelGroupTextSize = 2.7
        clusterSettings.pointsGroupingZoomLevel = NSNumber(value: clusterZoom)
        clusterSettings.buildPointsGroupConfig = true
        // Tiers split by DIGIT COUNT so each pill is sized to its text:
        //   low    ≤99    → 1–2 digit circle
        //   medium ≤999   → snug 3-digit pill
        //   high   ≥1000  → full-width 4-digit pill ("9999" worst case).
        clusterSettings.lowDensityPointsGroupImage = CampsiteMarkerIcons.makePill(digits: 2)
        clusterSettings.mediumDensityPointsGroupImage = CampsiteMarkerIcons.makePill(digits: 3)
        clusterSettings.highDensityPointsGroupImage = CampsiteMarkerIcons.makePill(digits: 4)
        clusterSettings.lowDensityPointsGroupMaxCount = 200
        clusterSettings.mediumDensityPointsGroupMaxCount = 4000
        // Group | GroupCenter, WITHOUT FitImage — same as Android. FitImage
        // resizes the group icon to fit the count text; dropping it keeps the
        // fixed-size pill while still showing the centred count (Group).
        clusterSettings.labelingMode = NSNumber(
            value: MarkerLabelingMode.group.rawValue |
                MarkerLabelingMode.groupCenter.rawValue
        )
        // Loose singles invisible here — the detail layer draws them coloured.
        clusterSettings.pointImage = CampsiteMarkerIcons.transparent
        mapViewController.addMarker(clustered, renderSettingsObject: clusterSettings)

        // 2) Detail layer — same full set, grouped identically but with
        //    transparent group images; colours each loose pin via customMarkerSettings.
        let detail = MarkerCollectionObject(name: "\(collectionName)-detail", type: .point)
        for marker in baseMarkers {
            detail.addMarker(markerObject(for: marker))
        }

        let detailSettings = MarkerCollectionRenderSettingsObject()
        detailSettings.imageSize = 6.4
        detailSettings.labelTextSize = 0
        detailSettings.labelGroupTextSize = 0
        detailSettings.pointsGroupingZoomLevel = NSNumber(value: clusterZoom)
        // Lets a tap on this (topmost) layer enumerate the group's members via
        // getPointsGroupHead / getPointsGroupComponents when a cluster is tapped.
        detailSettings.buildPointsGroupConfig = true
        detailSettings.lowDensityPointsGroupImage = CampsiteMarkerIcons.transparent
        detailSettings.mediumDensityPointsGroupImage = CampsiteMarkerIcons.transparent
        detailSettings.highDensityPointsGroupImage = CampsiteMarkerIcons.transparent
        detailSettings.pointImage = CampsiteMarkerIcons.transparent

        // Per-marker colour: the marker name carries the bookable flag as JSON
        // (see CampsiteMarkerDescriptor.markerName) — exactly the Android check.
        let bookablePin = self.bookablePin
        let notBookablePin = self.notBookablePin
        detailSettings.customMarkerSettings = { marker in
            marker.getName().contains("\"bookable\":true") ? bookablePin : notBookablePin
        }
        mapViewController.addMarker(detail, renderSettingsObject: detailSettings)

        #if DEBUG
        let bookableCount = baseMarkers.filter(\.isBookable).count
        print("[CampsitePOIRenderer] total=\(markers.count) bookable=\(bookableCount) " +
              "not=\(baseMarkers.count - bookableCount) clusterZoom=\(clusterZoom)")
        #endif

        // 3) Selected layer — highlighted, always visible, never grouped.
        if let selectedPOIId,
           let selected = markers.first(where: { $0.id == selectedPOIId }) {
            let layer = MarkerCollectionObject(name: "\(collectionName)-selected", type: .point)
            layer.addMarker(markerObject(for: selected))

            let selectedSettings = MarkerCollectionRenderSettingsObject()
            selectedSettings.imageSize = 7.0
            selectedSettings.labelTextSize = 0
            selectedSettings.pointsGroupingZoomLevel = 0
            selectedSettings.pointImage = CampsiteMarkerIcons.makePin(bookable: selected.isBookable, selected: true)
            mapViewController.addMarker(layer, renderSettingsObject: selectedSettings)
        }
    }

    private func markerObject(for descriptor: CampsiteMarkerDescriptor) -> MarkerObject {
        let object = MarkerObject(coordinates: [
            CoordinatesObject.coordinates(withLatitude: descriptor.latitude, longitude: descriptor.longitude)
        ])
        object.setName(descriptor.markerName)
        return object
    }
}
