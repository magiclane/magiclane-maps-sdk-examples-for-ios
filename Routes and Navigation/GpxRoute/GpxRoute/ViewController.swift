// Copyright (C) 2019-2021, General Magic B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of General Magic
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with General Magic.

import UIKit
import GEMKit

class ViewController: UIViewController, UISearchBarDelegate {
    
    var mapViewController: MapViewController?
    
    var navigationContext: NavigationContext?
    
    var mainRoute: RouteObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "GEM Gpx Route"
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.createMapView()
        
        self.mapViewController!.startRender()
        
        self.addRouteButton()
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
    
    func addRouteButton() {
        
        var image = UIImage.init(systemName: "point.topleft.down.curvedto.point.bottomright.up")
        let barButton1 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(routeButtonAction(item:)))
        
        image = UIImage.init(systemName: "clear")
        let barButton2 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(clearRouteButtonAction(item:)))
        
        image = UIImage.init(systemName: "play")
        let barButton3 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(startSimulation))
        
        self.navigationItem.rightBarButtonItems = [barButton1, barButton2, barButton3]
    }
    
    @objc func routeButtonAction(item: UIBarButtonItem) {
        
        guard let fileURL = Bundle.main.url(forResource: "test", withExtension: "gpx") else {
            
            return
        }
        
        guard let data = NSData.init(contentsOf: fileURL) as Data? else {
            
            return
        }
        
        if self.navigationContext == nil {
            
            self.navigationContext = NavigationContext.init()
            self.navigationContext?.setTransportMode(.bicycle)
        }
        
        let startPoints: [LandmarkObject] = [
            // LandmarkObject.landmark(withName: "Brasov", location: GeoLocation.coordinates(withLatitude: 45.6427, longitude: 25.5887))
        ]
        
        let endPoints: [LandmarkObject] = [
            // LandmarkObject.landmark(withName: "Sinaia", location: GeoLocation.coordinates(withLatitude: 45.3310, longitude: 25.5624))
        ]
        
        item.isEnabled = false
        
        self.navigationContext?.calculateRoute(withStartWaypoints: startPoints, buffer: data, endWaypoints: endPoints, completionHandler: { [weak self] (results: [RouteObject]) in
            
            guard let strongSelf = self else { return }
            
            NSLog("Found %d routes.", results.count)
            
            for route in results {
                
                if let timeDuration = route.getTimeDistance() {
                    
                    let time     = timeDuration.getTotalTimeFormatted() + timeDuration.getTotalTimeUnitFormatted()
                    let distance = timeDuration.getTotalDistanceFormatted() + timeDuration.getTotalDistanceUnitFormatted()
                    
                    NSLog("route time:%@, distance:%@", time, distance)
                }
            }
            
            if results.count > 0 {
                
                strongSelf.mainRoute = results.first
                
                strongSelf.mapViewController?.presentRoutes(results, withTraffic: nil, showSummary: true, animationDuration: 1000)
            }
            
            item.isEnabled = true
        })
    }
    
    @objc func startSimulation(item: UIBarButtonItem) {
        
        guard self.mainRoute != nil else { return }
        
        self.mapViewController!.removeAllRoutes()
        
        self.navigationContext!.simulateRoute(withRoute: self.mainRoute!, speedMultiplier: 2) { [weak self] (success) in
            
            guard let strongSelf = self else { return }
            
            if success {
                
                strongSelf.mapViewController!.showRoutes([strongSelf.mainRoute!], withTraffic: nil, showSummary: false)
                
                strongSelf.mapViewController!.startFollowingPosition(withAnimationDuration: 1600, zoomLevel: -1) { success in }
            }
        }
    }
    
    @objc func clearRouteButtonAction(item: UIBarButtonItem) {
        
        self.mapViewController?.removeAllRoutes()
    }
}
