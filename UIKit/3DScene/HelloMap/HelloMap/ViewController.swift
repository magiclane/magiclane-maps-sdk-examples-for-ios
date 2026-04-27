// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import UIKit
import GEMKit

class ViewController: UIViewController {

    var mapViewController: MapViewController?

    deinit {

        if let controller = mapViewController {

            controller.destroy()
        }
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        if let navigationController = self.navigationController {

            let appearance = navigationController.navigationBar.standardAppearance

            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }

        self.createMapView()
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        self.mapViewController!.startRender()
    }

    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)

        self.mapViewController!.stopRender()
    }

    // MARK: - Map View

    func createMapView() {

        self.mapViewController = MapViewController.init()
        self.mapViewController!.view.backgroundColor = UIColor.systemBackground

        self.addChild(self.mapViewController!)
        self.view.addSubview(self.mapViewController!.view)
        self.mapViewController!.didMove(toParent: self)
        
        self.mapViewController!.hideCompass()

        self.mapViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.mapViewController!.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            self.mapViewController!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            self.mapViewController!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -0),
            self.mapViewController!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -0)
        ])
        
        guard let paths = mapViewController!.getPreferences().getPaths() else { return }

        let path = PathObject(coordinates: [
            CoordinatesObject.coordinates(withLatitude: 52.3676, longitude: 4.9041),
            CoordinatesObject.coordinates(withLatitude: 52.3610, longitude: 4.9156),
            CoordinatesObject.coordinates(withLatitude: 52.3540, longitude: 4.9230)
        ])
        path.setName("Recorded track")
        
        let first = paths.getPathAt(0)
        let byName = paths.getPathByName("")
        
        paths.remove(at: <#T##Int32#>)

        _ = paths.add(
            path,
            colorBorder: .black,
            colorInner: .red,
            szBorder: 1.2,
            szInner: 0.7
        )

        if let area = path.getArea() {
            mapViewController!.center(onArea: area, zoomLevel: -1, animationDuration: 700)
        }
    }
}
