// SPDX-FileCopyrightText: 2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Adapted from FeatureMap (Engine/MapCameraState.swift). Self-contained:
// no Core / CoreUI dependency.

import Foundation

/// Converts between the standard 0–22 web-map zoom scale and Magic Lane zoom
/// levels. Ported verbatim from FeatureMap so the clustering thresholds match
/// the original feature's behaviour.
enum MapZoomConverter {
    /// Converts a 0–22 web-map zoom to a Magic Lane zoom level.
    static func toMagicLaneZoom(_ appZoom: Double) -> Int {
        let clamped = min(max(appZoom, 0), 22)
        return Int((clamped * 7.0) + 4.0)
    }

    /// Converts Magic Lane zoom levels back to app map zoom.
    static func fromMagicLaneZoom(_ magicLaneZoom: Int) -> Double {
        Double(magicLaneZoom - 4) / 7.0
    }
}
