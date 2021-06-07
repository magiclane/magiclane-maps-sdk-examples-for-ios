// Copyright (C) 2019-2021, General Magic B.V.
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
    
    var navigationViewController: NavigationViewController?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = "Simulate Route"
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
        let barButton1 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(routeButtonAction(item:)))

        image = UIImage.init(systemName: "clear")
        let barButton2 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(clearRouteButtonAction(item:)))
        
        image = UIImage.init(systemName: "play")
        let barButton3 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(startStopSimulation(item:)))
        
        self.navigationItem.rightBarButtonItems = [barButton1, barButton2, barButton3]
    }
    
    @objc func stopButtonAction() {
        
        if let array = self.navigationItem.rightBarButtonItems, array.count > 1 {
            
            let item = array[2]
            
            self.startStopSimulation(item: item)
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
        
        self.mapViewController!.startFollowingPosition(withAnimationDuration: 1000) { (success: Bool) in }
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
                
                strongSelf.mapViewController?.presentRoutes(results, withTraffic: strongSelf.trafficContext, showSummary: true, animationDuration: 1000)
            }
            
            item.isEnabled = true
        })
    }
    
    @objc func clearRouteButtonAction(item: UIBarButtonItem) {
        
        self.mapViewController?.removeAllRoutes()
        
        self.mainRoute = nil
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
            
            self.label.isHidden = true
            self.label.removeFromSuperview()
            
            self.navigationContext!.cancelSimulateRoute()
            
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
            
            self.mapViewController!.removeAllRoutes()
            
            let image = UIImage.init(systemName: "stop")
            item.image = image
            
            self.navigationContext!.simulateRoute(withRoute: self.mainRoute!, speedMultiplier: 2) { [weak self] (success) in
                
                guard let strongSelf = self else { return }
                
                if success {
                    
                    strongSelf.addLabelText()
                    
                    strongSelf.mapViewController!.presentRoutes([strongSelf.mainRoute!], withTraffic: strongSelf.trafficContext!, showSummary: false, animationDuration: 1600)
                }
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
        
        // NSLog("NavigationContext: navigationSound text:%@", text)
        
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
}
