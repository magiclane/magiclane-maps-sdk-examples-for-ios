// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import UIKit
import GEMKit

class ViewController: UIViewController, GEMSdkDelegate, MapViewControllerDelegate, NavigationContextDelegate {
    
    var mapViewController: MapViewController?
    var navigationContext: NavigationContext?
    var soundContext: SoundContext?
    var panelNavigationViewController: NavigationViewController?
    
    var label = UILabel.init()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let navigationController = self.navigationController {
            
            let appearance = navigationController.navigationBar.standardAppearance
            
            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }
        
        let isConnected = GEMSdk.shared().isOnlineConnection()
        
        self.onConnectionStatusUpdated(isConnected)
        
        GEMSdk.shared().delegate = self
        
        self.title = "Demo Route"
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.createMapView()
        
        self.addRouteButton()
        self.addLabelText()
        
        self.setCustomPositionTracker()
        self.setFollowPositionCameraFocus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.disableOverlays()
        self.disableMapTraffic()
    }
    
    // MARK: - GEMSdkDelegate
    
    func shouldUpdateWorldwideRoadMap(for status: ContentStoreOnlineSupportStatus) -> Bool {
        
        let value = (status == .expiredData || status == .oldData)
        
        self.updateStatus(message: "Map is updating...")
        
        self.refreshRouteButton(enable: !value)
        
        return value
    }
    
    func updateWorldwideRoadMapFinished(_ success: Bool) {
        
        self.updateStatus(message: "Map Ready")
        
        self.refreshRouteButton(enable: true)
    }
    
    func onConnectionStatusUpdated(_ connected: Bool) {
        
        self.updateStatus(message: connected ? "Map ready" : "No Internet Connection")
        
        self.refreshRouteButton(enable: connected)
    }
    
    func updateStatus(message: String) {
        
        self.label.text = message
        self.label.isHidden = false
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
        
        self.mapViewController!.startRender()
    }
    
    func setFollowPositionCameraFocus() {
        
        guard let mapViewController = self.mapViewController else { return }
        
        let point = CGPoint.init(x: 0.5, y: 0.75)
        
        mapViewController.getPreferences().getFollowPositionPreferences().setCameraFocus(point)
    }
    
    func disableMapTraffic() {
        
        guard let mapViewController = self.mapViewController else { return }
        
        mapViewController.getPreferences().setTrafficVisibility(false)
    }
    
    // MARK: - Buttons
    
    func addRouteButton() {
        
        let image = UIImage.init(systemName: "play")
        let barButton = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(calculateRoute(item:)))
        barButton.isEnabled = false
        
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func refreshRouteButton(enable: Bool) {
        
        if let button = self.navigationItem.rightBarButtonItem {
            
            button.isEnabled = enable
        }
    }
    
    @objc func stopButtonAction() {
        
        guard self.panelNavigationViewController != nil else { return }
        
        self.mapViewController!.stopFollowingPosition()
        
        self.navigationContext!.cancelSimulateRoute()
        
        if let soundContext = self.soundContext {
            
            soundContext.cancel()
        }
        
        self.clearButtonAction()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.panelNavigationViewController?.removeFromParent()
        self.panelNavigationViewController?.view.removeFromSuperview()
        self.panelNavigationViewController?.didMove(toParent: nil)
        
        self.panelNavigationViewController = nil
        
        self.mapViewController!.showCompass()
        
        self.mapViewController!.setPerspective(.view2D, animationDuration: 10) { (success) in
            
            DispatchQueue.main.async {
                
                self.mapViewController!.alignNorthUp(withAnimationDuration: 1200) { (success) in }
            }
        }
    }
    
    // MARK: - Label
    
    func addLabelText() {
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(startFollowLocation))
        
        self.label.font = UIFont.boldSystemFont(ofSize: 20)
        self.label.numberOfLines = 0
        self.label.backgroundColor = UIColor.white
        self.label.textAlignment = .center
        self.label.isUserInteractionEnabled = true
        self.label.addGestureRecognizer(tapGesture)
                
        self.label.layer.borderWidth = 1.4
        self.label.layer.cornerRadius = 8.0
        self.label.layer.masksToBounds = true
        self.label.layer.borderColor = UIColor.black.cgColor
        
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
        
        self.mapViewController!.startFollowingPosition(withAnimationDuration: 400, zoomLevel: -1) { (success: Bool) in }
    }
    
    @objc func calculateRoute(item: UIBarButtonItem) {
        
        self.updateStatus(message: "Calculating Route")
        
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
        
        let departure = LandmarkObject.landmark(withName: "Amsterdam",
                                                location: CoordinatesObject.coordinates(withLatitude: 52.358505, longitude: 4.880342))
        
        let destination = LandmarkObject.landmark(withName: "Paris",
                                                  location: CoordinatesObject.coordinates(withLatitude: 48.856693, longitude: 2.351461))
        
        let waypoints = [departure, destination]
        
        item.isEnabled = false
        
        self.navigationContext!.calculateRoute(withWaypoints: waypoints) { routeStatus in
            
            if routeStatus == .waitingInternetConnection {
                
                self.updateStatus(message: "Waiting Internet Connection")
            }
            
        } completionHandler: { [weak self] results, code in
        
            guard let strongSelf = self else { return }
            
            if let route = results.first {
                
                strongSelf.startSimulation(route: route)
            }
            
            item.isEnabled = true
        }
    }
    
    func clearButtonAction() {
        
        self.mapViewController?.removeHighlights()
        self.mapViewController?.removeAllRoutes()
        
        self.label.isHidden = true
    }
    
    func startSimulation(route: RouteObject) {
        
        guard let mapViewController = self.mapViewController else { return }
        
        mapViewController.removeAllRoutes()
        
        self.navigationContext?.simulate(withRoute: route, speedMultiplier: 1.4) { [weak self] (success) in
            
            guard let strongSelf = self else { return }
            
            if success {
                
                mapViewController.hideCompass()
                
                mapViewController.presentRoutes([route],
                                                withTraffic: nil,
                                                showSummary: false, animationDuration: 0)
                
                strongSelf.adjustRenderSettings(route: route)
            }
        }
    }
    
    // MARK: - MapViewControllerDelegate
    
    func mapViewController(_ mapViewController: MapViewController, didSelectRoute route: RouteObject) {
        
        
    }
    
    // MARK: - NavigationContextDelegate
    
    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationStatusChanged status: NavigationStatus) {
        
    }
    
    func navigationContext(_ navigationContext: NavigationContext, navigationStartedForRoute route: RouteObject) {
        
        self.mapViewController!.startFollowingPosition(withAnimationDuration: 0, zoomLevel: -1) { (success: Bool) in }
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
                
                self.panelNavigationViewController?.updateCustomTurnInformation(navigationContext: navigationContext)
                
                self.panelNavigationViewController?.updateLaneInformation(navigationContext: navigationContext)
                
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
        
    }
    
    func navigationContext(_ navigationContext: NavigationContext, onBetterRouteInvalidated state: Bool) {
        
    }
    
    // MARK: - Position Tracker
    
    func setCustomPositionTracker() {
        
        if let url = Bundle.main.url(forResource: "quad", withExtension: "glb") {
            
            if let data = NSData.init(contentsOf: url) as Data? {
                
                self.mapViewController!.customizePositionTrackerGlTF(data)
            }
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
    
    // MARK: - Utils
    
    func adjustRenderSettings(route: RouteObject) {
        
        guard let mapViewController = self.mapViewController else { return }
        
        let preferences = mapViewController.getPreferences()
        
        if let settings = preferences.getRenderSettings(route) {
            
            settings.textSize  = 3.2
            settings.imageSize = 3.2
            
            settings.lineType = .solid
            
            settings.contourInnerSize = 2
            settings.contourInnerColor = UIColor.systemOrange
            
            settings.contourOuterSize = 2
            settings.contourOuterColor = UIColor.black
            
            preferences.setRenderSettings(settings, route: route)
        }
    }
    
    func disableOverlays() {
        
        let context = OverlayServiceContext.init()
        context.disableOverlay(Int32(CommonOverlayIdentifier.safety.rawValue))
        context.disableOverlay(Int32(CommonOverlayIdentifier.socialReports.rawValue))
    }
}
