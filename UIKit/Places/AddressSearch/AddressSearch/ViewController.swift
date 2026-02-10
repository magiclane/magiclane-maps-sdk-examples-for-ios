// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import UIKit
import GEMKit

class ViewController: UIViewController, MapViewControllerDelegate {

    var mapViewController: MapViewController?

    var searchContext: SearchContext?

    var label = UILabel.init()
    var imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        if let navigationController = self.navigationController {

            let appearance = navigationController.navigationBar.standardAppearance

            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }

        self.title = "Address Search"
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.largeTitleDisplayMode = .never

        self.createMapView()

        self.mapViewController!.startRender()

        self.addSearchButton()
    }

    // MARK: - Map View

    func createMapView() {

        self.mapViewController = MapViewController.init()
        self.mapViewController!.delegate = self
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
    
    // MARK: - MapViewControllerDelegate

    func mapViewController(_ mapViewController: MapViewController, didSelectLandmark landmark: LandmarkObject, onTouch point: CGPoint) {

        let text = "  " + landmark.getLandmarkName() + "\n" + "  " + landmark.getLandmarkDescription()

        self.label.text = text
        self.label.isHidden = false

        let scale = UIScreen.main.scale
        self.imageView.image = landmark.getLandmarkImage(CGSize.init(width: 40 * scale, height: 40 * scale))
        self.imageView.isHidden = false

        let settings = HighlightRenderSettings.init()
        settings.showPin = true
        settings.imageSize = 7

        if landmark.isContourGeograficAreaEmpty() == false {

            settings.options = Int32(
                HighlightOption.showLandmark.rawValue | HighlightOption.overlap.rawValue | HighlightOption.showContour.rawValue)
            settings.contourInnerColor = UIColor.blue
            settings.contourOuterColor = UIColor.blue
        }

        self.mapViewController!.presentHighlights([landmark], settings: settings)

        self.mapViewController!.center(onCoordinates: landmark.getCoordinates(), zoomLevel: -1, animationDuration: 800)
    }

    func mapViewController(_ mapViewController: MapViewController, didSelectLandmark landmark: LandmarkObject, onLongTouch point: CGPoint) {

        let text = "  " + landmark.getLandmarkName() + "\n" + "  " + landmark.getLandmarkDescription()

        self.label.text = text
        self.label.isHidden = false

        let scale = UIScreen.main.scale
        self.imageView.image = landmark.getLandmarkImage(CGSize.init(width: 40 * scale, height: 40 * scale))
        self.imageView.isHidden = false

        let settings = HighlightRenderSettings.init()
        settings.showPin = true
        settings.imageSize = 7

        if landmark.isContourGeograficAreaEmpty() == false {

            settings.options = Int32(
                HighlightOption.showLandmark.rawValue | HighlightOption.overlap.rawValue | HighlightOption.showContour.rawValue)
            settings.contourInnerColor = UIColor.orange
            settings.contourOuterColor = UIColor.orange
        }

        self.mapViewController!.presentHighlights([landmark], settings: settings)
    }

    // MARK: - Address Search

    func addSearchButton() {

        let barButton = UIBarButtonItem.init(
            image: UIImage.init(systemName: "magnifyingglass"), style: .done, target: self, action: #selector(searchAddress))

        self.navigationItem.rightBarButtonItem = barButton
    }

    func searchCountries() {

        self.searchContext = SearchContext.init()
        self.searchContext!.setAddressSearchMaximumMatches(300)

        // Find all countries available
        self.searchContext!
            .addressSearchCountries(withQuery: "") { (results: [LandmarkObject]) in

                for landmark in results {

                    NSLog("country:%@", landmark.getLandmarkName())
                }
            }
    }

    @objc func searchAddress() {

        if self.searchContext == nil {

            self.searchContext = SearchContext.init()
        }

        // Address Search:
        //
        // California / Cuppertino / Infinite Loop / No 1

        let location = CoordinatesObject.coordinates(withLatitude: 37.33141, longitude: -122.03042)

        let country = self.searchContext!.addressSearchGetCountry(withCoordinates: location)

        self.searchContext!.setAddressSearchMaximumMatches(40)

        if self.searchContext!.hasAddressSearchState(withCountry: country) {

            self.searchState(inCountry: country)

        } else {

            self.searchCity(inCountry: country)
        }
    }

    func searchState(inCountry: LandmarkObject) {

        self.searchContext!
            .addressSearch(withLandmark: inCountry, level: .state, query: "California") { [weak self] (results: [LandmarkObject]) in

                guard let strongSelf = self else { return }

                if let state = results.first {

                    NSLog("address: state name:%@", state.getLandmarkName())

                    DispatchQueue.main.async {

                        strongSelf.searchCity(inState: state)
                    }
                }
            }
    }

    func searchCity(inState: LandmarkObject) {

        self.searchContext!
            .addressSearch(withLandmark: inState, level: .city, query: "Cuppertino") { [weak self] (results: [LandmarkObject]) in

                guard let strongSelf = self else { return }

                if let city = results.first {

                    NSLog("address: city name:%@", city.getLandmarkName())

                    DispatchQueue.main.async {

                        strongSelf.searchStreet(inCity: city)
                    }
                }
            }
    }

    func searchCity(inCountry: LandmarkObject) {

        self.searchContext!
            .addressSearch(withLandmark: inCountry, level: .city, query: "") { [weak self] (results: [LandmarkObject]) in

                guard let strongSelf = self else { return }

                if let city = results.first {

                    NSLog("address: city name:%@", city.getLandmarkName())

                    DispatchQueue.main.async {

                        strongSelf.searchStreet(inCity: city)
                    }
                }
            }
    }

    func searchStreet(inCity: LandmarkObject) {

        self.searchContext!
            .addressSearch(withLandmark: inCity, level: .street, query: "Infinite Loop") { [weak self] (results: [LandmarkObject]) in

                guard let strongSelf = self else { return }

                if let street = results.first {

                    NSLog("address: street name:%@", street.getLandmarkName())

                    DispatchQueue.main.async {

                        strongSelf.searchHouseNumber(inStreet: street)
                    }
                }
            }
    }

    func searchHouseNumber(inStreet: LandmarkObject) {

        self.searchContext!
            .addressSearch(withLandmark: inStreet, level: .houseNumber, query: "1") { [weak self] (results: [LandmarkObject]) in

                guard let strongSelf = self else { return }

                if let houseNumber = results.first {

                    NSLog("address: street house number:%@", houseNumber.getLandmarkName())

                    strongSelf.mapViewController!.removeHighlights()

                    let settings = HighlightRenderSettings.init()
                    settings.showPin = true
                    settings.imageSize = 7

                    if houseNumber.isContourGeograficAreaEmpty() == false {

                        settings.options = Int32(
                            HighlightOption.showLandmark.rawValue | HighlightOption.overlap.rawValue | HighlightOption.showContour.rawValue)
                        settings.contourInnerColor = UIColor.orange
                        settings.contourOuterColor = UIColor.orange
                    }

                    strongSelf.mapViewController!.presentHighlights([houseNumber], settings: settings)

                    strongSelf.mapViewController!.center(onCoordinates: houseNumber.getCoordinates(), zoomLevel: -1, animationDuration: 800)
                }
            }
    }
}
