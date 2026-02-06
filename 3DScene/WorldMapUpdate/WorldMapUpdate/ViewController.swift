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
            self.mapViewController!.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            self.mapViewController!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            self.mapViewController!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -0),
            self.mapViewController!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -0)
        ])
    }
}
