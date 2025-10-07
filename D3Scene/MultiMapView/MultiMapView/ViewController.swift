// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import UIKit
import GEMKit

class ViewController: UIViewController {
    
    var index: CGFloat = 0
    var offsetTop: CGFloat = 0
    var offsetLeft: CGFloat = 0
    var size: CGFloat = 172
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let navigationController = self.navigationController {
            
            let appearance = navigationController.navigationBar.standardAppearance
            
            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }
        
        var image = UIImage.init(systemName: "plus")
        let barButton1 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(buttonPlusPressed))
        
        image = UIImage.init(systemName: "minus")
        let barButton2 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(buttonMinusPressed))
        
        self.navigationItem.rightBarButtonItems = [barButton1]
        self.navigationItem.leftBarButtonItems = [barButton2]
    }
    
    // MARK: - Map View
    
    func createMapView() {
                
        self.offsetTop = 10 + self.index * 60.0 + 90
        self.offsetLeft = 10 + self.index * 40.0
        self.index += 1
        
        let mapViewController = MapViewController.init()
        mapViewController.view.backgroundColor = UIColor.systemBackground
        mapViewController.setCompassSize(20)
        
        mapViewController.view.layer.borderWidth = 1
        mapViewController.view.layer.borderColor = UIColor.darkGray.cgColor
        mapViewController.view.layer.cornerRadius = 8
        mapViewController.view.layer.shadowColor = UIColor.lightGray.cgColor
        mapViewController.view.layer.shadowOpacity = 0.8
        
        self.addChild(mapViewController)
        self.view.addSubview(mapViewController.view)
        mapViewController.didMove(toParent: self)
        
        mapViewController.view.translatesAutoresizingMaskIntoConstraints = false
        let constraintTop = NSLayoutConstraint( item: mapViewController.view!, attribute: NSLayoutConstraint.Attribute.top,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self.view, attribute: NSLayoutConstraint.Attribute.top,
                                                multiplier: 1.0, constant: self.offsetTop)
        
        let constraintLeft = NSLayoutConstraint( item: mapViewController.view!, attribute: NSLayoutConstraint.Attribute.leading,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading,
                                                 multiplier: 1.0, constant: self.offsetLeft)
        
        let constraintWidth = NSLayoutConstraint( item: mapViewController.view!, attribute: NSLayoutConstraint.Attribute.width,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                  multiplier: 1.0, constant: self.size)
        
        let constraintHeight = NSLayoutConstraint( item: mapViewController.view!, attribute: NSLayoutConstraint.Attribute.height,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                   multiplier: 1.0, constant: self.size)
        
        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintWidth, constraintHeight])
        
        mapViewController.startRender()
    }
    
    func deleteMapView() {
        
        if let mapViewController = self.children.last as? MapViewController {
            
            mapViewController.stopRender()
            
            mapViewController.willMove(toParent: nil)
            mapViewController.view.removeFromSuperview()
            mapViewController.removeFromParent()
            
            self.index -= 1
        }
    }
    
    // MARK: - Button Action
    
    @objc func buttonPlusPressed(barButton: UIBarButtonItem) {
        
        self.createMapView()
    }

    @objc func buttonMinusPressed(barButton: UIBarButtonItem) {
        
        self.deleteMapView()
    }
    
    // MARK: - Render
    
    func startRender() {
        
        for viewController in self.children {
            
            if let mapView = viewController as? MapViewController {
                
                mapView.startRender();
            }
        }
    }
    
    func stopRender() {
        
        for viewController in self.children {
            
            if let mapView = viewController as? MapViewController {
                
                mapView.stopRender();
            }
        }
    }
}

