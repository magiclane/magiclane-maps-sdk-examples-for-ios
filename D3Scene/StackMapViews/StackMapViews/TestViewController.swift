// Copyright (C) 2019-2024, Magic Lane B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of Magic Lane
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with Magic Lane.

import UIKit
import GEMKit

class TestViewController: UIViewController {
    
    var mapViewController: MapViewController?
    
    deinit {
        
        if let controller = mapViewController {
            
            controller.destroy()
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.mapViewController = MapViewController.init()
        self.mapViewController?.view.alpha = 0
        self.mapViewController?.view.backgroundColor = UIColor.systemBackground
        
        self.makeLayoutFor(viewController: self.mapViewController!)
        
        // self.addPolylines()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if self.mapViewController!.view.alpha == 0 {
            
            self.mapViewController!.startRender()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if self.mapViewController!.view.alpha == 0 {
            
            UIView.animate(withDuration: 0.2) {
                
                self.mapViewController!.view.alpha = 1
            }
            
        } else {
            
            self.mapViewController!.startRender()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        self.mapViewController!.stopRender()
    }
    
    // MARK: - Layout
    
    func makeLayoutFor(viewController: UIViewController)  {
        
        self.addChild(viewController)
        self.view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        let constraintTop = NSLayoutConstraint( item: viewController.view!, attribute: NSLayoutConstraint.Attribute.top,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self.view, attribute: NSLayoutConstraint.Attribute.top,
                                                multiplier: 1.0, constant: 0)
        
        let constraintLeft = NSLayoutConstraint( item: viewController.view!, attribute: NSLayoutConstraint.Attribute.leading,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading,
                                                 multiplier: 1.0, constant: 0)
        
        let constraintBottom = NSLayoutConstraint( item: viewController.view!, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: self.view, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   multiplier: 1.0, constant: -0)
        
        let constraintRight = NSLayoutConstraint( item: viewController.view!, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  multiplier: 1.0, constant: -0)
        
        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintBottom, constraintRight])
    }
    
    func addPolylines() {
        
        let coordinates = [
            
            CoordinatesObject.coordinates(withLatitude: 51, longitude: 5),
            CoordinatesObject.coordinates(withLatitude: 51.00001, longitude: 5.1),
            CoordinatesObject.coordinates(withLatitude: 51.00002, longitude: 5.2),
            CoordinatesObject.coordinates(withLatitude: 51.00003, longitude: 5.3),
            CoordinatesObject.coordinates(withLatitude: 51.00004, longitude: 5.3),
            CoordinatesObject.coordinates(withLatitude: 51.00005, longitude: 5.2),
            CoordinatesObject.coordinates(withLatitude: 51.00006, longitude: 5.15),
            CoordinatesObject.coordinates(withLatitude: 51.00007, longitude: 5.3),
            CoordinatesObject.coordinates(withLatitude: 51.00008, longitude: 5.2),
            CoordinatesObject.coordinates(withLatitude: 51.00009, longitude: 5.3),
            CoordinatesObject.coordinates(withLatitude: 51.0001, longitude: 5.123),
            CoordinatesObject.coordinates(withLatitude: 51.00011, longitude: 5.432),
            CoordinatesObject.coordinates(withLatitude: 51.00012, longitude: 5.234),
            CoordinatesObject.coordinates(withLatitude: 51.00013, longitude: 5.525),
            CoordinatesObject.coordinates(withLatitude: 51.00014, longitude: 5.234),
            CoordinatesObject.coordinates(withLatitude: 51.00015, longitude: 5.234234),
            CoordinatesObject.coordinates(withLatitude: 51.00016, longitude: 5.643),
            CoordinatesObject.coordinates(withLatitude: 51.00017, longitude: 5.523),
            CoordinatesObject.coordinates(withLatitude: 51.00018, longitude: 5.253),
            CoordinatesObject.coordinates(withLatitude: 51.00019, longitude: 5.643),
            CoordinatesObject.coordinates(withLatitude: 51.0002, longitude: 5.234),
            CoordinatesObject.coordinates(withLatitude: 51.00011, longitude: 5.152)
        ]
        
        let marker = MarkerObject.init(coordinates: coordinates)
        
        let markerCollection = MarkerCollectionObject.init(name: "My Polylines", type: .polyline)
        markerCollection.addMarker(marker)
        
        markerCollection.setInnerSize(0.5)
        markerCollection.setInnerColor(UIColor.red)
        
        markerCollection.setOuterSize(0.5)
        markerCollection.setOuterColor(UIColor.black)
        
        self.mapViewController!.addMarker(markerCollection, animationDuration: 1600)
    }
    
}
