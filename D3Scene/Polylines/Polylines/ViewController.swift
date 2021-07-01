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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.createMapView()
        
        self.mapViewController!.startRender()
        
        self.addPolylineButton()
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
    
    // MARK: - Polylines
    
    func addPolylineButton() {
        
        let image = UIImage.init(systemName: "pencil")
        
        let barButton = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(togglePolylines(_:)))
        barButton.tag = 1
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func togglePolylines(_ barButton: UIBarButtonItem) {
        
        if barButton.tag == 1 {
            
            barButton.tag = 2
            barButton.image = UIImage.init(systemName: "pencil.slash")
            
            let coordinates = self.generatePolylinesCoordinates()
            
            let inColor = self.randomColor()
            let outColor = self.randomColor()
            
            let insets = self.areaEdge(margin: 30)
            
            self.showEdgeaArea(insets: insets)
            
            self.mapViewController!.setEdgeAreaInsets(insets)
            
            self.mapViewController!.addPolylines(withCoordinates: coordinates, innerColor: inColor, outerColor: outColor, animationDuration: 1000)
            
        } else {
            
            barButton.tag = 1
            barButton.image = UIImage.init(systemName: "pencil")
            
            self.mapViewController!.removePolylines()
        }
    }
    
    // MARK: - Utils
    
    func generatePolylinesCoordinates() -> [GeoLocation] {
        
        var coordinates: [GeoLocation] = []
        
        coordinates.append(GeoLocation.coordinates(withLatitude: 52.360234, longitude: 4.886782))
        coordinates.append(GeoLocation.coordinates(withLatitude: 52.360495, longitude: 4.886266))
        coordinates.append(GeoLocation.coordinates(withLatitude: 52.360854, longitude: 4.885539))
        coordinates.append(GeoLocation.coordinates(withLatitude: 52.361184, longitude: 4.884849))
        coordinates.append(GeoLocation.coordinates(withLatitude: 52.361439, longitude: 4.884344))
        coordinates.append(GeoLocation.coordinates(withLatitude: 52.361593, longitude: 4.883986))
        
        return coordinates
    }
    
    func randomColor() -> UIColor {
        
        let random = { CGFloat(arc4random_uniform(255)) / 255.0 }
        
        return UIColor(red: random(), green: random(), blue: random(), alpha: 1)
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
