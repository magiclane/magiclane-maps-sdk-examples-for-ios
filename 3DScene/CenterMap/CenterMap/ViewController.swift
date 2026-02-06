// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import UIKit
import GEMKit

class ViewController: UIViewController {

    var mapViewController: MapViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        if let navigationController = self.navigationController {

            let appearance = navigationController.navigationBar.standardAppearance

            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }

        self.createMapView()

        self.mapViewController!.startRender()

        self.addCenterMapButton()
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
            self.mapViewController!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.mapViewController!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.mapViewController!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
    }

    // MARK: - Polylines

    func addCenterMapButton() {

        let image = UIImage.init(systemName: "target")

        let barButton = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(centerMapAction(_:)))
        self.navigationItem.rightBarButtonItem = barButton
    }

    @objc func centerMapAction(_ barButton: UIBarButtonItem) {

        let location = CoordinatesObject.coordinates(withLatitude: 48.840827, longitude: 2.381899)

        self.mapViewController!.center(onCoordinates: location, zoomLevel: 50, animationDuration: 1000)
    }
}
