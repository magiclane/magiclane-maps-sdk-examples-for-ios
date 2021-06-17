// Copyright (C) 2019-2021, General Magic B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of General Magic
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with General Magic.

import UIKit
import GEMKit

class ViewController: UIViewController, MapViewControllerDelegate, NavigationContextDelegate  {
    
    var mapViewController: MapViewController?
    
    var navigationContext: NavigationContext?
    
    var mainRoute: RouteObject?
    
    var myResults: [RouteObject] = []
    
    var searchContext: SearchContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
                
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.createMapView()

        self.mapViewController!.startRender()
        
        self.addRouteButton()
    }
    
    // MARK: - Map View

    func createMapView() {

        self.mapViewController = MapViewController.init()
        self.mapViewController!.delegate = self
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
    
    // MARK: - Buttons
    
    func addRouteButton() {
        
        var image = UIImage.init(systemName: "point.topleft.down.curvedto.point.bottomright.up")
        let barButton1 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(routeButtonAction))

        image = UIImage.init(systemName: "clear")
        let barButton2 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(clearRouteButtonAction))
        
        image = UIImage.init(systemName: "play")
        let barButton3 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(startStopSimulation(item:)))
        
        self.navigationItem.rightBarButtonItems = [barButton1, barButton2, barButton3]
    }
    
    @objc func routeButtonAction(item: UIBarButtonItem) {
        
        if self.navigationContext == nil {
            
            self.navigationContext = NavigationContext.init()
            self.navigationContext?.delegate = self
            
            // Settings
            self.navigationContext?.setTransportMode(.car)
            self.navigationContext?.setRouteType(.fastest)
            
            // Preferences
            self.navigationContext?.setAvoidMotorways(false)
            self.navigationContext?.setAvoidTollRoads(false)
            self.navigationContext?.setAvoidFerries(false)
            self.navigationContext?.setAvoidUnpavedRoads(true)
        }
        
        let waypoints = [
            
            LandmarkObject.landmark(withName: "San Francisco", location: GeoLocation.coordinates(withLatitude: 37.77903, longitude: -122.41991) ),
            LandmarkObject.landmark(withName: "San Jose",      location: GeoLocation.coordinates(withLatitude: 37.33619, longitude: -121.89058) )
        ];
        
        item.isEnabled = false
        
        weak var weakSelf = self
        
        self.navigationContext?.calculateRoute(withWaypoints: waypoints, completionHandler: { (results: [RouteObject]) in
            
            guard let strongSelf = weakSelf else { return }
            
            NSLog("Found %d routes.", results.count)
            
            strongSelf.myResults = results
            
            for route in results {
                
                if let timeDistance = route.getTimeDistance() {
                    
                    let time = timeDistance.getTotalTimeFormatted() + timeDistance.getTotalTimeUnitFormatted()
                    let distance = timeDistance.getTotalDistanceFormatted() + timeDistance.getTotalDistanceUnitFormatted()
                    
                    NSLog("route time:%@, distance:%@", time, distance)
                }
            }
            
            if results.count > 0 {
                
                strongSelf.mainRoute = results.first
                
                strongSelf.mapViewController?.presentRoutes(results, withTraffic: nil, showSummary: true, animationDuration: 1000)
            }
            
            item.isEnabled = true
        })
    }
    
    @objc func clearRouteButtonAction(item: UIBarButtonItem) {
        
        self.mapViewController?.removeAllRoutes()
    }
    
    @objc func startStopSimulation(item: UIBarButtonItem) {
        
        for route in self.myResults {
            
            if self.mapViewController!.isMainRoute(route) == false {
                
                self.mapViewController!.removeRoutes([route])
            }
        }
        
        self.myResults = []
        
        guard self.mainRoute != nil else {
            return
        }
        
        if self.navigationContext!.isSimulationActive() {
            
            let image = UIImage.init(systemName: "play")
            item.image = image
            
            self.navigationContext!.cancelSimulateRoute()
            
            self.mapViewController!.stopFollowingPosition()
            
            self.mapViewController!.removeRoutes([self.mainRoute!])
            
            self.mainRoute = nil
            
        } else {
            
            let image = UIImage.init(systemName: "stop")
            item.image = image
            
            self.navigationContext!.simulateRoute(withRoute: self.mainRoute!, speedMultiplier: 1) { [weak self] (success) in
                
                guard let strongSelf = self else { return }
                
                NSLog("Simulation Route started with success:%@", String(success))
                
                if success {
                    
                    strongSelf.addSearch()
                    
                    strongSelf.mapViewController!.hideSummary(for: [strongSelf.mainRoute!])
                }
            }
        }
    }
    
    func addSearch() {
        
        let image1 = UIImage.init(systemName: "magnifyingglass")
        
        let barButton1 = UIBarButtonItem.init(image: image1, style: .done, target: self, action: #selector(searchButton));
        
        self.navigationItem.leftBarButtonItems = [barButton1]
    }
    
    @objc func searchButton() {

        if self.searchContext == nil {
            
            self.searchContext = SearchContext.init()
            
            // Preferences
            self.searchContext?.setMaxMatches(20)
            self.searchContext?.setSearchMapPOIs(true)
            self.searchContext?.setSearchAddresses(true)
        }
        
        self.searchContext!.searchAlong(withRoute: self.mainRoute!, query: "Gas station") { (results: [LandmarkObject]) in
            
            for landmark in results {
                
                NSLog("results:%@", landmark.getLandmarkName())
            }
        }
    }
    
    // MARK: - MapViewControllerDelegate
    
    func mapViewController(_ mapViewController: MapViewController, didSelectLandmark landmark: LandmarkObject, onTouch point: CGPoint) {
        
    }
    
    func mapViewController(_ mapViewController: MapViewController, didSelectLandmark landmark: LandmarkObject, onLongTouch point: CGPoint) {
        
    }
    
    func mapViewController(_ mapViewController: MapViewController, didSelectRoute route: RouteObject) {
        
        self.mainRoute = route
        
        mapViewController.setMainRoute(route)
    }
    
    func mapViewController(_ mapViewController: MapViewController, didSelectStreets streets: [LandmarkObject]) {
        
    }
    
    func mapViewController(_ mapViewController: MapViewController, onTouch point: CGPoint) {
        
    }
    
    func mapViewController(_ mapViewController: MapViewController, onMove startPoint: CGPoint, to endPoint: CGPoint) {
        
    }

    // MARK: - NavigationContextDelegate
    
    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationStatusChanged status: NavigationStatus) {
        
        
    }
    
    func navigationContext(_ navigationContext: NavigationContext, navigationStartedForRoute route: RouteObject) {
        
        self.mapViewController!.startFollowingPosition(withAnimationDuration: 1200, zoomLevel: -1) { success in }
    }
    
    func navigationContext(_ navigationContext: NavigationContext, navigationInstructionUpdatedForRoute route: RouteObject) {
        
        let eta = navigationContext.getEstimateTimeOfArrivalFormatted() + navigationContext.getEstimateTimeOfArrivalUnitFormatted()
        
        let rtt = navigationContext.getRemainingTravelTimeFormatted() + navigationContext.getRemainingTravelTimeUnitFormatted()
        
        let rtd = navigationContext.getRemainingTravelDistanceFormatted() + navigationContext.getRemainingTravelDistanceUnitFormatted()
        
        NSLog("Navigation: refresh: eta:%@, rtt:%@, rtd:%@", eta, rtt, rtd)
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
}
