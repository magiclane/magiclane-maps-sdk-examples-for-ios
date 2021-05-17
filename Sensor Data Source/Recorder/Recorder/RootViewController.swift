// Copyright (C) 2019-2021, General Magic B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of General Magic
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with General Magic.

import UIKit
import GEMKit
import AVFoundation

class RootViewController: UIViewController {
    var recorderViewController: ImageDrawerController?
    
    var startStopRecBtn: UIBarButtonItem?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = "GEM Map View"
        self.view.backgroundColor = UIColor.systemBackground
                
        createImageDrawer()
        
        let startStopRecBtn = UIBarButtonItem(title: "Record", style: UIBarButtonItem.Style.done, target: self, action: #selector(startStopRecording))
        startStopRecBtn.image = UIImage(systemName: "play")
        startStopRecBtn.tag = 1
        
        let playLogBtn = UIBarButtonItem(title: "Logs", style: UIBarButtonItem.Style.done, target: self, action: #selector(goToPlayLog))
        playLogBtn.tag = 2
        
        self.navigationItem.rightBarButtonItems = [playLogBtn, startStopRecBtn]
        
        self.startStopRecBtn = startStopRecBtn
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.recorderViewController?.startRender()
    }
    
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        
        self.recorderViewController?.stopRender()
    }
    
    @objc func goToPlayLog(barButton: UIBarButtonItem) {
//        let viewController = LogPlaybackController.init()
//        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func startStopRecording() {
        if(recorderViewController?.isRecording() == true){
            startStopRecBtn?.image = UIImage(systemName: "play")
            recorderViewController?.stopRecording()
        } else {
            requestCameraPermission()
        }
    }
    
    func requestCameraPermission()
    {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
            if(!granted) {
                return
            }
            
            DispatchQueue.main.async {
                self.startStopRecBtn?.image = UIImage(systemName: "stop")
                self.recorderViewController?.starRecording()
            }
        }
    }
    
    // MARK: - Render
    
    func startRender() {
        
        for viewController in self.children {
            
            if let viewController = viewController as? ImageDrawerController {
                
                viewController.startRender();
            }
        }
    }
    
    func stopRender() {
        
        for viewController in self.children {
            
            if let viewController = viewController as? ImageDrawerController {
                
                viewController.stopRender();
            }
        }
    }
    
    // MARK: - Render
    
    func createImageDrawer() {
        let controllerView = ImageDrawerController.init()
        controllerView.view.backgroundColor = UIColor.systemBackground
        
        self.addChild(controllerView)
        self.view.addSubview(controllerView.view)
        controllerView.didMove(toParent: self)
        
        let border: CGFloat = 0
        
        controllerView.view.translatesAutoresizingMaskIntoConstraints = false
        let constraintTop = NSLayoutConstraint( item: controllerView.view!, attribute: NSLayoutConstraint.Attribute.top,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self.view, attribute: NSLayoutConstraint.Attribute.top,
                                                multiplier: 1.0, constant: border)

        let constraintLeft = NSLayoutConstraint( item: controllerView.view!, attribute: NSLayoutConstraint.Attribute.leading,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading,
                                                 multiplier: 1.0, constant: border)

        let constraintBottom = NSLayoutConstraint( item: controllerView.view!, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: self.view, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   multiplier: 1.0, constant: -border)

        let constraintRight = NSLayoutConstraint( item: controllerView.view!, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  multiplier: 1.0, constant: -border)
        
        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintBottom, constraintRight])
        self.recorderViewController = controllerView
    }
}
