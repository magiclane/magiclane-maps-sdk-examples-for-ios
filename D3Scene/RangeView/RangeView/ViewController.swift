// Copyright (C) 2019-2023, Magic Lane B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of Magic Lane
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with Magic Lane.

import UIKit
import GEMKit

class ViewController: UIViewController, MapViewControllerDelegate {
    
    var mapViewController: MapViewController?
    var rangeViewController: RangeViewController?
    
    var buttonExit: UIButton?
    
    deinit {
        
        if let controller = mapViewController {
            
            controller.destroy()
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let navigationController = self.navigationController {
            
            let appearance = navigationController.navigationBar.standardAppearance
            
            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }
        
        self.title = "Range Demo"
        
        self.createMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.mapViewController!.startRender()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        let location = CoordinatesObject.coordinates(withLatitude: 52.517477, longitude: 13.397152) // Berlin
        
        self.mapViewController!.center(onCoordinates: location, zoomLevel: 70, animationDuration: 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        self.mapViewController!.stopRender()
    }
    
    // MARK: - Map View
    
    func createMapView() {
        
        self.mapViewController = MapViewController.init()
        self.mapViewController!.delegate = self
        self.mapViewController!.view.backgroundColor = UIColor.systemBackground
        
        self.addChild(self.mapViewController!)
        self.view.addSubview(self.mapViewController!.view)
        self.mapViewController!.didMove(toParent: self)
        
        self.mapViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.mapViewController!.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            self.mapViewController!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            self.mapViewController!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -0),
            self.mapViewController!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -0),
        ])
    }
    
    // MARK: - TableView
    
    func addRangeView() {
        
        let rangeViewController = RangeViewController.init(mapViewController: self.mapViewController!)
        rangeViewController.view.layer.shadowColor = UIColor.darkGray.cgColor
        rangeViewController.view.layer.shadowOpacity = 0.8
        
        self.view.addSubview(rangeViewController.view)
        
        rangeViewController.view.translatesAutoresizingMaskIntoConstraints = false
        let constraintLeft = NSLayoutConstraint( item: rangeViewController.view!, attribute: NSLayoutConstraint.Attribute.leading,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading,
                                                 multiplier: 1.0, constant: 0.0)
        
        var constraintRight = NSLayoutConstraint( item: rangeViewController.view!, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  multiplier: 1.0, constant: -0.0)
        
        var constraintBottom = NSLayoutConstraint( item: rangeViewController.view!, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: self.view, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   multiplier: 1.0, constant: -0.0)
        
        var constraintHeight = NSLayoutConstraint( item: rangeViewController.view!, attribute: NSLayoutConstraint.Attribute.height,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                   multiplier: 1.0, constant: 360.0)
        
        NSLayoutConstraint.activate([constraintLeft, constraintRight, constraintBottom, constraintHeight])
        
        let size: CGFloat = 50
        
        let buttonExit = UIButton.init(type: .system)
        buttonExit.setImage(UIImage.init(systemName: "xmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)), for: .normal)
        buttonExit.addTarget(self, action: #selector(closeRangeView), for: .touchUpInside)
        buttonExit.layer.shadowColor = UIColor.darkGray.cgColor
        buttonExit.layer.shadowOpacity = 0.8
        buttonExit.backgroundColor = UIColor.systemBackground
        buttonExit.layer.cornerRadius = size / 2
        
        self.buttonExit = buttonExit
        
        self.view.addSubview(buttonExit)
        
        buttonExit.translatesAutoresizingMaskIntoConstraints = false
        constraintRight = NSLayoutConstraint( item: buttonExit, attribute: NSLayoutConstraint.Attribute.trailing,
                                              relatedBy: NSLayoutConstraint.Relation.equal,
                                              toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing,
                                              multiplier: 1.0, constant: -5.0)
        
        constraintBottom = NSLayoutConstraint( item: buttonExit, attribute: NSLayoutConstraint.Attribute.bottom,
                                               relatedBy: NSLayoutConstraint.Relation.equal,
                                               toItem: rangeViewController.view!, attribute: NSLayoutConstraint.Attribute.top,
                                               multiplier: 1.0, constant: size - 30)
        
        let constraintWidth = NSLayoutConstraint( item: buttonExit, attribute: NSLayoutConstraint.Attribute.width,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                  multiplier: 1.0, constant: size)
        
        constraintHeight = NSLayoutConstraint( item: buttonExit, attribute: NSLayoutConstraint.Attribute.height,
                                               relatedBy: NSLayoutConstraint.Relation.equal,
                                               toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                               multiplier: 1.0, constant: size)
        
        NSLayoutConstraint.activate([constraintRight, constraintBottom, constraintWidth, constraintHeight])
        
        self.rangeViewController = rangeViewController
    }
    
    // MARK: - MapViewControllerDelegate
    
    func mapViewController(_ mapViewController: MapViewController, didSelectLandmark landmark: LandmarkObject, onTouch point: CGPoint) {
        
        self.handleSelection(landmark: landmark)
    }
    
    func mapViewController(_ mapViewController: MapViewController, didSelectStreets streets: [LandmarkObject], onTouch point: CGPoint) {
        
        if let lmk = streets.first {
            
            self.handleSelection(landmark: lmk)
        }
    }
    
    func mapViewController(_ mapViewController: MapViewController, didSelectStreets streets: [LandmarkObject], onLongTouch point: CGPoint) {
        
        if let lmk = streets.first {
            
            self.handleSelection(landmark: lmk)
        }
    }
    
    // MARK: - Utils
    
    func handleSelection(landmark: LandmarkObject) {
        
        guard self.rangeViewController == nil else { return }
        
        self.highlight(landmark: landmark)
        
        self.addRangeView()
        
        self.rangeViewController!.landmark = landmark
    }
    
    func highlight(landmark: LandmarkObject) {
        
        guard let mapViewController = self.mapViewController else { return }
        
        let settings = HighlightRenderSettings.init()
        settings.showPin = true
        settings.imageSize = 7
        
        if landmark.isContourGeograficAreaEmpty() == false {
            
            settings.options = Int32( HighlightOptionsShowLandmark | HighlightOptionsOverlap | HighlightOptionsShowContour )
            settings.contourInnerColor = UIColor.white
            settings.contourOuterColor = UIColor.systemBlue
        }
        
        let insets = self.calculateAreaInsets()
        mapViewController.setEdgeAreaInsets(insets)
        
        mapViewController.presentHighlights([landmark], settings: settings, highlightId: 100)
        
        mapViewController.center(onCoordinates: landmark.getCoordinates(), zoomLevel: 80, animationDuration: 800)
    }
    
    func calculateAreaInsets() -> UIEdgeInsets {
        
        let scale = UIScreen.main.scale
        
        let insets = UIEdgeInsets.init(top: (self.view.safeAreaInsets.top) * scale,
                                       left: 0,
                                       bottom: (self.view.safeAreaInsets.bottom + 360) * scale,
                                       right: 0)
        
        return insets
    }
    
    @objc func closeRangeView() {
        
        guard let mapViewController = self.mapViewController else { return }
        
        mapViewController.removeHighlights()
        mapViewController.removeAllRoutes()
        
        if let rangeViewController = self.rangeViewController {
            
            rangeViewController.view.removeFromSuperview()
        }
        
        if let buttonExit = self.buttonExit {
            
            buttonExit.removeFromSuperview()
        }
        
        self.rangeViewController = nil
        self.buttonExit = nil
    }
}

