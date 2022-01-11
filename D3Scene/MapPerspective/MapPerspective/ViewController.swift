// Copyright (C) 2019-2022, General Magic B.V.
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
        
        let image = UIImage.init(systemName: "view.3d")
        let barButton = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(changeMapPerspective))
        barButton.tag = 1

        let image2 = UIImage.init(systemName: "location.north.line")
        let barButton2 = UIBarButtonItem.init(image: image2, style: .done, target: self, action: #selector(mapAlighNorthUp))
        
        self.navigationItem.rightBarButtonItems = [barButton, barButton2]
    }
    
    @objc func changeMapPerspective(item: UIBarButtonItem) {
        
        if item.tag == 1 {
           
            item.tag = 2
            
            item.image = UIImage.init(systemName: "view.2d")
            
            self.mapViewController!.setPerspective(.view3D, animationDuration: 1000) { success in }
            
        } else {
            
            item.tag = 1
            
            item.image = UIImage.init(systemName: "view.3d")
            
            self.mapViewController!.setPerspective(.view2D, animationDuration: 1000) { success in }
        }
    }
    
    @objc func mapAlighNorthUp() {
        
        self.mapViewController!.alignNorthUp(withAnimationDuration: 1000) { success in }
    }
}

