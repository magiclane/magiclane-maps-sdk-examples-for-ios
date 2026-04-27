// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit

// MARK: - Simulate Route Model

@MainActor
class SimulateRouteModel: NSObject, ObservableObject {

    // MARK: Published States

    @Published var isCalculating: Bool = false
    @Published var isSimulating: Bool = false
    @Published var showLabel: Bool = false
    @Published var labelText: String = ""
    @Published var navigationInstruction: NavigationInstructionObject?
    @Published var alarmItems: [OverlayItemObject] = []
    
    @Published var presentedRoutes: [RouteObject] = []

    // MARK: GEMKit Contexts

    private(set) var navigationContext: NavigationContext?
    private(set) var trafficContext: TrafficContext?
    private(set) var soundContext: SoundContext?
    private(set) var alarmContext: AlarmContext?
    private(set) var mainRoute: RouteObject?

    private var routeResults: [RouteObject] = []

    // MARK: Delegates (stored to keep alive)

    private var navigationHandler: NavigationHandler?

    // MARK: - Setup

    func setupFollowPositionPreferences(_ proxy: MapProxy) {

        guard let mapViewController = proxy.mapViewController else { return }

        let followPrefs = mapViewController.getPreferences().getFollowPositionPreferences()
        followPrefs.setTouchHandlerModifyPersistent(true)
    }

    func routeSelected(_ proxy: MapProxy, route: RouteObject) {

        self.mainRoute = route
        proxy.setMain(route: route)
    }

    // MARK: - Route Calculation

    func calculateRoute(_ proxy: MapProxy) {

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

        let departure = LandmarkObject.landmark(
            withName: "Munich 1",
            location: CoordinatesObject.coordinates(withLatitude: 48.15741, longitude: 11.53739))
        let destination = LandmarkObject.landmark(
            withName: "Munich 2",
            location: CoordinatesObject.coordinates(withLatitude: 48.166730, longitude: 11.53687))

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

    // MARK: - Simulation

    func startSimulation(_ proxy: MapProxy) {

        guard let mapViewController = proxy.mapViewController,
              let navigationContext = navigationContext,
              let mainRoute = mainRoute
        else { return }

        mapViewController.restoreFollowingPosition(withAnimationDuration: 0) { _ in }
        mapViewController.removeAllRoutes()

        let navDelegate = NavigationHandler(
            onNavigationStarted: { [weak self] context, route in
                self?.startFollowPosition(proxy)
            },
            onInstructionUpdated: { [weak self] context, route in

                guard let self else { return }

                let eta = context.getEstimateTimeOfArrivalFormatted() + context.getEstimateTimeOfArrivalUnitFormatted()
                let rtt = context.getRemainingTravelTimeFormatted() + context.getRemainingTravelTimeUnitFormatted()
                let rtd = context.getRemainingTravelDistanceFormatted() + context.getRemainingTravelDistanceUnitFormatted()

                labelText = eta + "     " + rtt + "     " + rtd
                showLabel = true
                isSimulating = true
                navigationInstruction = context.getNavigationInstruction()
                alarmItems = alarmContext?.getOverlayItemAlarms() ?? []
            },
            onDestinationReached: { [weak self] in
                self?.stopSimulation(proxy)
            },
            onSound: { [weak self] sound in
                self?.soundContext?.playSound(sound)
            }
        )

        navigationContext.delegate = navDelegate
        navigationHandler = navDelegate

        navigationContext.simulate(withRoute: mainRoute, speedMultiplier: 2) { [weak self] success in

            Task { @MainActor in

                guard let self else { return }
                guard let mainRoute = self.mainRoute else { return }

                if success {

                    proxy.removeAllRoutes()
                    mapViewController.hideCompass()
                    self.presentedRoutes = [mainRoute]
                }
            }
        }
    }

    func stopSimulation(_ proxy: MapProxy) {

        guard let mapViewController = proxy.mapViewController else { return }

        mapViewController.stopFollowingPosition()
        navigationContext?.cancelSimulateRoute()

        clearRoute(proxy)

        isSimulating = false
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
        presentedRoutes = []
        
        proxy.removeAllHighlights()
        proxy.removeAllRoutes()

        showLabel = false
    }

    // MARK: - Utils

    private func startFollowPosition(_ proxy: MapProxy) {

        proxy.mapViewController?.startFollowingPosition(withAnimationDuration: 1200, zoomLevel: -1) { _ in }
    }
}

// MARK: - Navigation Delegate Handler

class NavigationHandler: NSObject, NavigationContextDelegate {

    let onNavigationStarted: (NavigationContext, RouteObject) -> Void
    let onInstructionUpdated: (NavigationContext, RouteObject) -> Void
    let onDestinationReached: () -> Void
    let onSound: (SoundObject) -> Void

    init(
        onNavigationStarted: @escaping (NavigationContext, RouteObject) -> Void,
        onInstructionUpdated: @escaping (NavigationContext, RouteObject) -> Void,
        onDestinationReached: @escaping () -> Void,
        onSound: @escaping (SoundObject) -> Void
    ) {
        self.onNavigationStarted = onNavigationStarted
        self.onInstructionUpdated = onInstructionUpdated
        self.onDestinationReached = onDestinationReached
        self.onSound = onSound
    }

    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationStatusChanged status: NavigationStatus) {}

    func navigationContext(_ navigationContext: NavigationContext, navigationStartedForRoute route: RouteObject) {
        onNavigationStarted(navigationContext, route)
    }

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
