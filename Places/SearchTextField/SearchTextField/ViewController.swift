// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: BSD-3-Clause
//
// Contact Magic Lane at <info@magiclane.com> for commercial licensing options.

import UIKit
import GEMKit

class ViewController: UIViewController, UISearchBarDelegate, ResultsViewControllerDelegate {
    
    var mapViewController: MapViewController?
    
    var searchContext: SearchContext?
    
    let resultsViewController = ResultsViewController.init()
    
    var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let navigationController = self.navigationController {
            
            let appearance = navigationController.navigationBar.standardAppearance
            
            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }
        
        self.title = "Free Text Search"
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.resultsViewController.delegate = self
        
        self.searchController = UISearchController.init(searchResultsController: self.resultsViewController)
        self.searchController!.view.backgroundColor = UIColor.systemBackground
        self.searchController!.searchBar.delegate = self
        self.searchController!.searchBar.placeholder = "Search"
        self.searchController!.obscuresBackgroundDuringPresentation = false
        self.searchController!.hidesNavigationBarDuringPresentation = false
        self.navigationItem.searchController = self.searchController
        
        self.createMapView()

        self.mapViewController!.startRender()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        let location = CoordinatesObject.coordinates(withLatitude: 37.77903, longitude: -122.41991)
        
        self.mapViewController!.center(onCoordinates: location, zoomLevel: 50, animationDuration: 0)
    }
    
    // MARK: - Map View

    func createMapView() {

        self.mapViewController = MapViewController.init()
        self.mapViewController!.view.backgroundColor = UIColor.systemBackground

        self.addChild(self.mapViewController!)
        self.view.addSubview(self.mapViewController!.view)
        self.mapViewController!.didMove(toParent: self)

        self.mapViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        let constraintTop = NSLayoutConstraint( item: self.mapViewController!.view!, attribute: NSLayoutConstraint.Attribute.top,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self.view, attribute: NSLayoutConstraint.Attribute.top,
                                                multiplier: 1.0, constant: 0)

        let constraintLeft = NSLayoutConstraint( item: self.mapViewController!.view!, attribute: NSLayoutConstraint.Attribute.leading,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading,
                                                 multiplier: 1.0, constant: 0)

        let constraintBottom = NSLayoutConstraint( item: self.mapViewController!.view!, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: self.view, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   multiplier: 1.0, constant: -0)

        let constraintRight = NSLayoutConstraint( item: self.mapViewController!.view!, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  multiplier: 1.0, constant: -0)

        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintBottom, constraintRight])
    }


    // MARK: - UISearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        self.performSearch(text: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        guard let mapViewController = self.mapViewController else { return }
        
        if let searchContext = self.searchContext {
            
            searchContext.cancelSearch()
        }
        
        mapViewController.removeHighlights()
        
        self.resultsViewController.dataModel = []
        self.resultsViewController.tableView.reloadData()
    }
    
    func performSearch(text: String) {
        
        if self.searchContext == nil {

            self.searchContext = SearchContext.init()

            // Preferences
            self.searchContext?.setMaxMatches(40)
            self.searchContext?.setSearchMapPOIs(true)
            self.searchContext?.setSearchAddresses(true)
        }
        
        let location = self.getMapCenterLocation()
        
        self.searchContext?.search(withQuery: text, location: location) { [weak self] (results: [LandmarkObject]) in
            
            guard let strongSelf = self else { return }
            
            strongSelf.resultsViewController.dataModel = results
            strongSelf.resultsViewController.referencePoint = location
            
            strongSelf.resultsViewController.tableView.reloadData()
        }
    }

    // MARK: - ResultsViewControllerDelegate
    
    func didSelectLandmark(landmark: LandmarkObject) {
        
        guard let searchController = self.searchController else { return }
        
        guard let mapViewController = self.mapViewController else { return }
        
        searchController.dismiss(animated: true) { }
        
        let text = landmark.getLandmarkName()
        searchController.searchBar.text = text
        
        mapViewController.removeHighlights()
        
        let settings = HighlightRenderSettings.init()
        settings.showPin = true
        settings.imageSize = 7
        
        settings.options = Int32( HighlightOption.showLandmark.rawValue | HighlightOption.overlap.rawValue | HighlightOption.showContour.rawValue )
        settings.contourInnerColor = UIColor.orange
        settings.contourOuterColor = UIColor.orange
        
        mapViewController.presentHighlights([landmark], settings: settings)
        
        self.centerLandmark(landmark: landmark)
    }
    
    func centerLandmark(landmark: LandmarkObject) {
        
        guard let mapViewController = self.mapViewController else { return }
        
        if let contour = landmark.getContourGeograficArea(), !contour.isEmpty(){
            
            // default
            mapViewController.center(onArea: contour,
                                     zoomLevel: -1,
                                     animationDuration: 1200)
            
        } else {
            
            // 2d
            mapViewController.center(onCoordinates: landmark.getCoordinates(),
                                     zoomLevel: -1,
                                     mapAngle: Double.greatestFiniteMagnitude,
                                     viewAngle: 0,
                                     animationDuration: 1200)
        }
    }
    
    // MARK: - Utils
    
    func getMapCenterLocation() -> CoordinatesObject {
        
        guard let mapViewController = self.mapViewController else { return CoordinatesObject.init() }
        
        let scale = UIScreen.main.scale
        
        let center = mapViewController.view.center
        
        let point = CGPoint.init(x: center.x * scale, y: center.y * scale)
        
        let location = mapViewController.transformScreen(toWgs: point)
        
        return location
    }
}

protocol ResultsViewControllerDelegate: NSObject {
    
    func didSelectLandmark(landmark: LandmarkObject)
}

class ResultsViewController: UITableViewController {
    
    weak var delegate: ResultsViewControllerDelegate?
    
    var dataModel: [LandmarkObject] = []
    
    var referencePoint: CoordinatesObject?
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dataModel.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "testCell")
        
        let scale = UIScreen.main.scale
        let size = CGSize.init(width: 40 * scale, height: 40 * scale)
        
        let landmark = self.dataModel[indexPath.row]
        
        let text = landmark.getLandmarkName()
        let desc = landmark.getLandmarkDescription()
        let img  = landmark.getLandmarkImage(size)
        
        cell.textLabel?.text = text
        cell.detailTextLabel?.text = desc
        cell.imageView?.image = img
        
        self.setupAccessoryView(tableView: tableView, cell: cell, indexPath: indexPath)
        
        return cell
    }
    
    func setupAccessoryView(tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        
        let size = CGSize.init(width: 60, height: 40)
        
        let accessoryView = UIView.init(frame: CGRect.init(origin: CGPoint.zero, size: size))
        
        if let point = self.referencePoint {
            
            let statusText = self.dataModel[indexPath.row].getLandmarkDistanceFormatted(withLocation: point)
            let statusDesc = self.dataModel[indexPath.row].getLandmarkDistanceUnitFormatted(withLocation: point)
            
            let frameL1 = CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: CGSize.init(width: 60, height: 22))
            let frameL2 = CGRect.init(origin: CGPoint.init(x: 0, y: 22), size: CGSize.init(width: 60, height: 18))
            
            let labelText   = UILabel.init(frame: frameL1)
            labelText.text = statusText
            labelText.textAlignment = .right
            
            let labelDetail = UILabel.init(frame: frameL2)
            labelDetail.text = statusDesc
            labelDetail.textAlignment = .right
            labelDetail.font = UIFont.preferredFont(forTextStyle: .footnote)
            
            accessoryView.addSubview(labelText)
            accessoryView.addSubview(labelDetail)
        }
        
        cell.accessoryView = accessoryView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if self.delegate != nil {
            
            self.delegate!.didSelectLandmark(landmark: self.dataModel[indexPath.row])
        }
    }
}
