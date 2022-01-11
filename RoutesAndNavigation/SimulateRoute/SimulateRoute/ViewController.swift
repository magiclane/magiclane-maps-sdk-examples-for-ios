// Copyright (C) 2019-2022, General Magic B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of General Magic
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with General Magic.

import UIKit
import GEMKit

class ViewController: UIViewController, MapViewControllerDelegate, NavigationContextDelegate {
    
    var mapViewController: MapViewController?
    
    var navigationContext: NavigationContext?
    var soundContext: SoundContext?
    var trafficContext: TrafficContext?
    var alarmContext: AlarmContext?
    
    var mainRoute: RouteObject?
    var myResults: [RouteObject] = []
    
    var departure: LandmarkObject?
    var destination: LandmarkObject?
    
    var label = UILabel.init()
    
    var panelNavigationViewController: NavigationViewController?
    
    var roadBlockButton: UIButton?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let navigationController = self.navigationController {
            
            let appearance = navigationController.navigationBar.standardAppearance
            
            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }
        
        self.title = "Simulate Route"
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.createMapView()
        
        self.mapViewController!.startRender()
        
        self.addRouteButton()
        self.addLabelText()
        self.addInfoButton()
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
        let barButton1 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(routeButtonAction(item:)))

        image = UIImage.init(systemName: "clear")
        let barButton2 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(clearButtonAction))
        
        image = UIImage.init(systemName: "play")
        let barButton3 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(startSimulation(item:)))
        
        self.navigationItem.rightBarButtonItems = [barButton1, barButton2, barButton3]
    }
    
    @objc func stopButtonAction() {
        
        guard self.panelNavigationViewController != nil else { return }
        
        self.mapViewController!.stopFollowingPosition()
        
        self.navigationContext!.cancelSimulateRoute()
        
        self.clearButtonAction()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.panelNavigationViewController?.removeFromParent()
        self.panelNavigationViewController?.view.removeFromSuperview()
        self.panelNavigationViewController?.didMove(toParent: nil)
        
        self.panelNavigationViewController = nil
        
        self.mapViewController!.showCompass()
        
        self.mapViewController!.setPerspective(.view2D, animationDuration: 600) { (success) in
            
            DispatchQueue.main.async {
                
                self.mapViewController!.alignNorthUp(withAnimationDuration: 1200) { (success) in }
            }
        }
    }
    
    func addInfoButton() {
        
        let button = UIButton.init(type: .system)
        button.isHidden = true
        button.addTarget(self, action: #selector(infoButtonAction), for: .touchUpInside)
        button.backgroundColor = UIColor.systemBackground
        button.tintColor = UIColor.red
        
        if let image = UIImage.init(systemName: "hand.raised.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize:20)) {
            
            button.setImage(image, for: .normal)
        }
        
        let size: CGFloat = 50;
        
        button.layer.cornerRadius = size / 2.0
        button.layer.shadowOpacity = 0.8
        button.layer.shadowColor = UIColor.lightGray.cgColor
        
        self.view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        let constraintLeft = NSLayoutConstraint( item: button, attribute: NSLayoutConstraint.Attribute.leading,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading,
                                                 multiplier: 1.0, constant: 10)
        
        let constraintBottom = NSLayoutConstraint( item: button, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: self.label, attribute: NSLayoutConstraint.Attribute.top,
                                                   multiplier: 1.0, constant: -10)
        
        let constraintWidth = NSLayoutConstraint( item: button, attribute: NSLayoutConstraint.Attribute.width,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                  multiplier: 1.0, constant: size)
        
        let constraintHeight = NSLayoutConstraint( item: button, attribute: NSLayoutConstraint.Attribute.height,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                   multiplier: 1.0, constant: size)
        
        NSLayoutConstraint.activate([constraintLeft, constraintBottom, constraintWidth, constraintHeight])
        
        self.roadBlockButton = button
    }
    
    @objc func infoButtonAction() {
        
        guard let navigationContext = self.navigationContext else { return }
        
        if navigationContext.isSimulationActive() || navigationContext.isNavigationActive() {
            
            let length = 100 //m
            
            navigationContext.setRoadBlockWithLength(length, starting: -1)
        }
    }
    
    // MARK: - Label
    
    func addLabelText() {
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(startFollowLocation))
        
        self.label.font = UIFont.boldSystemFont(ofSize: 20)
        self.label.numberOfLines = 0
        self.label.backgroundColor = UIColor.white
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
    
    @objc func startFollowLocation() {
        
        self.mapViewController!.startFollowingPosition(withAnimationDuration: 1000, zoomLevel: -1) { (success: Bool) in }
    }
    
    @objc func routeButtonAction(item: UIBarButtonItem) {
        
        if self.navigationContext == nil {
            
            let preferences = RoutePreferencesObject.init()
            preferences.setTransportMode(.car)
            preferences.setRouteType(.fastest)
            preferences.setAvoidMotorways(false)
            preferences.setAvoidTollRoads(false)
            preferences.setAvoidFerries(false)
            preferences.setAvoidUnpavedRoads(true)
            
            self.navigationContext = NavigationContext.init(preferences: preferences)
            self.navigationContext?.delegate = self
        }
        
        if self.trafficContext == nil {
            
            self.trafficContext = TrafficContext.init()
            self.trafficContext?.setUseTraffic(.useOnline)
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
        
        // self.departure   = LandmarkObject.landmark(withName: "San Francisco", location: GeoLocation.coordinates(withLatitude: 37.77903, longitude: -122.41991) )
        // self.destination = LandmarkObject.landmark(withName: "San Jose",      location: GeoLocation.coordinates(withLatitude: 37.33619, longitude: -121.89058) )
        
        self.departure   = LandmarkObject.landmark(withName: "Munich 1", location: GeoLocation.coordinates(withLatitude: 48.15741,  longitude: 11.53739))
        self.destination = LandmarkObject.landmark(withName: "Munich 2", location: GeoLocation.coordinates(withLatitude: 48.166730, longitude: 11.53687))
        
        // self.departure = LandmarkObject.landmark(withName: "London 1", location: GeoLocation.coordinates(withLatitude: 51.53998, longitude: -0.1387) )
        // self.destination = LandmarkObject.landmark(withName: "London 2", location: GeoLocation.coordinates(withLatitude: 51.66105, longitude: -0.1687) )
        
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
                
                self.mapViewController!.setEdgeAreaInsets(self.areaEdge(margin: 15))
                
                strongSelf.mapViewController?.presentRoutes(results, withTraffic: strongSelf.trafficContext, showSummary: true, animationDuration: 1000)
            }
            
            item.isEnabled = true
        })
    }
    
    @objc func clearButtonAction() {
        
        self.mainRoute = nil
        
        self.mapViewController?.removeHighlights()
        
        self.mapViewController?.removeAllRoutes()
        
        self.label.isHidden = true
        self.roadBlockButton!.isHidden = true
    }
    
    @objc func startSimulation(item: UIBarButtonItem) {
        
        guard self.mainRoute != nil else { return }
        
        self.mapViewController!.removeAllRoutes()
        
        self.navigationContext!.simulate(withRoute: self.mainRoute!, speedMultiplier: 2) { [weak self] (success) in
            
            guard let strongSelf = self else { return }
            
            if success {
                
                strongSelf.mapViewController!.hideCompass()
                
                strongSelf.mapViewController!.presentRoutes([strongSelf.mainRoute!], withTraffic: strongSelf.trafficContext!, showSummary: false, animationDuration: 1600)
            }
        }
    }
    
    // MARK: - MapViewControllerDelegate
    
    func mapViewController(_ mapViewController: MapViewController, didSelectRoute route: RouteObject) {
        
        self.mainRoute = route
        
        mapViewController.setMainRoute(route)
    }
    
    // MARK: - NavigationContextDelegate
    
    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationStatusChanged status: NavigationStatus) {
        
    }
    
    func navigationContext(_ navigationContext: NavigationContext, navigationStartedForRoute route: RouteObject) {
        
        self.mapViewController!.startFollowingPosition(withAnimationDuration: 1200, zoomLevel: -1) { (success: Bool) in }
    }
    
    func navigationContext(_ navigationContext: NavigationContext, navigationInstructionUpdatedForRoute route: RouteObject) {
        
        let eta = navigationContext.getEstimateTimeOfArrivalFormatted() + navigationContext.getEstimateTimeOfArrivalUnitFormatted()
        
        let rtt = navigationContext.getRemainingTravelTimeFormatted() + navigationContext.getRemainingTravelTimeUnitFormatted()
        
        let rtd = navigationContext.getRemainingTravelDistanceFormatted() + navigationContext.getRemainingTravelDistanceUnitFormatted()
        
        // NSLog("Navigation: refresh: eta:%@, rtt:%@, rtd:%@", eta, rtt, rtd)
        
        let text = eta + "     " + rtt + "     " + rtd
        
        self.label.text = text
        self.label.isHidden = false
        self.roadBlockButton!.isHidden = false
        
        if !self.navigationController!.isNavigationBarHidden {
            
            if self.panelNavigationViewController == nil {
                
                self.createNavigationPanel()
            }
            
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        
        if let turnInstruction = navigationContext.getNavigationInstruction(), turnInstruction.getNavigationStatus() == .running {
            
            if turnInstruction.hasNextTurnInfo() {
                
                self.panelNavigationViewController?.updateTurnInformation(navigationContext: navigationContext)
                
                self.panelNavigationViewController?.updateLaneInformation(navigationContext: navigationContext)
                
                self.panelNavigationViewController?.updateTrafficInformation(navigationContext: navigationContext, route: route)
                
                self.panelNavigationViewController?.updateSignpostInformation(navigationContext: navigationContext)
                
                self.panelNavigationViewController?.updateRoadCodeInformation(navigationContext: navigationContext)
                
                self.panelNavigationViewController?.updateSafetyCameraInformation(navigationContext: navigationContext, alarmContext: self.alarmContext!)
                
                self.panelNavigationViewController?.updateSocialReportInformation(navigationContext: navigationContext, alarmContext: self.alarmContext!)
                
                self.panelNavigationViewController?.refreshContentLayout()
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
        
        // NSLog("NavigationContext: navigationSound text:%@", text)
        
        if let context = self.soundContext {
            
            context.playSound(sound)
        }
    }
    
    func navigationContext(_ navigationContext: NavigationContext, onBetterRouteDetected route: RouteObject, travelTime: Int, delay: Int, timeGain: Int) {
        
    }
    
    func navigationContext(_ navigationContext: NavigationContext, onBetterRouteInvalidated state: Bool) {
        
    }
    
    // MARK: - Navigation Panel
    
    func createNavigationPanel() {
        
        self.panelNavigationViewController = NavigationViewController.init()
        self.panelNavigationViewController!.stopButton.addTarget(self, action: #selector(stopButtonAction), for: .touchUpInside)
        
        self.addChild(self.panelNavigationViewController!)
        self.view.addSubview(self.panelNavigationViewController!.view)
        self.panelNavigationViewController!.didMove(toParent: self)
        
        let height = self.panelNavigationViewController!.viewHeight()
        
        self.panelNavigationViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        let constraintTop = NSLayoutConstraint( item: self.panelNavigationViewController!.view!, attribute: NSLayoutConstraint.Attribute.top,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self.view.safeAreaLayoutGuide, attribute: NSLayoutConstraint.Attribute.top,
                                                multiplier: 1.0, constant: 5.0)
        
        let constraintLeft = NSLayoutConstraint(item: self.panelNavigationViewController!.view!, attribute: NSLayoutConstraint.Attribute.leading,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading,
                                                multiplier: 1.0, constant: 10.0)
        
        let constraintRight = NSLayoutConstraint( item: self.panelNavigationViewController!.view!, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  multiplier: 1.0, constant: -10.0)
        
        let constraintHeight = NSLayoutConstraint( item: self.panelNavigationViewController!.view!, attribute: NSLayoutConstraint.Attribute.height,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                   multiplier: 1.0, constant: height)
        
        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintRight, constraintHeight])
    }
    
    func areaEdge(margin: CGFloat) -> UIEdgeInsets {
        
        let scale = UIScreen.main.scale
        
        let insets = UIEdgeInsets.init(top: (self.view.safeAreaInsets.top + margin) * scale,
                                       left: margin * scale,
                                       bottom: self.view.safeAreaInsets.bottom * scale,
                                       right: margin * scale)
        
        return insets
    }
}
