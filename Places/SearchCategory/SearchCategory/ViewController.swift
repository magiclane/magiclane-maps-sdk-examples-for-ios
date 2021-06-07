// Copyright (C) 2019-2021, General Magic B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of General Magic
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with General Magic.

import UIKit
import GEMKit

class ViewController: UIViewController {
    
    var mapViewController: MapViewController?
    
    var searchContext: SearchContext?
    
    var categoryContext: GenericCategoriesContext?
    
    let location = GeoLocation.coordinates(withLatitude: 48.840827, longitude: 2.371899)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.createMapView()
        
        self.mapViewController!.startRender()
        
        self.searchContext = SearchContext.init()
        self.searchContext?.setMaxMatches(30)
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
                        
        let barButton1 = UIBarButtonItem.init(title: "Accomodation", style: .done, target: self, action: #selector(searchButton1))
        
        let barButton2 = UIBarButtonItem.init(title: "Gas Station", style: .done, target: self, action: #selector(searchButton2))
        
        self.navigationItem.rightBarButtonItems = [barButton1]
        self.navigationItem.leftBarButtonItems = [barButton2]
    }
    
    @objc func searchButton1(item: UIBarButtonItem) {
        
        self.mapViewController!.center(with: self.location, zoomLevel: 60, animationDuration: 1200)
        
        let object = self.categoryContext!.getLandmarkCategoryObject(with: .accomodation)
        
        self.searchContext?.setCategory(object)
                
        self.searchContext?.searchArround(with: location) { [weak self] (results: [LandmarkObject]) in
            
            guard let strongSelf = self else { return }
            
            if results.count > 0 {
                
                 strongSelf.mapViewController!.presentHighlights(results, animationDuration: 800)
            }
        }
    }
    
    @objc func searchButton2(item: UIBarButtonItem) {
        
        self.mapViewController!.center(with: self.location, zoomLevel: 60, animationDuration: 800)
        
        let object = self.categoryContext!.getLandmarkCategoryObject(with: .gasStation)
        
        self.searchContext?.setCategory(object)
        
        self.searchContext?.searchArround(with: location) { [weak self] (results: [LandmarkObject]) in
            
            guard let strongSelf = self else { return }
            
            if results.count > 0 {
                
                 strongSelf.mapViewController!.presentHighlights(results, animationDuration: 1200)
            }
        }
    }
}


