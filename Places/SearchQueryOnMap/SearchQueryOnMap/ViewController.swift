// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import UIKit
import GEMKit

class ViewController: UIViewController {
    
    var mapViewController: MapViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let navigationController = self.navigationController {
            
            let appearance = navigationController.navigationBar.standardAppearance
            
            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }
        
        self.createMapView()
        
        self.mapViewController!.startRender()
        
        self.addSearch()
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
    
    func addSearch() {
        
        let image1 = UIImage.init(systemName: "magnifyingglass")
        let image2 = UIImage.init(systemName: "clear")
        let image3 = UIImage.init(systemName: "mappin.and.ellipse")
        let image4 = UIImage.init(systemName: "line.horizontal.3")
        
        let barButton1 = UIBarButtonItem.init(image: image1, style: .done, target: self, action: #selector(searchButton));
        
        let barButton2 = UIBarButtonItem.init(image: image2, style: .done, target: self, action: #selector(cleanMap));
        
        let barButton3 = UIBarButtonItem.init(image: image3, style: .done, target: self, action: #selector(searchNearbyButton));
        
        let barButton4 = UIBarButtonItem.init(image: image4, style: .done, target: self, action: #selector(searchInParallelButton));
        
        self.navigationItem.rightBarButtonItems = [barButton1, barButton3, barButton4]
        self.navigationItem.leftBarButtonItems = [barButton2]
    }
    
    @objc func searchButton() {
        
        weak var weakSelf = self
        
        self.mapViewController!.search(withQuery: "Paris") { (results: [LandmarkObject]) in
            
            guard let strongSelf = weakSelf else { return }
            
            if let landmark = results.first {
                
                strongSelf.mapViewController!.removeHighlights()
                
                let settings = HighlightRenderSettings.init()
                settings.showPin = true
                settings.imageSize = 7
                
                if landmark.isContourGeograficAreaEmpty() == false {
                    
                    settings.options = Int32( HighlightOption.showLandmark.rawValue | HighlightOption.overlap.rawValue | HighlightOption.showContour.rawValue )
                    settings.contourInnerColor = UIColor.white
                    settings.contourOuterColor = UIColor.systemBlue
                }
                
                self.mapViewController!.presentHighlights([landmark], settings: settings)
                
                self.mapViewController!.center(onCoordinates: landmark.getCoordinates(), zoomLevel: -1, animationDuration: 1200)

            }
        }
    }
    
    @objc func searchNearbyButton() {
        
        weak var weakSelf = self
        
        self.mapViewController!.searchAround { (results: [LandmarkObject]) in
            
            guard let strongSelf = weakSelf else { return }
            
            if let landmark = results.first {
                
                strongSelf.mapViewController!.removeHighlights()
                
                let settings = HighlightRenderSettings.init()
                settings.showPin = true
                settings.imageSize = 7
                
                if landmark.isContourGeograficAreaEmpty() == false {
                    
                    settings.options = Int32( HighlightOption.showLandmark.rawValue | HighlightOption.overlap.rawValue | HighlightOption.showContour.rawValue )
                    settings.contourInnerColor = UIColor.white
                    settings.contourOuterColor = UIColor.systemBlue
                }
                
                self.mapViewController!.presentHighlights([landmark], settings: settings, highlightId: 0)
                
                self.mapViewController!.center(onCoordinates: landmark.getCoordinates(), zoomLevel: -1, animationDuration: 1200)
            }
        }
    }
    
    @objc func searchInParallelButton() {
        
        self.mapViewController!.search(withQuery: "Starbucks") { (results: [LandmarkObject]) in
            
            for landmark in results {
                
                NSLog("landmark name:%@", landmark.getLandmarkName())
            }
        }
        
        self.mapViewController!.search(withQuery: "Hotels") { (results: [LandmarkObject]) in
            
            for landmark in results {
                
                NSLog("landmark name:%@", landmark.getLandmarkName())
            }
        }
        
        self.mapViewController!.searchAround { (results: [LandmarkObject]) in
            
            for landmark in results {
                
                NSLog("landmark name:%@", landmark.getLandmarkName())
            }
        }
    }
    
    @objc func cleanMap(item: UIBarButtonItem) {
        
        self.mapViewController!.removeHighlights()
    }
}

