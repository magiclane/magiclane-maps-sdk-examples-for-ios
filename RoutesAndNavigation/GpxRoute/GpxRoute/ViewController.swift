// Copyright (C) 2019-2021, General Magic B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of General Magic
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with General Magic.

import UIKit
import GEMKit

class ViewController: UIViewController, UISearchBarDelegate, NavigationContextDelegate {
    
    var mapViewController: MapViewController?
    
    var navigationContext: NavigationContext?
    
    var mainRoute: RouteObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "GEM Gpx Route"
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.createMapView()
        
        self.mapViewController!.startRender()
        
        self.addRouteButton()
    }
    
    // MARK: - Map View
    
    func createMapView() {
        
        self.mapViewController = MapViewController.init()
        self.mapViewController!.view.backgroundColor = UIColor.systemBackground
        
        self.addChild(self.mapViewController!)
        self.view.addSubview(self.mapViewController!.view)
        self.mapViewController!.didMove(toParent: self)
        
        self.mapViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        let constraintTop = NSLayoutConstraint( item: self.mapViewController!.view!, attribute: NSLayoutConstraint.Attribute.top,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self.view, attribute: NSLayoutConstraint.Attribute.top,
                                                multiplier: 1.0, constant: 0)
        
        let constraintLeft = NSLayoutConstraint( item: self.mapViewController!.view!, attribute: NSLayoutConstraint.Attribute.leading,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading,
                                                 multiplier: 1.0, constant: 0)
        
        let constraintBottom = NSLayoutConstraint( item: self.mapViewController!.view!, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: self.view, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   multiplier: 1.0, constant: -0)
        
        let constraintRight = NSLayoutConstraint( item: self.mapViewController!.view!, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  multiplier: 1.0, constant: -0)
        
        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintBottom, constraintRight])
    }
    
    func addRouteButton() {
        
        var image = UIImage.init(systemName: "point.topleft.down.curvedto.point.bottomright.up")
        let barButton1 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(routeButtonAction(item:)))
        
        image = UIImage.init(systemName: "clear")
        let barButton2 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(clearRouteButtonAction(item:)))
        
        image = UIImage.init(systemName: "play")
        let barButton3 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(startSimulation))
        
        self.navigationItem.rightBarButtonItems = [barButton1, barButton2, barButton3]
    }
    
    @objc func routeButtonAction(item: UIBarButtonItem) {
        
        guard let fileURL = Bundle.main.url(forResource: "test", withExtension: "gpx") else {
            
            return
        }
        
        guard let data = NSData.init(contentsOf: fileURL) as Data? else {
            
            return
        }
        
        if self.navigationContext == nil {
            
            self.navigationContext = NavigationContext.init()
            self.navigationContext?.delegate = self
            self.navigationContext?.setTransportMode(.bicycle)
        }
        
        let startPoints: [LandmarkObject] = [
            // LandmarkObject.landmark(withName: "Brasov", location: GeoLocation.coordinates(withLatitude: 45.6427, longitude: 25.5887))
        ]
        
        let endPoints: [LandmarkObject] = [
            // LandmarkObject.landmark(withName: "Sinaia", location: GeoLocation.coordinates(withLatitude: 45.3310, longitude: 25.5624))
        ]
        
        item.isEnabled = false
        
        self.navigationContext?.calculateRoute(withStartWaypoints: startPoints, buffer: data, endWaypoints: endPoints, completionHandler: { [weak self] (results: [RouteObject]) in
            
            guard let strongSelf = self else { return }
            
            NSLog("Found %d routes.", results.count)
            
            for route in results {
                
                if let timeDuration = route.getTimeDistance() {
                    
                    let time     = timeDuration.getTotalTimeFormatted() + timeDuration.getTotalTimeUnitFormatted()
                    let distance = timeDuration.getTotalDistanceFormatted() + timeDuration.getTotalDistanceUnitFormatted()
                    
                    NSLog("route time:%@, distance:%@", time, distance)
                }
            }
            
            if results.count > 0 {
                
                strongSelf.mainRoute = results.first
                
                let insets = strongSelf.areaEdge(margin: 70)
                
                strongSelf.mapViewController?.setEdgeAreaInsets(insets)

                strongSelf.mapViewController?.presentRoutes(results, withTraffic: nil, showSummary: true, animationDuration: 1000)
            }
            
            item.isEnabled = true
        })
    }
    
    @objc func startSimulation(item: UIBarButtonItem) {
        
        guard self.mainRoute != nil else { return }
        
        self.mapViewController!.removeAllRoutes()
        
        self.navigationContext!.simulateRoute(withRoute: self.mainRoute!, speedMultiplier: 2) { [weak self] (success) in
            
            guard let strongSelf = self else { return }
            
            if success {
                
                strongSelf.mapViewController!.showRoutes([strongSelf.mainRoute!], withTraffic: nil, showSummary: false)
            }
        }
    }
    
    @objc func clearRouteButtonAction(item: UIBarButtonItem) {
        
        self.mainRoute = nil
        
        self.mapViewController?.stopFollowingPosition()
        
        self.navigationContext!.cancelSimulateRoute()
        self.mapViewController?.removeAllRoutes()
    }
    
    // MARK: - NavigationContextDelegate
    
    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationStatusChanged status: NavigationStatus) {
        
    }
    
    func navigationContext(_ navigationContext: NavigationContext, navigationStartedForRoute route: RouteObject) {
                
        if self.mapViewController!.isFollowingPosition() == false {
            
            self.mapViewController!.startFollowingPosition(withAnimationDuration: 1600, zoomLevel: -1) { (success: Bool) in }
        }
    }
    
    func navigationContext(_ navigationContext: NavigationContext, navigationInstructionUpdatedForRoute route: RouteObject) {
        
    }
    
    func navigationContext(_ navigationContext: NavigationContext, navigationRouteUpdated route: RouteObject) {
        
    }
    
    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationWaypointReached waypoint: LandmarkObject) {
        
    }
    
    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationDestinationReached waypoint: LandmarkObject) {
                
    }
    
    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationError code: Int) {
        
    }
    
    func navigationContext(_ navigationContext: NavigationContext, canPlayNavigationSoundForRoute route: RouteObject) -> Bool {
        
        return false
    }
    
    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationSound sound: SoundObject) {
        
    }

    func navigationContext(_ navigationContext: NavigationContext, onBetterRouteDetected route: RouteObject, travelTime: Int, delay: Int, timeGain: Int) {

    }
    
    func navigationContext(_ navigationContext: NavigationContext, onBetterRouteInvalidated state: Bool) {
        
    }
    
    // MARK: - Utils
    
    func areaEdge(margin: CGFloat) -> UIEdgeInsets {
        
        let scale = UIScreen.main.scale
        
        let insets = UIEdgeInsets.init(top: (self.view.safeAreaInsets.top + margin) * scale,
                                       left: margin * scale,
                                       bottom: self.view.safeAreaInsets.bottom * scale,
                                       right: margin * scale)
        
        return insets
    }
}
