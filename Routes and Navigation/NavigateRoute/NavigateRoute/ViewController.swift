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
    
    var label = UILabel.init()
    
    let navigationPanel = UIView.init()
    let turnView        = UIView.init()
    let turnImage       = UIImageView.init()
    let turnDistance    = UILabel.init()
    let turnInstruction = UILabel.init()
    let stopButton      = UIButton.init(type: .system)
    let navigationPanelHeight: CGFloat = 120.0
    
    let turnImageSize: CGFloat = 80
    let turnDistHeight: CGFloat = 30
    let roadCodeSize: CGFloat = 40
    
    let lanePanel   = UIView.init()
    let laneImage   = UIImageView.init()
    let lanePanelHeight: CGFloat = 60.0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "Navigate Route"
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.createMapView()
        
        self.mapViewController!.startRender()
        
        self.addLocationButton()
        self.addNavigationPanel()
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
            
            self.mapViewController!.startFollowingPosition(withAnimationDuration: 1000)
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
        
        self.label.layer.shadowColor = UIColor.lightGray.cgColor
        self.label.layer.shadowOpacity = 0.8
        
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
    
    // MARK: - Panel
    
    func addNavigationPanel() {
        
        let buttonSize: CGFloat = 50
        let configuration = UIImage.SymbolConfiguration(pointSize: 40, weight: .semibold)
        let image = UIImage.init(systemName: "xmark.circle", withConfiguration: configuration)?.withRenderingMode(.alwaysTemplate)
        self.stopButton.tintColor = UIColor.red
        self.stopButton.backgroundColor = UIColor.black
        self.stopButton.setImage(image, for: .normal)
        self.stopButton.addTarget(self, action: #selector(stopButtonAction), for: .touchUpInside)
        self.stopButton.layer.cornerRadius = buttonSize / 2.0
        self.stopButton.layer.shadowColor = UIColor.gray.cgColor
        self.stopButton.layer.shadowOpacity = 0.8
        
        let font = UIFont.boldSystemFont(ofSize: 20)
        
        self.turnImage.contentMode = .center
        
        self.turnDistance.font = font
        self.turnDistance.textColor = UIColor.white
        self.turnDistance.numberOfLines = 1
        self.turnDistance.textAlignment = .center
        
        self.turnInstruction.font = font
        self.turnInstruction.textColor = UIColor.white
        self.turnInstruction.numberOfLines = 3
        self.turnInstruction.textAlignment = .center
        self.turnInstruction.lineBreakMode = .byTruncatingTail
        
        self.turnView.addSubview(self.turnImage)
        self.turnView.addSubview(self.turnDistance)
        
        self.lanePanel.backgroundColor = self.navigationPanel.backgroundColor
        self.lanePanel.isHidden = true
        self.lanePanel.layer.masksToBounds = true
        self.lanePanel.layer.cornerRadius = 8
        self.lanePanel.layer.borderWidth = 1.0
        self.lanePanel.layer.borderColor = UIColor.darkGray.cgColor
        
        self.laneImage.contentMode = .scaleAspectFit
        
        self.lanePanel.addSubview(self.laneImage)
        
        self.navigationPanel.isHidden = true
        self.navigationPanel.backgroundColor = UIColor.init(red: 20/255, green: 20/255, blue: 20/255, alpha: 1.0)
        self.navigationPanel.layer.cornerRadius = 8.0
        self.navigationPanel.layer.shadowColor = UIColor.gray.cgColor
        self.navigationPanel.layer.shadowOpacity = 0.8
        
        self.navigationPanel.addSubview(self.turnView)
        self.navigationPanel.addSubview(self.turnInstruction)
        self.navigationPanel.addSubview(self.lanePanel)
        self.navigationPanel.addSubview(self.stopButton)
        
        self.view.addSubview(self.navigationPanel)
        
        
        self.navigationPanel.translatesAutoresizingMaskIntoConstraints = false
        var constraintTop = NSLayoutConstraint( item: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.top,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self.view.safeAreaLayoutGuide, attribute: NSLayoutConstraint.Attribute.top,
                                                multiplier: 1.0, constant: 5.0)
        
        var constraintLeft = NSLayoutConstraint(item: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.leading,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading,
                                                multiplier: 1.0, constant: 10.0)
        
        var constraintRight = NSLayoutConstraint( item: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  multiplier: 1.0, constant: -10.0)
        
        var constraintHeight = NSLayoutConstraint( item: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.height,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                   multiplier: 1.0, constant: self.viewHeight())
        
        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintRight, constraintHeight])
        
        
        self.stopButton.translatesAutoresizingMaskIntoConstraints = false
        constraintTop = NSLayoutConstraint( item: self.stopButton, attribute: NSLayoutConstraint.Attribute.top,
                                            relatedBy: NSLayoutConstraint.Relation.equal,
                                            toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.top,
                                            multiplier: 1.0, constant: -8.0)
        
        constraintRight = NSLayoutConstraint(item: self.stopButton, attribute: NSLayoutConstraint.Attribute.trailing,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.trailing,
                                             multiplier: 1.0, constant: 8.0)
        
        var constraintWidth = NSLayoutConstraint( item: self.stopButton, attribute: NSLayoutConstraint.Attribute.width,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                  multiplier: 1.0, constant: buttonSize)
        
        constraintHeight = NSLayoutConstraint( item: self.stopButton, attribute: NSLayoutConstraint.Attribute.height,
                                               relatedBy: NSLayoutConstraint.Relation.equal,
                                               toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                               multiplier: 1.0, constant: buttonSize)
        
        NSLayoutConstraint.activate([constraintTop, constraintRight, constraintWidth, constraintHeight])
        
        
        self.turnImage.translatesAutoresizingMaskIntoConstraints = false
        constraintTop = NSLayoutConstraint(item: self.turnImage, attribute: NSLayoutConstraint.Attribute.top,
                                           relatedBy: NSLayoutConstraint.Relation.equal,
                                           toItem: self.turnView, attribute: NSLayoutConstraint.Attribute.top,
                                           multiplier: 1.0, constant: 0.0)
        
        constraintLeft = NSLayoutConstraint(item: self.turnImage, attribute: NSLayoutConstraint.Attribute.leading,
                                            relatedBy: NSLayoutConstraint.Relation.equal,
                                            toItem: self.turnView, attribute: NSLayoutConstraint.Attribute.leading,
                                            multiplier: 1.0, constant: 0.0)
        
        constraintWidth = NSLayoutConstraint(item: self.turnImage, attribute: NSLayoutConstraint.Attribute.width,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                             multiplier: 1.0, constant: self.turnImageSize)
        
        constraintHeight = NSLayoutConstraint(item: self.turnImage, attribute: NSLayoutConstraint.Attribute.height,
                                              relatedBy: NSLayoutConstraint.Relation.equal,
                                              toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                              multiplier: 1.0, constant: self.turnImageSize)
        
        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintWidth, constraintHeight])
        
        
        self.turnDistance.translatesAutoresizingMaskIntoConstraints = false
        constraintTop = NSLayoutConstraint(item: self.turnDistance, attribute: NSLayoutConstraint.Attribute.top,
                                           relatedBy: NSLayoutConstraint.Relation.equal,
                                           toItem: self.turnImage, attribute: NSLayoutConstraint.Attribute.bottom,
                                           multiplier: 1.0, constant: -2.5)
        
        constraintLeft = NSLayoutConstraint(item: self.turnDistance, attribute: NSLayoutConstraint.Attribute.leading,
                                            relatedBy: NSLayoutConstraint.Relation.equal,
                                            toItem: self.turnImage, attribute: NSLayoutConstraint.Attribute.leading,
                                            multiplier: 1.0, constant: 0.0)
        
        constraintRight = NSLayoutConstraint(item: self.turnDistance, attribute: NSLayoutConstraint.Attribute.trailing,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.turnImage, attribute: NSLayoutConstraint.Attribute.trailing,
                                             multiplier: 1.0, constant: 0.0)
        
        constraintHeight = NSLayoutConstraint(item: self.turnDistance, attribute: NSLayoutConstraint.Attribute.height,
                                              relatedBy: NSLayoutConstraint.Relation.equal,
                                              toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                              multiplier: 1.0, constant: self.turnDistHeight)
        
        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintRight, constraintHeight])
        
        
        self.turnView.translatesAutoresizingMaskIntoConstraints = false
        let constraintCenterY = NSLayoutConstraint(item: self.turnView, attribute: NSLayoutConstraint.Attribute.centerY,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.centerY,
                                                   multiplier: 1.0, constant: 0.0)
        
        constraintLeft = NSLayoutConstraint(item: self.turnView, attribute: NSLayoutConstraint.Attribute.leading,
                                            relatedBy: NSLayoutConstraint.Relation.equal,
                                            toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.leading,
                                            multiplier: 1.0, constant: 0.0)
        
        constraintWidth = NSLayoutConstraint(item: self.turnView, attribute: NSLayoutConstraint.Attribute.width,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                             multiplier: 1.0, constant: self.turnImageSize)
        
        constraintHeight = NSLayoutConstraint(item: self.turnView, attribute: NSLayoutConstraint.Attribute.height,
                                              relatedBy: NSLayoutConstraint.Relation.equal,
                                              toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                              multiplier: 1.0, constant: self.turnImageSize + self.turnDistHeight)
        
        NSLayoutConstraint.activate([constraintCenterY, constraintLeft, constraintWidth, constraintHeight])
        
        
        self.turnInstruction.translatesAutoresizingMaskIntoConstraints = false
        constraintTop = NSLayoutConstraint( item: self.turnInstruction, attribute: NSLayoutConstraint.Attribute.top,
                                            relatedBy: NSLayoutConstraint.Relation.equal,
                                            toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.top,
                                            multiplier: 1.0, constant: 0.0)
        
        constraintLeft = NSLayoutConstraint( item: self.turnInstruction, attribute: NSLayoutConstraint.Attribute.leading,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.leading,
                                             multiplier: 1.0, constant: self.turnImageSize)
        
        constraintRight = NSLayoutConstraint(item: self.turnInstruction, attribute: NSLayoutConstraint.Attribute.trailing,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.trailing,
                                             multiplier: 1.0, constant: -5.0)
        
        var constraintBottom = NSLayoutConstraint( item: self.turnInstruction, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   multiplier: 1.0, constant: -0.0)
        
        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintRight, constraintBottom])
        
        
        self.turnInstruction.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        self.turnInstruction.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.vertical)
        
        self.turnInstruction.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        self.turnInstruction.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.vertical)
        
        
        self.laneImage.translatesAutoresizingMaskIntoConstraints = false
        constraintTop = NSLayoutConstraint( item: self.laneImage, attribute: NSLayoutConstraint.Attribute.top,
                                            relatedBy: NSLayoutConstraint.Relation.equal,
                                            toItem: self.lanePanel, attribute: NSLayoutConstraint.Attribute.top,
                                            multiplier: 1.0, constant: 5.0)
        
        constraintLeft = NSLayoutConstraint( item: self.laneImage, attribute: NSLayoutConstraint.Attribute.leading,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.lanePanel, attribute: NSLayoutConstraint.Attribute.leading,
                                             multiplier: 1.0, constant: 0.0)
        
        constraintRight = NSLayoutConstraint(item: self.laneImage, attribute: NSLayoutConstraint.Attribute.trailing,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.lanePanel, attribute: NSLayoutConstraint.Attribute.trailing,
                                             multiplier: 1.0, constant: -0.0)
        
        constraintBottom = NSLayoutConstraint( item: self.laneImage, attribute: NSLayoutConstraint.Attribute.bottom,
                                               relatedBy: NSLayoutConstraint.Relation.equal,
                                               toItem: self.lanePanel, attribute: NSLayoutConstraint.Attribute.bottom,
                                               multiplier: 1.0, constant: -5.0)
        
        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintRight, constraintBottom])
        
        
        self.lanePanel.translatesAutoresizingMaskIntoConstraints = false
        constraintBottom = NSLayoutConstraint( item: self.lanePanel, attribute: NSLayoutConstraint.Attribute.bottom,
                                               relatedBy: NSLayoutConstraint.Relation.equal,
                                               toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.bottom,
                                               multiplier: 1.0, constant: -2.5)
        
        constraintLeft = NSLayoutConstraint( item: self.lanePanel, attribute: NSLayoutConstraint.Attribute.leading,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.leading,
                                             multiplier: 1.0, constant: 2.5)
        
        constraintRight = NSLayoutConstraint(item: self.lanePanel, attribute: NSLayoutConstraint.Attribute.trailing,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.trailing,
                                             multiplier: 1.0, constant: -2.5)
        
        constraintHeight = NSLayoutConstraint( item: self.lanePanel, attribute: NSLayoutConstraint.Attribute.height,
                                               relatedBy: NSLayoutConstraint.Relation.equal,
                                               toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                               multiplier: 1.0, constant: self.lanePanelHeight)
        
        NSLayoutConstraint.activate([constraintBottom, constraintLeft, constraintRight, constraintHeight])
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
            self.soundContext!.setUseTts(true)
        }
        
        let location = self.positionContext!.getPosition().getPositionGeoLocation()
        
        let start = LandmarkObject.landmark(withName: "My Position", location: location)
        let stop  = LandmarkObject.landmark(withName: "Location", location: GeoLocation.coordinates(withLatitude: 51.491506, longitude: -0.082238) )
        
        self.departure = start
        self.destination = stop
        
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
                
                strongSelf.mapViewController?.presentRoutes(results, withSummary: true, traffic: self.trafficContext, animationDuration: 1000)
            }
            
            item.isEnabled = true
        })
    }
    
    @objc func clearRouteButtonAction(item: UIBarButtonItem) {
        
        self.mapViewController?.removeAllRoutes()
        
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
            
            self.mainRoute = nil
            
            self.navigationPanel.isHidden = true
            
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            
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
    
    // MARK: - Layout
    
    func refreshContentLayout() {

        var requestUpdateLayout: Bool = false

        let array: [NSLayoutConstraint] = self.view.constraints + self.navigationPanel.constraints + self.lanePanel.constraints

        for constraint in array {
            
            if constraint.isActive && constraint.firstItem === self.navigationPanel && constraint.firstAttribute == NSLayoutConstraint.Attribute.height && constraint.secondItem == nil {

                // Default
                let constant: CGFloat = self.viewHeight()

                if constraint.constant != constant {

                    // Mark
                    requestUpdateLayout = true

                    // Adjust
                    constraint.constant = constant
                }
            }
            
            if constraint.isActive && constraint.firstItem === self.turnView && constraint.firstAttribute == NSLayoutConstraint.Attribute.centerY {
                
                var constant: CGFloat = 0

                if self.lanePanel.isHidden == false {
                    
                    constant = -self.lanePanelHeight/2
                }

                if constraint.constant != constant {
                    
                    requestUpdateLayout = true
                    
                    constraint.constant = constant
                }
            }
            
            if constraint.isActive && constraint.firstItem === self.turnInstruction && constraint.firstAttribute == NSLayoutConstraint.Attribute.bottom {
                
                var constant: CGFloat = 0

                if self.lanePanel.isHidden == false {
                    
                    constant = -self.lanePanelHeight/2
                }

                if constraint.constant != constant {
                    
                    requestUpdateLayout = true
                    
                    constraint.constant = constant
                }
            }
        }
        
        if requestUpdateLayout {
            
            self.view.layoutIfNeeded()
        }
    }
    
    func viewHeight() -> CGFloat {
        
        var height: CGFloat = self.navigationPanelHeight;
        
        if self.lanePanel.isHidden == false {
            
            height += self.lanePanelHeight;
        }
        
        return height
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
        
        self.mapViewController!.startFollowingPosition(withAnimationDuration: 1200)
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
            
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            
            self.navigationPanel.isHidden = false
        }
        
        var text1 = ""
        var text2 = ""
        var image: UIImage?
        
        if let turnInstruction = navigationContext.getNavigationInstruction(), turnInstruction.hasNextTurnInfo() {
            
            let scale = UIScreen.main.scale
            let size = CGSize.init(width: 60 * scale, height: 60 * scale)
            image = turnInstruction.getNextTurnImage(size,
                                                     colorActiveInner: UIColor.white,
                                                     colorActiveOuter: UIColor.black,
                                                     colorInactiveInner: UIColor.lightGray,
                                                     colorInactiveOuter: UIColor.lightGray)
            
            text1 = turnInstruction.getDistanceToNextTurnFormatted() + turnInstruction.getDistanceToNextTurnUnitFormatted()
            text2 = turnInstruction.getNextTurnInstructionFormatted()
            
            let laneSize = CGSize.init(width: self.lanePanel.frame.size.width * scale, height: self.lanePanel.frame.size.height * scale)
            
            if let image = turnInstruction.getLaneImage(laneSize,
                                                        backgroundColor: UIColor.black,
                                                        activeColor: UIColor.black,
                                                        inactiveColor: UIColor.lightGray) {
                
                self.laneImage.image = image
                self.lanePanel.isHidden = false
                
            } else {
                
                self.laneImage.image = nil
                self.lanePanel.isHidden = true
            }
        }
        
        self.turnImage.image = image
        self.turnDistance.text = text1
        self.turnInstruction.text = text2
        
        self.refreshContentLayout()
    }
    
    func navigationContext(_ navigationContext: NavigationContext, navigationRouteUpdated route: RouteObject) {
        
    }
    
    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationWaypointReached waypoint: LandmarkObject) {
        
    }
    
    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationDestinationReached waypoint: LandmarkObject) {
     
        self.label.isHidden = true
    }
    
    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationError code: Int) {
        
    }
    
    func navigationContext(_ navigationContext: NavigationContext, canPlayNavigationSoundForRoute route: RouteObject) -> Bool {
        
        return true
    }
    
    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationSound text: String) {
        
        NSLog("NavigationContext: navigationSound text:%@", text)
        
        if let context = self.soundContext {
            
            context.playText(text)
        }
    }
}
