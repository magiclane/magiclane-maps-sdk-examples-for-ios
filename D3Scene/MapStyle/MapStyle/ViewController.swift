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
    
    var onlineMapStyleList: [ContentStoreObject] = []
    
    var mapStyleContext: MapStyleContext?
    
    var label = UILabel.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let navigationController = self.navigationController {
            
            let appearance = navigationController.navigationBar.standardAppearance
            
            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }
        
        self.createMapView()
        
        self.mapViewController!.startRender()
        
        self.addMapStyleButton()
        self.addLabelText()
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
    
    // MARK: - Label
    
    func addLabelText() {
        
        self.label.font = UIFont.boldSystemFont(ofSize: 18)
        self.label.numberOfLines = 0
        self.label.backgroundColor = UIColor.systemBackground
        self.label.isHidden = true
        self.label.textAlignment = .center
        
        self.view.addSubview(self.label)
        
        self.label.translatesAutoresizingMaskIntoConstraints = false
        let constraintLeft = NSLayoutConstraint( item: self.label, attribute: NSLayoutConstraint.Attribute.leading,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading,
                                                 multiplier: 1.0, constant: 15.0)
        
        let constraintBottom = NSLayoutConstraint( item: self.label, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: self.view.safeAreaLayoutGuide, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   multiplier: 1.0, constant: -15.0)
        
        let constraintRight = NSLayoutConstraint( item: self.label, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  multiplier: 1.0, constant: -15.0)
        
        NSLayoutConstraint.activate([constraintLeft, constraintBottom, constraintRight])
    }
    
    // MARK: - Map Style
    
    func addMapStyleButton() {
        
        let image = UIImage.init(systemName: "map")
        let barButton = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(changeMapStyle))
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func loadOnlineMapStyleList() {
        
        if self.mapStyleContext == nil {
            
            self.mapStyleContext = MapStyleContext.init()
        }
        
        self.mapStyleContext?.getOnlineList(completionHandler: { (array: [ContentStoreObject]) in
            
            self.onlineMapStyleList = array
        })
    }
    
    @objc func changeMapStyle() {
        
        let count = self.onlineMapStyleList.count
        
        guard count > 0 else {
            
            self.loadOnlineMapStyleList()
            
            return
        }
        
        let random = Int.random(in: 0..<count)
        
        let randomObject = self.onlineMapStyleList[random]
        
        let localObjects = self.mapStyleContext?.getLocalList()
        
        for item in localObjects! {
            
            if item.getIdentifier() == randomObject.getIdentifier() {
                
                self.mapViewController!.applyStyle(withStyleIdentifier: item.getIdentifier(), smoothTransition: true)
                
                self.label.text = item.getName() + ", id:\(item.getIdentifier())"
                self.label.isHidden = false
                
                return
            }
        }
        
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        
        randomObject.download(withAllowCellularNetwork: true) { [weak self] (success: Bool) in
            
            guard let strongSelf = self else { return }
            
            let status = randomObject.getStatus()
            
            if success && status == .completed {
                
                strongSelf.mapViewController!.applyStyle(withStyleIdentifier: randomObject.getIdentifier(), smoothTransition: true)
                
                strongSelf.label.text = randomObject.getName() + ", id:\(randomObject.getIdentifier())"
                strongSelf.label.isHidden = false
            }
            
            strongSelf.navigationItem.leftBarButtonItem?.isEnabled = true
        }
        
        
    }
}

