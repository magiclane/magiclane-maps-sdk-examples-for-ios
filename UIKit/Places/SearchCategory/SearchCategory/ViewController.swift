// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import UIKit
import GEMKit

class ViewController: UIViewController {

    var mapViewController: MapViewController?

    var searchContext: SearchContext?

    var categoryContext: GenericCategoriesContext?

    let location = CoordinatesObject.coordinates(withLatitude: 48.840827, longitude: 2.371899)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        if let navigationController = self.navigationController {

            let appearance = navigationController.navigationBar.standardAppearance

            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }

        self.createMapView()

        self.mapViewController!.startRender()

        self.searchContext = SearchContext.init()
        self.searchContext?.setMaxMatches(40)
        self.searchContext?.setSearchMapPOIs(true)

        self.categoryContext = GenericCategoriesContext.init()

        self.addSearchButtons()
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

    func addSearchButtons() {

        let barButton1 = UIBarButtonItem.init(title: "Accommodation", style: .done, target: self, action: #selector(searchButton1))

        let barButton2 = UIBarButtonItem.init(title: "Gas Station", style: .done, target: self, action: #selector(searchButton2))

        self.navigationItem.rightBarButtonItems = [barButton1]
        self.navigationItem.leftBarButtonItems = [barButton2]
    }

    @objc func searchButton1(item: UIBarButtonItem) {

        guard let object = self.categoryContext!.getCategory(.accommodation) else { return }

        self.mapViewController!.center(onCoordinates: self.location, zoomLevel: 60, animationDuration: 1200)

        self.searchContext?.setCategory(object)

        self.searchContext?
            .searchAround(withLocation: location) { [weak self] (results: [LandmarkObject]) in

                guard let strongSelf = self else { return }

                if !results.isEmpty {

                    strongSelf.mapViewController!.removeHighlights()

                    let settings = HighlightRenderSettings.init()

                    strongSelf.mapViewController!.presentHighlights(results, settings: settings)
                }
            }
    }

    @objc func searchButton2(item: UIBarButtonItem) {

        guard let object = self.categoryContext!.getCategory(.gasStation) else { return }

        self.mapViewController!.center(onCoordinates: self.location, zoomLevel: 60, animationDuration: 800)

        self.searchContext?.setCategory(object)

        self.searchContext?
            .searchAround(withLocation: location) { [weak self] (results: [LandmarkObject]) in

                guard let strongSelf = self else { return }

                if !results.isEmpty {

                    strongSelf.mapViewController!.removeHighlights()

                    let settings = HighlightRenderSettings.init()

                    strongSelf.mapViewController!.presentHighlights(results, settings: settings)
                }
            }
    }
}
