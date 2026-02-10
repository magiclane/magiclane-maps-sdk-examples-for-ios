// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import UIKit
import GEMKit

class ViewController: UIViewController, UISearchBarDelegate {

    var mapViewController1: MapViewController?
    var mapViewController2: MapViewController?

    var navigationContext1: NavigationContext?
    var navigationContext2: NavigationContext?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        if let navigationController = self.navigationController {

            let appearance = navigationController.navigationBar.standardAppearance

            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }

        self.title = "Multi Map Route"
        self.view.backgroundColor = UIColor.lightGray
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.largeTitleDisplayMode = .never

        self.addRouteButton()
    }

    // MARK: - Map View

    func createMap1View() {

        self.mapViewController1 = MapViewController.init()
        self.mapViewController1!.view.backgroundColor = UIColor.systemBackground

        self.mapViewController1!.view.layer.cornerRadius = 8
        self.mapViewController1!.view.layer.masksToBounds = true

        self.addChild(self.mapViewController1!)
        self.view.addSubview(self.mapViewController1!.view)
        self.mapViewController1!.didMove(toParent: self)

        self.mapViewController1?.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.mapViewController1!.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 15),
            self.mapViewController1!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            self.mapViewController1!.view.bottomAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.mapViewController1!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15)
        ])

        self.mapViewController1!.startRender()
    }

    func createMap2View() {

        self.mapViewController2 = MapViewController.init()
        self.mapViewController2!.view.backgroundColor = UIColor.systemBackground

        self.mapViewController2!.view.layer.cornerRadius = 8
        self.mapViewController2!.view.layer.masksToBounds = true

        self.addChild(self.mapViewController2!)
        self.view.addSubview(self.mapViewController2!.view)
        self.mapViewController2!.didMove(toParent: self)

        self.mapViewController2?.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.mapViewController2!.view.topAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 10),
            self.mapViewController2!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            self.mapViewController2!.view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -5),
            self.mapViewController2!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15)
        ])

        self.mapViewController2!.startRender()
    }

    func addRouteButton() {

        var image = UIImage.init(systemName: "point.topleft.down.curvedto.point.bottomright.up")
        let barButton1 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(route1ButtonAction(item:)))

        image = UIImage.init(systemName: "point.topleft.down.curvedto.point.bottomright.up")
        let barButton2 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(route2ButtonAction(item:)))

        image = UIImage.init(systemName: "clear")
        let barButton = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(clearRouteButtonAction(item:)))

        self.navigationItem.rightBarButtonItems = [barButton1, barButton2]
        self.navigationItem.leftBarButtonItems = [barButton]
    }

    @objc func route1ButtonAction(item: UIBarButtonItem) {

        if self.navigationContext1 == nil {

            self.createMap1View()

            let preferences = RoutePreferencesObject.init()
            preferences.setTransportMode(.car)
            preferences.setRouteType(.fastest)
            preferences.setAvoidMotorways(false)
            preferences.setAvoidTollRoads(false)
            preferences.setAvoidFerries(false)
            preferences.setAvoidUnpavedRoads(true)

            self.navigationContext1 = NavigationContext.init(preferences: preferences)

            return
        }

        self.mapViewController1?.removeAllRoutes()

        item.isEnabled = false

        let waypoints = [

            LandmarkObject.landmark(
                withName: "San Francisco", location: CoordinatesObject.coordinates(withLatitude: 37.77903, longitude: -122.41991)),
            LandmarkObject.landmark(
                withName: "San Jose", location: CoordinatesObject.coordinates(withLatitude: 37.33619, longitude: -121.89058))
        ]

        self.navigationContext1?
            .calculateRoute(
                withWaypoints: waypoints,
                completionHandler: { [weak self] (results: [RouteObject]) in

                    guard let strongSelf = self else { return }

                    for route in results {

                        if let timeDuration = route.getTimeDistance() {

                            let time = timeDuration.getTotalTimeFormatted() + timeDuration.getTotalTimeUnitFormatted()
                            let distance = timeDuration.getTotalDistanceFormatted() + timeDuration.getTotalDistanceUnitFormatted()

                            NSLog("route time:%@, distance:%@", time, distance)
                        }
                    }

                    if !results.isEmpty {

                        strongSelf.mapViewController1?.presentRoutes(results, withTraffic: nil, showSummary: true, animationDuration: 1000)
                    }

                    item.isEnabled = true
                })
    }

    @objc func route2ButtonAction(item: UIBarButtonItem) {

        if self.navigationContext2 == nil {

            self.createMap2View()

            let preferences = RoutePreferencesObject.init()
            preferences.setTransportMode(.car)
            preferences.setRouteType(.fastest)
            preferences.setAvoidMotorways(false)
            preferences.setAvoidTollRoads(false)
            preferences.setAvoidFerries(false)
            preferences.setAvoidUnpavedRoads(true)

            self.navigationContext2 = NavigationContext.init(preferences: preferences)

            return
        }

        self.mapViewController2?.removeAllRoutes()

        item.isEnabled = false

        let waypoints = [

            LandmarkObject.landmark(
                withName: "London", location: CoordinatesObject.coordinates(withLatitude: 51.50732, longitude: -0.12765)),
            LandmarkObject.landmark(
                withName: "Maidstone", location: CoordinatesObject.coordinates(withLatitude: 51.27483, longitude: 0.52316))
        ]

        self.navigationContext2?
            .calculateRoute(
                withWaypoints: waypoints,
                completionHandler: { [weak self] (results: [RouteObject]) in

                    guard let strongSelf = self else { return }

                    for route in results {

                        if let timeDuration = route.getTimeDistance() {

                            let time = timeDuration.getTotalTimeFormatted() + timeDuration.getTotalTimeUnitFormatted()
                            let distance = timeDuration.getTotalDistanceFormatted() + timeDuration.getTotalDistanceUnitFormatted()

                            NSLog("route time:%@, distance:%@", time, distance)
                        }
                    }

                    if !results.isEmpty {

                        strongSelf.mapViewController2?.presentRoutes(results, withTraffic: nil, showSummary: true, animationDuration: 1000)
                    }

                    item.isEnabled = true
                })
    }

    @objc func clearRouteButtonAction(item: UIBarButtonItem) {

        self.mapViewController1?.removeAllRoutes()
        self.mapViewController2?.removeAllRoutes()
    }
}
