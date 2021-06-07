// Copyright (C) 2019-2021, General Magic B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of General Magic
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with General Magic.

import UIKit
import GEMKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MapViewControllerDelegate, NavigationContextDelegate  {
    
    var mapViewController: MapViewController?
    
    var locationManager: CLLocationManager?
    
    var navigationContext: NavigationContext?
    var trafficContext: TrafficContext?
    var mainRoute: RouteObject?
    var myResults: [RouteObject] = []
    var departure: LandmarkObject?
    var destination: LandmarkObject?
    var positionContext: PositionContext?
    var soundContext: SoundContext?
    var alarmContext: AlarmContext?
    
    var label = UILabel.init()
    
    var navigationViewController: NavigationViewController?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "Navigate Route"
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.createMapView()
        
        self.mapViewController!.startRender()
        
        self.addLocationButton()
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
    
    func addLocationButton() {
        
        if self.locationManager == nil {
            
            self.locationManager = CLLocationManager.init()
            self.locationManager!.delegate = self
        }
        
        var image = UIImage.init(systemName: "location")
        
        if self.isLocationAvailable() == false {
            
            image = UIImage.init(systemName: "location.slash")
        }
        
        let barButton = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(startFollowLocation))
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    @objc func startFollowLocation() {
        
        if self.isLocationAvailable() == false {
            
            self.requestLocationPermission()
            
        } else {
            
            self.addRouteButton()
            
            self.mapViewController!.startFollowingPosition(withAnimationDuration: 1000) { success in }
        }
    }
    
    func isLocationAvailable() -> Bool {
        
        return (self.locationManager!.authorizationStatus == .authorizedWhenInUse)
    }
    
    func requestLocationPermission() {
        
        if self.locationManager!.authorizationStatus == .notDetermined {
            
            self.locationManager!.requestWhenInUseAuthorization()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        if manager.authorizationStatus == .authorizedWhenInUse {
            
            self.startFollowLocation()
            
        } else {
            
            self.addLocationButton()
        }
    }
    
    func addRouteButton() {
        
        var image = UIImage.init(systemName: "point.topleft.down.curvedto.point.bottomright.up")
        let barButton1 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(routeButtonAction(item:)))
        
        image = UIImage.init(systemName: "clear")
        let barButton2 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(clearRouteButtonAction(item:)))
        
        image = UIImage.init(systemName: "play")
        let barButton3 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(startStopNavigation(item:)))
        
        self.navigationItem.rightBarButtonItems = [barButton1, barButton2, barButton3]
    }
    
    // MARK: - Label
    
    func addLabelText() {
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(startFollowLocation))
        
        self.label.font = UIFont.boldSystemFont(ofSize: 20)
        self.label.numberOfLines = 0
        self.label.backgroundColor = UIColor.systemBackground
        self.label.isHidden = true
        self.label.textAlignment = .center
        self.label.isUserInteractionEnabled = true
        self.label.addGestureRecognizer(tapGesture)
        
        self.label.layer.borderColor = UIColor.systemBlue.cgColor
        self.label.layer.borderWidth = 1.4
        self.label.layer.cornerRadius = 8.0
        self.label.layer.masksToBounds = true
         
        self.view.addSubview(self.label)
        
        self.label.translatesAutoresizingMaskIntoConstraints = false
        let constraintLeft = NSLayoutConstraint( item: self.label, attribute: NSLayoutConstraint.Attribute.leading,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading,
                                                 multiplier: 1.0, constant: 10.0)
        
        let constraintBottom = NSLayoutConstraint( item: self.label, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: self.view.safeAreaLayoutGuide, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   multiplier: 1.0, constant: -10.0)
        
        let constraintRight = NSLayoutConstraint( item: self.label, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  multiplier: 1.0, constant: -10.0)
        
        let constraintHeight = NSLayoutConstraint( item: self.label, attribute: NSLayoutConstraint.Attribute.height,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                   multiplier: 1.0, constant: 54.0)
        
        NSLayoutConstraint.activate([constraintLeft, constraintBottom, constraintRight, constraintHeight])
    }
    
    @objc func stopButtonAction() {
        
        if let array = self.navigationItem.rightBarButtonItems, array.count > 1 {
            
            let item = array[2]
            
            self.startStopNavigation(item: item)
        }
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
        
        if self.trafficContext == nil {
            
            self.trafficContext = TrafficContext.init()
            self.trafficContext?.setUseTraffic(.useOnline)
        }
        
        if self.positionContext == nil {
            
            self.positionContext = PositionContext.init()
        }
        
        if self.soundContext == nil {
            
            self.soundContext = SoundContext.init()            
            self.soundContext?.setUseTtsWithCompletionHandler({ success in })
        }
        
        if self.alarmContext == nil {
            
            self.alarmContext = AlarmContext.init()
            self.alarmContext?.setAlarmDistance(600)
            self.alarmContext?.setMonitorWithoutRoute(false)
            
            self.alarmContext?.registerSafetyCameraNotifications(completionHandler: { success in
                
                NSLog("AlarmContext: registerSafetyCamera with success:%@", String(success))
            })
            
            self.alarmContext?.registerSocialReportNotifications(completionHandler: { success in
                
                NSLog("AlarmContext: registerSafetyCamera with success:%@", String(success))
            })
        }
        
        guard let location = self.positionContext!.getPosition().getPositionGeoLocation() else { return }
        
        self.departure = LandmarkObject.landmark(withName: "My Position", location: location)
        
        guard let start = self.departure, let stop = self.destination else {
            return
        }
        
        let waypoints = [ start, stop];
        
        item.isEnabled = false
        
        weak var weakSelf = self
        
        self.navigationContext?.calculateRoute(withWaypoints: waypoints, completionHandler: { (results: [RouteObject]) in
            
            guard let strongSelf = weakSelf else { return }
            
            NSLog("Found %d routes.", results.count)
            
            strongSelf.myResults = results
            
            for route in results {
                
                if let timeDuration = route.getTimeDistance() {
                    
                    let time     = timeDuration.getTotalTimeFormatted() + timeDuration.getTotalTimeUnitFormatted()
                    let distance = timeDuration.getTotalDistanceFormatted() + timeDuration.getTotalDistanceUnitFormatted()
                    
                    NSLog("route time:%@, distance:%@", time, distance)
                }
            }
            
            if results.count > 0 {
                
                strongSelf.mainRoute = results.first
                
                strongSelf.mapViewController?.presentRoutes(results, withTraffic: strongSelf.trafficContext, showSummary: true, animationDuration: 1000)
            }
            
            item.isEnabled = true
        })
    }
    
    @objc func clearRouteButtonAction(item: UIBarButtonItem) {
        
        self.mapViewController!.removeHighlights()
        
        self.mapViewController?.removeAllRoutes()
        
        self.destination = nil
        
        self.mainRoute = nil
    }
    
    @objc func startStopNavigation(item: UIBarButtonItem) {
        
        for route in self.myResults {
            
            if self.mapViewController!.isMainRoute(route) == false {
                
                self.mapViewController!.removeRoutes([route])
            }
        }
        
        self.myResults = []
        
        guard self.mainRoute != nil else {
            return
        }
        
        if self.navigationContext!.isNavigationActive() {
            
            let image = UIImage.init(systemName: "play")
            item.image = image
            
            self.label.isHidden = true
            self.label.removeFromSuperview()
            
            self.navigationContext!.cancelNavigateRoute()
            
            self.mapViewController!.stopFollowingPosition()
            
            self.mapViewController!.removeRoutes([self.mainRoute!])
            
            self.destination = nil
            
            self.mainRoute = nil
            
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            
            self.navigationViewController?.removeFromParent()
            self.navigationViewController?.view.removeFromSuperview()
            self.navigationViewController?.didMove(toParent: nil)
            
            self.navigationViewController = nil
            
        } else {
            
            let image = UIImage.init(systemName: "stop")
            item.image = image
            
            self.navigationContext!.navigateRoute(withRoute: self.mainRoute!) { [weak self] (success) in
                
                guard let strongSelf = self else {
                    return
                }
                
                NSLog("Navigation Route started with success:%@", String(success))
                
                if success {
                    
                    strongSelf.addLabelText()
                    
                    strongSelf.mapViewController!.hideSummary(for: [strongSelf.mainRoute!])
                }
            }
        }
    }
    
    // MARK: - MapViewControllerDelegate
    
    func mapViewController(_ mapViewController: MapViewController, didSelectLandmark landmark: LandmarkObject, onTouch point: CGPoint) {
        
        guard self.mainRoute == nil else {
            return
        }
        
        self.destination = landmark
        
        self.showLandmark(landmark: landmark)
    }
    
    func mapViewController(_ mapViewController: MapViewController, didSelectLandmark landmark: LandmarkObject, onLongTouch point: CGPoint) {
        
        guard self.mainRoute == nil else {
            return
        }
        
        self.destination = landmark
        
        self.showLandmark(landmark: landmark)
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
        
        self.mapViewController!.startFollowingPosition(withAnimationDuration: 1200) { (success: Bool) in }
    }
    
    func navigationContext(_ navigationContext: NavigationContext, navigationInstructionUpdatedForRoute route: RouteObject) {
        
        let eta = navigationContext.getEstimateTimeOfArrivalFormatted() + navigationContext.getEstimateTimeOfArrivalUnitFormatted()
        
        let rtt = navigationContext.getRemainingTravelTimeFormatted() + navigationContext.getRemainingTravelTimeUnitFormatted()
        
        let rtd = navigationContext.getRemainingTravelDistanceFormatted() + navigationContext.getRemainingTravelDistanceUnitFormatted()
        
        // NSLog("Navigation: refresh: eta:%@, rtt:%@, rtd:%@", eta, rtt, rtd)
        
        let text = eta + "     " + rtt + "     " + rtd
        
        self.label.text = text
        self.label.isHidden = false
        
        if !self.navigationController!.isNavigationBarHidden {
            
            if self.navigationViewController == nil {
                
                self.createNavigationPanel()
            }
            
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        
        if let turnInstruction = navigationContext.getNavigationInstruction(), turnInstruction.getNavigationStatus() == .running {
            
            if turnInstruction.hasNextTurnInfo() {
                
                self.navigationViewController?.updateTurnInformation(navigationContext: navigationContext)
                
                self.navigationViewController?.updateLaneInformation(navigationContext: navigationContext)
                
                self.navigationViewController?.updateTrafficInformation(navigationContext: navigationContext, route: route)
                
                self.navigationViewController?.updateSignpostInformation(navigationContext: navigationContext)
                
                self.navigationViewController?.updateRoadCodeInformation(navigationContext: navigationContext)
                
                self.navigationViewController?.updateSafetyCameraInformation(navigationContext: navigationContext, alarmContext: self.alarmContext!)
                
                self.navigationViewController?.updateSocialReportInformation(navigationContext: navigationContext, alarmContext: self.alarmContext!)
                
                self.navigationViewController?.refreshContentLayout()
            }
        }
    }
    
    func navigationContext(_ navigationContext: NavigationContext, navigationRouteUpdated route: RouteObject) {
        
    }
    
    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationWaypointReached waypoint: LandmarkObject) {
        
    }
    
    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationDestinationReached waypoint: LandmarkObject) {
        
        self.stopButtonAction()
    }
    
    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationError code: Int) {
        
    }
    
    func navigationContext(_ navigationContext: NavigationContext, canPlayNavigationSoundForRoute route: RouteObject) -> Bool {
        
        return true
    }
    
    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationSound sound: SoundObject) {
        
        if let context = self.soundContext {
            
            context.playSound(sound)
        }
    }
    
    // MARK: - Navigation Panel
    
    func createNavigationPanel() {
        
        self.navigationViewController = NavigationViewController.init()
        self.navigationViewController!.stopButton.addTarget(self, action: #selector(stopButtonAction), for: .touchUpInside)
        
        self.addChild(self.navigationViewController!)
        self.view.addSubview(self.navigationViewController!.view)
        self.navigationViewController!.didMove(toParent: self)
        
        let height = self.navigationViewController!.viewHeight()
        
        self.navigationViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        let constraintTop = NSLayoutConstraint( item: self.navigationViewController!.view!, attribute: NSLayoutConstraint.Attribute.top,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self.view.safeAreaLayoutGuide, attribute: NSLayoutConstraint.Attribute.top,
                                                multiplier: 1.0, constant: 5.0)
        
        let constraintLeft = NSLayoutConstraint(item: self.navigationViewController!.view!, attribute: NSLayoutConstraint.Attribute.leading,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading,
                                                multiplier: 1.0, constant: 10.0)
        
        let constraintRight = NSLayoutConstraint( item: self.navigationViewController!.view!, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  multiplier: 1.0, constant: -10.0)
        
        let constraintHeight = NSLayoutConstraint( item: self.navigationViewController!.view!, attribute: NSLayoutConstraint.Attribute.height,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                   multiplier: 1.0, constant: height)
        
        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintRight, constraintHeight])
    }
    
    // MARK: - Utils
    
    func showLandmark(landmark: LandmarkObject) {
        
        let text = "  " + landmark.getLandmarkName() + "\n" + "  " + landmark.getLandmarkDescription()
        
        self.label.text = text
        self.label.isHidden = false
        
        self.mapViewController!.presentHighlight(landmark, contourColor: UIColor.systemBlue, centerLayout: true, animationDuration: 600)
    }
}
