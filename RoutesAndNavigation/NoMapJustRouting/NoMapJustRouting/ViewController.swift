// Copyright (C) 2019-2024, Magic Lane B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of Magic Lane
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with Magic Lane.

import UIKit
import GEMKit

class ViewController: UIViewController, NavigationContextDelegate, GEMSdkDelegate {
    
    var navigationContext: NavigationContext?
    var soundContext: SoundContext?
    
    var mainRoute: RouteObject?
    var departure: LandmarkObject?
    var destination: LandmarkObject?
    
    var timesLabel = UILabel.init()
    
    var statusLabel = UILabel.init()
    
    var panelNavigationViewController: NavigationViewController?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        GEMSdk.shared().delegate = self
        
        self.title = "Just Routing"
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.addLabelText()
        self.addStatusLabelText()
        
        self.refreshButtons()
    }
    
    // MARK: - Buttons
    
    func refreshButtons() {
        
        let barButton = UIBarButtonItem.init(image: UIImage.init(systemName: "map"),
                                             style: .done, target: self, action: #selector(openMaps))
        
        self.navigationItem.leftBarButtonItem = barButton
        
        let barButton1 = UIBarButtonItem.init(image: UIImage.init(systemName: "point.topleft.down.curvedto.point.bottomright.up"),
                                              style: .done, target: self, action: #selector(routeButtonAction(item:)))
        
        let barButton2 = UIBarButtonItem.init(image: UIImage.init(systemName: "clear"),
                                              style: .done, target: self, action: #selector(clearButtonAction))
        
        self.navigationItem.rightBarButtonItems = [barButton2, barButton1]
    }
    
    @objc func openMaps() {
        
        let viewController = DownloadMapsViewController.init()
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func stopButtonAction() {
        
        guard self.panelNavigationViewController != nil else { return }
        
        self.navigationContext!.cancelSimulateRoute()
        
        self.clearButtonAction()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.panelNavigationViewController?.removeFromParent()
        self.panelNavigationViewController?.view.removeFromSuperview()
        self.panelNavigationViewController?.didMove(toParent: nil)
        
        self.panelNavigationViewController = nil
    }
    
    // MARK: - GEMSdkDelegate
    
    func onConnectionStatusUpdated(_ connected: Bool) {
        
        self.refreshButtons()
        
        if let viewController = self.navigationController?.topViewController as? DownloadMapsViewController {
            
            viewController.refreshContent()
        }
    }
    
    // MARK: - Label
    
    func addLabelText() {
        
        self.timesLabel.font = UIFont.boldSystemFont(ofSize: 20)
        self.timesLabel.numberOfLines = 0
        self.timesLabel.backgroundColor = UIColor.white
        self.timesLabel.isHidden = true
        self.timesLabel.textAlignment = .center
        self.timesLabel.isUserInteractionEnabled = true
        
        self.timesLabel.layer.borderColor = UIColor.systemBlue.cgColor
        self.timesLabel.layer.borderWidth = 1.4
        self.timesLabel.layer.cornerRadius = 8.0
        self.timesLabel.layer.masksToBounds = true
        
        self.view.addSubview(self.timesLabel)
        
        self.timesLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraintLeft = NSLayoutConstraint( item: self.timesLabel, attribute: NSLayoutConstraint.Attribute.leading,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading,
                                                 multiplier: 1.0, constant: 10.0)
        
        let constraintBottom = NSLayoutConstraint( item: self.timesLabel, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: self.view.safeAreaLayoutGuide, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   multiplier: 1.0, constant: -10.0)
        
        let constraintRight = NSLayoutConstraint( item: self.timesLabel, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  multiplier: 1.0, constant: -10.0)
        
        let constraintHeight = NSLayoutConstraint( item: self.timesLabel, attribute: NSLayoutConstraint.Attribute.height,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                   multiplier: 1.0, constant: 54.0)
        
        NSLayoutConstraint.activate([constraintLeft, constraintBottom, constraintRight, constraintHeight])
    }
    
    func addStatusLabelText() {
        
        self.statusLabel.font = UIFont.systemFont(ofSize: 26, weight: .semibold)
        self.statusLabel.numberOfLines = 0
        self.statusLabel.textAlignment = .center
        
        self.view.addSubview(self.statusLabel)
        
        self.statusLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraintCenterY = NSLayoutConstraint( item: self.statusLabel, attribute: NSLayoutConstraint.Attribute.centerY,
                                                    relatedBy: NSLayoutConstraint.Relation.equal,
                                                    toItem: self.view, attribute: NSLayoutConstraint.Attribute.centerY,
                                                    multiplier: 1.0, constant: 0.0)
        
        let constraintLeft = NSLayoutConstraint( item: self.statusLabel, attribute: NSLayoutConstraint.Attribute.leading,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading,
                                                 multiplier: 1.0, constant: 15.0)
        
        let constraintRight = NSLayoutConstraint( item: self.statusLabel, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  multiplier: 1.0, constant: -15.0)
        
        NSLayoutConstraint.activate([constraintCenterY, constraintLeft, constraintRight])
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
        
        if self.soundContext == nil {
            
            self.soundContext = SoundContext.init()
            self.soundContext?.setUseTtsWithCompletionHandler({ success in })
        }
        
        //        self.departure = LandmarkObject.landmark(withName: "Munich 1", location:
        //                                                    CoordinatesObject.coordinates(withLatitude: 48.15741,  longitude: 11.53739))
        //
        //        self.destination = LandmarkObject.landmark(withName: "Munich 2", location:
        //                                                    CoordinatesObject.coordinates(withLatitude: 48.166730, longitude: 11.53687))
        
        self.departure = LandmarkObject.landmark(withName: "Hamburg 1", location:
                                                    CoordinatesObject.coordinates(withLatitude: 53.554010,  longitude: 10.027508))
        
        self.destination = LandmarkObject.landmark(withName: "Hamburg 2", location:
                                                    CoordinatesObject.coordinates(withLatitude: 53.618284, longitude: 10.028659))
        
        guard let start = self.departure, let stop = self.destination else { return }
        
        let waypoints = [ start, stop];
        
        item.isEnabled = false
        
        self.navigationContext!.calculateRoute(withWaypoints: waypoints) { routeStatus in
            
            switch(routeStatus) {
            case .calculating :
                self.statusLabel.text = "Calculating"
            case .waitingInternetConnection:
                self.statusLabel.text = "Waiting Internet Connection"
            case .ready:
                self.statusLabel.text = "Ready"
            case .uninitialized:
                self.statusLabel.text = "Uninitialized"
            case .error:
                self.statusLabel.text = "Error"
            default:
                self.statusLabel.text = ""
                break
            }
            
        } completionHandler: { [weak self] results, code in
            
            guard let strongSelf = self else { return }
            
            NSLog("Found %d routes.", results.count)
            
            for route in results {
                
                if let timeDuration = route.getTimeDistance() {
                    
                    let time     = timeDuration.getTotalTimeFormatted()     + timeDuration.getTotalTimeUnitFormatted()
                    let distance = timeDuration.getTotalDistanceFormatted() + timeDuration.getTotalDistanceUnitFormatted()
                    
                    NSLog("route time:%@, distance:%@", time, distance)
                }
            }
            
            if results.count > 0 {
                
                strongSelf.mainRoute = results.first
                
                strongSelf.startSimulation()
            }
            
            item.isEnabled = true
        }
    }
    
    @objc func clearButtonAction() {
        
        guard let navigationContext = self.navigationContext else { return }
        
        navigationContext.cancelCalculateRoute()
        
        navigationContext.cancelSimulateRoute()
        
        self.mainRoute = nil
        
        self.timesLabel.isHidden = true
        
        self.statusLabel.text = ""
    }
    
    @objc func startSimulation() {
        
        guard let mainRoute = self.mainRoute else { return }
        
        guard let navigationContext = self.navigationContext else { return }
        
        navigationContext.simulate(withRoute: mainRoute, speedMultiplier: 2.0) { [weak self] (success) in
            
            guard let _ = self else { return }
        }
    }
    
    // MARK: - NavigationContextDelegate
    
    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationStatusChanged status: NavigationStatus) {
        
        switch status {
            
        case .running:
            self.statusLabel.text = "Running"
            
        case .waitingGPS:
            self.statusLabel.text = "Waiting GPS"
            
        case .waitingRoute:
            self.statusLabel.text = "Waiting Route"
            
        default:
            self.statusLabel.text = ""
        }
    }
    
    func navigationContext(_ navigationContext: NavigationContext, navigationStartedForRoute route: RouteObject) {
        
        if self.navigationController?.isNavigationBarHidden == false {
            
            self.navigationController?.popToRootViewController(animated: true)
            
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    func navigationContext(_ navigationContext: NavigationContext, navigationInstructionUpdatedForRoute route: RouteObject, updatedEvents: Int32) {
        
        let eta = navigationContext.getEstimateTimeOfArrivalFormatted() + navigationContext.getEstimateTimeOfArrivalUnitFormatted()
        
        let rtt = navigationContext.getRemainingTravelTimeFormatted() + navigationContext.getRemainingTravelTimeUnitFormatted()
        
        let rtd = navigationContext.getRemainingTravelDistanceFormatted() + navigationContext.getRemainingTravelDistanceUnitFormatted()
        
        // NSLog("Navigation: refresh: eta:%@, rtt:%@, rtd:%@", eta, rtt, rtd)
        
        let text = eta + "     " + rtt + "     " + rtd
        
        self.timesLabel.text = text
        self.timesLabel.isHidden = false
        
        if self.panelNavigationViewController == nil {
            
            self.createNavigationPanel()
        }
        
        if let turnInstruction = navigationContext.getNavigationInstruction(), turnInstruction.getNavigationStatus() == .running {
            
            if turnInstruction.hasNextTurnInfo() {
                
                self.panelNavigationViewController?.updateTurnInformation(navigationContext: navigationContext)
                
                self.panelNavigationViewController?.updateLaneInformation(navigationContext: navigationContext)
                
                self.panelNavigationViewController?.updateSignpostInformation(navigationContext: navigationContext)
                
                self.panelNavigationViewController?.updateRoadCodeInformation(navigationContext: navigationContext)
                
                self.panelNavigationViewController?.refreshContentLayout()
            }
        }
    }
    
    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationWaypointReached waypoint: LandmarkObject) {
        
    }
    
    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationDestinationReached waypoint: LandmarkObject) {
        
        self.stopButtonAction()
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
