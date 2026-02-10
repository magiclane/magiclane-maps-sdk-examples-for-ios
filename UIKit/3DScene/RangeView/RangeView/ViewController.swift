// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import UIKit
import GEMKit

class ViewController: UIViewController, MapViewControllerDelegate {

    var mapViewController: MapViewController?
    var rangeViewController: RangeViewController?

    var buttonExit: UIButton?

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

        self.title = "Range Demo"

        self.createMapView()
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        self.mapViewController!.startRender()
    }

    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        let location = CoordinatesObject.coordinates(withLatitude: 52.517477, longitude: 13.397152)  // Berlin

        self.mapViewController!.center(onCoordinates: location, zoomLevel: 70, animationDuration: 0)
    }

    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)

        self.mapViewController!.stopRender()
    }

    // MARK: - Map View

    func createMapView() {

        self.mapViewController = MapViewController.init()
        self.mapViewController!.delegate = self
        self.mapViewController!.view.backgroundColor = UIColor.systemBackground

        self.addChild(self.mapViewController!)
        self.view.addSubview(self.mapViewController!.view)
        self.mapViewController!.didMove(toParent: self)

        self.mapViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.mapViewController!.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            self.mapViewController!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            self.mapViewController!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -0),
            self.mapViewController!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -0)
        ])
    }

    // MARK: - TableView

    func addRangeView() {

        let rangeViewController = RangeViewController.init(mapViewController: self.mapViewController!)
        rangeViewController.view.layer.shadowColor = UIColor.darkGray.cgColor
        rangeViewController.view.layer.shadowOpacity = 0.8

        self.view.addSubview(rangeViewController.view)

        rangeViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rangeViewController.view!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            rangeViewController.view!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            rangeViewController.view!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            rangeViewController.view!.heightAnchor.constraint(equalToConstant: 360)
        ])

        let size: CGFloat = 50

        let buttonExit = UIButton.init(type: .system)
        buttonExit.setImage(
            UIImage.init(systemName: "xmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)),
            for: .normal)
        buttonExit.addTarget(self, action: #selector(closeRangeView), for: .touchUpInside)
        buttonExit.layer.shadowColor = UIColor.darkGray.cgColor
        buttonExit.layer.shadowOpacity = 0.8
        buttonExit.backgroundColor = UIColor.systemBackground
        buttonExit.layer.cornerRadius = size / 2

        self.buttonExit = buttonExit

        self.view.addSubview(buttonExit)

        buttonExit.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonExit.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -5),
            buttonExit.bottomAnchor.constraint(equalTo: rangeViewController.view!.topAnchor, constant: size - 30),
            buttonExit.widthAnchor.constraint(equalToConstant: size),
            buttonExit.heightAnchor.constraint(equalToConstant: size)
        ])

        self.rangeViewController = rangeViewController
    }

    // MARK: - MapViewControllerDelegate

    func mapViewController(_ mapViewController: MapViewController, didSelectLandmarks landmarks: [LandmarkObject], onTouch point: CGPoint) {

        guard let lmk = landmarks.first else { return }

        self.handleSelection(landmark: lmk)
    }

    func mapViewController(
        _ mapViewController: MapViewController, didSelectLandmarks landmarks: [LandmarkObject], onLongTouch point: CGPoint
    ) {

        guard let lmk = landmarks.first else { return }

        self.handleSelection(landmark: lmk)
    }

    func mapViewController(_ mapViewController: MapViewController, didSelectStreets streets: [LandmarkObject], onTouch point: CGPoint) {

        guard let lmk = streets.first else { return }

        self.handleSelection(landmark: lmk)
    }

    func mapViewController(_ mapViewController: MapViewController, didSelectStreets streets: [LandmarkObject], onLongTouch point: CGPoint) {

        if let lmk = streets.first {

            self.handleSelection(landmark: lmk)
        }
    }

    // MARK: - Utils

    func handleSelection(landmark: LandmarkObject) {

        if self.rangeViewController != nil {

            self.closeRangeView()
        }

        self.highlight(landmark: landmark)

        self.addRangeView()

        self.rangeViewController!.landmark = landmark
    }

    func highlight(landmark: LandmarkObject) {

        guard let mapViewController = self.mapViewController else { return }

        let settings = HighlightRenderSettings.init()
        settings.showPin = true
        settings.imageSize = 7

        if landmark.isContourGeograficAreaEmpty() == false {

            settings.options = Int32(
                HighlightOption.showLandmark.rawValue | HighlightOption.overlap.rawValue | HighlightOption.showContour.rawValue)
            settings.contourInnerColor = UIColor.white
            settings.contourOuterColor = UIColor.systemBlue
        }

        let insets = self.calculateAreaInsets()
        mapViewController.setEdgeAreaInsets(insets)

        mapViewController.presentHighlights([landmark], settings: settings, highlightId: 100)

        // Center animation
        // mapViewController.center(onCoordinates: landmark.getCoordinates(), zoomLevel: 80, animationDuration: 800)
    }

    func calculateAreaInsets() -> UIEdgeInsets {

        let scale = UIScreen.main.scale

        let insets = UIEdgeInsets.init(
            top: (self.view.safeAreaInsets.top) * scale,
            left: 0,
            bottom: (self.view.safeAreaInsets.bottom + 360) * scale,
            right: 0)

        return insets
    }

    @objc func closeRangeView() {

        guard let mapViewController = self.mapViewController else { return }

        mapViewController.removeHighlights()
        mapViewController.removeAllRoutes()

        if let rangeViewController = self.rangeViewController {

            rangeViewController.view.removeFromSuperview()
        }

        if let buttonExit = self.buttonExit {

            buttonExit.removeFromSuperview()
        }

        self.rangeViewController = nil
        self.buttonExit = nil
    }
}
