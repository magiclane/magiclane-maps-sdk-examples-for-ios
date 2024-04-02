// Copyright (C) 2019-2023, Magic Lane B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of Magic Lane
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with Magic Lane.

import UIKit
import GEMKit

class ViewController: UIViewController, MapViewControllerDelegate  {
    
    var mapViewController: MapViewController?
    
    var label = UILabel.init()
    var imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let navigationController = self.navigationController {
            
            let appearance = navigationController.navigationBar.standardAppearance
            
            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }
        
        self.title = "Map Selection"
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.createMapView()

        self.mapViewController!.startRender()
        
        self.addLabelText()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Paris
        let location = CoordinatesObject.coordinates(withLatitude: 48.840827, longitude: 2.381899)
        
        self.mapViewController!.center(onCoordinates: location, zoomLevel: 70, animationDuration: 1200)
    }
    
    // MARK: - Map View
    
    func createMapView() {

        self.mapViewController = MapViewController.init()
        self.mapViewController!.delegate = self
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
        
    // MARK: - Label
    
    func addLabelText() {
        
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.isHidden = true
        self.imageView.layer.shadowColor = UIColor.lightGray.cgColor
        self.imageView.layer.shadowOpacity = 0.8
        
        self.label.font = UIFont.boldSystemFont(ofSize: 14)
        self.label.numberOfLines = 0
        self.label.backgroundColor = UIColor.systemBackground
        self.label.isHidden = true
        
        self.label.layer.shadowColor = UIColor.lightGray.cgColor
        self.label.layer.shadowOpacity = 0.8
        
        self.view.addSubview(self.label)
        self.view.addSubview(self.imageView)
        
        self.label.translatesAutoresizingMaskIntoConstraints = false
        var constraintLeft = NSLayoutConstraint( item: self.label, attribute: NSLayoutConstraint.Attribute.leading,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading,
                                                 multiplier: 1.0, constant: 10.0)
        
        let constraintBottom = NSLayoutConstraint( item: self.label, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: self.view.safeAreaLayoutGuide, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   multiplier: 1.0, constant: -10.0)
        
        let constraintRight = NSLayoutConstraint( item: self.label, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  multiplier: 1.0, constant: -10.0)

        var constraintHeight = NSLayoutConstraint( item: self.label, attribute: NSLayoutConstraint.Attribute.height,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                  multiplier: 1.0, constant: 70.0)
        
        NSLayoutConstraint.activate([constraintLeft, constraintBottom, constraintRight, constraintHeight])
        
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        constraintLeft = NSLayoutConstraint( item: self.imageView, attribute: NSLayoutConstraint.Attribute.leading,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.label, attribute: NSLayoutConstraint.Attribute.leading,
                                             multiplier: 1.0, constant: 0.0)
        
        let constraintTop = NSLayoutConstraint( item: self.imageView, attribute: NSLayoutConstraint.Attribute.top,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self.label, attribute: NSLayoutConstraint.Attribute.top,
                                                multiplier: 1.0, constant: -20.0)
        
        let constraintWidth = NSLayoutConstraint( item: self.imageView, attribute: NSLayoutConstraint.Attribute.width,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                  multiplier: 1.0, constant: 40.0)
        
        constraintHeight = NSLayoutConstraint( item: self.imageView, attribute: NSLayoutConstraint.Attribute.height,
                                               relatedBy: NSLayoutConstraint.Relation.equal,
                                               toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                               multiplier: 1.0, constant: 40.0)
        
        NSLayoutConstraint.activate([constraintLeft, constraintTop, constraintWidth, constraintHeight])
    }
    
    // MARK: - MapViewControllerDelegate
    
    func mapViewController(_ mapViewController: MapViewController, didSelectLandmark landmark: LandmarkObject, onTouch point: CGPoint) {
        
        let text = "  " + landmark.getLandmarkName() + "\n" + "  " + landmark.getLandmarkDescription()
        
        self.label.text = text
        self.label.isHidden = false
        
        let scale = UIScreen.main.scale
        self.imageView.image = landmark.getLandmarkImage(CGSize.init(width: 40*scale, height: 40*scale))
        self.imageView.isHidden = false
        
        self.highlight(landmark: landmark)
    }
    
    func mapViewController(_ mapViewController: MapViewController, didSelectLandmark landmark: LandmarkObject, onLongTouch point: CGPoint) {
        
        let text = "  " + landmark.getLandmarkName() + "\n" + "  " + landmark.getLandmarkDescription()
        
        self.label.text = text
        self.label.isHidden = false
        
        let scale = UIScreen.main.scale
        self.imageView.image = landmark.getLandmarkImage(CGSize.init(width: 40*scale, height: 40*scale))
        self.imageView.isHidden = false
        
        self.highlight(landmark: landmark)
    }
    
    func highlight(landmark: LandmarkObject) {
        
        let settings = HighlightRenderSettings.init()
        settings.showPin = true
        settings.imageSize = 7
        
        if landmark.isContourGeograficAreaEmpty() == false {
            
            settings.options = Int32( HighlightOption.showLandmark.rawValue | HighlightOption.overlap.rawValue | HighlightOption.showContour.rawValue )
            settings.contourInnerColor = UIColor.white
            settings.contourOuterColor = UIColor.systemBlue
        }
        
        self.mapViewController!.presentHighlights([landmark], settings: settings, highlightId: 0)
        
        self.mapViewController!.center(onCoordinates: landmark.getCoordinates(), zoomLevel: -1, animationDuration: 900)
    }
}
