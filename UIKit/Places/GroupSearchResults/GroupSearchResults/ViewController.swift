// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import UIKit
import GEMKit

struct Place {
    let title: String
    let details: String
    let landmark: LandmarkObject
}

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {

    var mapViewController: MapViewController?

    let searchContext = SearchContext.init()
    let defaultHighlightId: Int32 = 10

    var landmarks: [LandmarkObject] = []
    var results: [Place] = []
    var selectedIndex: Int? = nil

    var searchField: UITextField!
    var activityIndicator: UIActivityIndicatorView!
    var tableView: UITableView!
    var centerButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Group Search Results"
        self.navigationItem.largeTitleDisplayMode = .never
        self.view.backgroundColor = .systemBackground

        if let navigationController = self.navigationController {
            let appearance = navigationController.navigationBar.standardAppearance
            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }

        setupViews()
        createMapView()
        mapViewController!.startRender()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let location = CoordinatesObject.coordinates(withLatitude: 52.368447, longitude: 4.888229)
        mapViewController!.center(onCoordinates: location, zoomLevel: 64, animationDuration: 0)


    }

    // MARK: - UI Setup

    func setupViews() {
        let searchContainer = UIView()
        searchContainer.translatesAutoresizingMaskIntoConstraints = false

        searchField = UITextField()
        searchField.placeholder = "Search"
        searchField.borderStyle = .roundedRect
        searchField.returnKeyType = .search
        searchField.delegate = self
        searchField.translatesAutoresizingMaskIntoConstraints = false

        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        searchContainer.addSubview(searchField)
        searchContainer.addSubview(activityIndicator)

        tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false

        centerButton = UIButton(type: .system)
        centerButton.setTitle("Center Results", for: .normal)
        centerButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        centerButton.addTarget(self, action: #selector(centerResultsTapped), for: .touchUpInside)
        centerButton.isEnabled = false
        centerButton.translatesAutoresizingMaskIntoConstraints = false

        let mapContainer = UIView()
        mapContainer.translatesAutoresizingMaskIntoConstraints = false
        mapContainer.tag = 100

        self.view.addSubview(searchContainer)
        self.view.addSubview(mapContainer)
        self.view.addSubview(tableView)
        self.view.addSubview(centerButton)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            searchContainer.topAnchor.constraint(equalTo: guide.topAnchor, constant: 8),
            searchContainer.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 15),
            searchContainer.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -15),
            searchContainer.heightAnchor.constraint(equalToConstant: 44),

            searchField.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor),
            searchField.topAnchor.constraint(equalTo: searchContainer.topAnchor),
            searchField.bottomAnchor.constraint(equalTo: searchContainer.bottomAnchor),
            searchField.trailingAnchor.constraint(equalTo: activityIndicator.leadingAnchor, constant: -8),

            activityIndicator.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),

            mapContainer.topAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: 8),
            mapContainer.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 15),
            mapContainer.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -15),
            mapContainer.heightAnchor.constraint(equalToConstant: 300),

            tableView.topAnchor.constraint(equalTo: mapContainer.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 15),
            tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -15),
            tableView.bottomAnchor.constraint(equalTo: centerButton.topAnchor, constant: -8),

            centerButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -8),
            centerButton.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            centerButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    // MARK: - Map View

    func createMapView() {
        guard let mapContainer = self.view.viewWithTag(100) else { return }

        self.mapViewController = MapViewController.init()
        self.mapViewController!.view.backgroundColor = .systemBackground

        self.addChild(self.mapViewController!)
        mapContainer.addSubview(self.mapViewController!.view)
        self.mapViewController!.didMove(toParent: self)

        self.mapViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.mapViewController!.view.topAnchor.constraint(equalTo: mapContainer.topAnchor),
            self.mapViewController!.view.leadingAnchor.constraint(equalTo: mapContainer.leadingAnchor),
            self.mapViewController!.view.bottomAnchor.constraint(equalTo: mapContainer.bottomAnchor),
            self.mapViewController!.view.trailingAnchor.constraint(equalTo: mapContainer.trailingAnchor),
        ])

    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = textField.text, !text.isEmpty {
            performSearch(text: text)
        }
        return true
    }

    // MARK: - Search

    func performSearch(text: String) {
        guard let mapViewController = self.mapViewController else { return }

        mapViewController.removeHighlights()

        let amsterdam = CoordinatesObject.coordinates(withLatitude: 52.368447, longitude: 4.888229)
        mapViewController.center(onCoordinates: amsterdam, zoomLevel: 60, animationDuration: 0)

        landmarks.removeAll()
        results.removeAll()
        selectedIndex = nil
        tableView.reloadData()
        activityIndicator.startAnimating()

        searchContext.setLocationHint(
            RectangleGeographicAreaObject(
                location: amsterdam,
                horizontalRadius: 2000, verticalRadius: 2000))

        searchContext.search(withQuery: text, location: amsterdam) { [weak self] (response: [LandmarkObject]) in
            guard let self = self else { return }

            self.activityIndicator.stopAnimating()

            for item in response {
                item.setImage(self.getImageObject())
                self.landmarks.append(item)
            }

            self.results = response.map { item in
                let coords = item.getCoordinates()
                return Place(
                    title: item.getLandmarkName(),
                    details: "Lat:\(coords.latitude), Long:\(coords.longitude)",
                    landmark: item)
            }

            let settings = self.getHighlightSettings()
            mapViewController.presentHighlights(self.landmarks, settings: settings, highlightId: self.defaultHighlightId)

            self.centerButton.isEnabled = !self.landmarks.isEmpty
            self.tableView.reloadData()
        }
    }

    func getHighlightSettings() -> HighlightRenderSettings {
        let settings = HighlightRenderSettings.init()
        settings.options = Int32(
            HighlightOption.showLandmark.rawValue | HighlightOption.group.rawValue | HighlightOption.selectable.rawValue)
        settings.textColor = UIColor.darkGray
        settings.textSize = 2.2
        settings.imageSize = 5.6
        return settings
    }

    func getImageObject() -> ImageObject {
        if let image = UIImage(named: "MapPinDefault"),
           let data = image.pngData()
        {
            return ImageObject(dataBuffer: data, format: .png)
        }
        return ImageObject()
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let place = results[indexPath.row]
        cell.textLabel?.text = place.title
        cell.detailTextLabel?.text = place.details
        cell.detailTextLabel?.textColor = .secondaryLabel

        if selectedIndex == indexPath.row {
            cell.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        } else {
            cell.backgroundColor = .clear
        }

        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let mapViewController = self.mapViewController else { return }

        selectedIndex = indexPath.row
        tableView.reloadData()

        let place = results[indexPath.row]
        mapViewController.center(onCoordinates: place.landmark.getCoordinates(), zoomLevel: -1, animationDuration: 1200)
    }

    // MARK: - Center Results

    @objc func centerResultsTapped() {
        guard let mapViewController = self.mapViewController else { return }

        selectedIndex = nil
        tableView.reloadData()

        let list = mapViewController.getHighlight(defaultHighlightId)
        guard !list.isEmpty else { return }
        guard let area = mapViewController.getHighlightArea(defaultHighlightId) else { return }
        mapViewController.center(onArea: area, zoomLevel: -1, animationDuration: 1200)
    }
}
