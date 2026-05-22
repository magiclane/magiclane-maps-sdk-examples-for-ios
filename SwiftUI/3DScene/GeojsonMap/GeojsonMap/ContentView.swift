// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit

struct ContentView: View {
    @State private var isLoaded = false

    var body: some View {
        MapReader { proxy in
            ZStack(alignment: .bottomTrailing) {
                MapBase(initialPosition: .paris, initialZoomLevel: 46)
                    .mapCompass(false)

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
        }
        .ignoresSafeArea()
    }
    
    func loadFile(_ proxy: MapProxy) {
        
        guard let mapViewController = proxy.mapViewController else { return }
        
        guard let url = Bundle.main.url(forResource: "paris_coffee", withExtension: "geojson") else { return }
        
        let bubbleSize = CGSize(width: 44, height: 44)
        
        let redColor = UIColor(red: 220/255, green: 53/255, blue: 53/255, alpha: 0.9)
        let orangeColor = UIColor(red: 217/255, green: 149/255, blue: 88/255, alpha: 0.9)
        
        let strokeWidth: CGFloat = 2
        let bubbleRect = CGRect(origin: .zero, size: bubbleSize)
            .insetBy(dx: strokeWidth / 2.0, dy: strokeWidth / 2.0)
        
        let bubbleRenderer = UIGraphicsImageRenderer(size: bubbleSize)
        
        // Red bubble used as the backdrop for cluster count labels.
        let clusterBubbleImage = bubbleRenderer.image { context in
            
            let cg = context.cgContext
            
            redColor.setFill()
            cg.fillEllipse(in: bubbleRect)
            
            UIColor.white.setStroke()
            cg.setLineWidth(strokeWidth)
            cg.strokeEllipse(in: bubbleRect)
        }
        
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .bold)
        let imgSymbol = UIImage(systemName: "cup.and.heat.waves", withConfiguration: imgConfig)?
            .withTintColor(.black, renderingMode: .alwaysOriginal)
        
        let imgBubbleImage = bubbleRenderer.image { context in
            
            let cg = context.cgContext
            
            orangeColor.setFill()
            cg.fillEllipse(in: bubbleRect)
            
            UIColor.white.setStroke()
            cg.setLineWidth(strokeWidth)
            cg.strokeEllipse(in: bubbleRect)
            
            if let tent = imgSymbol {
                
                let tentOrigin = CGPoint(x: (bubbleSize.width - tent.size.width) / 2.0,
                                         y: (bubbleSize.height - tent.size.height) / 2.0)
                
                tent.draw(at: tentOrigin)
            }
        }
        
        let renderSettings = MarkerCollectionRenderSettingsObject()
        renderSettings.pointImage = imgBubbleImage
        renderSettings.imageSize = 6
        
        renderSettings.lowDensityPointsGroupImage = clusterBubbleImage
        renderSettings.mediumDensityPointsGroupImage = clusterBubbleImage
        renderSettings.highDensityPointsGroupImage = clusterBubbleImage
        
        renderSettings.labelGroupTextColor = .white
        renderSettings.labelGroupTextSize = NSNumber(value: 2.4)
        
        renderSettings.labelingMode = NSNumber(value: MarkerLabelingMode.group.rawValue
                                               | MarkerLabelingMode.groupCenter.rawValue
                                               | MarkerLabelingMode.textCentered.rawValue)
        
        var code: SDKErrorCode = .kNoError
        
        let collections = mapViewController.getMarkerCollection(fromGeoJson: url.path,
                                                                filters: nil,
                                                                prefix: nil,
                                                                importPolygonAsArea: false,
                                                                code: &code)
        
        print("testing: getMarkerCollectionFromGeoJson collections:%d, code:%d", collections.count, code.rawValue)
        
        for collection in collections {
            
            mapViewController.addMarker(collection, renderSettingsObject: renderSettings)
        }
    }
}

#Preview {
    ContentView()
}

extension CoordinatesObject {
    static let paris =
    CoordinatesObject.coordinates(withLatitude: 48.852546, longitude: 2.345789)
}

