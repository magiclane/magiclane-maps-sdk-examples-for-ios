// Copyright (C) 2019-2021, General Magic B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of General Magic
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with General Magic.

import UIKit
import GEMKit

protocol ResultsViewControllerDelegate: NSObject {
    
    func didSelectLandmark(landmark: LandmarkObject)
}

class ResultsViewController: UITableViewController {
    
    weak var delegate: ResultsViewControllerDelegate?
    
    var dataModel: [LandmarkObject] = []
    
    var referencePoint: GeoLocation?
    
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
            
            let statusText = self.dataModel[indexPath.row].getLandmarkDistanceFormatted(with: point)
            let statusDesc = self.dataModel[indexPath.row].getLandmarkDistanceUnitFormatted(with: point)
            
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

class ViewController: UIViewController, UISearchBarDelegate, ResultsViewControllerDelegate {
    
    var mapViewController: MapViewController?
    
    var searchContext: SearchContext?
    
    let resultsViewController = ResultsViewController.init()
    
    var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "GEM Search"
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.resultsViewController.delegate = self
        
        self.searchController = UISearchController.init(searchResultsController: self.resultsViewController)
        self.searchController!.view.backgroundColor = UIColor.systemBackground
        self.searchController!.searchBar.delegate = self
        self.searchController!.searchBar.placeholder = "Search"
        self.searchController!.obscuresBackgroundDuringPresentation = false
        // self.searchController.searchResultsUpdater = nil
        self.navigationItem.searchController = self.searchController
        
        self.createMapView()

        self.mapViewController!.startRender()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        let location = GeoLocation.coordinates(withLatitude: 37.77903, longitude: -122.41991)
        
        self.mapViewController!.center(on: location, zoomLevel: 50, animationDuration: 1000)
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

        if self.searchContext != nil {

            self.searchContext?.cancelSearch()
        }
        
        self.resultsViewController.dataModel = []
        self.resultsViewController.tableView.reloadData()
    }

    func performSearch(text: String)
    {
        if self.searchContext == nil {

            self.searchContext = SearchContext.init()

            // Preferences
            self.searchContext?.setMaxMatches(20)
            self.searchContext?.setSearchMapPOIs(true)
            self.searchContext?.setSearchAddresses(true)
        }

        // San Francisco
        let location = GeoLocation.coordinates(withLatitude: 37.77903, longitude: -122.41991)
        
        weak var weakSelf = self
        
        self.searchContext?.search(withQuery: text, location: location) { (results: [LandmarkObject]) in
            
            guard let strongSelf = weakSelf else { return }
            
            strongSelf.resultsViewController.dataModel = results
            strongSelf.resultsViewController.referencePoint = location
            
            strongSelf.resultsViewController.tableView.reloadData()
        }
    }

    // MARK: - ResultsViewControllerDelegate
    
    func didSelectLandmark(landmark: LandmarkObject) {
        
        self.searchController!.isActive = false
        
        self.mapViewController!.presentHighlight(landmark, contourColor: UIColor.orange, centerLayout: true, animationDuration: 1200)
    }
}
