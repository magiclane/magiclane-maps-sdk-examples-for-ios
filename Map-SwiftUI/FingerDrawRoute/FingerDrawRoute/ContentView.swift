// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: BSD-3-Clause
//
// Contact Magic Lane at <info@magiclane.com> for commercial licensing options.

import SwiftUI
import GEMKit

struct ContentView: View {
    @State var drawPathOn: Bool = true     
    @State var navigationContext: NavigationContext? = nil
    
    var body: some View {
        MapReader { proxy in
            ZStack(alignment: .leading) {            
                MapBase()
                    .onAppear() {
                        proxy.centerOn(coordinates: .amsterdam, zoomLevel: 66) 
                    }
                    .ignoresSafeArea()
                Button() {
                    drawPath(proxy)
                } label: {
                    VStack(alignment: .leading) {
                        Image(systemName: "hand.draw")                            
                            .font(.system(size: 32, weight: .semibold))
                            .frame(width: 60, height: 60)
                            .foregroundStyle(.blue)
                            .background(.background)
                            .clipShape(Circle())
                            .shadow(color: .gray, radius: 3)
                        Spacer()
                    }
                    .padding()
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!drawPathOn)
            }
        }        
    }
    
    func drawPath(_ proxy: MapProxy) {
        
        guard let mapViewController = proxy.mapViewController else { return }
        
        mapViewController.removeAllRoutes()
        mapViewController.removeAllMarkers()
        
        mapViewController.hideCompass()
        mapViewController.view.layer.borderWidth = 16
        mapViewController.view.layer.borderColor = UIColor.gray.withAlphaComponent(0.26).cgColor
        
        mapViewController.setTouchViewBehaviour(.fingerDraw) { marker in
            
            mapViewController.showCompass()
            mapViewController.view.layer.borderWidth = 0
            mapViewController.view.layer.borderColor = nil
            
            mapViewController.setTouchViewBehaviour(.default)
            
            if let coordinates = marker?.getCoordinates(), coordinates.count > 0 {
                
                let path = PathObject.init(coordinates: coordinates)
                
                if let lmk = RouteBookmarksObject.setWaypointTrackData(path) {
                    
                    calculateRoute(proxy, waypoints: [lmk])
                }
            }
        }
        
        drawPathOn = false
    }
    
    func calculateRoute(_ proxy: MapProxy, waypoints: [LandmarkObject]) {
        
        guard let mapViewController = proxy.mapViewController else { return }
        
        let navigationContext = self.createNavigationContext()
        
        navigationContext.calculateRoute(withWaypoints: waypoints) { routeStatus in
            
        } completionHandler: { results, code in
            
            if let route = results.first {
                
                let scale = UIScreen.main.scale
                let insets = UIEdgeInsets.init(top: 120 * scale, left: 60 * scale, 
                                               bottom: 120 * scale, right: 60 * scale)
                mapViewController.setEdgeAreaInsets(insets)
                mapViewController.presentRoutes(results, withTraffic: nil, showSummary: true, animationDuration: 1600)
                
                let preferences = mapViewController.getPreferences()
                if let settings = preferences.getRenderSettings(route) {
                    settings.textSize  = 3.6
                    settings.imageSize = 3.6
                    preferences.setRenderSettings(settings, route: route)
                }                
            }
            
            drawPathOn = true
        }
    }
    
    func createNavigationContext() -> NavigationContext {
        
        guard self.navigationContext == nil else { return self.navigationContext! } 
        
        let preferences = RoutePreferencesObject.init()
        preferences.setRouteType(.fastest)
        preferences.setIgnoreRestrictionsOverTrack(true)
        preferences.setAccurateTrackMatch(false) // only for track data
        preferences.setTransportMode(.bicycle)
        
        self.navigationContext = NavigationContext.init(preferences: preferences) 
        
        return self.navigationContext!
    }
}

#Preview {
    ContentView()    
}

extension CoordinatesObject {
    static let amsterdam = CoordinatesObject.coordinates(withLatitude: 52.296245, longitude: 4.582780) 
}
