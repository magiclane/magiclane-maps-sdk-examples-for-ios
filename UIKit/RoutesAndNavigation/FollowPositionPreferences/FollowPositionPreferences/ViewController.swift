// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

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

    var followPositionButton: UIButton?
    var resetFollowPreferencesButton: UIButton?

    var positionTrackerState: Data?

    override func viewDidLoad() {

        super.viewDidLoad()

        if let navigationController = self.navigationController {

            let appearance = navigationController.navigationBar.standardAppearance

            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }

        self.title = "Follow Preferences"
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.largeTitleDisplayMode = .never

        self.createMapView()

        self.mapViewController!.startRender()

        self.addRouteButtons()
        self.addLabelText()
        self.addFollowPositionButton()
        self.addResetFollowPreferencesButton()
    }

    // MARK: - Map View

    func createMapView() {

        self.mapViewController = MapViewController.init()
        self.mapViewController!.delegate = self
        self.mapViewController!.view.backgroundColor = UIColor.systemBackground

        // Enable modification persistence for the zoom and angle changes while following position
        self.setMapFollowPositionPreferences()

        self.addChild(self.mapViewController!)
        self.view.addSubview(self.mapViewController!.view)
        self.mapViewController!.didMove(toParent: self)

        self.mapViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.mapViewController!.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.mapViewController!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.mapViewController!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.mapViewController!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }

    func setMapFollowPositionPreferences() {

        guard let mapViewController = self.mapViewController else { return }

        let followPositionPreferences = mapViewController.getPreferences().getFollowPositionPreferences()

        followPositionPreferences.setTouchHandlerModifyPersistent(true)
    }

    // MARK: - Buttons

    func addRouteButtons() {

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

        self.navigationContext = nil

        self.clearButtonAction()

        self.navigationController?.setNavigationBarHidden(false, animated: true)

        self.panelNavigationViewController?.removeFromParent()
        self.panelNavigationViewController?.view.removeFromSuperview()
        self.panelNavigationViewController?.didMove(toParent: nil)

        self.panelNavigationViewController = nil

        self.mapViewController!.showCompass()

        self.mapViewController!
            .setPerspective(.view2D, animationDuration: 600) { (success) in

                DispatchQueue.main.async {

                    self.mapViewController!.alignNorthUp(withAnimationDuration: 1200) { (success) in }
                }
            }
    }

    func addFollowPositionButton() {

        let button = UIButton.init(type: .system)
        button.isHidden = true
        button.addTarget(self, action: #selector(followPositionButtonAction), for: .touchUpInside)
        button.backgroundColor = UIColor.systemBackground
        button.tintColor = UIColor.systemBlue

        if let image = UIImage.init(systemName: "location", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20)) {

            button.setImage(image, for: .normal)
        }

        let size: CGFloat = 50

        button.layer.cornerRadius = size / 2.0
        button.layer.shadowOpacity = 0.8
        button.layer.shadowColor = UIColor.lightGray.cgColor

        self.view.addSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            button.bottomAnchor.constraint(equalTo: self.label.topAnchor, constant: -10),
            button.widthAnchor.constraint(equalToConstant: size),
            button.heightAnchor.constraint(equalToConstant: size)
        ])

        self.followPositionButton = button
    }

    func addResetFollowPreferencesButton() {

        let button = UIButton.init(type: .system)
        button.isHidden = true
        button.addTarget(self, action: #selector(resetFollowPositionPreferencesButtonAction), for: .touchUpInside)
        button.backgroundColor = UIColor.systemBackground
        button.tintColor = UIColor.systemBlue

        if let image = UIImage.init(systemName: "location.fill.viewfinder", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20)) {

            button.setImage(image, for: .normal)
        }
        
        button.setTitle("Reset", for: .normal)

        let height: CGFloat = 50
        let width: CGFloat = 120

        button.layer.cornerRadius = height / 2.0
        button.layer.shadowOpacity = 0.8
        button.layer.shadowColor = UIColor.lightGray.cgColor

        self.view.addSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            button.bottomAnchor.constraint(equalTo: self.label.topAnchor, constant: -10),
            button.widthAnchor.constraint(equalToConstant: width),
            button.heightAnchor.constraint(equalToConstant: height)
        ])

        self.resetFollowPreferencesButton = button
    }

    @objc func followPositionButtonAction() {

        guard self.navigationContext != nil else { return }

        guard let mapViewController = self.mapViewController else { return }

        mapViewController.startFollowingPosition(withAnimationDuration: 200, zoomLevel: -1) { success in

            // Do any action on completion
        }
    }

    @objc func resetFollowPositionPreferencesButtonAction() {

        guard self.navigationContext != nil else { return }

        guard let mapViewController = self.mapViewController else { return }

        mapViewController.restoreFollowingPosition(
            withAnimationDuration: 200,
            completionHandler: { success in

                // Do any action on completion
            })

        self.positionTrackerState = nil

        self.resetFollowPreferencesButton!.isHidden = true
    }

    // MARK: - Label

    func addLabelText() {

        self.label.font = UIFont.boldSystemFont(ofSize: 20)
        self.label.numberOfLines = 0
        self.label.backgroundColor = .systemBackground
        self.label.isHidden = true
        self.label.textColor = .label
        self.label.textAlignment = .center
        self.label.isUserInteractionEnabled = true

        self.label.layer.borderColor = UIColor.systemBlue.cgColor
        self.label.layer.borderWidth = 1.4
        self.label.layer.cornerRadius = 8.0
        self.label.layer.masksToBounds = true

        self.view.addSubview(self.label)

        self.label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.label.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            self.label.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            self.label.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            self.label.heightAnchor.constraint(equalToConstant: 54)
        ])
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

            self.alarmContext?
                .registerSafetyCameraNotifications(completionHandler: { success in

                    NSLog("AlarmContext: registerSafetyCamera with success:%@", String(success))
                })

            self.alarmContext?
                .registerSocialReportNotifications(completionHandler: { success in

                    NSLog("AlarmContext: registerSafetyCamera with success:%@", String(success))
                })
        }

        // self.departure   = LandmarkObject.landmark(withName: "San Francisco", location: CoordinatesObject.coordinates(withLatitude: 37.77903, longitude: -122.41991) )
        // self.destination = LandmarkObject.landmark(withName: "San Jose",      location: CoordinatesObject.coordinates(withLatitude: 37.33619, longitude: -121.89058) )

        self.departure = LandmarkObject.landmark(
            withName: "Munich 1", location: CoordinatesObject.coordinates(withLatitude: 48.15741, longitude: 11.53739))
        self.destination = LandmarkObject.landmark(
            withName: "Munich 2", location: CoordinatesObject.coordinates(withLatitude: 48.166730, longitude: 11.53687))

        // self.departure = LandmarkObject.landmark(withName: "London 1", location: CoordinatesObject.coordinates(withLatitude: 51.53998, longitude: -0.1387) )
        // self.destination = LandmarkObject.landmark(withName: "London 2", location: CoordinatesObject.coordinates(withLatitude: 51.66105, longitude: -0.1687) )

        guard let start = self.departure, let stop = self.destination else {
            return
        }

        let waypoints = [start, stop]

        item.isEnabled = false

        self.navigationContext?
            .calculateRoute(
                withWaypoints: waypoints,
                completionHandler: { [weak self] (results: [RouteObject]) in

                    guard let strongSelf = self else { return }

                    NSLog("Found %d routes.", results.count)

                    strongSelf.myResults = results

                    for route in results {

                        if let timeDuration = route.getTimeDistance() {

                            let time = timeDuration.getTotalTimeFormatted() + timeDuration.getTotalTimeUnitFormatted()
                            let distance = timeDuration.getTotalDistanceFormatted() + timeDuration.getTotalDistanceUnitFormatted()

                            NSLog("route time:%@, distance:%@", time, distance)
                        }
                    }

                    if !results.isEmpty {

                        strongSelf.mainRoute = results.first

                        strongSelf.mapViewController!.setEdgeAreaInsets(strongSelf.areaEdge(margin: 15))

                        strongSelf.mapViewController?
                            .presentRoutes(results, withTraffic: strongSelf.trafficContext, showSummary: true, animationDuration: 1000)
                    }

                    item.isEnabled = true
                })
    }

    @objc func clearButtonAction() {

        self.mainRoute = nil

        self.mapViewController?.removeHighlights()

        self.mapViewController?.removeAllRoutes()

        self.navigationContext = nil

        self.label.isHidden = true
        self.followPositionButton!.isHidden = true
        self.resetFollowPreferencesButton!.isHidden = true
    }

    @objc func startSimulation(item: UIBarButtonItem) {

        guard self.mainRoute != nil else { return }

        self.mapViewController!.removeAllRoutes()

        self.navigationContext!
            .simulate(withRoute: self.mainRoute!, speedMultiplier: 2) { [weak self] (success) in

                guard let strongSelf = self else { return }

                if success {

                    strongSelf.mapViewController!.hideCompass()

                    strongSelf.mapViewController!
                        .presentRoutes(
                            [strongSelf.mainRoute!], withTraffic: strongSelf.trafficContext!, showSummary: false, animationDuration: 1600)
                }
            }
    }

    // MARK: - MapViewControllerDelegate

    func mapViewController(_ mapViewController: MapViewController, onFollowingPositionStateChanged isFollowingPosition: Bool) {

        self.followPositionButton!.isHidden = isFollowingPosition
    }

    func mapViewController(_ mapViewController: MapViewController, didSelectRoute route: RouteObject) {

        self.mainRoute = route

        mapViewController.setMainRoute(route)
    }

    func mapViewController(
        _ mapViewController: MapViewController, onPinch startPoint1: CGPoint, startPoint2: CGPoint,
        toPoint1 endPoint1: CGPoint, toPoint2 endPoint2: CGPoint,
        center: CGPoint
    ) {

        self.savePositionTrackerState()
    }

    func mapViewController(
        _ mapViewController: MapViewController, onShove pointersAngleDeg: Double, initial: CGPoint, start: CGPoint, end: CGPoint
    ) {

        self.savePositionTrackerState()
    }

    func savePositionTrackerState() {

        guard self.navigationContext != nil else { return }

        guard let mapViewController = self.mapViewController else { return }

        let isFollowingPosition = mapViewController.isFollowingPosition()

        if isFollowingPosition {

            if let state = mapViewController.saveStatePositionTracker() {

                self.positionTrackerState = state

                self.resetFollowPreferencesButton!.isHidden = false
            }
        }
    }

    // MARK: - NavigationContextDelegate

    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationStatusChanged status: NavigationStatus) {

    }

    func navigationContext(_ navigationContext: NavigationContext, navigationStartedForRoute route: RouteObject) {

        self.mapViewController!.startFollowingPosition(withAnimationDuration: 1200, zoomLevel: -1) { (success: Bool) in }
    }

    func navigationContext(
        _ navigationContext: NavigationContext, navigationInstructionUpdatedForRoute route: RouteObject, updatedEvents: Int32
    ) {

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

    func navigationContext(
        _ navigationContext: NavigationContext, route: RouteObject, navigationDestinationReached waypoint: LandmarkObject
    ) {

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

    func navigationContext(
        _ navigationContext: NavigationContext, onBetterRouteDetected route: RouteObject, travelTime: Int, delay: Int, timeGain: Int
    ) {

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
        NSLayoutConstraint.activate([
            self.panelNavigationViewController!.view!.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 5),
            self.panelNavigationViewController!.view!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            self.panelNavigationViewController!.view!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            self.panelNavigationViewController!.view!.heightAnchor.constraint(equalToConstant: height)
        ])
    }

    func areaEdge(margin: CGFloat) -> UIEdgeInsets {

        let scale = UIScreen.main.scale

        let insets = UIEdgeInsets.init(
            top: (self.view.safeAreaInsets.top + margin) * scale,
            left: margin * scale,
            bottom: self.view.safeAreaInsets.bottom * scale,
            right: margin * scale)

        return insets
    }
}
