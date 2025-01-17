// Copyright (C) 2019-2024, Magic Lane B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of Magic Lane
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with Magic Lane.

import UIKit
import GEMKit
import CarPlay

class CPRootViewController: UIViewController, CPMapTemplateDelegate  {
    
    var mapViewController: MapViewController?
    
    var mapTemplate: CPMapTemplate?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.mapTemplate = CPMapTemplate.init()
        self.mapTemplate!.mapDelegate = self
        self.mapTemplate!.automaticallyHidesNavigationBar = true
        
        self.addMapButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    // MARK: - Map View
    
    func createMapView() {
        
        let ppi = self.getWindowPpi()
        let scale = self.getWindowScale()
        
        self.mapViewController = MapViewController.init(ppi: ppi, scale: scale)
        self.mapViewController!.view.backgroundColor = UIColor.systemBackground
        self.mapViewController!.hideCompass()
        
        self.mapViewController!.view.alpha = 0
        
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
    
    func startRender() {
        
        guard self.mapViewController != nil else {
            return
        }
        
        self.mapViewController!.startRender()
        
        if let mapView = self.mapViewController!.view, mapView.alpha == 0 {
            
            UIView.animate(withDuration: 1.0) {
                
                mapView.alpha = 1
            }
        }
    }
    
    func stopRender() {
        
        guard self.mapViewController != nil else {
            return
        }
        
        self.mapViewController!.stopRender()
    }
    
    
    // Mark: - Buttos
    
    func addMapButtons() {
        
        let buttonPan = CPMapButton.init { [weak self] (button: CPMapButton) in
            
            guard let strongSelf = self else { return }
            
            if strongSelf.mapTemplate!.isPanningInterfaceVisible == false {
                
                strongSelf.mapTemplate?.showPanningInterface(animated: true)
                
                strongSelf.addNavigationButton()
            }
        }
        buttonPan.image = UIImage.init(named: "CP_Pan")
        
        
        let buttonZoomIn = CPMapButton.init { [weak self] (button: CPMapButton) in
            
            guard let strongSelf = self else { return }
            
            let level = strongSelf.mapViewController!.getZoomLevel() + 4
            
            strongSelf.mapViewController?.center(onZoomLevel: level, animationDuration: 200)
        }
        buttonZoomIn.image = UIImage.init(named: "CP_Plus")
        
        
        let buttonZoomOut = CPMapButton.init { [weak self] (button: CPMapButton) in
            
            guard let strongSelf = self else { return }
            
            let level = strongSelf.mapViewController!.getZoomLevel() - 4
            
            strongSelf.mapViewController?.center(onZoomLevel: level, animationDuration: 200)
            
            /*let scale = strongSelf.getWindowScale()
            let x = ( strongSelf.mapViewController!.view.frame.size.width  / 2.0 ) * scale
            let y = ( strongSelf.mapViewController!.view.frame.size.height / 2.0 ) * scale
            strongSelf.mapViewController?.setZoomWithLevel(level, point: CGPoint(x: x, y: y), animationDuration: 300) */
        }
        buttonZoomOut.image = UIImage.init(named: "CP_Minus")
        
        
        self.mapTemplate!.mapButtons = [buttonPan, buttonZoomIn, buttonZoomOut]
    }
    
    func addNavigationButton() {
        
        let button = CPBarButton.init(type: .text) { [weak self] (button: CPBarButton) in
            
            guard let strongSelf = self else { return }
            
            strongSelf.mapTemplate?.dismissPanningInterface(animated: true)
            
            strongSelf.mapTemplate!.trailingNavigationBarButtons = []
        }
        button.title = "Done"
        
        self.mapTemplate!.trailingNavigationBarButtons = [button]
    }
    
    // MARK: - CPMapTemplateDelegate
    
    func mapTemplate(_ mapTemplate: CPMapTemplate, panWith direction: CPMapTemplate.PanDirection) {
        
        guard let mapViewController = self.mapViewController else { return }
        
        let offset: CGFloat = 25.0
        
        var translation: CGPoint = .zero
        
        switch direction {
            
        case .left:
            translation = CGPoint.init(x: offset, y: 0)
            
        case .right:
            translation = CGPoint.init(x: -offset, y: 0)
            
        case .up:
            translation = CGPoint.init(x: 0, y: offset)
            
        case .down:
            translation = CGPoint.init(x: 0, y: -offset)
            
        default:
            break
        }
        
        let scale = self.getWindowScale()
        
        let value = CGPoint.init(x: scale * translation.x, y: scale * translation.y)
        
        mapViewController.scrollMap(value)
    }
    
    func mapTemplateDidBeginPanGesture(_ mapTemplate: CPMapTemplate) {
        
    }
    
    func mapTemplate(_ mapTemplate: CPMapTemplate, didUpdatePanGestureWithTranslation translation: CGPoint, velocity: CGPoint) {
        
        guard let mapViewController = self.mapViewController else { return }
        
        let scale = self.getWindowScale()
        
        let value = CGPoint.init(x: scale * translation.x, y: scale * translation.y)
        
        mapViewController.scrollMap(value)
    }
    
    func mapTemplate(_ mapTemplate: CPMapTemplate, didEndPanGestureWithVelocity velocity: CGPoint) {
        
        guard let mapViewController = self.mapViewController else { return }
        
        mapViewController.flingMap(velocity)
    }
    
    // MARK: - Utils
    
    func getWindowPpi() -> Int {
        
        let window = CarPlayInterface.sharedInstance().getWindow()
        
        // Standard: 800 x 480, scale 2.0, 7 inch
        var ppi: Int = 134
        
        if window!.screen.scale >= 3
        {
            ppi = 400
        }
        
        return ppi
    }
    
    func getWindowScale() -> CGFloat {
        
        let count = UIScreen.screens.count
        
        NSLog("screens count=%d", count)
        
        for screen in UIScreen.screens {
            
            if screen === UIScreen.main {
                
                NSLog("found main screen")
                
            } else {
                
                NSLog("found carplay screen")
                
                let scale = screen.scale
                
                return scale
            }
        }
        
        return 2.0
    }
}

