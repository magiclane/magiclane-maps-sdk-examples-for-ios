// Copyright (C) 2019-2024, Magic Lane B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of Magic Lane
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with Magic Lane.

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
        
        self.title = "Shapes"
        
        self.createMapView()
        
        self.mapViewController!.startRender()
        self.mapViewController!.setEdgeAreaInsets(self.areaEdge(margin: 30))
        self.mapViewController!.hideCompass()
        
        self.addShapesButton()
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
    
    // MARK: - Shapes
    
    func addShapesButton() {
        
        var image = UIImage.init(systemName: "circle")
        let barButton1 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(toggleCircle(_:)))
        barButton1.tag = 1
        
        image = UIImage.init(systemName: "line.diagonal")
        let barButton2 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(togglePolylines(_:)))
        barButton2.tag = 2
        
        image = UIImage.init(systemName: "triangle")
        let barButton3 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(togglePolygon(_:)))
        barButton3.tag = 3

        image = UIImage.init(systemName: "clear")
        let barButton = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(clearAll))
        
        self.navigationItem.rightBarButtonItems = [barButton1, barButton2, barButton3]
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    @objc func toggleCircle(_ barButton: UIBarButtonItem) {
        
        let name = "My Circle"
        
        if let marker = self.markerAvailable(name: name) {
            
            self.mapViewController!.removeMarker(marker)
            
        } else {
            
            let coordinates = CoordinatesObject.coordinates(withLatitude: 52.350934, longitude: 4.886882)
            
            let marker = MarkerObject.init(circleCenter: coordinates, radius: 3000)
            
            let markerCollection = MarkerCollectionObject.init(name: name, type: .polygon);
            markerCollection.addMarker(marker)
            
            markerCollection.setInnerSize(0.6)
            markerCollection.setInnerColor(UIColor.red)
            
            markerCollection.setOuterSize(1.2)
            markerCollection.setOuterColor(UIColor.black)
            
            markerCollection.setFill(UIColor.yellow.withAlphaComponent(0.25))
            
            self.mapViewController!.addMarker(markerCollection, animationDuration: 100)
        }
    }
    
    @objc func togglePolylines(_ barButton: UIBarButtonItem) {
        
        let name = "My Polyline"
        
        if let marker = self.markerAvailable(name: name) {
            
            self.mapViewController!.removeMarker(marker)
            
        } else {
            
            let coordinates = self.generatePolylinesCoordinates()
            
            let marker = MarkerObject.init(coordinates: coordinates)
            
            let markerCollection = MarkerCollectionObject.init(name: name, type: .polyline);
            markerCollection.addMarker(marker)
            
            markerCollection.setInnerSize(1.0)
            markerCollection.setInnerColor(UIColor.red)
            
            markerCollection.setOuterSize(1.2)
            markerCollection.setOuterColor(UIColor.black)
            
            self.mapViewController!.addMarker(markerCollection, animationDuration: 100)
        }
    }
    
    @objc func togglePolygon(_ barButton: UIBarButtonItem) {
        
        let name = "My Polygon"
        
        if let marker = self.markerAvailable(name: name) {
            
            self.mapViewController!.removeMarker(marker)
            
        } else {
            
            let coordinates = self.generatePolygonCoordinates()
            
            let marker = MarkerObject.init(coordinates: coordinates)
            
            let markerCollection = MarkerCollectionObject.init(name: name, type: .polygon);
            markerCollection.addMarker(marker)
            
            markerCollection.setInnerSize(0.6)
            markerCollection.setInnerColor(UIColor.red)
            
            markerCollection.setOuterSize(1.2)
            markerCollection.setOuterColor(UIColor.black)
            
            markerCollection.setFill(UIColor.yellow.withAlphaComponent(0.25))
            
            self.mapViewController!.addMarker(markerCollection, animationDuration: 100)
        }
    }
    
    @objc func clearAll() {
        
        let allMarkers = self.mapViewController!.getAvailableMarkers()
        
        for marker in allMarkers {
            
            self.mapViewController!.removeMarker(marker)
        }
    }
    
    // MARK: - Utils
    
    func generatePointsCoordinates() -> [CoordinatesObject] {
        
        var coordinates: [CoordinatesObject] = []
        
        coordinates.append(CoordinatesObject.coordinates(withLatitude: 52.380495, longitude: 4.930882))
        coordinates.append(CoordinatesObject.coordinates(withLatitude: 52.380495, longitude: 4.900882))
        coordinates.append(CoordinatesObject.coordinates(withLatitude: 52.380495, longitude: 4.870882))
        coordinates.append(CoordinatesObject.coordinates(withLatitude: 52.380495, longitude: 4.840882))
        
        return coordinates
    }
    
    func generatePolylinesCoordinates() -> [CoordinatesObject] {
        
        var coordinates: [CoordinatesObject] = []
        
        coordinates.append(CoordinatesObject.coordinates(withLatitude: 52.360495, longitude: 4.936882))
        coordinates.append(CoordinatesObject.coordinates(withLatitude: 52.360495, longitude: 4.836882))
        
        return coordinates
    }
    
    func generatePolygonCoordinates() -> [CoordinatesObject] {
        
        var coordinates: [CoordinatesObject] = []
        
        coordinates.append(CoordinatesObject.coordinates(withLatitude: 52.340234, longitude: 4.886882))
        coordinates.append(CoordinatesObject.coordinates(withLatitude: 52.300495, longitude: 4.936882))
        coordinates.append(CoordinatesObject.coordinates(withLatitude: 52.300495, longitude: 4.836882))
        
        return coordinates
    }
    
    func markerAvailable(name: String) -> MarkerCollectionObject? {
        
        let allMarkers = self.mapViewController!.getAvailableMarkers()
        
        for marker in allMarkers {
            
            let markerName = marker.getName()
            
            if markerName == name {
                
                return marker
            }
        }
        
        return nil
    }
    
    func areaEdge(margin: CGFloat) -> UIEdgeInsets {
        
        let scale = UIScreen.main.scale
        
        let insets = UIEdgeInsets.init(top: (self.view.safeAreaInsets.top + margin) * scale,
                                       left: margin * scale,
                                       bottom: (self.view.safeAreaInsets.bottom + margin) * scale,
                                       right: margin * scale)
        
        return insets
    }
}

