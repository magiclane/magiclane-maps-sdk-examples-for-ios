// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: BSD-3-Clause
//
// Contact Magic Lane at <info@magiclane.com> for commercial licensing options.

import UIKit
import GEMKit

class ViewController: UIViewController {
    
    var mapViewController: MapViewController?
    
    var searchContext: SearchContext?
    
    var categoryContext: GenericCategoriesContext?
    
    let location = CoordinatesObject.coordinates(withLatitude: 48.840827, longitude: 2.371899)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let navigationController = self.navigationController {
            
            let appearance = navigationController.navigationBar.standardAppearance
            
            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }
        
        self.createMapView()
        
        self.mapViewController!.startRender()
        
        self.searchContext = SearchContext.init()
        self.searchContext?.setMaxMatches(40)
        self.searchContext?.setSearchMapPOIs(true)
        
        self.categoryContext = GenericCategoriesContext.init()
        
        self.addSearchButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
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
    
    // MARK: - Search
    
    func addSearchButtons() {
                        
        let barButton1 = UIBarButtonItem.init(title: "Accommodation", style: .done, target: self, action: #selector(searchButton1))
        
        let barButton2 = UIBarButtonItem.init(title: "Gas Station", style: .done, target: self, action: #selector(searchButton2))
        
        self.navigationItem.rightBarButtonItems = [barButton1]
        self.navigationItem.leftBarButtonItems = [barButton2]
    }
    
    @objc func searchButton1(item: UIBarButtonItem) {
        
        guard let object = self.categoryContext!.getCategory(.accommodation) else { return }
        
        self.mapViewController!.center(onCoordinates: self.location, zoomLevel: 60, animationDuration: 1200)
        
        self.searchContext?.setCategory(object)
                
        self.searchContext?.searchAround(withLocation: location) { [weak self] (results: [LandmarkObject]) in
            
            guard let strongSelf = self else { return }
            
            if results.count > 0 {
                
                strongSelf.mapViewController!.removeHighlights()
                
                let settings = HighlightRenderSettings.init()
                
                strongSelf.mapViewController!.presentHighlights(results, settings: settings)
            }
        }
    }
    
    @objc func searchButton2(item: UIBarButtonItem) {
        
        guard let object = self.categoryContext!.getCategory(.gasStation) else { return }
        
        self.mapViewController!.center(onCoordinates: self.location, zoomLevel: 60, animationDuration: 800)
        
        self.searchContext?.setCategory(object)
        
        self.searchContext?.searchAround(withLocation: location) { [weak self] (results: [LandmarkObject]) in
            
            guard let strongSelf = self else { return }
            
            if results.count > 0 {
                
                strongSelf.mapViewController!.removeHighlights()
                
                let settings = HighlightRenderSettings.init()
                
                strongSelf.mapViewController!.presentHighlights(results, settings: settings)
            }
        }
    }
}


