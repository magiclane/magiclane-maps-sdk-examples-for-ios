// Copyright (C) 2019-2021, General Magic B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of General Magic
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with General Magic.

import UIKit
import GEMKit

class ViewController: UIViewController, MapViewControllerDelegate, NavigationContextDelegate  {
    
    var mapViewController: MapViewController?
    
    var navigationContext: NavigationContext?
    
    var trafficContext: TrafficContext?
    
    var mainRoute: RouteObject?
    
    var myResults: [RouteObject] = []
    
    var departure: LandmarkObject?
    var destination: LandmarkObject?
    
    var soundContext: SoundContext?
    
    var label = UILabel.init()
    
    let navigationPanel = UIView.init()
    let turnView        = UIView.init()
    let turnImage       = UIImageView.init()
    let turnDistance    = UILabel.init()
    let turnInstruction = UILabel.init()
    let stopButton      = UIButton.init(type: .system)
    let navigationPanelHeight: CGFloat = 110.0
    
    let turnDistFontSize: CGFloat = 24
    let turnDistUnitFontSize: CGFloat = 14

    let turnImageSize: CGFloat = 80
    let turnDistHeight: CGFloat = 30
    let roadCodeSize: CGFloat = 40
    
    let lanePanel   = UIView.init()
    let laneImage   = UIImageView.init()
    let lanePanelHeight: CGFloat = 60.0
    
    let trafficPanel   = UIView.init()
    let trafficImage   = UIImageView.init()
    let trafficTitle   = UILabel.init()
    let trafficDetails = UILabel.init()
    let trafficPanelHeight: CGFloat = 60.0
    let trafficImageSize: CGFloat = 50.0
    
    let signPostImage = UIImageView.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "Simulate Route"
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.createMapView()

        self.mapViewController!.startRender()
        
        self.addRouteButton()
        self.addNavigationPanel()
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
    
    // MARK: - Buttons
    
    func addRouteButton() {
        
        var image = UIImage.init(systemName: "point.topleft.down.curvedto.point.bottomright.up")
        let barButton1 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(routeButtonAction(item:)))

        image = UIImage.init(systemName: "clear")
        let barButton2 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(clearRouteButtonAction(item:)))
        
        image = UIImage.init(systemName: "play")
        let barButton3 = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(startStopSimulation(item:)))
        
        self.navigationItem.rightBarButtonItems = [barButton1, barButton2, barButton3]
    }
    
    // MARK: - Panel
    
    func addNavigationPanel() {
        
        let buttonSize: CGFloat = 44
        let configuration = UIImage.SymbolConfiguration(pointSize: 40, weight: .semibold)
        let image = UIImage.init(systemName: "xmark.circle", withConfiguration: configuration)?.withRenderingMode(.alwaysTemplate)
        self.stopButton.tintColor = UIColor.red
        self.stopButton.backgroundColor = UIColor.black
        self.stopButton.setImage(image, for: .normal)
        self.stopButton.addTarget(self, action: #selector(stopButtonAction), for: .touchUpInside)
        self.stopButton.layer.cornerRadius = buttonSize / 2.0
        self.stopButton.layer.shadowColor = UIColor.gray.cgColor
        self.stopButton.layer.shadowOpacity = 0.8
        
        let font = UIFont.boldSystemFont(ofSize: 20)
        
        self.turnImage.contentMode = .center
        
        self.turnDistance.font = font
        self.turnDistance.textColor = UIColor.white
        self.turnDistance.numberOfLines = 1
        self.turnDistance.textAlignment = .center
        
        self.turnInstruction.font = font
        self.turnInstruction.textColor = UIColor.white
        self.turnInstruction.numberOfLines = 3
        self.turnInstruction.textAlignment = .center
        self.turnInstruction.lineBreakMode = .byTruncatingTail
        
        self.turnView.addSubview(self.turnImage)
        self.turnView.addSubview(self.turnDistance)
        
        self.lanePanel.backgroundColor = self.navigationPanel.backgroundColor
        self.lanePanel.isHidden = true
        self.lanePanel.layer.masksToBounds = true
        self.lanePanel.layer.cornerRadius = 8
        self.lanePanel.layer.borderWidth = 1.0
        self.lanePanel.layer.borderColor = UIColor.darkGray.cgColor
        
        self.laneImage.contentMode = .scaleAspectFit
        
        self.lanePanel.addSubview(self.laneImage)
        
        self.trafficImage.contentMode = .scaleAspectFit
        self.trafficTitle.numberOfLines = 1
        self.trafficTitle.textAlignment = .natural
        self.trafficDetails.numberOfLines = 1
        self.trafficDetails.textAlignment = .natural
        self.trafficPanel.layer.cornerRadius = 8
        self.trafficPanel.isHidden = true
        self.trafficPanel.addSubview(self.trafficTitle)
        self.trafficPanel.addSubview(self.trafficDetails)
        self.trafficPanel.addSubview(self.trafficImage)
        
        self.signPostImage.contentMode = .scaleAspectFit
        self.signPostImage.isHidden = true
        self.signPostImage.layer.masksToBounds = true
        self.signPostImage.backgroundColor = UIColor.black
        self.turnInstruction.addSubview(self.signPostImage)
        
        self.navigationPanel.isHidden = true
        self.navigationPanel.backgroundColor = UIColor.init(red: 20/255, green: 20/255, blue: 20/255, alpha: 1.0)
        self.navigationPanel.layer.cornerRadius = 8.0
        self.navigationPanel.layer.shadowColor = UIColor.gray.cgColor
        self.navigationPanel.layer.shadowOpacity = 0.8
        
        self.navigationPanel.addSubview(self.turnView)
        self.navigationPanel.addSubview(self.lanePanel)
        self.navigationPanel.addSubview(self.trafficPanel)
        self.navigationPanel.addSubview(self.turnInstruction)
        self.navigationPanel.addSubview(self.stopButton)
        
        self.view.addSubview(self.navigationPanel)
        
        
        self.navigationPanel.translatesAutoresizingMaskIntoConstraints = false
        var constraintTop = NSLayoutConstraint( item: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.top,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self.view.safeAreaLayoutGuide, attribute: NSLayoutConstraint.Attribute.top,
                                                multiplier: 1.0, constant: 5.0)
        
        var constraintLeft = NSLayoutConstraint(item: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.leading,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading,
                                                multiplier: 1.0, constant: 10.0)
        
        var constraintRight = NSLayoutConstraint( item: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  multiplier: 1.0, constant: -10.0)
        
        var constraintHeight = NSLayoutConstraint( item: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.height,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                   multiplier: 1.0, constant: self.viewHeight())
        
        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintRight, constraintHeight])
        
        
        self.stopButton.translatesAutoresizingMaskIntoConstraints = false
        constraintTop = NSLayoutConstraint( item: self.stopButton, attribute: NSLayoutConstraint.Attribute.top,
                                            relatedBy: NSLayoutConstraint.Relation.equal,
                                            toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.top,
                                            multiplier: 1.0, constant: -8.0)
        
        constraintRight = NSLayoutConstraint(item: self.stopButton, attribute: NSLayoutConstraint.Attribute.trailing,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.trailing,
                                             multiplier: 1.0, constant: 8.0)
        
        var constraintWidth = NSLayoutConstraint( item: self.stopButton, attribute: NSLayoutConstraint.Attribute.width,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                  multiplier: 1.0, constant: buttonSize)
        
        constraintHeight = NSLayoutConstraint( item: self.stopButton, attribute: NSLayoutConstraint.Attribute.height,
                                               relatedBy: NSLayoutConstraint.Relation.equal,
                                               toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                               multiplier: 1.0, constant: buttonSize)
        
        NSLayoutConstraint.activate([constraintTop, constraintRight, constraintWidth, constraintHeight])
        
        
        self.turnImage.translatesAutoresizingMaskIntoConstraints = false
        constraintTop = NSLayoutConstraint(item: self.turnImage, attribute: NSLayoutConstraint.Attribute.top,
                                           relatedBy: NSLayoutConstraint.Relation.equal,
                                           toItem: self.turnView, attribute: NSLayoutConstraint.Attribute.top,
                                           multiplier: 1.0, constant: 0.0)
        
        constraintLeft = NSLayoutConstraint(item: self.turnImage, attribute: NSLayoutConstraint.Attribute.leading,
                                            relatedBy: NSLayoutConstraint.Relation.equal,
                                            toItem: self.turnView, attribute: NSLayoutConstraint.Attribute.leading,
                                            multiplier: 1.0, constant: 0.0)
        
        constraintWidth = NSLayoutConstraint(item: self.turnImage, attribute: NSLayoutConstraint.Attribute.width,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                             multiplier: 1.0, constant: self.turnImageSize)
        
        constraintHeight = NSLayoutConstraint(item: self.turnImage, attribute: NSLayoutConstraint.Attribute.height,
                                              relatedBy: NSLayoutConstraint.Relation.equal,
                                              toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                              multiplier: 1.0, constant: self.turnImageSize)
        
        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintWidth, constraintHeight])
        
        
        self.turnDistance.translatesAutoresizingMaskIntoConstraints = false
        constraintTop = NSLayoutConstraint(item: self.turnDistance, attribute: NSLayoutConstraint.Attribute.top,
                                           relatedBy: NSLayoutConstraint.Relation.equal,
                                           toItem: self.turnImage, attribute: NSLayoutConstraint.Attribute.bottom,
                                           multiplier: 1.0, constant: -2.5)
        
        constraintLeft = NSLayoutConstraint(item: self.turnDistance, attribute: NSLayoutConstraint.Attribute.leading,
                                            relatedBy: NSLayoutConstraint.Relation.equal,
                                            toItem: self.turnImage, attribute: NSLayoutConstraint.Attribute.leading,
                                            multiplier: 1.0, constant: 0.0)
        
        constraintRight = NSLayoutConstraint(item: self.turnDistance, attribute: NSLayoutConstraint.Attribute.trailing,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.turnImage, attribute: NSLayoutConstraint.Attribute.trailing,
                                             multiplier: 1.0, constant: 0.0)
        
        constraintHeight = NSLayoutConstraint(item: self.turnDistance, attribute: NSLayoutConstraint.Attribute.height,
                                              relatedBy: NSLayoutConstraint.Relation.equal,
                                              toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                              multiplier: 1.0, constant: self.turnDistHeight)
        
        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintRight, constraintHeight])
        
        
        self.turnView.translatesAutoresizingMaskIntoConstraints = false
        constraintTop = NSLayoutConstraint(item: self.turnView, attribute: NSLayoutConstraint.Attribute.top,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.top,
                                                   multiplier: 1.0, constant: 0.0)

        constraintLeft = NSLayoutConstraint(item: self.turnView, attribute: NSLayoutConstraint.Attribute.leading,
                                            relatedBy: NSLayoutConstraint.Relation.equal,
                                            toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.leading,
                                            multiplier: 1.0, constant: 0.0)

        constraintWidth = NSLayoutConstraint(item: self.turnView, attribute: NSLayoutConstraint.Attribute.width,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                             multiplier: 1.0, constant: self.turnImageSize)

        constraintHeight = NSLayoutConstraint(item: self.turnView, attribute: NSLayoutConstraint.Attribute.height,
                                              relatedBy: NSLayoutConstraint.Relation.equal,
                                              toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                              multiplier: 1.0, constant: self.turnImageSize + self.turnDistHeight)
        
        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintWidth, constraintHeight])

        
        self.turnInstruction.translatesAutoresizingMaskIntoConstraints = false
        constraintTop = NSLayoutConstraint( item: self.turnInstruction, attribute: NSLayoutConstraint.Attribute.top,
                                            relatedBy: NSLayoutConstraint.Relation.equal,
                                            toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.top,
                                            multiplier: 1.0, constant: 0.0)

        constraintLeft = NSLayoutConstraint( item: self.turnInstruction, attribute: NSLayoutConstraint.Attribute.leading,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.leading,
                                             multiplier: 1.0, constant: self.turnImageSize)

        constraintRight = NSLayoutConstraint(item: self.turnInstruction, attribute: NSLayoutConstraint.Attribute.trailing,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.trailing,
                                             multiplier: 1.0, constant: -0.0)

        var constraintBottom = NSLayoutConstraint( item: self.turnInstruction, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: self.turnView, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   multiplier: 1.0, constant: -0.0)
        
        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintRight, constraintBottom])
        
        self.turnInstruction.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        self.turnInstruction.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.vertical)

        self.turnInstruction.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        self.turnInstruction.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.vertical)
        
        
        self.laneImage.translatesAutoresizingMaskIntoConstraints = false
        constraintTop = NSLayoutConstraint( item: self.laneImage, attribute: NSLayoutConstraint.Attribute.top,
                                            relatedBy: NSLayoutConstraint.Relation.equal,
                                            toItem: self.lanePanel, attribute: NSLayoutConstraint.Attribute.top,
                                            multiplier: 1.0, constant: 5.0)
        
        constraintLeft = NSLayoutConstraint( item: self.laneImage, attribute: NSLayoutConstraint.Attribute.leading,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.lanePanel, attribute: NSLayoutConstraint.Attribute.leading,
                                             multiplier: 1.0, constant: 0.0)
        
        constraintRight = NSLayoutConstraint(item: self.laneImage, attribute: NSLayoutConstraint.Attribute.trailing,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.lanePanel, attribute: NSLayoutConstraint.Attribute.trailing,
                                             multiplier: 1.0, constant: -0.0)
        
        constraintBottom = NSLayoutConstraint( item: self.laneImage, attribute: NSLayoutConstraint.Attribute.bottom,
                                               relatedBy: NSLayoutConstraint.Relation.equal,
                                               toItem: self.lanePanel, attribute: NSLayoutConstraint.Attribute.bottom,
                                               multiplier: 1.0, constant: -5.0)

        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintRight, constraintBottom])
        
        
        self.lanePanel.translatesAutoresizingMaskIntoConstraints = false
        constraintBottom = NSLayoutConstraint( item: self.lanePanel, attribute: NSLayoutConstraint.Attribute.bottom,
                                            relatedBy: NSLayoutConstraint.Relation.equal,
                                            toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.bottom,
                                            multiplier: 1.0, constant: -2.5)
        
        constraintLeft = NSLayoutConstraint( item: self.lanePanel, attribute: NSLayoutConstraint.Attribute.leading,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.leading,
                                             multiplier: 1.0, constant: 2.5)
        
        constraintRight = NSLayoutConstraint(item: self.lanePanel, attribute: NSLayoutConstraint.Attribute.trailing,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.trailing,
                                             multiplier: 1.0, constant: -2.5)
        
        constraintHeight = NSLayoutConstraint( item: self.lanePanel, attribute: NSLayoutConstraint.Attribute.height,
                                               relatedBy: NSLayoutConstraint.Relation.equal,
                                               toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                               multiplier: 1.0, constant: self.lanePanelHeight)
        
        NSLayoutConstraint.activate([constraintBottom, constraintLeft, constraintRight, constraintHeight])
        
        self.trafficImage.translatesAutoresizingMaskIntoConstraints = false
        constraintLeft = NSLayoutConstraint( item: self.trafficImage, attribute: NSLayoutConstraint.Attribute.leading,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self.trafficPanel, attribute: NSLayoutConstraint.Attribute.leading,
                                                 multiplier: 1.0, constant: 5.0)

        let constraintCenterY = NSLayoutConstraint( item: self.trafficImage, attribute: NSLayoutConstraint.Attribute.centerY,
                                                    relatedBy: NSLayoutConstraint.Relation.equal,
                                                    toItem: self.trafficPanel, attribute: NSLayoutConstraint.Attribute.centerY,
                                                    multiplier: 1.0, constant: 0.0)

        constraintWidth = NSLayoutConstraint(item: self.trafficImage, attribute: NSLayoutConstraint.Attribute.width,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                 multiplier: 1.0, constant: self.trafficImageSize)

        constraintHeight = NSLayoutConstraint( item: self.trafficImage, attribute: NSLayoutConstraint.Attribute.height,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                   multiplier: 1.0, constant: self.trafficImageSize)

        NSLayoutConstraint.activate([constraintLeft, constraintCenterY, constraintWidth, constraintHeight])


        self.trafficTitle.translatesAutoresizingMaskIntoConstraints = false
        constraintTop = NSLayoutConstraint( item: self.trafficTitle, attribute: NSLayoutConstraint.Attribute.top,
                                            relatedBy: NSLayoutConstraint.Relation.equal,
                                            toItem: self.trafficPanel, attribute: NSLayoutConstraint.Attribute.top,
                                            multiplier: 1.0, constant: 0.0)
        
        constraintLeft = NSLayoutConstraint( item: self.trafficTitle, attribute: NSLayoutConstraint.Attribute.leading,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.trafficImage, attribute: NSLayoutConstraint.Attribute.trailing,
                                             multiplier: 1.0, constant: 5.0)
        
        constraintRight = NSLayoutConstraint(item: self.trafficTitle, attribute: NSLayoutConstraint.Attribute.trailing,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.trafficPanel, attribute: NSLayoutConstraint.Attribute.trailing,
                                             multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintRight])
        
        
        self.trafficDetails.translatesAutoresizingMaskIntoConstraints = false
        constraintTop = NSLayoutConstraint( item: self.trafficDetails, attribute: NSLayoutConstraint.Attribute.top,
                                            relatedBy: NSLayoutConstraint.Relation.equal,
                                            toItem: self.trafficTitle, attribute: NSLayoutConstraint.Attribute.bottom,
                                            multiplier: 1.0, constant: 0.0)
        
        constraintLeft = NSLayoutConstraint( item: self.trafficDetails, attribute: NSLayoutConstraint.Attribute.leading,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.trafficImage, attribute: NSLayoutConstraint.Attribute.trailing,
                                             multiplier: 1.0, constant: 5.0)
        
        constraintRight = NSLayoutConstraint(item: self.trafficDetails, attribute: NSLayoutConstraint.Attribute.trailing,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.trafficPanel, attribute: NSLayoutConstraint.Attribute.trailing,
                                             multiplier: 1.0, constant: 0.0)
        
        constraintBottom = NSLayoutConstraint( item: self.trafficDetails, attribute: NSLayoutConstraint.Attribute.bottom,
                                               relatedBy: NSLayoutConstraint.Relation.equal,
                                               toItem: self.trafficPanel, attribute: NSLayoutConstraint.Attribute.bottom,
                                               multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintRight, constraintBottom])
        
        
        self.trafficPanel.translatesAutoresizingMaskIntoConstraints = false
        constraintBottom = NSLayoutConstraint( item: self.trafficPanel, attribute: NSLayoutConstraint.Attribute.bottom,
                                            relatedBy: NSLayoutConstraint.Relation.equal,
                                            toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.bottom,
                                            multiplier: 1.0, constant: -2.5)

        constraintLeft = NSLayoutConstraint( item: self.trafficPanel, attribute: NSLayoutConstraint.Attribute.leading,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.leading,
                                             multiplier: 1.0, constant: 2.5)

        constraintRight = NSLayoutConstraint(item: self.trafficPanel, attribute: NSLayoutConstraint.Attribute.trailing,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.trailing,
                                             multiplier: 1.0, constant: -2.5)
        
        constraintHeight = NSLayoutConstraint( item: self.trafficPanel, attribute: NSLayoutConstraint.Attribute.height,
                                               relatedBy: NSLayoutConstraint.Relation.equal,
                                               toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                               multiplier: 1.0, constant: self.trafficPanelHeight)

        NSLayoutConstraint.activate([constraintBottom, constraintLeft, constraintRight, constraintHeight])

        
        self.trafficTitle.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        self.trafficTitle.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.vertical)
        self.trafficDetails.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        self.trafficDetails.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.vertical)

        self.trafficTitle.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        self.trafficTitle.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.vertical)
        self.trafficDetails.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        self.trafficDetails.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.vertical)
        
        
        self.signPostImage.translatesAutoresizingMaskIntoConstraints = false
        constraintTop = NSLayoutConstraint( item: self.signPostImage, attribute: NSLayoutConstraint.Attribute.top,
                                            relatedBy: NSLayoutConstraint.Relation.equal,
                                            toItem: self.turnInstruction, attribute: NSLayoutConstraint.Attribute.top,
                                            multiplier: 1.0, constant: 2.5)
        
        constraintLeft = NSLayoutConstraint( item: self.signPostImage, attribute: NSLayoutConstraint.Attribute.leading,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.turnInstruction, attribute: NSLayoutConstraint.Attribute.leading,
                                             multiplier: 1.0, constant: 0.0)
        
        constraintRight = NSLayoutConstraint(item: self.signPostImage, attribute: NSLayoutConstraint.Attribute.trailing,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.turnInstruction, attribute: NSLayoutConstraint.Attribute.trailing,
                                             multiplier: 1.0, constant: -5.0)
        
        constraintBottom = NSLayoutConstraint( item: self.signPostImage, attribute: NSLayoutConstraint.Attribute.bottom,
                                               relatedBy: NSLayoutConstraint.Relation.equal,
                                               toItem: self.turnInstruction, attribute: NSLayoutConstraint.Attribute.bottom,
                                               multiplier: 1.0, constant: -2.5)
        
        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintRight, constraintBottom])
    }
    
    @objc func stopButtonAction() {
        
        if let array = self.navigationItem.rightBarButtonItems, array.count > 1 {
            
            let item = array[2]
            
            self.startStopSimulation(item: item)
        }
    }
    
    // MARK: - Label
    
    func addLabelText() {
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(startFollowLocation))
        
        self.label.font = UIFont.boldSystemFont(ofSize: 20)
        self.label.numberOfLines = 0
        self.label.backgroundColor = UIColor.systemBackground
        self.label.isHidden = true
        self.label.textAlignment = .center
        self.label.isUserInteractionEnabled = true
        self.label.addGestureRecognizer(tapGesture)
        
        self.label.layer.shadowColor = UIColor.lightGray.cgColor
        self.label.layer.shadowOpacity = 0.8
        
        self.view.addSubview(self.label)
        
        self.label.translatesAutoresizingMaskIntoConstraints = false
        let constraintLeft = NSLayoutConstraint( item: self.label, attribute: NSLayoutConstraint.Attribute.leading,
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

        let constraintHeight = NSLayoutConstraint( item: self.label, attribute: NSLayoutConstraint.Attribute.height,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                  multiplier: 1.0, constant: 54.0)
        
        NSLayoutConstraint.activate([constraintLeft, constraintBottom, constraintRight, constraintHeight])
    }
    
    @objc func startFollowLocation() {
        
        self.mapViewController!.startFollowingPosition(withAnimationDuration: 1000) { (success: Bool) in }
    }
    
    @objc func routeButtonAction(item: UIBarButtonItem) {
        
        if self.navigationContext == nil {
            
            self.navigationContext = NavigationContext.init()
            self.navigationContext?.delegate = self
            
            // Settings
            self.navigationContext?.setTransportMode(.car)
            self.navigationContext?.setRouteType(.fastest)
            
            // Preferences
            self.navigationContext?.setAvoidMotorways(false)
            self.navigationContext?.setAvoidTollRoads(false)
            self.navigationContext?.setAvoidFerries(false)
            self.navigationContext?.setAvoidUnpavedRoads(true)
        }
        
        if self.trafficContext == nil {
            
            self.trafficContext = TrafficContext.init()
            self.trafficContext?.setUseTraffic(.useOnline)
        }
        
        if self.soundContext == nil {
            
            self.soundContext = SoundContext.init()
            self.soundContext!.setUseTts(true)
        }
        
        self.departure   = LandmarkObject.landmark(withName: "San Francisco", location: GeoLocation.coordinates(withLatitude: 37.77903, longitude: -122.41991) )
        self.destination = LandmarkObject.landmark(withName: "San Jose",      location: GeoLocation.coordinates(withLatitude: 37.33619, longitude: -121.89058) )
        
        guard let start = self.departure, let stop = self.destination else {
            return
        }
        
        let waypoints = [ start, stop];
            
        item.isEnabled = false
        
        weak var weakSelf = self
        
        self.navigationContext?.calculateRoute(withWaypoints: waypoints, completionHandler: { (results: [RouteObject]) in
            
            guard let strongSelf = weakSelf else { return }
            
            NSLog("Found %d routes.", results.count)
            
            strongSelf.myResults = results
            
            for route in results {
                
                if let timeDuration = route.getTimeDistance() {
                    
                    let time     = timeDuration.getTotalTimeFormatted() + timeDuration.getTotalTimeUnitFormatted()
                    let distance = timeDuration.getTotalDistanceFormatted() + timeDuration.getTotalDistanceUnitFormatted()
                    
                    NSLog("route time:%@, distance:%@", time, distance)
                }
            }
            
            if results.count > 0 {
                
                strongSelf.mainRoute = results.first
                
                strongSelf.mapViewController?.presentRoutes(results, withTraffic: strongSelf.trafficContext, showSummary: true, animationDuration: 1000)
            }
            
            item.isEnabled = true
        })
    }
    
    @objc func clearRouteButtonAction(item: UIBarButtonItem) {
        
        self.mapViewController?.removeAllRoutes()
        
        self.mainRoute = nil
    }
    
    @objc func startStopSimulation(item: UIBarButtonItem) {
        
        for route in self.myResults {
            
            if self.mapViewController!.isMainRoute(route) == false {
                
                self.mapViewController!.removeRoutes([route])
            }
        }
        
        self.myResults = []
        
        guard self.mainRoute != nil else {
            return
        }
        
        if self.navigationContext!.isSimulationActive() {
            
            let image = UIImage.init(systemName: "play")
            item.image = image
            
            self.label.isHidden = true
            self.label.removeFromSuperview()
            
            self.navigationContext!.cancelSimulateRoute()
            
            self.mapViewController!.stopFollowingPosition()
            
            self.mapViewController!.removeRoutes([self.mainRoute!])
            
            self.destination = nil
            
            self.mainRoute = nil
            
            self.navigationPanel.isHidden = true
            
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            
        } else {
            
            let image = UIImage.init(systemName: "stop")
            item.image = image
            
            self.navigationContext!.simulateRoute(withRoute: self.mainRoute!, speedMultiplier: 6) { [weak self] (success) in
                
                guard let strongSelf = self else { return }
                
                NSLog("Simulation Route started with success:%@", String(success))
                
                if success {
                    
                    strongSelf.addLabelText()
                    
                    strongSelf.mapViewController!.hideSummary(for: [strongSelf.mainRoute!])
                }
            }
        }
    }
    
    // MARK: - Layout
    
    func refreshContentLayout() {

        var requestUpdateLayout: Bool = false

        let array: [NSLayoutConstraint] = self.view.constraints + self.navigationPanel.constraints + self.lanePanel.constraints

        for constraint in array {
            
            if constraint.isActive && constraint.firstItem === self.navigationPanel && constraint.firstAttribute == NSLayoutConstraint.Attribute.height && constraint.secondItem == nil {

                // Default
                let constant: CGFloat = self.viewHeight()

                if constraint.constant != constant {

                    // Mark
                    requestUpdateLayout = true

                    // Adjust
                    constraint.constant = constant
                }
            }
            
            if constraint.isActive && constraint.firstItem === self.lanePanel && constraint.firstAttribute == NSLayoutConstraint.Attribute.bottom {
                
                var constant: CGFloat = -2.5
                
                if self.trafficPanel.isHidden == false {
                    
                    constant -= self.trafficPanelHeight
                }
                
                if constraint.constant != constant {
                    
                    requestUpdateLayout = true
                    
                    constraint.constant = constant
                }
            }
        }
        
        if requestUpdateLayout {
            
            self.view.layoutIfNeeded()
        }
    }
    
    func viewHeight() -> CGFloat {
        
        var height: CGFloat = self.navigationPanelHeight;
        
        if self.lanePanel.isHidden == false {
            
            height += self.lanePanelHeight + 2.5;
        }

        if self.trafficPanel.isHidden == false {
            
            height += self.trafficPanelHeight + 2.5;
        }

        return height
    }
    
    // MARK: - MapViewControllerDelegate
    
    func mapViewController(_ mapViewController: MapViewController, didSelectLandmark landmark: LandmarkObject, onTouch point: CGPoint) {
        
    }
    
    func mapViewController(_ mapViewController: MapViewController, didSelectLandmark landmark: LandmarkObject, onLongTouch point: CGPoint) {
        
    }
    
    func mapViewController(_ mapViewController: MapViewController, didSelectRoute route: RouteObject) {
        
        self.mainRoute = route
        
        mapViewController.setMainRoute(route)
    }
    
    func mapViewController(_ mapViewController: MapViewController, didSelectStreets streets: [LandmarkObject]) {
        
    }
    
    func mapViewController(_ mapViewController: MapViewController, onTouch point: CGPoint) {
        
    }
    
    func mapViewController(_ mapViewController: MapViewController, onMove startPoint: CGPoint, to endPoint: CGPoint) {
        
    }
    
    // MARK: - NavigationContextDelegate
    
    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationStatusChanged status: NavigationStatus) {
        
    }
    
    func navigationContext(_ navigationContext: NavigationContext, navigationStartedForRoute route: RouteObject) {
        
        self.mapViewController!.startFollowingPosition(withAnimationDuration: 1200) { (success: Bool) in }
    }
    
    func navigationContext(_ navigationContext: NavigationContext, navigationInstructionUpdatedForRoute route: RouteObject) {
        
        let eta = navigationContext.getEstimateTimeOfArrivalFormatted() + navigationContext.getEstimateTimeOfArrivalUnitFormatted()
        
        let rtt = navigationContext.getRemainingTravelTimeFormatted() + navigationContext.getRemainingTravelTimeUnitFormatted()
        
        let rtd = navigationContext.getRemainingTravelDistanceFormatted() + navigationContext.getRemainingTravelDistanceUnitFormatted()
        
        // NSLog("Navigation: refresh: eta:%@, rtt:%@, rtd:%@", eta, rtt, rtd)
        
        let text = eta + "     " + rtt + "     " + rtd
        
        self.label.text = text
        self.label.isHidden = false
        
        if !self.navigationController!.isNavigationBarHidden {
            
            self.navigationPanel.isHidden = false
            
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        
        self.updateTurnInformation(navigationContext: navigationContext)
        
        self.updateLaneInformation(navigationContext: navigationContext)
        
        self.updateTrafficInformation(navigationContext: navigationContext, route: route)
        
        self.updateSignpostInformation(navigationContext: navigationContext)
        
        self.refreshContentLayout()
    }
    
    func navigationContext(_ navigationContext: NavigationContext, navigationRouteUpdated route: RouteObject) {
        
    }
    
    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationWaypointReached waypoint: LandmarkObject) {
        
    }
    
    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationDestinationReached waypoint: LandmarkObject) {
        
        self.stopButtonAction()
    }
    
    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationError code: Int) {
        
    }
    
    func navigationContext(_ navigationContext: NavigationContext, canPlayNavigationSoundForRoute route: RouteObject) -> Bool {
        
        return true
    }
    
    func navigationContext(_ navigationContext: NavigationContext, route: RouteObject, navigationSound text: String) {
        
        // NSLog("NavigationContext: navigationSound text:%@", text)
        
        if let context = self.soundContext {
            
            context.playText(text)
        }
    }
    
    // MARK: - Utils
    
    func updateTurnInformation(navigationContext: NavigationContext) {
        
        var distance = ""
        var distanceUnit = ""
        var instruction = ""
        var image: UIImage?
        
        if let turnInstruction = navigationContext.getNavigationInstruction(), turnInstruction.hasNextTurnInfo() {
            
            let scale = UIScreen.main.scale
            let size = CGSize.init(width: 60 * scale, height: 60 * scale)
            image = turnInstruction.getNextTurnImage(size,
                                                     colorActiveInner: UIColor.white,
                                                     colorActiveOuter: UIColor.black,
                                                     colorInactiveInner: UIColor.lightGray,
                                                     colorInactiveOuter: UIColor.lightGray)
            
            distance  = turnInstruction.getDistanceToNextTurnFormatted()
            distanceUnit = turnInstruction.getDistanceToNextTurnUnitFormatted()
            instruction = turnInstruction.getNextTurnInstructionFormatted()
        }
        
        self.turnImage.image = image
        
        let fontDist     = UIFont.boldSystemFont(ofSize: self.turnDistFontSize)
        let fontDistUnit = UIFont.boldSystemFont(ofSize: self.turnDistUnitFontSize)

        let attrDist     = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: fontDist]
        let attrDistUnit = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: fontDistUnit]

        let distStringAttr     = NSAttributedString(string: distance, attributes: attrDist)
        let distUnitStringAttr = NSAttributedString(string: distanceUnit, attributes: attrDistUnit)
        
        var attributedText = NSMutableAttributedString.init()
        attributedText.append(distStringAttr)
        attributedText.append(distUnitStringAttr)
        self.turnDistance.attributedText = attributedText
        
        attributedText = NSMutableAttributedString.init()
        let attrInstr = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: fontDist]
        let instructionAttr = NSAttributedString(string: instruction, attributes: attrInstr)
        attributedText.append(instructionAttr)
        self.turnInstruction.attributedText = attributedText
    }
    
    func updateLaneInformation(navigationContext: NavigationContext) {
        
        var image: UIImage?
        
        if let turnInstruction = navigationContext.getNavigationInstruction(), turnInstruction.hasNextTurnInfo() {
            
            let scale = UIScreen.main.scale
            let laneSize = CGSize.init(width: self.lanePanel.frame.size.width * scale, height: self.lanePanel.frame.size.height * scale)
            
            image = turnInstruction.getLaneImage(laneSize, backgroundColor: UIColor.black, activeColor: UIColor.white, inactiveColor: UIColor.lightGray)
        }
        
        self.laneImage.image = image
        self.lanePanel.isHidden = !(image != nil)
    }
    
    func updateTrafficInformation(navigationContext: NavigationContext, route: RouteObject) {
                
        var title = ""
        var distance = ""
        var distanceUnit = ""
        var delay = ""
        var delayUnit = ""
        var delayDistance = ""
        var delayDistanceUnit = ""
        var image: UIImage?
        let backgroundColor = UIColor.init(red: 255.0/255.0, green: 175/255.0, blue: 63.0/255.0, alpha: 1.0)
        
        let font     = UIFont.boldSystemFont(ofSize: self.turnDistFontSize)
        let fontUnit = UIFont.boldSystemFont(ofSize: self.turnDistUnitFontSize)
        
        let attrValue = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: font]
        let attrUnit  = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: fontUnit]
        
        
        if let turnInstruction = navigationContext.getNavigationInstruction(), turnInstruction.hasNextTurnInfo() {
            
            if let remainingTravelDistance = turnInstruction.getRemainingTravelTimeDistance()?.getTotalDistance() {
                
                let trafficEvents = route.getTrafficEvents()
                
                for event in trafficEvents {
                    
                    if event.hasTrafficEvent(onDistance: remainingTravelDistance) {
                        
                        let scale = UIScreen.main.scale
                        let size = CGSize.init(width: 60 * scale, height: 60 * scale)
                        
                        if let img = event.getImage(size) {
                            image = img
                        }
                        
                        title = event.getDescription()
                        distance = event.getDistanceFormatted()
                        distanceUnit = event.getDistanceUnitFormatted()

                        delay = event.getDelayTimeFormatted()
                        delayUnit = event.getDelayTimeUnitFormatted()

                        delayDistance = event.getDelayDistanceFormatted()
                        delayDistanceUnit = event.getDelayDistanceUnitFormatted()
                        
                        break
                    }
                }
            }
        }
        
        self.trafficTitle.attributedText = NSAttributedString(string: title, attributes: attrValue)
        
        let attributedText = NSMutableAttributedString.init()
        
        let stringDoubleSpace = NSAttributedString(string: "  ", attributes: attrValue)
        
        if distance.count > 0 {
            
            let distanceAttr     = NSAttributedString(string: distance, attributes: attrValue)
            let distanceUnitAttr = NSAttributedString(string: distanceUnit, attributes: attrUnit)
            attributedText.append(distanceAttr)
            attributedText.append(distanceUnitAttr)
        }
        
        if delay.count > 0 {
            
            if attributedText.length > 0 {
                
                attributedText.append(stringDoubleSpace)
            }

            let delayAttr     = NSAttributedString(string: delay, attributes: attrValue)
            let delayUnitAttr = NSAttributedString(string: delayUnit, attributes: attrUnit)
            attributedText.append(delayAttr)
            attributedText.append(delayUnitAttr)
        }

        if delayDistance.count > 0 {
            
            if attributedText.length > 0 {
                
                attributedText.append(stringDoubleSpace)
            }

            let delayDistanceAttr     = NSAttributedString(string: delayDistance, attributes: attrValue)
            let delayDistanceUnitAttr = NSAttributedString(string: delayDistanceUnit, attributes: attrUnit)
            attributedText.append(delayDistanceAttr)
            attributedText.append(delayDistanceUnitAttr)
        }

        self.trafficImage.image = image
        self.trafficDetails.attributedText = attributedText

        let isHidden: Bool = !(image != nil)
        self.trafficPanel.isHidden = isHidden
        self.trafficPanel.backgroundColor = backgroundColor
    }
    
    func updateSignpostInformation(navigationContext: NavigationContext) {
        
        var image: UIImage?
        
        if let turnInstruction = navigationContext.getNavigationInstruction(), turnInstruction.hasNextTurnInfo() {
            
            if turnInstruction.hasSignpostInfo() {
                
                var imgSizeWidth: CGFloat = 200.0
                var imgSizeHeight: CGFloat = 100.0

                let panelSize = self.signPostImage.frame.size

                if panelSize.width > 0 && panelSize.height > 0 {
                    
                    imgSizeWidth  = panelSize.width
                    imgSizeHeight = panelSize.height
                }
                
                let scale = UIScreen.main.scale
                let size = CGSize.init(width: imgSizeWidth * scale, height: imgSizeHeight * scale)
                
                let border = Int(scale * 5)
                image = turnInstruction.getSignpostImage(size, border: border, roundCorners: true, rows: 3)
            }
        }
        
        self.signPostImage.image = image
        self.signPostImage.isHidden = !(image != nil)
    }
    
    // MARK: - Map Style
    
    func changeMapStyle() {
        
        let mapStyleContext = MapStyleContext.init()
        
        let localObjects = mapStyleContext.getLocalList()
        
        for item in localObjects {
            
            if item.getIdentifier() == 8589935278  { // Night Blues
                
                self.mapViewController!.applyStyle(withStyleIdentifier: item.getIdentifier())
                
                return
            }
        }
        
        mapStyleContext.getOnlineList(completionHandler: { (array: [ContentStoreObject]) in
            
            for item in array {
                
                if item.getIdentifier() == 8589935246 {
                    
                    item.download(withAllowCellularNetwork: true) { [weak self] (success: Bool) in
                        
                        guard let strongSelf = self else { return }
                        
                        if item.getStatus() == .completed {
                            
                            strongSelf.mapViewController!.applyStyle(withStyleIdentifier: item.getIdentifier())
                        }
                    }
                }
            }
        })
    }
    
    // MARK: - Status Bar
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {

        return UIStatusBarStyle.default
    }
}
