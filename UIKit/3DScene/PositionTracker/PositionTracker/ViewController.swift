// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import UIKit
import GEMKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    var mapViewController: MapViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        if let navigationController = self.navigationController {

            let appearance = navigationController.navigationBar.standardAppearance

            navigationController.navigationBar.scrollEdgeAppearance = appearance

            let array = [
                UIBarButtonItem.init(
                    image: UIImage.init(systemName: "location.fill"), style: .done, target: self, action: #selector(defaultPositionTracker)),
                UIBarButtonItem.init(
                    image: UIImage.init(systemName: "car.fill"), style: .done, target: self, action: #selector(carPositionTracker)),
                UIBarButtonItem.init(
                    image: UIImage.init(systemName: "airplane"), style: .done, target: self, action: #selector(planePositionTracker)),
                UIBarButtonItem.init(
                    image: UIImage.init(systemName: "circle.fill"), style: .done, target: self, action: #selector(imagePositionTracker))
            ]

            self.navigationItem.leftBarButtonItems = array
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(systemName: "location"), style: .done, target: self, action: #selector(startFollowLocation))
        }

        AppManager.shared.startLiveSensors()

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
            self.mapViewController!.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.mapViewController!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.mapViewController!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.mapViewController!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }

    // MARK: - Location

    @objc func startFollowLocation() {

        AppManager.shared.requestLocationPermission()
        self.mapViewController!.startFollowingPosition(withAnimationDuration: 0, zoomLevel: 70, viewAngle: 0) { success in }
    }

    @objc func defaultPositionTracker() {

        self.mapViewController!.setPositionTrackerScaleFactor(1)
        self.mapViewController!.setDefaultPositionTracker()
    }

    @objc func carPositionTracker() {

        let fileName = "car"

        if let urlMtl = Bundle.main.url(forResource: fileName, withExtension: "mtl") {

            if let material = NSData.init(contentsOf: urlMtl) as Data? {

                if let urlObj = Bundle.main.url(forResource: fileName, withExtension: "obj") {

                    if let object = NSData.init(contentsOf: urlObj) as Data? {

                        self.mapViewController!.setPositionTrackerScaleFactor(1)
                        self.mapViewController!.customizePositionTracker(object, material: material)
                    }
                }
            }
        }
    }

    @objc func planePositionTracker() {

        let fileName = "plane"

        if let urlMtl = Bundle.main.url(forResource: fileName, withExtension: "mtl") {

            if let material = NSData.init(contentsOf: urlMtl) as Data? {

                if let urlObj = Bundle.main.url(forResource: fileName, withExtension: "obj") {

                    if let object = NSData.init(contentsOf: urlObj) as Data? {

                        self.mapViewController!.setPositionTrackerScaleFactor(1)
                        self.mapViewController!.customizePositionTracker(object, material: material)
                    }
                }
            }
        }
    }
    
    @objc func imagePositionTracker() {
        guard let image = UIImage.init(named: "DotRay") else { return }
        if let data = image.pngData() {
            
            self.mapViewController!.setPositionTrackerScaleFactor(2)
            self.mapViewController!.customizePositionTracker(data)
        }
    }
}
