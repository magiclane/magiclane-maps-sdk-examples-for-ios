// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: BSD-3-Clause
//
// Contact Magic Lane at <info@magiclane.com> for commercial licensing options.

import UIKit
import GEMKit

class ViewController: UIViewController, MapViewControllerDelegate  {
    
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
        self.addLabelText()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        
    // MARK: - Label
    
    func addLabelText() {
        
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.isHidden = true
        self.imageView.layer.shadowColor = UIColor.lightGray.cgColor
        self.imageView.layer.shadowOpacity = 0.8
        
        self.label.font = UIFont.boldSystemFont(ofSize: 14)
        self.label.numberOfLines = 0
        self.label.backgroundColor = UIColor.systemBackground
        self.label.isHidden = true
        
        self.label.layer.shadowColor = UIColor.lightGray.cgColor
        self.label.layer.shadowOpacity = 0.8
        
        self.view.addSubview(self.label)
        self.view.addSubview(self.imageView)
        
        self.label.translatesAutoresizingMaskIntoConstraints = false
        var constraintLeft = NSLayoutConstraint( item: self.label, attribute: NSLayoutConstraint.Attribute.leading,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading,
                                                 multiplier: 1.0, constant: 10.0)
        
        let constraintBottom = NSLayoutConstraint( item: self.label, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: self.view.safeAreaLayoutGuide, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   multiplier: 1.0, constant: -10.0)
        
        let constraintRight = NSLayoutConstraint( item: self.label, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  multiplier: 1.0, constant: -10.0)

        var constraintHeight = NSLayoutConstraint( item: self.label, attribute: NSLayoutConstraint.Attribute.height,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                  multiplier: 1.0, constant: 70.0)
        
        NSLayoutConstraint.activate([constraintLeft, constraintBottom, constraintRight, constraintHeight])
        
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        constraintLeft = NSLayoutConstraint( item: self.imageView, attribute: NSLayoutConstraint.Attribute.leading,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.label, attribute: NSLayoutConstraint.Attribute.leading,
                                             multiplier: 1.0, constant: 0.0)
        
        let constraintTop = NSLayoutConstraint( item: self.imageView, attribute: NSLayoutConstraint.Attribute.top,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self.label, attribute: NSLayoutConstraint.Attribute.top,
                                                multiplier: 1.0, constant: -20.0)
        
        let constraintWidth = NSLayoutConstraint( item: self.imageView, attribute: NSLayoutConstraint.Attribute.width,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                  multiplier: 1.0, constant: 40.0)
        
        constraintHeight = NSLayoutConstraint( item: self.imageView, attribute: NSLayoutConstraint.Attribute.height,
                                               relatedBy: NSLayoutConstraint.Relation.equal,
                                               toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                               multiplier: 1.0, constant: 40.0)
        
        NSLayoutConstraint.activate([constraintLeft, constraintTop, constraintWidth, constraintHeight])
    }
    
    // MARK: - MapViewControllerDelegate
    
    func mapViewController(_ mapViewController: MapViewController, didSelectLandmark landmark: LandmarkObject, onTouch point: CGPoint) {
        
        let text = "  " + landmark.getLandmarkName() + "\n" + "  " + landmark.getLandmarkDescription()
        
        self.label.text = text
        self.label.isHidden = false
        
        let scale = UIScreen.main.scale
        self.imageView.image = landmark.getLandmarkImage(CGSize.init(width: 40*scale, height: 40*scale))
        self.imageView.isHidden = false
        
        let settings = HighlightRenderSettings.init()
        settings.showPin = true
        settings.imageSize = 7
        
        if landmark.isContourGeograficAreaEmpty() == false {
            
            settings.options = Int32( HighlightOption.showLandmark.rawValue | HighlightOption.overlap.rawValue | HighlightOption.showContour.rawValue )
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
        self.imageView.image = landmark.getLandmarkImage(CGSize.init(width: 40*scale, height: 40*scale))
        self.imageView.isHidden = false
        
        let settings = HighlightRenderSettings.init()
        settings.showPin = true
        settings.imageSize = 7
        
        if landmark.isContourGeograficAreaEmpty() == false {
            
            settings.options = Int32( HighlightOption.showLandmark.rawValue | HighlightOption.overlap.rawValue | HighlightOption.showContour.rawValue )
            settings.contourInnerColor = UIColor.orange
            settings.contourOuterColor = UIColor.orange
        }
        
        self.mapViewController!.presentHighlights([landmark], settings: settings)
    }
    
    // MARK: - Address Search
    
    func addSearchButton() {
        
        let barButton = UIBarButtonItem.init(image: UIImage.init(systemName: "magnifyingglass"), style: .done, target: self, action: #selector(searchAddress))
        
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func searchCountries() {
        
        self.searchContext = SearchContext.init()
        self.searchContext!.setAddressSearchMaximumMatches(300)
        
        // Find all countries available
        self.searchContext!.addressSearchCountries(withQuery: "") { (results: [LandmarkObject]) in
            
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
        
        self.searchContext!.addressSearch(withLandmark: inCountry, level: .state, query: "California") { [weak self] (results: [LandmarkObject]) in
            
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
        
        self.searchContext!.addressSearch(withLandmark: inState, level: .city, query: "Cuppertino") { [weak self] (results: [LandmarkObject]) in
            
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
        
        self.searchContext!.addressSearch(withLandmark: inCountry, level: .city, query: "") { [weak self] (results: [LandmarkObject]) in
            
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
        
        self.searchContext!.addressSearch(withLandmark: inCity, level: .street, query: "Infinite Loop") { [weak self] (results: [LandmarkObject]) in
            
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
        
        self.searchContext!.addressSearch(withLandmark: inStreet, level: .houseNumber, query: "1") { [weak self] (results: [LandmarkObject]) in
            
            guard let strongSelf = self else { return; }
            
            if let houseNumber = results.first {
                
                NSLog("address: street house number:%@", houseNumber.getLandmarkName())
                
                strongSelf.mapViewController!.removeHighlights()
                
                let settings = HighlightRenderSettings.init()
                settings.showPin = true
                settings.imageSize = 7
                
                if houseNumber.isContourGeograficAreaEmpty() == false {
                    
                    settings.options = Int32( HighlightOption.showLandmark.rawValue | HighlightOption.overlap.rawValue | HighlightOption.showContour.rawValue )
                    settings.contourInnerColor = UIColor.orange
                    settings.contourOuterColor = UIColor.orange
                }
                
                strongSelf.mapViewController!.presentHighlights([houseNumber], settings: settings)
                
                strongSelf.mapViewController!.center(onCoordinates: houseNumber.getCoordinates(), zoomLevel: -1, animationDuration: 800)
            }
        }
    }
}
