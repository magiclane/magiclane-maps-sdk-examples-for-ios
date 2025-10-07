// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import UIKit
import GEMKit

class NavigationViewController: UIViewController {
    
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

    let safetyPanel   = UIView.init()
    let safetyImage   = UIImageView.init()
    let safetyDetails = UILabel.init()
    let safetyPanelHeight: CGFloat = 60.0
    let safetyImageSize: CGFloat = 50.0

    let reportsPanel         = UIView.init()
    let reportsPanelAnimated = UIView.init()
    let reportsImage   = UIImageView.init()
    let reportsBadge   = UILabel.init()
    let reportsDetails = UILabel.init()
    let thumbsUpButton   = UIButton.init(type: .custom)
    let thumbsDownButton = UIButton.init(type: .custom)
    let reportsPanelHeight: CGFloat = 60.0
    let reportsImageSize: CGFloat = 50.0
    let reportsBadgeSize: CGFloat = 26.0
    
    let customTurnNextImage = UIImageView.init()
    let customTurnNextNextImage = UIImageView.init()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.addNavigationPanel()
        self.addExtraPanels()
    }
    
    func addNavigationPanel() {
        
        let buttonSize: CGFloat = 44
        let configuration = UIImage.SymbolConfiguration(pointSize: 40, weight: .semibold)
        let image = UIImage.init(systemName: "xmark.circle", withConfiguration: configuration)?.withRenderingMode(.alwaysTemplate)
        self.stopButton.tintColor = UIColor.red
        self.stopButton.backgroundColor = UIColor.black
        self.stopButton.setImage(image, for: .normal)
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
        
        self.safetyImage.contentMode = .center
        self.safetyDetails.numberOfLines = 2
        self.safetyDetails.textAlignment = .natural
        self.safetyPanel.backgroundColor = UIColor.white
        self.safetyPanel.layer.masksToBounds = true
        self.safetyPanel.layer.cornerRadius = 8
        self.safetyPanel.isHidden = true
        self.safetyPanel.addSubview(self.safetyImage)
        self.safetyPanel.addSubview(self.safetyDetails)
        
        self.signPostImage.contentMode = .scaleAspectFit
        self.signPostImage.isHidden = true
        self.signPostImage.layer.masksToBounds = true
        self.signPostImage.backgroundColor = UIColor.black
        self.turnInstruction.addSubview(self.signPostImage)
        
        self.reportsImage.contentMode = .center
        
        self.reportsBadge.adjustsFontSizeToFitWidth = true
        self.reportsBadge.numberOfLines = 1
        self.reportsBadge.textAlignment = .center
        self.reportsBadge.backgroundColor = UIColor.white
        self.reportsBadge.layer.masksToBounds = true
        self.reportsBadge.layer.cornerRadius = self.reportsBadgeSize/2
        self.reportsBadge.layer.borderWidth = 1.8
        self.reportsBadge.layer.borderColor = UIColor.black.cgColor
        self.reportsBadge.isHidden = true

        self.reportsImage.addSubview(self.reportsBadge)

        self.reportsDetails.numberOfLines = 2
        self.reportsDetails.textAlignment = .natural

        self.reportsPanel.backgroundColor         = UIColor.white
        self.reportsPanelAnimated.backgroundColor = UIColor.white
        self.reportsPanelAnimated.layer.cornerRadius = 8
        self.reportsPanelAnimated.isHidden = true

        self.reportsPanel.layer.masksToBounds = true
        self.reportsPanel.layer.cornerRadius = 8
        self.reportsPanel.isHidden = true
        
        self.thumbsUpButton.layer.masksToBounds   = true
        self.thumbsDownButton.layer.masksToBounds = true
        self.thumbsUpButton.layer.cornerRadius    = 8
        self.thumbsDownButton.layer.cornerRadius  = 8
        
        self.thumbsUpButton.addTarget(self, action: #selector(thumbsUpButtonAction), for: .touchUpInside)
        self.thumbsDownButton.addTarget(self, action: #selector(thumbsDownButtonAction), for: .touchUpInside)
        
        self.reportsPanel.addSubview(self.reportsPanelAnimated)
        self.reportsPanel.addSubview(self.reportsImage)
        self.reportsPanel.addSubview(self.reportsDetails)
        self.reportsPanel.addSubview(self.thumbsUpButton)
        self.reportsPanel.addSubview(self.thumbsDownButton)
        
        
        self.navigationPanel.backgroundColor = UIColor.init(red: 20/255, green: 20/255, blue: 20/255, alpha: 1.0)
        self.navigationPanel.layer.cornerRadius = 8.0
        self.navigationPanel.layer.shadowColor = UIColor.gray.cgColor
        self.navigationPanel.layer.shadowOpacity = 0.8
        
        self.navigationPanel.addSubview(self.turnView)
        self.navigationPanel.addSubview(self.lanePanel)
        self.navigationPanel.addSubview(self.trafficPanel)
        self.navigationPanel.addSubview(self.safetyPanel)
        self.navigationPanel.addSubview(self.reportsPanel)
        self.navigationPanel.addSubview(self.turnInstruction)
        self.navigationPanel.addSubview(self.stopButton)
        
        self.view.addSubview(self.navigationPanel)
        
        self.navigationPanel.translatesAutoresizingMaskIntoConstraints = false
        var constraintTop = NSLayoutConstraint( item: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.top,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self.view, attribute: NSLayoutConstraint.Attribute.top,
                                                multiplier: 1.0, constant: 0.0)
        
        var constraintLeft = NSLayoutConstraint(item: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.leading,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading,
                                                multiplier: 1.0, constant: 0.0)
        
        var constraintRight = NSLayoutConstraint( item: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  multiplier: 1.0, constant: 0.0)
        
        var constraintBottom = NSLayoutConstraint( item: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: self.view, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   multiplier: 1.0, constant: 0)
        
        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintRight, constraintBottom])
        
        
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
        
        var constraintHeight = NSLayoutConstraint( item: self.stopButton, attribute: NSLayoutConstraint.Attribute.height,
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

        constraintBottom = NSLayoutConstraint( item: self.turnInstruction, attribute: NSLayoutConstraint.Attribute.bottom,
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

        var constraintCenterY = NSLayoutConstraint( item: self.trafficImage, attribute: NSLayoutConstraint.Attribute.centerY,
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
                                             multiplier: 1.0, constant: -2.5)
        
        constraintBottom = NSLayoutConstraint( item: self.signPostImage, attribute: NSLayoutConstraint.Attribute.bottom,
                                               relatedBy: NSLayoutConstraint.Relation.equal,
                                               toItem: self.turnInstruction, attribute: NSLayoutConstraint.Attribute.bottom,
                                               multiplier: 1.0, constant: -2.5)
        
        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintRight, constraintBottom])
        
        self.safetyImage.translatesAutoresizingMaskIntoConstraints = false
        constraintLeft = NSLayoutConstraint( item: self.safetyImage, attribute: NSLayoutConstraint.Attribute.leading,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self.safetyPanel, attribute: NSLayoutConstraint.Attribute.leading,
                                                 multiplier: 1.0, constant: 5.0)

        constraintCenterY = NSLayoutConstraint( item: self.safetyImage, attribute: NSLayoutConstraint.Attribute.centerY,
                                                    relatedBy: NSLayoutConstraint.Relation.equal,
                                                    toItem: self.safetyPanel, attribute: NSLayoutConstraint.Attribute.centerY,
                                                    multiplier: 1.0, constant: 0.0)

        constraintWidth = NSLayoutConstraint(item: self.safetyImage, attribute: NSLayoutConstraint.Attribute.width,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                 multiplier: 1.0, constant: self.safetyImageSize)

        constraintHeight = NSLayoutConstraint( item: self.safetyImage, attribute: NSLayoutConstraint.Attribute.height,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                   multiplier: 1.0, constant: self.safetyImageSize)

        NSLayoutConstraint.activate([constraintLeft, constraintCenterY, constraintWidth, constraintHeight])
        
        self.safetyDetails.translatesAutoresizingMaskIntoConstraints = false
        constraintTop = NSLayoutConstraint( item: self.safetyDetails, attribute: NSLayoutConstraint.Attribute.top,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self.safetyPanel, attribute: NSLayoutConstraint.Attribute.top,
                                                multiplier: 1.0, constant: 0.0)

        constraintLeft = NSLayoutConstraint( item: self.safetyDetails, attribute: NSLayoutConstraint.Attribute.leading,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.safetyImage, attribute: NSLayoutConstraint.Attribute.trailing,
                                             multiplier: 1.0, constant: 5.0)

        constraintRight = NSLayoutConstraint(item: self.safetyDetails, attribute: NSLayoutConstraint.Attribute.trailing,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self.safetyPanel, attribute: NSLayoutConstraint.Attribute.trailing,
                                                 multiplier: 1.0, constant: 0.0)

        constraintBottom = NSLayoutConstraint( item: self.safetyDetails, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: self.safetyPanel, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   multiplier: 1.0, constant: 0.0)

        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintRight, constraintBottom])
        
        self.safetyPanel.translatesAutoresizingMaskIntoConstraints = false
        constraintBottom = NSLayoutConstraint( item: self.safetyPanel, attribute: NSLayoutConstraint.Attribute.bottom,
                                            relatedBy: NSLayoutConstraint.Relation.equal,
                                            toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.bottom,
                                            multiplier: 1.0, constant: -2.5)

        constraintLeft = NSLayoutConstraint( item: self.safetyPanel, attribute: NSLayoutConstraint.Attribute.leading,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.leading,
                                             multiplier: 1.0, constant: 2.5)

        constraintRight = NSLayoutConstraint(item: self.safetyPanel, attribute: NSLayoutConstraint.Attribute.trailing,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.trailing,
                                             multiplier: 1.0, constant: -2.5)
        
        constraintHeight = NSLayoutConstraint( item: self.safetyPanel, attribute: NSLayoutConstraint.Attribute.height,
                                               relatedBy: NSLayoutConstraint.Relation.equal,
                                               toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                               multiplier: 1.0, constant: self.safetyPanelHeight)

        NSLayoutConstraint.activate([constraintBottom, constraintLeft, constraintRight, constraintHeight])

        
        self.safetyDetails.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        self.safetyDetails.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.vertical)
        
        self.safetyDetails.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        self.safetyDetails.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.vertical)
        
        
        self.reportsImage.translatesAutoresizingMaskIntoConstraints = false
        constraintLeft = NSLayoutConstraint( item: self.reportsImage, attribute: NSLayoutConstraint.Attribute.leading,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self.reportsPanel, attribute: NSLayoutConstraint.Attribute.leading,
                                                 multiplier: 1.0, constant: 5.0)

        constraintCenterY = NSLayoutConstraint( item: self.reportsImage, attribute: NSLayoutConstraint.Attribute.centerY,
                                                    relatedBy: NSLayoutConstraint.Relation.equal,
                                                    toItem: self.reportsPanel, attribute: NSLayoutConstraint.Attribute.centerY,
                                                    multiplier: 1.0, constant: 0.0)

        constraintWidth = NSLayoutConstraint(item: self.reportsImage, attribute: NSLayoutConstraint.Attribute.width,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                 multiplier: 1.0, constant: self.reportsImageSize)

        constraintHeight = NSLayoutConstraint( item: self.reportsImage, attribute: NSLayoutConstraint.Attribute.height,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                   multiplier: 1.0, constant: self.reportsImageSize)

        NSLayoutConstraint.activate([constraintLeft, constraintCenterY, constraintWidth, constraintHeight])

        
        self.reportsBadge.translatesAutoresizingMaskIntoConstraints = false
        constraintTop = NSLayoutConstraint( item: self.reportsBadge, attribute: NSLayoutConstraint.Attribute.top,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self.reportsImage, attribute: NSLayoutConstraint.Attribute.top,
                                                multiplier: 1.0, constant: -4.0)

        constraintRight = NSLayoutConstraint( item: self.reportsBadge, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: self.reportsImage, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  multiplier: 1.0, constant: 8.0)

        constraintWidth = NSLayoutConstraint(item: self.reportsBadge, attribute: NSLayoutConstraint.Attribute.width,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                             multiplier: 1.0, constant: self.reportsBadgeSize)

        constraintHeight = NSLayoutConstraint( item: self.reportsBadge, attribute: NSLayoutConstraint.Attribute.height,
                                               relatedBy: NSLayoutConstraint.Relation.equal,
                                               toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                               multiplier: 1.0, constant: self.reportsBadgeSize)

        NSLayoutConstraint.activate([constraintTop, constraintRight, constraintWidth, constraintHeight])

        
        self.reportsDetails.translatesAutoresizingMaskIntoConstraints = false
        constraintTop = NSLayoutConstraint( item: self.reportsDetails, attribute: NSLayoutConstraint.Attribute.top,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self.reportsPanel, attribute: NSLayoutConstraint.Attribute.top,
                                                multiplier: 1.0, constant: 0.0)

        constraintLeft = NSLayoutConstraint( item: self.reportsDetails, attribute: NSLayoutConstraint.Attribute.leading,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.reportsImage, attribute: NSLayoutConstraint.Attribute.trailing,
                                             multiplier: 1.0, constant: 10.0)

        constraintRight = NSLayoutConstraint(item: self.reportsDetails, attribute: NSLayoutConstraint.Attribute.trailing,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self.reportsPanel, attribute: NSLayoutConstraint.Attribute.trailing,
                                                 multiplier: 1.0, constant: 0.0)

        constraintBottom = NSLayoutConstraint( item: self.reportsDetails, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: self.reportsPanel, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   multiplier: 1.0, constant: 0.0)

        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintRight, constraintBottom])

        
        self.thumbsUpButton.translatesAutoresizingMaskIntoConstraints = false
        constraintRight = NSLayoutConstraint( item: self.thumbsUpButton, attribute: NSLayoutConstraint.Attribute.trailing,
                                              relatedBy: NSLayoutConstraint.Relation.equal,
                                              toItem: self.reportsPanel, attribute: NSLayoutConstraint.Attribute.trailing,
                                              multiplier: 1.0, constant: -5.0)

        constraintCenterY = NSLayoutConstraint( item: self.thumbsUpButton, attribute: NSLayoutConstraint.Attribute.centerY,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self.reportsPanel, attribute: NSLayoutConstraint.Attribute.centerY,
                                                multiplier: 1.0, constant: 0.0)

        constraintWidth = NSLayoutConstraint(item: self.thumbsUpButton, attribute: NSLayoutConstraint.Attribute.width,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                 multiplier: 1.0, constant: self.reportsImageSize)

        constraintHeight = NSLayoutConstraint( item: self.thumbsUpButton, attribute: NSLayoutConstraint.Attribute.height,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                   multiplier: 1.0, constant: self.reportsImageSize)

        NSLayoutConstraint.activate([constraintRight, constraintCenterY, constraintWidth, constraintHeight])
        
        
        self.thumbsDownButton.translatesAutoresizingMaskIntoConstraints = false
        constraintRight = NSLayoutConstraint( item: self.thumbsDownButton, attribute: NSLayoutConstraint.Attribute.trailing,
                                              relatedBy: NSLayoutConstraint.Relation.equal,
                                              toItem: self.reportsPanel, attribute: NSLayoutConstraint.Attribute.trailing,
                                              multiplier: 1.0, constant: -(self.reportsImageSize + 15))

        constraintCenterY = NSLayoutConstraint( item: self.thumbsDownButton, attribute: NSLayoutConstraint.Attribute.centerY,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self.reportsPanel, attribute: NSLayoutConstraint.Attribute.centerY,
                                                multiplier: 1.0, constant: 0.0)

        constraintWidth = NSLayoutConstraint(item: self.thumbsDownButton, attribute: NSLayoutConstraint.Attribute.width,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                 multiplier: 1.0, constant: self.reportsImageSize)

        constraintHeight = NSLayoutConstraint( item: self.thumbsDownButton, attribute: NSLayoutConstraint.Attribute.height,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                   multiplier: 1.0, constant: self.reportsImageSize)

        NSLayoutConstraint.activate([constraintRight, constraintCenterY, constraintWidth, constraintHeight])
        
        
        self.reportsPanel.translatesAutoresizingMaskIntoConstraints = false
        constraintBottom = NSLayoutConstraint( item: self.reportsPanel, attribute: NSLayoutConstraint.Attribute.bottom,
                                            relatedBy: NSLayoutConstraint.Relation.equal,
                                            toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.bottom,
                                            multiplier: 1.0, constant: -2.5)

        constraintLeft = NSLayoutConstraint( item: self.reportsPanel, attribute: NSLayoutConstraint.Attribute.leading,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.leading,
                                             multiplier: 1.0, constant: 2.5)

        constraintRight = NSLayoutConstraint(item: self.reportsPanel, attribute: NSLayoutConstraint.Attribute.trailing,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.navigationPanel, attribute: NSLayoutConstraint.Attribute.trailing,
                                             multiplier: 1.0, constant: -2.5)

        constraintHeight = NSLayoutConstraint( item: self.reportsPanel, attribute: NSLayoutConstraint.Attribute.height,
                                               relatedBy: NSLayoutConstraint.Relation.equal,
                                               toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                               multiplier: 1.0, constant: self.reportsPanelHeight)

        NSLayoutConstraint.activate([constraintBottom, constraintLeft, constraintRight, constraintHeight])
        
        
        self.reportsPanelAnimated.translatesAutoresizingMaskIntoConstraints = false
        constraintTop = NSLayoutConstraint( item: self.reportsPanelAnimated, attribute: NSLayoutConstraint.Attribute.top,
                                            relatedBy: NSLayoutConstraint.Relation.equal,
                                            toItem: self.reportsPanel, attribute: NSLayoutConstraint.Attribute.top,
                                            multiplier: 1.0, constant: 0.0)

        constraintLeft = NSLayoutConstraint( item: self.reportsPanelAnimated, attribute: NSLayoutConstraint.Attribute.leading,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.reportsPanel, attribute: NSLayoutConstraint.Attribute.leading,
                                             multiplier: 1.0, constant: 0.0)

        constraintRight = NSLayoutConstraint(item: self.reportsPanelAnimated, attribute: NSLayoutConstraint.Attribute.trailing,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.reportsPanel, attribute: NSLayoutConstraint.Attribute.trailing,
                                             multiplier: 1.0, constant: -0.0)

        constraintBottom = NSLayoutConstraint( item: self.reportsPanelAnimated, attribute: NSLayoutConstraint.Attribute.bottom,
                                               relatedBy: NSLayoutConstraint.Relation.equal,
                                               toItem: self.reportsPanel, attribute: NSLayoutConstraint.Attribute.bottom,
                                               multiplier: 1.0, constant: 0.0)

        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintRight, constraintBottom])
        
        
        // Priority compression and hugging
        self.reportsDetails.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        self.reportsDetails.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.vertical)

        self.reportsDetails.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        self.reportsDetails.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.vertical)
        
        
        
        /*self.turnView.layer.borderWidth = 1.0
        self.turnView.layer.borderColor = UIColor.red.cgColor
        
        self.turnImage.layer.borderWidth = 1.0
        self.turnImage.layer.borderColor = UIColor.red.cgColor
        
        self.turnDistance.layer.borderWidth = 1.0
        self.turnDistance.layer.borderColor = UIColor.red.cgColor
        
        self.turnInstruction.layer.borderWidth = 2.0
        self.turnInstruction.layer.borderColor = UIColor.red.cgColor
         
        self.stopButton.layer.borderWidth = 2.0
        self.stopButton.layer.borderColor = UIColor.white.cgColor
        
        self.trafficPanel.layer.borderWidth = 1.0
        self.trafficPanel.layer.borderColor = UIColor.white.cgColor
        
        self.trafficTitle.layer.borderWidth = 1.0
        self.trafficTitle.layer.borderColor = UIColor.white.cgColor

        self.trafficDetails.layer.borderWidth = 1.0
        self.trafficDetails.layer.borderColor = UIColor.white.cgColor
        
        self.trafficImage.layer.borderWidth = 1.0
        self.trafficImage.layer.borderColor = UIColor.white.cgColor
        
        self.signPostImage.layer.borderWidth = 1.0
        self.signPostImage.layer.borderColor = UIColor.white.cgColor*/
    }
    
    func addExtraPanels() {
        
        navigationPanel.addSubview(self.customTurnNextImage)
        navigationPanel.addSubview(self.customTurnNextNextImage)
        
        self.customTurnNextImage.contentMode = .scaleAspectFit
        self.customTurnNextNextImage.contentMode = .scaleAspectFit
        
        self.customTurnNextImage.backgroundColor = UIColor.white
        self.customTurnNextNextImage.backgroundColor = UIColor.white
        
        self.customTurnNextImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.customTurnNextImage.leadingAnchor.constraint(equalTo: navigationPanel.leadingAnchor, constant: 10),
            self.customTurnNextImage.topAnchor.constraint(equalTo: navigationPanel.bottomAnchor, constant: 15),
            self.customTurnNextImage.widthAnchor.constraint(equalToConstant: self.turnImageSize),
            self.customTurnNextImage.heightAnchor.constraint(equalToConstant: self.turnImageSize)
        ])
        
        self.customTurnNextNextImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.customTurnNextNextImage.trailingAnchor.constraint(equalTo: navigationPanel.trailingAnchor, constant: -10),
            self.customTurnNextNextImage.topAnchor.constraint(equalTo: navigationPanel.bottomAnchor, constant: 15),
            self.customTurnNextNextImage.widthAnchor.constraint(equalToConstant: self.turnImageSize),
            self.customTurnNextNextImage.heightAnchor.constraint(equalToConstant: self.turnImageSize)
        ])
        
        self.customTurnNextImage.layer.cornerRadius = 8
        self.customTurnNextNextImage.layer.cornerRadius = 8
    }
    
    // MARK: - Layout
    
    func refreshContentLayout() {

        var requestUpdateLayout: Bool = false
        
        let array: [NSLayoutConstraint] = self.view.constraints + self.navigationPanel.constraints + self.lanePanel.constraints
        
        for constraint in array {
            
            if constraint.isActive && constraint.firstItem === self.view && constraint.firstAttribute == NSLayoutConstraint.Attribute.height {
                
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
                    
                    constant -= self.trafficPanelHeight + 2.5
                }

                if self.safetyPanel.isHidden == false {
                    
                    constant -= self.safetyPanelHeight + 2.5
                }
                
                if self.reportsPanel.isHidden == false {
                    
                    constant -= self.reportsPanelHeight + 2.5
                }
                
                if constraint.constant != constant {
                    
                    requestUpdateLayout = true
                    
                    constraint.constant = constant
                }
            }
            
            if constraint.isActive && constraint.firstItem === self.trafficPanel && constraint.firstAttribute == NSLayoutConstraint.Attribute.bottom {
                
                var constant: CGFloat = -2.5
                
                if self.safetyPanel.isHidden == false {
                    
                    constant -= self.safetyPanelHeight + 2.5
                }
                
                if self.reportsPanel.isHidden == false {
                    
                    constant -= self.reportsPanelHeight + 2.5
                }
                
                if constraint.constant != constant {
                    
                    requestUpdateLayout = true
                    
                    constraint.constant = constant
                }
            }
            
            if constraint.isActive && constraint.firstItem === self.safetyPanel && constraint.firstAttribute == NSLayoutConstraint.Attribute.bottom {
                
                var constant: CGFloat = -2.5
                
                if self.reportsPanel.isHidden == false {
                    
                    constant -= self.reportsPanelHeight + 2.5
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
        
        if self.safetyPanel.isHidden == false {
            
            height += self.safetyPanelHeight + 2.5
        }
        
        if self.reportsPanel.isHidden == false {
            
            height += self.reportsPanelHeight + 2.5
        }
        
        return height
    }
    
    // MARK: - Utils
    
    func updateTurnInformation(navigationContext: NavigationContext) {
        
        var distance = ""
        var distanceUnit = ""
        var instruction = ""
        var image: UIImage?
        
        if let turnInstruction = navigationContext.getNavigationInstruction() {
            
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
    
    func updateCustomTurnInformation(navigationContext: NavigationContext) {
        
        self.customTurnNextImage.isHidden = false
        self.customTurnNextNextImage.isHidden = false
        
        if let turnInstruction = navigationContext.getNavigationInstruction() {
            
            if let nextTurnDetails = turnInstruction.getNextTurnDetails() {
                
                let turnId64 = nextTurnDetails.getTurnId64()
                
                if let image = UIImage(named: String(format:"%d", turnId64.rawValue)) {
                    
                    self.customTurnNextImage.image = image
                    self.customTurnNextImage.isHidden = false
                }
            }
            
            if let nextNextTurnDetails = turnInstruction.getNextNextTurnDetails() {
                
                let turnId64 = nextNextTurnDetails.getTurnId64()
                
                if let image = UIImage(named: String(format:"%d", turnId64.rawValue)) {
                    
                    self.customTurnNextNextImage.image = image
                    self.customTurnNextNextImage.isHidden = false
                }
            }
        }
    }
    
    func updateLaneInformation(navigationContext: NavigationContext) {
        
        var image: UIImage?
        
        if let turnInstruction = navigationContext.getNavigationInstruction() {
            
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
        
        
        if let turnInstruction = navigationContext.getNavigationInstruction() {
            
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
        
        if let turnInstruction = navigationContext.getNavigationInstruction() {
            
            var imgHeight: CGFloat = 100.0
            
            let panelSize = self.signPostImage.frame.size
            
            if panelSize.height > 0 {
                
                imgHeight = panelSize.height
            }
            
            let scale = UIScreen.main.scale
            let factor: CGFloat = 2.5
            let height: CGFloat = imgHeight * scale
            
            let sizePixels = CGSize.init(width: factor * height, height: height)
            
            let border = Int(scale * 5)
            image = turnInstruction.getSignpostImage(sizePixels, border: border, roundCorners: true, rows: 3)
        }
        
        self.signPostImage.image = image
        self.signPostImage.isHidden = !(image != nil)
    }
    
    func updateRoadCodeInformation(navigationContext: NavigationContext) {
        
        if let turnInstruction = navigationContext.getNavigationInstruction() {
            
            var roadCodeSize: CGFloat = 80
            
            if let string = self.turnInstruction.attributedText, string.length > 0 {
                
                roadCodeSize = 40
            }
            
            let scale = UIScreen.main.scale
            let factor: CGFloat = 2.5
            let height: CGFloat = roadCodeSize * scale
            
            let sizePixels = CGSize.init(width: factor * height, height: height)
            
            var image: UIImage?
            
            if turnInstruction.hasNextRoadInfo() {
                
                image = turnInstruction.getNextRoadCodeImage(sizePixels)
                
            } else  if turnInstruction.hasCurrentRoadInfo() {
                
                image = turnInstruction.getCurrentRoadCodeImage(sizePixels)
            }
            
            if let img = image {
                
                // let font = UIFont.boldSystemFont(ofSize: self.turnDistFontSize)
                let bounds = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
                
                let attachment = NSTextAttachment()
                attachment.image = img
                attachment.bounds = bounds
                
                if let string = self.turnInstruction.attributedText, string.length > 0 {
                    
                    let attributedText = NSMutableAttributedString.init()
                    attributedText.append(NSAttributedString.init(attachment: attachment))
                    attributedText.append(NSAttributedString.init(string: "\n"))
                    attributedText.append(string)
                    
                    self.turnInstruction.attributedText = attributedText
                    
                } else {
                    
                    let attributedText = NSMutableAttributedString.init()
                    attributedText.append(NSAttributedString.init(attachment: attachment))
                    
                    self.turnInstruction.attributedText = attributedText
                }
            }
        }
    }
    
    func updateSafetyCameraInformation(navigationContext: NavigationContext, alarmContext: AlarmContext) {
        
        let alarms = alarmContext.getOverlayItemAlarms()
        
        for item in alarms {
            
            let identifier = CommonOverlayIdentifier.init(rawValue: item.getOverlayUid())
            
            if identifier == .safety {
                
                let scale = UIScreen.main.scale
                let height: CGFloat = 50 * scale
                
                if let image = item.getAspectRatioImage(height) {
                    
                    let font     = UIFont.boldSystemFont(ofSize: self.turnDistFontSize)
                    let fontUnit = UIFont.boldSystemFont(ofSize: self.turnDistUnitFontSize)
                    
                    let attrDist     = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: font]
                    let attrDistUnit = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: fontUnit]
                    
                    let value1 = alarmContext.getDistanceFormatted(with: item)
                    let value2 = alarmContext.getDistanceUnitFormatted(with: item)
                    
                    let distStringAttr     = NSAttributedString(string: value1, attributes: attrDist)
                    let distUnitStringAttr = NSAttributedString(string: value2, attributes: attrDistUnit)
                    
                    let attributedText = NSMutableAttributedString.init()
                    attributedText.append(distStringAttr)
                    attributedText.append(distUnitStringAttr)
                    
                    self.safetyImage.image = image
                    self.safetyDetails.attributedText = attributedText
                    self.safetyPanel.isHidden = false
                    
                    return
                }
            }
        }
        
        self.safetyImage.image = nil
        self.safetyDetails.attributedText = NSAttributedString(string: "")
        self.safetyPanel.isHidden = true
    }
    
    func updateSocialReportInformation(navigationContext: NavigationContext, alarmContext: AlarmContext) {
        
        let alarms = alarmContext.getOverlayItemAlarms()
        
        for item in alarms {
            
            let identifier = CommonOverlayIdentifier.init(rawValue: item.getOverlayUid())
            
            if identifier == .socialReports {
                
                let scale = UIScreen.main.scale
                let height: CGFloat = 50 * scale
                
                if let image = item.getAspectRatioImage(height) {
                    
                    let font     = UIFont.boldSystemFont(ofSize: self.turnDistFontSize)
                    let fontUnit = UIFont.boldSystemFont(ofSize: self.turnDistUnitFontSize)
                    
                    let attrDist     = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: font]
                    let attrDistUnit = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: fontUnit]
                    
                    let value1 = alarmContext.getDistanceFormatted(with: item)
                    let value2 = alarmContext.getDistanceUnitFormatted(with: item)
                    
                    let distStringAttr     = NSAttributedString(string: value1, attributes: attrDist)
                    let distUnitStringAttr = NSAttributedString(string: value2, attributes: attrDistUnit)
                    
                    let attributedText = NSMutableAttributedString.init()
                    attributedText.append(distStringAttr)
                    attributedText.append(distUnitStringAttr)
                    
                    self.reportsImage.image = image
                    self.reportsDetails.attributedText = attributedText
                    self.reportsPanel.isHidden = false
                    
                    return
                }
            }
        }
        
        self.reportsImage.image = nil
        self.reportsDetails.attributedText = NSAttributedString(string: "")
        self.reportsPanel.isHidden = true
    }
    
    // MARK: - Thumbs Up/Down

    @objc func thumbsUpButtonAction() {
        guard self.thumbsUpButton.isHidden == false else {
            return
        }
    }

    @objc func thumbsDownButtonAction() {
        guard self.thumbsDownButton.isHidden == false else {
            return
        }
    }
}

