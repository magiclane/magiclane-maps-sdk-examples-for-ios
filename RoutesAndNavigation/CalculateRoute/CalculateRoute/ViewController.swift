// Copyright (C) 2019-2023, Magic Lane B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of Magic Lane
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with Magic Lane.

import UIKit
import GEMKit

class ViewController: UIViewController, UISearchBarDelegate {
    
    var mapViewController: MapViewController?
    
    var navigationContext: NavigationContext?
    
    var trafficContext: TrafficContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let navigationController = self.navigationController {
            
            let appearance = navigationController.navigationBar.standardAppearance
            
            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }
        
        self.title = "GEM Routes"
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
        
        self.navigationItem.rightBarButtonItems = [barButton1, barButton2]
    }
    
    @objc func routeButtonAction(item: UIBarButtonItem) {
        
        if self.navigationContext == nil {
            
            let preferences = RoutePreferencesObject.init()
            preferences.setTransportMode(.car)
            preferences.setRouteType(.fastest)
            preferences.setAvoidMotorways(false)
            preferences.setAvoidTollRoads(false)
            preferences.setAvoidFerries(false)
            preferences.setAvoidUnpavedRoads(true)
            
            self.navigationContext = NavigationContext.init(preferences: preferences)
        }
        
        if self.trafficContext == nil {
            
            self.trafficContext = TrafficContext.init()
            self.trafficContext?.setUseTraffic(.useOnline)
        }
        
        let waypoints = [
            
            LandmarkObject.landmark(withName: "San Francisco", location: CoordinatesObject.coordinates(withLatitude: 37.77903, longitude: -122.41991) ),
            LandmarkObject.landmark(withName: "San Jose",      location: CoordinatesObject.coordinates(withLatitude: 37.33619, longitude: -121.89058) )
        ];
        
        item.isEnabled = false
        
        weak var weakSelf = self
        
        self.navigationContext?.calculateRoute(withWaypoints: waypoints, completionHandler: { (results: [RouteObject]) in
            
            guard let strongSelf = weakSelf else { return }
            
            NSLog("Found %d routes.", results.count)
            
            for route in results {
                
                if let timeDuration = route.getTimeDistance() {
                    
                    let time     = timeDuration.getTotalTimeFormatted() + timeDuration.getTotalTimeUnitFormatted()
                    let distance = timeDuration.getTotalDistanceFormatted() + timeDuration.getTotalDistanceUnitFormatted()
                    
                    NSLog("route time:%@, distance:%@", time, distance)
                }
            }
            
            if results.count > 0 {
                
                let insets = strongSelf.areaEdge(margin: 70)
                
                strongSelf.showEdgeaArea(insets: insets)
                
                strongSelf.mapViewController?.setEdgeAreaInsets(insets)
                
                strongSelf.mapViewController?.presentRoutes(results, withTraffic: self.trafficContext, showSummary: true, animationDuration: 1600)
            }
            
            item.isEnabled = true
        })
    }
    
    @objc func clearRouteButtonAction(item: UIBarButtonItem) {
        
        self.mapViewController?.removeAllRoutes()
    }
    
    func areaEdge(margin: CGFloat) -> UIEdgeInsets {
        
        let scale = UIScreen.main.scale
        
        let insets = UIEdgeInsets.init(top: (self.view.safeAreaInsets.top + margin) * scale,
                                       left: margin * scale,
                                       bottom: self.view.safeAreaInsets.bottom * scale,
                                       right: margin * scale)
        
        return insets
    }
    
    func showEdgeaArea(insets: UIEdgeInsets) {
        
        let scale = UIScreen.main.scale
        
        let insetsPoints = UIEdgeInsets.init(top: insets.top/scale, left: insets.left/scale,
                                             bottom: insets.bottom/scale, right: insets.right/scale)
        
        if let view = self.view.viewWithTag(10) {
            view.removeFromSuperview()
        }
        
        if let view = self.view.viewWithTag(11) {
            view.removeFromSuperview()
        }

        if let view = self.view.viewWithTag(12) {
            view.removeFromSuperview()
        }

        if let view = self.view.viewWithTag(13) {
            view.removeFromSuperview()
        }
        
        let color = UIColor.systemRed.withAlphaComponent(0.2)
        
        let viewTop = UIView.init()
        viewTop.tag = 10
        viewTop.backgroundColor = color
        viewTop.isUserInteractionEnabled = false
        
        let viewBottom = UIView.init()
        viewBottom.tag = 12
        viewBottom.backgroundColor = color
        viewBottom.isUserInteractionEnabled = false
        
        let viewLeft = UIView.init()
        viewLeft.tag = 11
        viewLeft.backgroundColor = color
        viewLeft.isUserInteractionEnabled = false
        
        let viewRight = UIView.init()
        viewRight.tag = 13
        viewRight.backgroundColor = color
        viewRight.isUserInteractionEnabled = false
        
        
        self.view.addSubview(viewTop)
        self.view.addSubview(viewLeft)
        self.view.addSubview(viewBottom)
        self.view.addSubview(viewRight)
        
        
        viewTop.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewTop.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            viewTop.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            viewTop.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            viewTop.heightAnchor.constraint(equalToConstant: insetsPoints.top)
        ])
        
        viewLeft.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewLeft.topAnchor.constraint(equalTo: viewTop.bottomAnchor, constant: 0),
            viewLeft.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            viewLeft.widthAnchor.constraint(equalToConstant: insetsPoints.left),
            viewLeft.bottomAnchor.constraint(equalTo: viewBottom.topAnchor, constant: 0),
        ])
        
        viewBottom.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewBottom.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
            viewBottom.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            viewBottom.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            viewBottom.heightAnchor.constraint(equalToConstant: insetsPoints.bottom)
        ])
        
        viewRight.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewRight.topAnchor.constraint(equalTo: viewTop.bottomAnchor, constant: 0),
            viewRight.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            viewRight.widthAnchor.constraint(equalToConstant: insetsPoints.right),
            viewRight.bottomAnchor.constraint(equalTo: viewBottom.topAnchor, constant: 0),
        ])
    }
}
