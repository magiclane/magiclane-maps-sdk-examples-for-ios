// SPDX-FileCopyrightText: 2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Marker artwork using the actual eurocampings.co.uk assets, rasterized from
// the official SVGs (https://cdn.acsi.eu/A/6/7/8/{bookable,non_bookable,cluster}.svg):
//
//   • pin_bookable.png      — bookable campsite  (red  #DD3137, tent glyph)
//   • pin_non_bookable.png  — not bookable       (green #007228, tent glyph)
//
// The cluster capsule (#0C4B22) is drawn in code (see makePill) so it can widen
// for 3- and 4-digit counts instead of being a fixed-width asset.
//
// Note the site's own colour scheme: BOOKABLE is RED, NOT-BOOKABLE is GREEN.
// The PNGs are rasterized at 4× so they stay crisp; Magic Lane's `imageSize`
// (a physical size, not a pixel multiplier) controls how big they draw on the map.

import UIKit

enum CampsiteMarkerIcons {

    private static let cache = NSCache<NSString, UIImage>()

    private static func bundled(_ name: String) -> UIImage {
        if let cached = cache.object(forKey: name as NSString) { return cached }
        let image = Bundle.main.url(forResource: name, withExtension: "png")
            .flatMap { UIImage(contentsOfFile: $0.path) } ?? UIImage()
        cache.setObject(image, forKey: name as NSString)
        return image
    }

    /// Pin for a campsite. `selected` is intentionally ignored here — the
    /// renderer emphasises the selected pin via a larger `imageSize`.
    static func makePin(bookable: Bool, selected: Bool = false) -> UIImage {
        bundled(bookable ? "pin_bookable" : "pin_non_bookable")
    }

    private static let clusterColor = UIColor(red: 0x0C/255.0, green: 0x4B/255.0, blue: 0x22/255.0, alpha: 1)

    /// Cluster capsule background — reproduces the ACSI `cluster.svg` (flat
    /// `#0C4B22` capsule with a white 40% border), widened to fit `digits` of
    /// count text. The count itself is drawn over it by Magic Lane's
    /// group-labeling engine. Drawing it (vs the fixed-width PNG) lets the
    /// capsule grow for 3- and 4-digit counts at low zoom.
    static func makePill(digits: Int = 1) -> UIImage {
        let height: CGFloat = 96                       // 4× the 24pt SVG, matches pin crispness
        let stroke: CGFloat = height / 24.0            // ~1px stroke on the 24pt original
        // Visible capsule width per digit count. The count text is ~0.47×height
        // tall (labelGroupTextSize 2.7 / imageSize 5.8), so a digit is ~0.27×
        // height wide; these widths keep a snug end-cap margin instead of the
        // old over-wide pills that wasted space and overlapped neighbours.
        // ≤2 digits → circle. The count is centred by the SDK's GroupCenter
        // labeling, so it lands dead-centre.
        let width: CGFloat
        if digits >= 4 {
            width = height * 1.42                      // 4-digit capsule (fits "9999")
        } else if digits == 3 {
            width = height * 1.18                      // snug 3-digit capsule
        } else {
            width = height                             // 1–2 digits → circle
        }
        let size = CGSize(width: width, height: height)

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            let rect = CGRect(origin: .zero, size: size).insetBy(dx: stroke, dy: stroke)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: rect.height / 2)
            clusterColor.setFill()
            path.fill()
            UIColor.white.withAlphaComponent(0.4).setStroke()
            path.lineWidth = stroke
            path.stroke()
        }
    }

    /// A fully transparent 64×64 image. Used as the clustered layer's loose
    /// `pointImage` and the detail layer's group images, so those draw nothing —
    /// the detail layer's `customMarkerSettings` owns every individual pin.
    /// Sized 64×64 (power-of-two) to mirror the Android port.
    static let transparent: UIImage = {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 64, height: 64))
        return renderer.image { _ in }
    }()
}
