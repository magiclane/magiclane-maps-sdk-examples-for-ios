// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: BSD-3-Clause
//
// Contact Magic Lane at <info@magiclane.com> for commercial licensing options.

import UIKit
import GEMKit

class ViewController: UIViewController, UISearchBarDelegate {
    
    var mapViewController1: MapViewController?
    var mapViewController2: MapViewController?
    
    var navigationContext1: NavigationContext?
    var navigationContext2: NavigationContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let navigationController = self.navigationController {
            
            let appearance = navigationController.navigationBar.standardAppearance
            
            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }
        
        self.title = "GEM Routes"
        self.view.backgroundColor = UIColor.lightGray
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.addRouteButton()
    }
    
    // MARK: - Map View

    func createMap1View() {
        
        self.mapViewController1 = MapViewController.init()
        self.mapViewController1!.view.backgroundColor = UIColor.systemBackground
        
        self.mapViewController1!.view.layer.cornerRadius = 8
        self.mapViewController1!.view.layer.masksToBounds = true
        
        self.addChild(self.mapViewController1!)
        self.view.addSubview(self.mapViewController1!.view)
        self.mapViewController1!.didMove(toParent: self)
        
        self.mapViewController1?.view.translatesAutoresizingMaskIntoConstraints = false
        let constraintTop = NSLayoutConstraint( item: self.mapViewController1!.view!, attribute: NSLayoutConstraint.Attribute.top,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self.view.safeAreaLayoutGuide, attribute: NSLayoutConstraint.Attribute.top,
                                                multiplier: 1.0, constant: 15)
        
        let constraintLeft = NSLayoutConstraint( item: self.mapViewController1!.view!, attribute: NSLayoutConstraint.Attribute.leading,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading,
                                                 multiplier: 1.0, constant: 15)
        
        let constraintBottom = NSLayoutConstraint( item: self.mapViewController1!.view!, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: self.view, attribute: NSLayoutConstraint.Attribute.centerY,
                                                   multiplier: 1.0, constant: -0)
        
        let constraintRight = NSLayoutConstraint( item: self.mapViewController1!.view!, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  multiplier: 1.0, constant: -15)
        
        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintBottom, constraintRight])
        
        self.mapViewController1!.startRender()
    }
    
    func createMap2View() {

        self.mapViewController2 = MapViewController.init()
        self.mapViewController2!.view.backgroundColor = UIColor.systemBackground
        
        self.mapViewController2!.view.layer.cornerRadius = 8
        self.mapViewController2!.view.layer.masksToBounds = true
        
        self.addChild(self.mapViewController2!)
        self.view.addSubview(self.mapViewController2!.view)
        self.mapViewController2!.didMove(toParent: self)
        
        self.mapViewController2?.view.translatesAutoresizingMaskIntoConstraints = false
        let constraintTop = NSLayoutConstraint( item: self.mapViewController2!.view!, attribute: NSLayoutConstraint.Attribute.top,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self.view, attribute: NSLayoutConstraint.Attribute.centerY,
                                                multiplier: 1.0, constant: 10)
        
        let constraintLeft = NSLayoutConstraint( item: self.mapViewController2!.view!, attribute: NSLayoutConstraint.Attribute.leading,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading,
                                                 multiplier: 1.0, constant: 15)
        
        let constraintBottom = NSLayoutConstraint( item: self.mapViewController2!.view!, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: self.view.safeAreaLayoutGuide, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   multiplier: 1.0, constant: -5)
        
        let constraintRight = NSLayoutConstraint( item: self.mapViewController2!.view!, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  multiplier: 1.0, constant: -15)
        
        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintBottom, constraintRight])
        
        self.mapViewController2!.startRender()
    }
    
    func addRouteButton() {
        
        var image = UIImage.init(systemName: "point.topleft.down.curvedto.point.bottomright.up")
        let barButton1 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(route1ButtonAction(item:)))
        
        image = UIImage.init(systemName: "point.topleft.down.curvedto.point.bottomright.up")
        let barButton2 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(route2ButtonAction(item:)))
        
        image = UIImage.init(systemName: "clear")
        let barButton = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(clearRouteButtonAction(item:)))
        
        self.navigationItem.rightBarButtonItems = [barButton1, barButton2]
        self.navigationItem.leftBarButtonItems = [barButton]
    }
    
    @objc func route1ButtonAction(item: UIBarButtonItem) {
        
        if self.navigationContext1 == nil {
            
            self.createMap1View()
            
            let preferences = RoutePreferencesObject.init()
            preferences.setTransportMode(.car)
            preferences.setRouteType(.fastest)
            preferences.setAvoidMotorways(false)
            preferences.setAvoidTollRoads(false)
            preferences.setAvoidFerries(false)
            preferences.setAvoidUnpavedRoads(true)
            
            self.navigationContext1 = NavigationContext.init(preferences: preferences)
            
            return
        }
        
        self.mapViewController1?.removeAllRoutes()
        
        item.isEnabled = false
        
        let waypoints = [
            
            LandmarkObject.landmark(withName: "San Francisco", location: CoordinatesObject.coordinates(withLatitude: 37.77903, longitude: -122.41991) ),
            LandmarkObject.landmark(withName: "San Jose",      location: CoordinatesObject.coordinates(withLatitude: 37.33619, longitude: -121.89058) )
        ];
        
        weak var weakSelf = self
        
        self.navigationContext1?.calculateRoute(withWaypoints: waypoints, completionHandler: { (results: [RouteObject]) in
            
            guard let strongSelf = weakSelf else { return }
            
            for route in results {
                
                if let timeDuration = route.getTimeDistance() {
                    
                    let time     = timeDuration.getTotalTimeFormatted() + timeDuration.getTotalTimeUnitFormatted()
                    let distance = timeDuration.getTotalDistanceFormatted() + timeDuration.getTotalDistanceUnitFormatted()
                    
                    NSLog("route time:%@, distance:%@", time, distance)
                }
            }
            
            if results.count > 0 {
                
                strongSelf.mapViewController1?.presentRoutes(results, withTraffic: nil, showSummary: true, animationDuration: 1000)
            }
            
            item.isEnabled = true
        })
    }
    
    @objc func route2ButtonAction(item: UIBarButtonItem) {
        
        if self.navigationContext2 == nil {
            
            self.createMap2View()
            
            let preferences = RoutePreferencesObject.init()
            preferences.setTransportMode(.car)
            preferences.setRouteType(.fastest)
            preferences.setAvoidMotorways(false)
            preferences.setAvoidTollRoads(false)
            preferences.setAvoidFerries(false)
            preferences.setAvoidUnpavedRoads(true)
            
            self.navigationContext2 = NavigationContext.init(preferences: preferences)
            
            return
        }
        
        self.mapViewController2?.removeAllRoutes()
        
        item.isEnabled = false
        
        let waypoints = [
            
            LandmarkObject.landmark(withName: "London",    location: CoordinatesObject.coordinates(withLatitude: 51.50732, longitude: -0.12765) ),
            LandmarkObject.landmark(withName: "Maidstone", location: CoordinatesObject.coordinates(withLatitude: 51.27483, longitude: 0.52316) )
        ];
        
        weak var weakSelf = self
        
        self.navigationContext2?.calculateRoute(withWaypoints: waypoints, completionHandler: { (results: [RouteObject]) in
            
            guard let strongSelf = weakSelf else { return }
            
            for route in results {
                
                if let timeDuration = route.getTimeDistance() {
                    
                    let time     = timeDuration.getTotalTimeFormatted() + timeDuration.getTotalTimeUnitFormatted()
                    let distance = timeDuration.getTotalDistanceFormatted() + timeDuration.getTotalDistanceUnitFormatted()
                    
                    NSLog("route time:%@, distance:%@", time, distance)
                }
            }
            
            if results.count > 0 {
                
                strongSelf.mapViewController2?.presentRoutes(results, withTraffic: nil, showSummary: true, animationDuration: 1000)
            }
            
            item.isEnabled = true
        })
    }
    
    @objc func clearRouteButtonAction(item: UIBarButtonItem) {
        
        self.mapViewController1?.removeAllRoutes()
        self.mapViewController2?.removeAllRoutes()
    }
}
