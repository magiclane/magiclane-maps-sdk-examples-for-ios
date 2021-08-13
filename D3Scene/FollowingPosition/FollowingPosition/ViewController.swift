// Copyright (C) 2019-2021, General Magic B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of General Magic
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with General Magic.

import UIKit
import GEMKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var mapViewController: MapViewController?
    
    var locationManager: CLLocationManager?
    
    let positionContext = PositionContext.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.createMapView()
        
        self.mapViewController!.startRender()
        
        self.addLocationButton()
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
    
    // MARK: - Location
    
    func addLocationButton() {
        
        if self.locationManager == nil {

            self.locationManager = CLLocationManager.init()
            self.locationManager!.delegate = self
        }
        
        if self.isLocationAvailable() {
            
            if self.positionContext.isProcessingLocationSevicesData() == false {
            
                self.positionContext.startProcessingLocationSevicesData(withAllowBackgroundLocationUpdates: false)
            }
        }
        
        var image = UIImage.init(systemName: "location")
        
        if self.isLocationAvailable() == false {
            
            image = UIImage.init(systemName: "location.slash")
        }
        
        let barButton = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(startFollowLocation))
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func startFollowLocation() {
        
        if self.isLocationAvailable() == false {
            
            self.requestLocationPermission()
            
        } else {
            
            self.mapViewController!.startFollowingPosition(withAnimationDuration: 1000, zoomLevel: -1) { success in }
        }
    }
    
    func isLocationAvailable() -> Bool {
        
        return (self.locationManager!.authorizationStatus == .authorizedWhenInUse)
    }
    
    func requestLocationPermission() {

        if self.locationManager!.authorizationStatus == .notDetermined {

            self.locationManager!.requestWhenInUseAuthorization()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {

        self.addLocationButton()
    }
}
