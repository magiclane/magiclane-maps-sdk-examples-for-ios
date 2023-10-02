// Copyright (C) 2019-2023, Magic Lane B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of Magic Lane
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with Magic Lane.

import UIKit
import GEMKit

class ViewController: UIViewController, MapViewControllerDelegate, NavigationContextDelegate {
    
    var mapViewController: MapViewController?
    
    var navigationContext: NavigationContext?
    var soundContext: SoundContext?
    var trafficContext: TrafficContext?
    
    var mainRoute: RouteObject?
    var myResults: [RouteObject] = []
    var betterRoute: RouteObject?
    var timeGainMinutes: UInt = 0
    
    var departure: LandmarkObject?
    var destination: LandmarkObject?
    
    var label = UILabel.init()
    
    var panelNavigationViewController: NavigationViewController?
        
    var myPositionButton: UIButton?
    var betterRouteButton: UIButton?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let navigationController = self.navigationController {
            
            let appearance = navigationController.navigationBar.standardAppearance
            
            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }
        
        self.title = ""
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.createMapView()
        
        self.mapViewController!.startRender()
        
        self.addRouteButton()
        self.addMyPositionButton()
        self.addLabelText()
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
        let barButton3 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(startSimulation))
        
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
        
        self.myPositionButton?.isHidden = true
        
        self.mapViewController!.setPerspective(.view2D, animationDuration: 600) { (success) in
            
            DispatchQueue.main.async {
                
                self.mapViewController!.alignNorthUp(withAnimationDuration: 1200) { (success) in }
            }
        }
    }
    
    func addMyPositionButton() {
        
        let button = UIButton.init(type: .system)
        button.addTarget(self, action: #selector(startFollowLocation), for: .touchUpInside)
        button.backgroundColor = UIColor.systemBackground
        button.isHidden = true
        
        if let image = UIImage.init(systemName: "location", withConfiguration: UIImage.SymbolConfiguration(pointSize:18)) {
            
            let img = image.withRenderingMode(.alwaysTemplate)
            
            button.setImage(img , for: .normal)
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
                                                   toItem: self.view.safeAreaLayoutGuide, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   multiplier: 1.0, constant: -15)
        
        let constraintWidth = NSLayoutConstraint( item: button, attribute: NSLayoutConstraint.Attribute.width,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                  multiplier: 1.0, constant: size)
        
        let constraintHeight = NSLayoutConstraint( item: button, attribute: NSLayoutConstraint.Attribute.height,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                   multiplier: 1.0, constant: size)
        
        NSLayoutConstraint.activate([constraintLeft, constraintBottom, constraintWidth, constraintHeight])
        
        self.myPositionButton = button
    }
    
    @objc func startFollowLocation() {
        
        if self.continueNavigationOnBetterRoute() {
            
            return
        }
        
        if self.mapViewController!.isFollowingPosition() == false {
            
            self.mapViewController!.startFollowingPosition(withAnimationDuration: 2200, zoomLevel: -1) { (success: Bool) in }
        }
    }
    
    // MARK: - Label
    
    func addLabelText() {
        
        self.label.font = UIFont.boldSystemFont(ofSize: 20)
        self.label.numberOfLines = 0
        self.label.backgroundColor = UIColor.white
        self.label.isHidden = true
        self.label.textAlignment = .center
        self.label.isUserInteractionEnabled = true
        
        self.label.layer.borderWidth = 1.4
        self.label.layer.cornerRadius = 8.0
        self.label.layer.masksToBounds = true
        
        self.view.addSubview(self.label)
        
        self.label.translatesAutoresizingMaskIntoConstraints = false
        let constraintLeft = NSLayoutConstraint( item: self.label, attribute: NSLayoutConstraint.Attribute.leading,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self.myPositionButton, attribute: NSLayoutConstraint.Attribute.trailing,
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
                                                  multiplier: 1.0, constant: 60.0)
        
        NSLayoutConstraint.activate([constraintLeft, constraintBottom, constraintRight, constraintHeight])
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
            preferences.setAvoidTraffic(true)
            
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
        
        self.departure   = LandmarkObject.landmark(withName: "Munich 1", location: CoordinatesObject.coordinates(withLatitude: 48.15741,  longitude: 11.53739))
        self.destination = LandmarkObject.landmark(withName: "Munich 2", location: CoordinatesObject.coordinates(withLatitude: 47.56730,  longitude: 11.03687))
        
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
                
                strongSelf.mapViewController?.presentRoutes(results, withTraffic: strongSelf.trafficContext, showSummary: true, animationDuration: 1600)
            }
            
            item.isEnabled = true
        })
    }
    
    @objc func clearButtonAction() {
        
        self.mainRoute = nil
        self.betterRoute = nil
        
        self.mapViewController?.removeHighlights()
        
        self.mapViewController?.removeAllRoutes()
        
        self.label.isHidden = true
    }
    
    @objc func startSimulation() {
        
        self.mainRoute = self.mapViewController!.getMainRoute()
        
        guard self.mainRoute != nil else { return }
        
        self.betterRoute = nil
        
        self.mapViewController!.removeAllRoutes()
        
        self.navigationContext!.simulate(withRoute: self.mainRoute!, speedMultiplier: 2) { [weak self] (success) in
            
            guard let strongSelf = self else { return }
            
            if success {
                
                strongSelf.myPositionButton?.isHidden = false
                
                strongSelf.mapViewController!.hideCompass()
                
                strongSelf.mapViewController!.presentRoutes([strongSelf.mainRoute!], withTraffic: strongSelf.trafficContext!, showSummary: false, animationDuration: 1600)
            }
        }
    }
    
    func presentBetterRouteButton() {
        
        guard self.betterRouteButton == nil else {
            return
        }
        
        let button = UIButton.init(type: .roundedRect)
        button.addTarget(self, action: #selector(betterRouteAction), for: .touchUpInside)
        button.backgroundColor = UIColor.systemGreen
        
        if let image = UIImage.init(systemName: "point.topleft.down.curvedto.point.bottomright.up", withConfiguration: UIImage.SymbolConfiguration(pointSize:20)) {
            
            let img = image.withRenderingMode(.alwaysTemplate)
            
            button.setImage(img, for: .normal)
            button.tintColor = UIColor.white
        }
        
        let size: CGFloat = 50;
        
        button.layer.cornerRadius = size / 2.0
        button.layer.shadowOpacity = 0.8
        button.layer.shadowColor = UIColor.lightGray.cgColor
        
        self.view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: self.myPositionButton!.leadingAnchor, constant: 0),
            button.bottomAnchor.constraint(equalTo: self.myPositionButton!.topAnchor, constant: -10.0),
            button.widthAnchor.constraint(equalToConstant: size),
            button.heightAnchor.constraint(equalToConstant: size)
        ])
        
        self.betterRouteButton = button
    }
        
    @objc func betterRouteAction() {
        
        guard self.mainRoute != nil else {
            return
        }

        guard self.betterRoute != nil else {
            return
        }

        self.panelNavigationViewController!.view.isHidden = true
        
        self.mapViewController!.stopFollowingPosition()
        self.mapViewController!.removeAllRoutes()
        self.mapViewController!.removeHighlights()
        self.mapViewController!.showCompass()
        
        self.mapViewController!.showRoutes([self.mainRoute!], withTraffic:self.trafficContext!, showSummary: true)
        self.mapViewController!.showBetterRoute(self.betterRoute!, withTraffic:self.trafficContext!, timeGain: self.timeGainMinutes, showSummary: true)
        self.mapViewController!.center(onRoutes: [self.mainRoute!, self.betterRoute!], displayMode: .branches, animationDuration: 1600)
        
        self.removeBetterRouteButton()
    }
    
    func removeBetterRouteButton() {
        
        guard self.betterRouteButton != nil else {
            return
        }
        
        let button = self.betterRouteButton
        
        UIView.animate(withDuration: 1.0, animations: {
            
            button?.alpha = 0
            
        }) { finished in
            
            button?.removeFromSuperview()
        }
        
        self.betterRouteButton = nil
    }
    
     func continueNavigationOnBetterRoute() -> Bool {
        
        guard self.mainRoute != nil else {
            return false
        }

        guard self.betterRoute != nil else {
            return false
        }
        
        guard let mainNavRoute = self.mapViewController!.getMainRoute() else {
            return false
        }
        
        self.panelNavigationViewController!.view.isHidden = false
        
        if mainNavRoute.isEqual(withRoute: self.betterRoute!) {
            
            // Better route selected. Start simulation is need it.
            
            self.mainRoute = mainNavRoute
            
            self.soundContext!.playText("You are on the fastest route.")
            
            self.betterRoute = nil
            
            self.startSimulation()
            
            return true
            
        } else {
            
            // Continue with current route.
            
            self.betterRoute = nil
            
            self.mapViewController!.removeAllRoutes()
            
            self.mapViewController!.showRoutes([self.mainRoute!], withTraffic:self.trafficContext!, showSummary: false)
            
            self.mapViewController!.hideCompass()
            
            return false
        }
    }
    
    // MARK: - MapViewControllerDelegate
    
    func mapViewController(_ mapViewController: MapViewController, didSelectRoute route: RouteObject) {
        
        mapViewController.setMainRoute(route)
    }
    
    // MARK: - NavigationContextDelegate
    
    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationStatusChanged status: NavigationStatus) {
        
    }
    
    func navigationContext(_ navigationContext: NavigationContext, navigationStartedForRoute route: RouteObject) {
        
        self.mapViewController!.startFollowingPosition(withAnimationDuration: 1200, zoomLevel: -1) { (success: Bool) in }
    }
    
    func navigationContext(_ navigationContext: NavigationContext, navigationInstructionUpdatedForRoute route: RouteObject, updatedEvents: Int32) {
        
        let eta = navigationContext.getEstimateTimeOfArrivalFormatted() + navigationContext.getEstimateTimeOfArrivalUnitFormatted()
        
        let rtt = navigationContext.getRemainingTravelTimeFormatted() + navigationContext.getRemainingTravelTimeUnitFormatted()
        
        let rtd = navigationContext.getRemainingTravelDistanceFormatted() + navigationContext.getRemainingTravelDistanceUnitFormatted()
        
        // NSLog("Navigation: refresh: eta:%@, rtt:%@, rtd:%@", eta, rtt, rtd)
        
        let text = eta + "     " + rtt + "     " + rtd
        
        self.label.text = text
        self.label.isHidden = false
        
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
        
        var minutes: Int = 0
        
        if timeGain < 0 { // roadblock
            
            minutes = 60
            
        } else {
            
            if timeGain < 30 { // under 30 sec.
                
                return
            }
            
            minutes = timeGain / 60
            
            if timeGain % 60 >= 30
            {
                minutes += 1
            }
        }
        
        if minutes > 1 {
            
            let ttsMessage = "An alternative route is available which can save you " + String(minutes) + " minutes."
            
            self.soundContext!.playText(ttsMessage)
            
            self.betterRoute = route
            
            self.timeGainMinutes = UInt(minutes)
            
            self.presentBetterRouteButton()
        }
    }
    
    func navigationContext(_ navigationContext: NavigationContext, onBetterRouteInvalidated state: Bool) {
        
        self.removeBetterRouteButton()
        
        if self.betterRoute != nil {
            
            if self.mainRoute != nil {
                
                if self.mapViewController!.isFollowingPosition() == false {
                    
                    self.mapViewController!.hideCompass()
                    self.mapViewController!.removeAllRoutes()
                    self.mapViewController!.setMainRoute(self.mainRoute!)
                    self.mapViewController!.showRoutes([self.mainRoute!], withTraffic:self.trafficContext!, showSummary: false)
                    self.mapViewController!.startFollowingPosition(withAnimationDuration: 1600, zoomLevel: -1) { success in }
                }
                
                self.panelNavigationViewController!.view.isHidden = false
            }
        }
        
        self.betterRoute = nil
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
}
