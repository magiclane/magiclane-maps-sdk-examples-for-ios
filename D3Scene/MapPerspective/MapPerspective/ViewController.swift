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
        
        self.addMapPerspective()
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
    
    // MARK: - Perspective
    
    func addMapPerspective() {
        
        let barButton = UIBarButtonItem.init(image: UIImage.init(systemName: "view.3d"), style: .done, target: self, action: #selector(changeMapPerspective))
        
        let barButton2 = UIBarButtonItem.init(image: UIImage.init(systemName: "location.north.line"), style: .done, target: self, action: #selector(mapAlighNorthUp))
        
        let barButton3 = UIBarButtonItem.init(image: UIImage.init(systemName: "perspective"), style: .done, target: self, action: #selector(togglePerspectiveGesture))
        
        self.navigationItem.rightBarButtonItems = [barButton, barButton2]
        self.navigationItem.leftBarButtonItems  = [barButton3]
    }
    
    @objc func changeMapPerspective(item: UIBarButtonItem) {
        
        guard let mapViewController = self.mapViewController else { return }
        
        if mapViewController.getPerspective() == .view2D {
           
            item.image = UIImage.init(systemName: "view.2d")
            
            mapViewController.setPerspective(.view3D, animationDuration: 1000) { success in }
            
        } else {
            
            item.image = UIImage.init(systemName: "view.3d")
            
            self.mapViewController!.setPerspective(.view2D, animationDuration: 1000) { success in }
        }
    }
    
    @objc func mapAlighNorthUp() {
        
        self.mapViewController!.alignNorthUp(withAnimationDuration: 1000) { success in }
    }
    
    @objc func togglePerspectiveGesture() {
        
        guard let preferences = self.mapViewController?.getPreferences() else { return }
        
        let state = preferences.isTouchGestureEnabled(.onShove)
        
        // Single gesture
        preferences.enableTouchGesture(.onShove, enable: !state)
        
        // Multiple gestures
        // let gestures = (MapViewTouchGestures.onShove.rawValue | MapViewTouchGestures.onRotate.rawValue | MapViewTouchGestures.onPinch.rawValue | MapViewTouchGestures.onPinchSwipe.rawValue)
        // preferences.enableTouchGestures(gestures, enable: !state)
    }
}
