// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import UIKit
import GEMKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MapViewControllerDelegate, NavigationContextDelegate,
    PositionContextDelegate
{

    var mapViewController: MapViewController?

    var locationManager: CLLocationManager?

    var navigationContext: NavigationContext?
    var trafficContext: TrafficContext?
    var mainRoute: RouteObject?
    var myResults: [RouteObject] = []
    var departure: LandmarkObject?
    var destination: LandmarkObject?
    var soundContext: SoundContext?
    var alarmContext: AlarmContext?

    var positionContext: PositionContext?

    var dataSource: DataSourceContext?

    var label = UILabel.init()

    var panelNavigationViewController: NavigationViewController?

    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view.

        if let navigationController = self.navigationController {

            let appearance = navigationController.navigationBar.standardAppearance

            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }

        let configuration = DataSourceConfigurationObject.init()
        configuration.setPositionDistanceFilter(0)
        configuration.setPositionAccuracy(.whenMoving)
        configuration.setPositionActivity(.automotive)
        configuration.setAllowBackgroundLocationUpdates(true)

        self.dataSource = DataSourceContext.init()
        self.dataSource!.setConfiguration(configuration, for: .improvedPosition)

        self.positionContext = PositionContext.init(context: self.dataSource!)
        self.positionContext!.delegate = self
        self.positionContext!.startUpdatingPositionDelegate(.improvedPosition)

        self.title = "Navigate Route"
        self.navigationItem.largeTitleDisplayMode = .never

        self.createMapView()

        self.setMapFollowPositionPreferences()
        
        self.mapViewController!.startRender()

        self.refreshLocationButton()

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
        
        // Allow user to change follow position angle and zoom by touch (pinch or 2xfinger drag)
        followPositionPreferences.setTouchHandlerModifyPersistent(true)
    }

    // MARK: - Buttons

    func refreshLocationButton() {

        if self.locationManager == nil {

            self.locationManager = CLLocationManager.init()
            self.locationManager!.delegate = self
        }

        if self.isLocationAvailable() {

            if let context = self.dataSource {

                if context.isStopped() == false {

                    context.start()
                }
            }
        }

        let image = self.isLocationAvailable() ? UIImage.init(systemName: "location") : UIImage.init(systemName: "location.slash")

        let barButton = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(startFollowLocation))
        self.navigationItem.leftBarButtonItem = barButton
    }

    @objc func startFollowLocation(animation: TimeInterval = 1000) {

        if self.isLocationAvailable() == false {

            self.requestLocationPermission()

        } else {

            self.addRouteButton()

            self.mapViewController!.startFollowingPosition(withAnimationDuration: animation, zoomLevel: -1) { success in }
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

        self.refreshLocationButton()

        if manager.authorizationStatus == .authorizedWhenInUse {

            self.startFollowLocation(animation: 0)
        }
    }

    func addRouteButton() {

        var image = UIImage.init(systemName: "point.topleft.down.curvedto.point.bottomright.up")
        let barButton1 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(routeButtonAction(item:)))

        image = UIImage.init(systemName: "clear")
        let barButton2 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(clearButtonAction))

        image = UIImage.init(systemName: "play")
        let barButton3 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(startNavigation(item:)))

        self.navigationItem.rightBarButtonItems = [barButton1, barButton2, barButton3]
    }

    // MARK: - Label

    func addLabelText() {

        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(startFollowLocation))

        self.label.font = UIFont.boldSystemFont(ofSize: 20)
        self.label.numberOfLines = 0
        self.label.backgroundColor = UIColor.systemBackground
        self.label.isHidden = false
        self.label.textAlignment = .center
        self.label.isUserInteractionEnabled = true
        self.label.addGestureRecognizer(tapGesture)

        self.label.layer.borderColor = UIColor.systemBlue.cgColor
        self.label.layer.borderWidth = 1.4
        self.label.layer.cornerRadius = 8.0
        self.label.layer.masksToBounds = true
        
        self.label.text = "Select a point on the map and tap the route button."

        self.view.addSubview(self.label)

        self.label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.label.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            self.label.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            self.label.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            self.label.heightAnchor.constraint(equalToConstant: 54)
        ])
    }

    @objc func stopButtonAction() {

        guard self.panelNavigationViewController != nil else { return }

        self.mapViewController!.stopFollowingPosition()

        self.navigationContext!.cancelNavigateRoute()

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

    @objc func routeButtonAction(item: UIBarButtonItem) {

        guard let positionContext = self.positionContext else { return }

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

        guard let position = positionContext.getPosition() else { return }

        let location = position.getCoordinates()

        if location.isValid() == false {

            return
        }

        self.departure = LandmarkObject.landmark(withName: "My Position", location: location)

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

                        strongSelf.mapViewController?
                            .presentRoutes(results, withTraffic: strongSelf.trafficContext, showSummary: true, animationDuration: 1000)
                    }

                    item.isEnabled = true
                })
    }

    @objc func clearButtonAction() {

        self.mainRoute = nil

        self.destination = nil

        self.mapViewController?.removeHighlights()

        self.mapViewController?.removeAllRoutes()

        self.label.isHidden = false
        
        self.label.text = "Select a point on the map and tap the route button."
    }

    @objc func startNavigation(item: UIBarButtonItem) {

        guard self.mainRoute != nil else { return }

        // restore to default in case it was changed by pinch gesture
        self.mapViewController!.restoreFollowingPosition(withAnimationDuration: 0) { success in }
        
        self.mapViewController!.removeAllRoutes()

        self.navigationContext!
            .navigate(withRoute: self.mainRoute!) { [weak self] (success) in

                guard let strongSelf = self else { return }

                if success {

                    strongSelf.mapViewController!.hideCompass()

                    strongSelf.mapViewController!
                        .presentRoutes(
                            [strongSelf.mainRoute!], withTraffic: strongSelf.trafficContext!, showSummary: false, animationDuration: 1600)
                    
                    strongSelf.startFollowLocation()
                }
            }
    }

    // MARK: - PositionContextDelegate

    func positionContext(_ positionContext: PositionContext, didUpdatePosition position: PositionObject) {

        /*if position.hasTerrainData() {

            let slope    = position.getTerrainSlope()
            let altitude = position.getTerrainAltitude()

            NSLog("slope:%f, altitude:%f", slope, altitude)
        }*/
    }

    // MARK: - MapViewControllerDelegate

    func mapViewController(_ mapViewController: MapViewController, didSelectLandmarks landmarks: [LandmarkObject], onTouch point: CGPoint) {

        guard let landmark = landmarks.first else { return }

        self.processSelection(landmark: landmark)
    }

    func mapViewController(
        _ mapViewController: MapViewController, didSelectLandmarks landmarks: [LandmarkObject], onLongTouch point: CGPoint
    ) {

        guard let landmark = landmarks.first else { return }

        self.processSelection(landmark: landmark)
    }

    func mapViewController(_ mapViewController: MapViewController, didSelectStreets streets: [LandmarkObject], onTouch point: CGPoint) {

        guard let landmark = streets.first else { return }

        self.processSelection(landmark: landmark)
    }

    func mapViewController(_ mapViewController: MapViewController, didSelectStreets streets: [LandmarkObject], onLongTouch point: CGPoint) {

        guard let landmark = streets.first else { return }

        self.processSelection(landmark: landmark)
    }

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

                self.panelNavigationViewController?.updateTrafficInformation(navigationContext: navigationContext, route: route)

                self.panelNavigationViewController?.updateSignpostInformation(navigationContext: navigationContext)

                self.panelNavigationViewController?.updateRoadCodeInformation(navigationContext: navigationContext)

                self.panelNavigationViewController?
                    .updateSafetyCameraInformation(navigationContext: navigationContext, alarmContext: self.alarmContext!)

                self.panelNavigationViewController?
                    .updateSocialReportInformation(navigationContext: navigationContext, alarmContext: self.alarmContext!)

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

    // MARK: - Utils

    func showLandmark(landmark: LandmarkObject, centerLayout: Bool) {

        let text = "  " + landmark.getLandmarkName() + "\n" + "  " + landmark.getLandmarkDescription()

        self.label.text = text
        self.label.isHidden = false

        let settings = HighlightRenderSettings.init()
        settings.showPin = true

        if landmark.isContourGeograficAreaEmpty() == false {

            settings.options = Int32(
                HighlightOption.showLandmark.rawValue | HighlightOption.overlap.rawValue | HighlightOption.showContour.rawValue)
            settings.contourInnerColor = UIColor.systemBlue
            settings.contourOuterColor = UIColor.systemBlue
        }

        self.mapViewController!.presentHighlights([landmark], settings: settings)

        if centerLayout {

            self.mapViewController!.center(onCoordinates: landmark.getCoordinates(), zoomLevel: -1, animationDuration: 600)
        }
    }

    func processSelection(landmark: LandmarkObject) {

        guard self.mainRoute == nil else { return }

        self.destination = landmark

        self.showLandmark(landmark: landmark, centerLayout: false)
    }
}
