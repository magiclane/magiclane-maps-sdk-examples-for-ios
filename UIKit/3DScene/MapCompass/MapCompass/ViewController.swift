// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
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
        self.mapViewController!.showCompass()

        self.mapViewController!.setCompassFollowUserInterfaceStyle(true)
        
        self.setCompassTapHandler()
        self.changeCompassSize()
        self.changeCompassInsets()
        
        // Different approach to change compass layout
        //
        // self.changeCompassConstraints()
    }

    // MARK: - Map View

    func createMapView() {

        self.mapViewController = MapViewController.init()
        self.mapViewController!.view.backgroundColor = UIColor.systemBackground

        self.addChild(self.mapViewController!)
        self.view.addSubview(self.mapViewController!.view)
        self.mapViewController!.didMove(toParent: self)

        self.mapViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.mapViewController!.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.mapViewController!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.mapViewController!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.mapViewController!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
    }
    
    func setCompassTapHandler() {
        
        self.mapViewController!.setTapCompassCompletionHandler({ mode in 
            
            print("tap compass")
        })
    }
    
    func changeCompassSize() {
        
        self.mapViewController!.setCompassSize(60.0)
    }
    
    func changeCompassInsets() {
        
        self.mapViewController!.setCompassInsets(UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 40))
    }
    
    // Change constraints directly after map loads
    func changeCompassConstraints() {
        
        let compassImageView = self.mapViewController!.getCompassImageView()
        
        NSLayoutConstraint.deactivate(self.mapViewController!.getCompassLayoutConstraints())
        
        NSLayoutConstraint.activate([
            compassImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 50),
            compassImageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
        ])
    }
}
