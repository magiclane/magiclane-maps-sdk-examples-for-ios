// Copyright (C) 2019-2023, Magic Lane B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of Magic Lane
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with Magic Lane.

import UIKit
import GEMKit

let bottomViewHeight: CGFloat = 390.0

class ViewController: UIViewController, UISearchBarDelegate, MapViewControllerDelegate {
    
    var mapViewController: MapViewController?
    
    var navigationContext: NavigationContext?
    
    var trafficContext: TrafficContext?
    
    var routeProfileViewController: RouteProfileViewController?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let navigationController = self.navigationController {
            
            let appearance = navigationController.navigationBar.standardAppearance
            
            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }
        
        self.title = "Route Profile"
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.createMapView()
        
        self.addButtons()
        
        self.mapViewController!.startRender()
        
        self.setCustomStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        let location = CoordinatesObject.coordinates(withLatitude: 46.559458, longitude: 7.892932) // Murren
        
        self.mapViewController!.center(onCoordinates: location, zoomLevel: 55, animationDuration: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
    }
    
    // MARK: - Map View

    func createMapView() {

        self.mapViewController = MapViewController.init()
        self.mapViewController!.view.backgroundColor = UIColor.systemBackground
        self.mapViewController!.delegate = self

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
    
    // MARK: - MapViewControllerDelegate
    
    func mapViewController(_ mapViewController: MapViewController, didSelectRoute route: RouteObject) {
        
        mapViewController.setMainRoute(route)
        
        if let routeProfileViewController = self.routeProfileViewController {
            
            routeProfileViewController.refreshWithRoute(route)
        }
    }
    
    func mapViewController(_ mapViewController: MapViewController, onMove startPoint: CGPoint, to endPoint: CGPoint) {
        
    }
    
    func mapViewController(_ mapViewController: MapViewController, onPinch startPoint1: CGPoint, startPoint2: CGPoint,
                           toPoint1 endPoint1: CGPoint, toPoint2 endPoint2: CGPoint,
                           center: CGPoint) {
        
        if let routeProfileViewController = self.routeProfileViewController {
            
            routeProfileViewController.onMapZoomed()
        }
    }
    
    // MARK: - Utils
    
    func centerPresentedRoutes() {
        
        guard let mapViewController = self.mapViewController else { return }
        
        let routes = mapViewController.getPresentedRoutes()
        
        if routes.count > 0 {
            
            mapViewController.stopFollowingPosition()
            
            let insets = self.areaEdge(margin: 70)
            
            mapViewController.setEdgeAreaInsets(insets)
            
            mapViewController.center(onRoutes: routes, displayMode: .full, animationDuration: 1400)
        }
    }
    
    func addButtons() {
        
        var image = UIImage.init(systemName: "point.topleft.down.curvedto.point.bottomright.up")
        let barButton1 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(routeButtonAction(item:)))

        image = UIImage.init(systemName: "clear")
        let barButton2 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(clearRouteButtonAction(item:)))
        
        self.navigationItem.rightBarButtonItems = [barButton1, barButton2]
    }
    
    @objc func routeButtonAction(item: UIBarButtonItem) {
        
        if self.navigationContext == nil {
            
            let preferences = RoutePreferencesObject.init()
            preferences.setTransportMode(.pedestrian)
            preferences.setRouteType(.fastest)
            preferences.setBuildTerrainProfile(true)
            
            self.navigationContext = NavigationContext.init(preferences: preferences)
        }
        
        if self.trafficContext == nil {
            
            self.trafficContext = TrafficContext.init()
            self.trafficContext?.setUseTraffic(.useOnline)
        }
        
        
        
        let waypoints = [
            
            LandmarkObject.landmark(withName: "Murren 1", location: CoordinatesObject.coordinates(withLatitude: 46.593443, longitude: 7.910699) ),
            LandmarkObject.landmark(withName: "Murren 2", location: CoordinatesObject.coordinates(withLatitude: 46.559458, longitude: 7.892932) )
        ];
        
        item.isEnabled = false
        
        weak var weakSelf = self
        
        self.navigationContext?.calculateRoute(withWaypoints: waypoints, completionHandler: { (results: [RouteObject]) in
            
            guard let strongSelf = weakSelf else { return }
            
            NSLog("Found %d routes.", results.count)
            
            for route in results {
                
                if let timeDuration = route.getTimeDistance() {
                    
                    let time     = timeDuration.getTotalTimeFormatted() + timeDuration.getTotalTimeUnitFormatted()
                    let distance = timeDuration.getTotalDistanceFormatted() + timeDuration.getTotalDistanceUnitFormatted()
                    
                    NSLog("route time:%@, distance:%@", time, distance)
                }
            }
            
            if results.count > 0 {
                
                let insets = strongSelf.areaEdge(margin: 70)
                
                // strongSelf.mapViewController?.setDebugEdgeAreaVisible(true)
                strongSelf.mapViewController?.setEdgeAreaInsets(insets)
                
                strongSelf.mapViewController?.presentRoutes(results, withTraffic: self.trafficContext, showSummary: true, animationDuration: 1600)
                
                strongSelf.showRouteProfile()
            }
            
            item.isEnabled = true
        })
    }
    
    func showRouteProfile() {
        
        guard let mapViewController = self.mapViewController else { return }
        
        guard self.routeProfileViewController == nil else { return }
        
        let route = mapViewController.getMainRoute()
        
        self.routeProfileViewController = RouteProfileViewController()
        self.routeProfileViewController!.mapViewController = mapViewController
        self.routeProfileViewController!.route = route
        
        self.mapViewController!.addChild(self.routeProfileViewController!)
        self.mapViewController!.view.addSubview(self.routeProfileViewController!.view)
        self.routeProfileViewController!.didMove(toParent: self.mapViewController!)
        
        self.routeProfileViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        let constraintLeft = NSLayoutConstraint( item: self.routeProfileViewController!.view!, attribute: NSLayoutConstraint.Attribute.leading,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading,
                                                 multiplier: 1.0, constant: 0.0)
        
        let constraintRight = NSLayoutConstraint( item: self.routeProfileViewController!.view!, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  multiplier: 1.0, constant: -0.0)
        
        let constraintBottom = NSLayoutConstraint( item: self.routeProfileViewController!.view!, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: self.view, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   multiplier: 1.0, constant: -0.0)
        
        let constraintHeight = NSLayoutConstraint( item: self.routeProfileViewController!.view!, attribute: NSLayoutConstraint.Attribute.height,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                   multiplier: 1.0, constant: bottomViewHeight)
        
        NSLayoutConstraint.activate([constraintLeft, constraintRight, constraintBottom, constraintHeight])
    }
    
    @objc func clearRouteButtonAction(item: UIBarButtonItem) {
        
        guard let mapViewController = self.mapViewController else { return }
        
        mapViewController.removeAllRoutes()
        
        if let routeProfileViewController = self.routeProfileViewController {
                        
            routeProfileViewController.clean()
            
            routeProfileViewController.willMove(toParent: nil)
            routeProfileViewController.view.removeFromSuperview()
            routeProfileViewController.removeFromParent()
        }
        
        self.routeProfileViewController = nil
    }
    
    func areaEdge(margin: CGFloat) -> UIEdgeInsets {
        
        let scale = UIScreen.main.scale
        
        let insets = UIEdgeInsets.init(top: (self.view.safeAreaInsets.top + margin) * scale,
                                       left: margin * scale,
                                       bottom: (self.view.safeAreaInsets.bottom + bottomViewHeight) * scale,
                                       right: margin * scale)
        
        return insets
    }
    
    func setCustomStyle() {
        
//        if let url = Bundle.main.url(forResource: "Basic_1_Modern_with_Elevation", withExtension: "style") {
//
//            if let data = NSData.init(contentsOf: url) as Data? {
//
//                self.mapViewController!.applyStyle(withStyleBuffer: data, smoothTransition: false)
//            }
//        }
    }
}

