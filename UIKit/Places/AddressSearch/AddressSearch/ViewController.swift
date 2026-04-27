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

    // MARK: - Search Progress UI
    var progressContainer: UIView!
    var stageLabels: [UILabel] = []
    var stageSpinners: [UIActivityIndicatorView] = []
    var stageIcons: [UIImageView] = []
    var progressTitleLabel: UILabel!

    func createProgressPanel() {
        progressContainer = UIView()
        progressContainer.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.92)
        progressContainer.layer.cornerRadius = 12
        progressContainer.translatesAutoresizingMaskIntoConstraints = false
        progressContainer.isHidden = true
        self.view.addSubview(progressContainer)

        NSLayoutConstraint.activate([
            progressContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            progressContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            progressContainer.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 8)
        ])

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        progressContainer.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: progressContainer.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: progressContainer.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: progressContainer.trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: progressContainer.bottomAnchor, constant: -12)
        ])

        progressTitleLabel = UILabel()
        progressTitleLabel.text = "Searching Address…"
        progressTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        progressTitleLabel.textColor = .label
        stack.addArrangedSubview(progressTitleLabel)

        stageLabels = []
        stageSpinners = []
        stageIcons = []

        for stage in SearchStage.allCases {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 8
            row.alignment = .center

            let icon = UIImageView()
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.widthAnchor.constraint(equalToConstant: 18).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 18).isActive = true
            icon.contentMode = .scaleAspectFit
            icon.tintColor = .tertiaryLabel
            icon.image = UIImage(systemName: "circle")
            row.addArrangedSubview(icon)
            stageIcons.append(icon)

            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.hidesWhenStopped = true
            spinner.translatesAutoresizingMaskIntoConstraints = false
            spinner.widthAnchor.constraint(equalToConstant: 18).isActive = true
            spinner.heightAnchor.constraint(equalToConstant: 18).isActive = true
            row.addArrangedSubview(spinner)
            stageSpinners.append(spinner)

            let lbl = UILabel()
            lbl.text = stage.displayName
            lbl.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            lbl.textColor = .secondaryLabel
            row.addArrangedSubview(lbl)
            stageLabels.append(lbl)

            stack.addArrangedSubview(row)
        }
    }

    func showProgress() {
        // Reset all stages
        for i in SearchStage.allCases.indices {
            stageIcons[i].image = UIImage(systemName: "circle")
            stageIcons[i].tintColor = .tertiaryLabel
            stageIcons[i].isHidden = false
            stageSpinners[i].stopAnimating()
            stageLabels[i].textColor = .secondaryLabel
            stageLabels[i].font = UIFont.systemFont(ofSize: 13, weight: .regular)
        }
        progressTitleLabel.text = "Searching Address…"
        progressContainer.isHidden = false
        progressContainer.alpha = 0
        UIView.animate(withDuration: 0.25) { self.progressContainer.alpha = 1 }
    }

    func updateStage(_ stage: SearchStage, active: Bool = false, completed: Bool = false, skipped: Bool = false) {
        DispatchQueue.main.async {
            let i = stage.rawValue
            if completed {
                self.stageSpinners[i].stopAnimating()
                self.stageIcons[i].isHidden = false
                self.stageIcons[i].image = UIImage(systemName: "checkmark.circle.fill")
                self.stageIcons[i].tintColor = .systemGreen
                self.stageLabels[i].textColor = .label
                self.stageLabels[i].font = UIFont.systemFont(ofSize: 13, weight: .medium)
            } else if active {
                self.stageIcons[i].isHidden = true
                self.stageSpinners[i].startAnimating()
                self.stageLabels[i].textColor = .label
                self.stageLabels[i].font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            } else if skipped {
                self.stageSpinners[i].stopAnimating()
                self.stageIcons[i].isHidden = false
                self.stageIcons[i].image = UIImage(systemName: "minus.circle")
                self.stageIcons[i].tintColor = .tertiaryLabel
                self.stageLabels[i].textColor = .tertiaryLabel
            }
        }
    }

    func hideProgress() {
        DispatchQueue.main.async {
            self.progressTitleLabel.text = "Address Found ✓"
            UIView.animate(withDuration: 0.3, delay: 2.0, options: []) {
                self.progressContainer.alpha = 0
            } completion: { _ in
                self.progressContainer.isHidden = true
            }
        }
    }

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
        self.createProgressPanel()

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
    }

    func mapViewController(_ mapViewController: MapViewController, didSelectLandmark landmark: LandmarkObject, onLongTouch point: CGPoint) {
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

        showProgress()
        updateStage(.country, active: true)

        let location = CoordinatesObject.coordinates(withLatitude: 37.33141, longitude: -122.03042)

        let country = self.searchContext!.addressSearchGetCountry(withCoordinates: location)

        updateStage(.country, completed: true)

        self.searchContext!.setAddressSearchMaximumMatches(40)

        if self.searchContext!.hasAddressSearchState(withCountry: country) {
            updateStage(.state, active: true)
            self.searchState(inCountry: country)
        } else {
            updateStage(.state, skipped: true)
            updateStage(.city, active: true)
            self.searchCity(inCountry: country)
        }
    }

    func searchState(inCountry: LandmarkObject) {

        self.searchContext!
            .addressSearch(withLandmark: inCountry, level: .state, query: "California") { [weak self] (results: [LandmarkObject]) in

                guard let strongSelf = self else { return }

                if let state = results.first {

                    NSLog("address: state name:%@", state.getLandmarkName())

                    strongSelf.updateStage(.state, completed: true)
                    strongSelf.updateStage(.city, active: true)

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

                    strongSelf.updateStage(.city, completed: true)
                    strongSelf.updateStage(.street, active: true)

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

                    strongSelf.updateStage(.city, completed: true)
                    strongSelf.updateStage(.street, active: true)

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

                    strongSelf.updateStage(.street, completed: true)
                    strongSelf.updateStage(.houseNumber, active: true)

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

                    strongSelf.updateStage(.houseNumber, completed: true)
                    strongSelf.hideProgress()

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

enum SearchStage: Int, CaseIterable {
    case country = 0, state, city, street, houseNumber

    var displayName: String {
        switch self {
        case .country: return "Country"
        case .state: return "State"
        case .city: return "City"
        case .street: return "Street"
        case .houseNumber: return "House Number"
        }
    }
}
