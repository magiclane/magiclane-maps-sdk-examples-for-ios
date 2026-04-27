// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import UIKit
import GEMKit

class ViewController: UIViewController, MapViewControllerDelegate, NavigationContextDelegate {

    var mapViewController: MapViewController?
    var navigationContext: NavigationContext?

    var mainRoute: RouteObject?
    var routeResults: [RouteObject] = []

    let defaultHighlightId: Int32 = 10

    var searchContext: SearchContext?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        if let navigationController = self.navigationController {

            let appearance = navigationController.navigationBar.standardAppearance

            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }

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

        self.mapViewController!.setEdgeAreaInsets(UIEdgeInsets(top: 30, left: 40, bottom: 30, right: 40))

        self.mapViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.mapViewController!.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.mapViewController!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.mapViewController!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.mapViewController!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }

    // MARK: - Buttons

    func addRouteButton() {

        var image = UIImage.init(systemName: "point.topleft.down.curvedto.point.bottomright.up")
        let barButton1 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(routeButtonAction))

        image = UIImage.init(systemName: "clear")
        let barButton2 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(clearRouteButtonAction))

        self.navigationItem.rightBarButtonItems = [barButton1, barButton2]
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

        let waypoints = [

            LandmarkObject.landmark(
                withName: "San Francisco", location: CoordinatesObject.coordinates(withLatitude: 37.77903, longitude: -122.41991)),
            LandmarkObject.landmark(
                withName: "San Jose", location: CoordinatesObject.coordinates(withLatitude: 37.33619, longitude: -121.89058))
        ]

        item.isEnabled = false

        self.navigationContext?
            .calculateRoute(
                withWaypoints: waypoints,
                completionHandler: { [weak self] (results: [RouteObject]) in

                    guard let strongSelf = self else { return }

                    NSLog("Found %d routes.", results.count)

                    strongSelf.routeResults = results

                    for route in results {

                        if let timeDistance = route.getTimeDistance() {

                            let time = timeDistance.getTotalTimeFormatted() + timeDistance.getTotalTimeUnitFormatted()
                            let distance = timeDistance.getTotalDistanceFormatted() + timeDistance.getTotalDistanceUnitFormatted()

                            NSLog("route time:%@, distance:%@", time, distance)
                        }
                    }

                    if !results.isEmpty {

                        strongSelf.mainRoute = results.first
                        strongSelf.addSearch()

                        strongSelf.mapViewController?.presentRoutes(results, withTraffic: nil, showSummary: true, animationDuration: 1000)
                    }

                    item.isEnabled = true
                })
    }

    @objc func clearRouteButtonAction(item: UIBarButtonItem) {

        self.mapViewController?.removeAllRoutes()
        self.mapViewController?.removeHighlights()
    }

    func addSearch() {

        let image1 = UIImage.init(systemName: "magnifyingglass")

        let barButton1 = UIBarButtonItem.init(image: image1, style: .done, target: self, action: #selector(searchButton))

        self.navigationItem.leftBarButtonItems = [barButton1]
    }

    @objc func searchButton() {

        guard let mainRoute = self.mainRoute else {
            return
        }

        if self.searchContext == nil {

            self.searchContext = SearchContext.init()

            // Preferences
            self.searchContext?.setMaxMatches(40)
            self.searchContext?.setSearchMapPOIs(true)
            self.searchContext?.setSearchAddresses(true)
        }

        self.searchContext!
            .searchAlong(withRoute: mainRoute, query: "Gas station") { [weak self] (results: [LandmarkObject]) in

                guard let strongSelf = self else { return }

                let settings = HighlightRenderSettings()

                settings.imageSize = 7
                settings.options = Int32(HighlightOption.group.rawValue)

                strongSelf.mapViewController?.presentHighlights(results, settings: settings, highlightId: strongSelf.defaultHighlightId)
            }
    }

    // MARK: - MapViewControllerDelegate

    func mapViewController(_ mapViewController: MapViewController, didSelectRoute route: RouteObject) {

        self.mainRoute = route

        mapViewController.setMainRoute(route)
    }

    func mapViewController(
        _ mapViewController: MapViewController, onPinch startPoint1: CGPoint, startPoint2: CGPoint, toPoint1 endPoint1: CGPoint,
        toPoint2 endPoint2: CGPoint
    ) {

    }
}
