// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import UIKit
import GEMKit

class ViewController: UIViewController {

    var mapViewController: MapViewController?

    var searchContext: SearchContext?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        if let navigationController = self.navigationController {

            let appearance = navigationController.navigationBar.standardAppearance

            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }

        self.createMapView()

        self.mapViewController!.startRender()

        self.addSearch()
    }

    // MARK: - Map View

    func createMapView() {

        self.mapViewController = MapViewController.init()
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

    // MARK: - Search

    func addSearch() {

        let barButton = UIBarButtonItem.init(barButtonSystemItem: .search, target: self, action: #selector(searchButton))

        self.navigationItem.rightBarButtonItems = [barButton]
    }

    @objc func searchButton(item: UIBarButtonItem) {

        if self.searchContext == nil {

            self.searchContext = SearchContext.init()
            self.searchContext?.setMaxMatches(40)
            self.searchContext?.setSearchMapPOIs(true)
        }

        let location = CoordinatesObject.coordinates(withLatitude: 48.840827, longitude: 2.371899)

        self.mapViewController!.center(onCoordinates: location, zoomLevel: 60, animationDuration: 1200)

        self.searchContext?
            .search(withQuery: "store", location: location) { (results: [LandmarkObject]) in

                for landmark in results {

                    NSLog("results:%@", landmark.getLandmarkName())
                }

                if !results.isEmpty {

                    self.mapViewController!.removeHighlights()

                    let settings = HighlightRenderSettings.init()

                    self.mapViewController!.presentHighlights(results, settings: settings)
                }
            }
    }
}
