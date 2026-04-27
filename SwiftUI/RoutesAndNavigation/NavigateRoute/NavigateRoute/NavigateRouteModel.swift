// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit
import CoreLocation

// MARK: - Navigate Route Model

@MainActor
class NavigateRouteModel: NSObject, ObservableObject, CLLocationManagerDelegate {

    // MARK: Published States

    @Published var isLocationAvailable: Bool = false
    @Published var isCalculating: Bool = false
    @Published var isNavigating: Bool = false
    @Published var showLabel: Bool = true
    @Published var labelText: String = "Select a point on the map and tap the route button."
    @Published var navigationInstruction: NavigationInstructionObject?
    @Published var alarmItems: [OverlayItemObject] = []

    @Published var presentedRoutes: [RouteObject] = []

    // MARK: GEMKit Contexts

    private(set) var navigationContext: NavigationContext?
    private(set) var trafficContext: TrafficContext?
    private(set) var soundContext: SoundContext?
    private(set) var alarmContext: AlarmContext?
    private(set) var mainRoute: RouteObject?

    private var dataSource: DataSourceContext?
    private var positionContext: PositionContext?
    private var destination: LandmarkObject?
    private var routeResults: [RouteObject] = []

    // MARK: Delegates (stored to keep alive)

    private var navigationHandler: NavigationHandler?

    // MARK: Location

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        isLocationAvailable = locationManager.authorizationStatus == .authorizedWhenInUse
    }

    func requestLocationPermission() {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let available = manager.authorizationStatus == .authorizedWhenInUse
        Task { @MainActor in
            isLocationAvailable = available
        }
    }

    // MARK: - Setup

    func setupDataSource() {

        guard dataSource == nil else { return }

        let configuration = DataSourceConfigurationObject()
        configuration.setPositionDistanceFilter(0)
        configuration.setPositionAccuracy(.whenMoving)
        configuration.setPositionActivity(.automotive)
        configuration.setAllowBackgroundLocationUpdates(false)

        dataSource = DataSourceContext()
        dataSource!.setConfiguration(configuration, for: .improvedPosition)

        positionContext = PositionContext(context: dataSource!)
        positionContext!.startUpdatingPositionDelegate(.improvedPosition)
    }

    func setupLocation() {

        if isLocationAvailable {
            dataSource?.start()
        }
    }

    func onLocationBecameAvailable(_ proxy: MapProxy) {

        dataSource?.start()
        startFollowLocation(proxy, animation: 0)
    }

    func setupFollowPositionPreferences(_ proxy: MapProxy) {

        guard let mapViewController = proxy.mapViewController else { return }

        // Set follow position preferences
        let followPrefs = mapViewController.getPreferences().getFollowPositionPreferences()
        followPrefs.setTouchHandlerModifyPersistent(true)
    }

    func landmarkSelected(_ proxy: MapProxy, landmark: LandmarkObject) {

        guard self.mainRoute == nil else { return }
        self.destination = landmark
        self.showLandmark(proxy, landmark: landmark)
    }

    func routeSelected(_ proxy: MapProxy, route: RouteObject) {

        self.mainRoute = route
        proxy.setMain(route: route)
    }

    // MARK: - Location Following

    func startFollowLocation(_ proxy: MapProxy, animation: TimeInterval = 1000) {

        guard isLocationAvailable else {
            requestLocationPermission()
            return
        }

        proxy.mapViewController?.startFollowingPosition(withAnimationDuration: animation, zoomLevel: -1) { _ in }
    }

    // MARK: - Route Calculation

    func calculateRoute(_ proxy: MapProxy) {

        guard let positionContext = positionContext, let position = positionContext.getPosition() else { return }

        let location = position.getCoordinates()
        guard location.isValid() else { return }

        let departure = LandmarkObject.landmark(withName: "My Position", location: location)
        guard let destination = destination else { return }

        if navigationContext == nil {

            let preferences = RoutePreferencesObject()
            preferences.setTransportMode(.car)
            preferences.setRouteType(.fastest)
            preferences.setAvoidMotorways(false)
            preferences.setAvoidTollRoads(false)
            preferences.setAvoidFerries(false)
            preferences.setAvoidUnpavedRoads(true)

            navigationContext = NavigationContext(preferences: preferences)
        }

        if trafficContext == nil {

            trafficContext = TrafficContext()
            trafficContext?.setUseTraffic(.useOnline)
        }

        if soundContext == nil {

            soundContext = SoundContext()
            soundContext?.setUseTtsWithCompletionHandler({ _ in })
        }

        if alarmContext == nil {

            alarmContext = AlarmContext()
            alarmContext?.setAlarmDistance(600)
            alarmContext?.setMonitorWithoutRoute(false)

            alarmContext?.registerSafetyCameraNotifications(completionHandler: { success in
                NSLog("AlarmContext: registerSafetyCamera with success:%@", String(success))
            })

            alarmContext?.registerSocialReportNotifications(completionHandler: { success in
                NSLog("AlarmContext: registerSocialReport with success:%@", String(success))
            })
        }

        let waypoints = [departure, destination]
        isCalculating = true

        navigationContext?.calculateRoute(withWaypoints: waypoints, completionHandler: { [weak self] results in

            Task { @MainActor in
                guard let self else { return }

                NSLog("Found %d routes.", results.count)

                self.routeResults = results

                for route in results {
                    if let timeDuration = route.getTimeDistance() {
                        let time = timeDuration.getTotalTimeFormatted() + timeDuration.getTotalTimeUnitFormatted()
                        let distance = timeDuration.getTotalDistanceFormatted() + timeDuration.getTotalDistanceUnitFormatted()
                        NSLog("route time:%@, distance:%@", time, distance)
                    }
                }

                if !results.isEmpty {

                    self.presentedRoutes = results
                    self.mainRoute = results.first
                }

                self.isCalculating = false
            }
        })
    }

    // MARK: - Navigation

    func startNavigation(_ proxy: MapProxy) {

        guard let mapViewController = proxy.mapViewController,
              let navigationContext = navigationContext,
              let mainRoute = mainRoute
        else { return }

        // Restore follow position in case it was changed by pinch gesture
        mapViewController.restoreFollowingPosition(withAnimationDuration: 0) { _ in }
        mapViewController.removeAllRoutes()

        // Set navigation delegate
        let navDelegate = NavigationHandler(
            onInstructionUpdated: { [weak self] context, route in

                guard let self else { return }

                let eta = context.getEstimateTimeOfArrivalFormatted() + context.getEstimateTimeOfArrivalUnitFormatted()
                let rtt = context.getRemainingTravelTimeFormatted() + context.getRemainingTravelTimeUnitFormatted()
                let rtd = context.getRemainingTravelDistanceFormatted() + context.getRemainingTravelDistanceUnitFormatted()

                labelText = eta + "     " + rtt + "     " + rtd
                showLabel = true
                isNavigating = true
                alarmItems = alarmContext?.getOverlayItemAlarms() ?? []
                navigationInstruction = context.getNavigationInstruction()
            },
            onDestinationReached: { [weak self] in
                self?.stopNavigation(proxy)
            },
            onSound: { [weak self] sound in
                self?.soundContext?.playSound(sound)
            }
        )

        navigationContext.delegate = navDelegate
        navigationHandler = navDelegate

        navigationContext.navigate(withRoute: mainRoute) { [weak self] success in

            Task { @MainActor in

                guard let self else { return }
                guard let mainRoute = self.mainRoute else { return }

                if success {

                    proxy.removeAllRoutes()
                    mapViewController.hideCompass()
                    
                    self.presentedRoutes = [mainRoute]
                    self.startFollowLocation(proxy)
                }
            }
        }
    }

    func stopNavigation(_ proxy: MapProxy) {

        guard let mapViewController = proxy.mapViewController else { return }

        mapViewController.stopFollowingPosition()
        navigationContext?.cancelNavigateRoute()

        clearRoute(proxy)

        isNavigating = false
        navigationInstruction = nil
        navigationContext = nil
        navigationHandler = nil
        alarmItems = []

        mapViewController.showCompass()

        mapViewController.setPerspective(.view2D, animationDuration: 600) { _ in

            DispatchQueue.main.async {
                mapViewController.alignNorthUp(withAnimationDuration: 1200) { _ in }
            }
        }
    }

    // MARK: - Clear

    func clearRoute(_ proxy: MapProxy) {

        mainRoute = nil
        destination = nil
        presentedRoutes = []

        proxy.removeAllHighlights()
        proxy.removeAllRoutes()

        showLabel = true
        labelText = "Select a point on the map and tap the route button."
    }

    // MARK: - Utils

    func showLandmark(_ proxy: MapProxy, landmark: LandmarkObject) {

        guard let mapViewController = proxy.mapViewController else { return }

        let text = "  " + landmark.getLandmarkName() + "\n" + "  " + landmark.getLandmarkDescription()

        labelText = text
        showLabel = true

        let settings = HighlightRenderSettings()
        settings.showPin = true

        if landmark.isContourGeograficAreaEmpty() == false {

            settings.options = Int32(
                HighlightOption.showLandmark.rawValue | HighlightOption.overlap.rawValue | HighlightOption.showContour.rawValue)
            settings.contourInnerColor = .systemBlue
            settings.contourOuterColor = .systemBlue
        }

        mapViewController.presentHighlights([landmark], settings: settings)
    }
}

// MARK: - Navigation Delegate Handler

class NavigationHandler: NSObject, NavigationContextDelegate {

    let onInstructionUpdated: (NavigationContext, RouteObject) -> Void
    let onDestinationReached: () -> Void
    let onSound: (SoundObject) -> Void

    init(
        onInstructionUpdated: @escaping (NavigationContext, RouteObject) -> Void,
        onDestinationReached: @escaping () -> Void,
        onSound: @escaping (SoundObject) -> Void
    ) {
        self.onInstructionUpdated = onInstructionUpdated
        self.onDestinationReached = onDestinationReached
        self.onSound = onSound
    }

    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationStatusChanged status: NavigationStatus) {}

    func navigationContext(_ navigationContext: NavigationContext, navigationStartedForRoute route: RouteObject) {}

    func navigationContext(_ navigationContext: NavigationContext, navigationInstructionUpdatedForRoute route: RouteObject, updatedEvents: Int32) {

        if let instruction = navigationContext.getNavigationInstruction(), instruction.getNavigationStatus() == .running {
            if instruction.hasNextTurnInfo() {
                onInstructionUpdated(navigationContext, route)
            }
        }
    }

    func navigationContext(_ navigationContext: NavigationContext, navigationRouteUpdated route: RouteObject) {}

    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationWaypointReached waypoint: LandmarkObject) {}

    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationDestinationReached waypoint: LandmarkObject) {
        onDestinationReached()
    }

    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject?, navigationError code: Int) {}

    func navigationContext(_ navigationContext: NavigationContext, canPlayNavigationSoundForRoute route: RouteObject) -> Bool {
        return true
    }

    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationSound sound: SoundObject) {
        onSound(sound)
    }

    func navigationContext(_ navigationContext: NavigationContext, onBetterRouteDetected route: RouteObject, travelTime: Int, delay: Int, timeGain: Int) {}

    func navigationContext(_ navigationContext: NavigationContext, onBetterRouteInvalidated state: Bool) {}
}
