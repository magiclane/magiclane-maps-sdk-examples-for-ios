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
        
        self.addButton()
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
    
    func addButton() {
        
        let image = UIImage.init(systemName: "plus.circle")
        let barButton = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(newMapViewController))
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func newMapViewController() {
        
        let testViewController = TestViewController.init()
        testViewController.view.backgroundColor = UIColor.systemBackground
        
        self.navigationController?.pushViewController(testViewController, animated: true)
    }
}
