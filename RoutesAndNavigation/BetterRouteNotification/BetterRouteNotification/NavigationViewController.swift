// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import UIKit
import GEMKit

class NavigationViewController: UIViewController {

    let navigationPanel = UIView.init()
    let turnView = UIView.init()
    let turnImage = UIImageView.init()
    let turnDistance = UILabel.init()
    let turnInstruction = UILabel.init()
    let stopButton = UIButton.init(type: .system)
    let navigationPanelHeight: CGFloat = 110.0

    let turnDistFontSize: CGFloat = 24
    let turnDistUnitFontSize: CGFloat = 14

    let turnImageSize: CGFloat = 80
    let turnDistHeight: CGFloat = 30
    let roadCodeSize: CGFloat = 40

    let lanePanel = UIView.init()
    let laneImage = UIImageView.init()
    let lanePanelHeight: CGFloat = 60.0

    let trafficPanel = UIView.init()
    let trafficImage = UIImageView.init()
    let trafficTitle = UILabel.init()
    let trafficDetails = UILabel.init()
    let trafficPanelHeight: CGFloat = 60.0
    let trafficImageSize: CGFloat = 50.0

    let signPostImage = UIImageView.init()

    let safetyPanel = UIView.init()
    let safetyImage = UIImageView.init()
    let safetyDetails = UILabel.init()
    let safetyPanelHeight: CGFloat = 60.0
    let safetyImageSize: CGFloat = 50.0

    let reportsPanel = UIView.init()
    let reportsPanelAnimated = UIView.init()
    let reportsImage = UIImageView.init()
    let reportsBadge = UILabel.init()
    let reportsDetails = UILabel.init()
    let thumbsUpButton = UIButton.init(type: .custom)
    let thumbsDownButton = UIButton.init(type: .custom)
    let reportsPanelHeight: CGFloat = 60.0
    let reportsImageSize: CGFloat = 50.0
    let reportsBadgeSize: CGFloat = 26.0

    override func viewDidLoad() {

        super.viewDidLoad()

        self.addNavigationPanel()
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
        self.signPostImage.backgroundColor = self.navigationPanel.backgroundColor
        self.turnInstruction.addSubview(self.signPostImage)

        self.reportsImage.contentMode = .center

        self.reportsBadge.adjustsFontSizeToFitWidth = true
        self.reportsBadge.numberOfLines = 1
        self.reportsBadge.textAlignment = .center
        self.reportsBadge.backgroundColor = UIColor.white
        self.reportsBadge.layer.masksToBounds = true
        self.reportsBadge.layer.cornerRadius = self.reportsBadgeSize / 2
        self.reportsBadge.layer.borderWidth = 1.8
        self.reportsBadge.layer.borderColor = UIColor.black.cgColor
        self.reportsBadge.isHidden = true

        self.reportsImage.addSubview(self.reportsBadge)

        self.reportsDetails.numberOfLines = 2
        self.reportsDetails.textAlignment = .natural

        self.reportsPanel.backgroundColor = UIColor.white
        self.reportsPanelAnimated.backgroundColor = UIColor.white
        self.reportsPanelAnimated.layer.cornerRadius = 8
        self.reportsPanelAnimated.isHidden = true

        self.reportsPanel.layer.masksToBounds = true
        self.reportsPanel.layer.cornerRadius = 8
        self.reportsPanel.isHidden = true

        self.thumbsUpButton.layer.masksToBounds = true
        self.thumbsDownButton.layer.masksToBounds = true
        self.thumbsUpButton.layer.cornerRadius = 8
        self.thumbsDownButton.layer.cornerRadius = 8

        self.thumbsUpButton.addTarget(self, action: #selector(thumbsUpButtonAction), for: .touchUpInside)
        self.thumbsDownButton.addTarget(self, action: #selector(thumbsDownButtonAction), for: .touchUpInside)

        self.reportsPanel.addSubview(self.reportsPanelAnimated)
        self.reportsPanel.addSubview(self.reportsImage)
        self.reportsPanel.addSubview(self.reportsDetails)
        self.reportsPanel.addSubview(self.thumbsUpButton)
        self.reportsPanel.addSubview(self.thumbsDownButton)

        self.navigationPanel.backgroundColor = UIColor.init(red: 20 / 255, green: 20 / 255, blue: 20 / 255, alpha: 1.0)
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
        NSLayoutConstraint.activate([
            self.navigationPanel.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.navigationPanel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationPanel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationPanel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        self.stopButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.stopButton.topAnchor.constraint(equalTo: self.navigationPanel.topAnchor, constant: -8),
            self.stopButton.trailingAnchor.constraint(equalTo: self.navigationPanel.trailingAnchor, constant: 8),
            self.stopButton.widthAnchor.constraint(equalToConstant: buttonSize),
            self.stopButton.heightAnchor.constraint(equalToConstant: buttonSize)
        ])

        self.turnImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.turnImage.topAnchor.constraint(equalTo: self.turnView.topAnchor),
            self.turnImage.leadingAnchor.constraint(equalTo: self.turnView.leadingAnchor),
            self.turnImage.widthAnchor.constraint(equalToConstant: self.turnImageSize),
            self.turnImage.heightAnchor.constraint(equalToConstant: self.turnImageSize)
        ])

        self.turnDistance.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.turnDistance.topAnchor.constraint(equalTo: self.turnImage.bottomAnchor, constant: -2.5),
            self.turnDistance.leadingAnchor.constraint(equalTo: self.turnImage.leadingAnchor),
            self.turnDistance.trailingAnchor.constraint(equalTo: self.turnImage.trailingAnchor),
            self.turnDistance.heightAnchor.constraint(equalToConstant: self.turnDistHeight)
        ])

        self.turnView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.turnView.topAnchor.constraint(equalTo: self.navigationPanel.topAnchor),
            self.turnView.leadingAnchor.constraint(equalTo: self.navigationPanel.leadingAnchor),
            self.turnView.widthAnchor.constraint(equalToConstant: self.turnImageSize),
            self.turnView.heightAnchor.constraint(equalToConstant: self.turnImageSize + self.turnDistHeight)
        ])

        self.turnInstruction.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.turnInstruction.topAnchor.constraint(equalTo: self.navigationPanel.topAnchor),
            self.turnInstruction.leadingAnchor.constraint(equalTo: self.navigationPanel.leadingAnchor, constant: self.turnImageSize),
            self.turnInstruction.trailingAnchor.constraint(equalTo: self.navigationPanel.trailingAnchor),
            self.turnInstruction.bottomAnchor.constraint(equalTo: self.turnView.bottomAnchor)
        ])

        self.turnInstruction.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        self.turnInstruction.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.vertical)
        self.turnInstruction.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        self.turnInstruction.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.vertical)

        self.laneImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.laneImage.topAnchor.constraint(equalTo: self.lanePanel.topAnchor, constant: 5),
            self.laneImage.leadingAnchor.constraint(equalTo: self.lanePanel.leadingAnchor),
            self.laneImage.trailingAnchor.constraint(equalTo: self.lanePanel.trailingAnchor),
            self.laneImage.bottomAnchor.constraint(equalTo: self.lanePanel.bottomAnchor, constant: -5)
        ])

        self.lanePanel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.lanePanel.bottomAnchor.constraint(equalTo: self.navigationPanel.bottomAnchor, constant: -2.5),
            self.lanePanel.leadingAnchor.constraint(equalTo: self.navigationPanel.leadingAnchor, constant: 2.5),
            self.lanePanel.trailingAnchor.constraint(equalTo: self.navigationPanel.trailingAnchor, constant: -2.5),
            self.lanePanel.heightAnchor.constraint(equalToConstant: self.lanePanelHeight)
        ])

        self.trafficImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.trafficImage.leadingAnchor.constraint(equalTo: self.trafficPanel.leadingAnchor, constant: 5),
            self.trafficImage.centerYAnchor.constraint(equalTo: self.trafficPanel.centerYAnchor),
            self.trafficImage.widthAnchor.constraint(equalToConstant: self.trafficImageSize),
            self.trafficImage.heightAnchor.constraint(equalToConstant: self.trafficImageSize)
        ])

        self.trafficTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.trafficTitle.topAnchor.constraint(equalTo: self.trafficPanel.topAnchor),
            self.trafficTitle.leadingAnchor.constraint(equalTo: self.trafficImage.trailingAnchor, constant: 5),
            self.trafficTitle.trailingAnchor.constraint(equalTo: self.trafficPanel.trailingAnchor)
        ])

        self.trafficDetails.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.trafficDetails.topAnchor.constraint(equalTo: self.trafficTitle.bottomAnchor),
            self.trafficDetails.leadingAnchor.constraint(equalTo: self.trafficImage.trailingAnchor, constant: 5),
            self.trafficDetails.trailingAnchor.constraint(equalTo: self.trafficPanel.trailingAnchor),
            self.trafficDetails.bottomAnchor.constraint(equalTo: self.trafficPanel.bottomAnchor)
        ])

        self.trafficPanel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.trafficPanel.bottomAnchor.constraint(equalTo: self.navigationPanel.bottomAnchor, constant: -2.5),
            self.trafficPanel.leadingAnchor.constraint(equalTo: self.navigationPanel.leadingAnchor, constant: 2.5),
            self.trafficPanel.trailingAnchor.constraint(equalTo: self.navigationPanel.trailingAnchor, constant: -2.5),
            self.trafficPanel.heightAnchor.constraint(equalToConstant: self.trafficPanelHeight)
        ])

        self.trafficTitle.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        self.trafficTitle.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.vertical)
        self.trafficDetails.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        self.trafficDetails.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.vertical)

        self.trafficTitle.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        self.trafficTitle.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.vertical)
        self.trafficDetails.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        self.trafficDetails.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.vertical)

        self.signPostImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.signPostImage.topAnchor.constraint(equalTo: self.turnInstruction.topAnchor, constant: 2.5),
            self.signPostImage.leadingAnchor.constraint(equalTo: self.turnInstruction.leadingAnchor),
            self.signPostImage.trailingAnchor.constraint(equalTo: self.turnInstruction.trailingAnchor, constant: -2.5),
            self.signPostImage.bottomAnchor.constraint(equalTo: self.turnInstruction.bottomAnchor, constant: -2.5)
        ])

        self.safetyImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.safetyImage.leadingAnchor.constraint(equalTo: self.safetyPanel.leadingAnchor, constant: 5),
            self.safetyImage.centerYAnchor.constraint(equalTo: self.safetyPanel.centerYAnchor),
            self.safetyImage.widthAnchor.constraint(equalToConstant: self.safetyImageSize),
            self.safetyImage.heightAnchor.constraint(equalToConstant: self.safetyImageSize)
        ])

        self.safetyDetails.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.safetyDetails.topAnchor.constraint(equalTo: self.safetyPanel.topAnchor),
            self.safetyDetails.leadingAnchor.constraint(equalTo: self.safetyImage.trailingAnchor, constant: 5),
            self.safetyDetails.trailingAnchor.constraint(equalTo: self.safetyPanel.trailingAnchor),
            self.safetyDetails.bottomAnchor.constraint(equalTo: self.safetyPanel.bottomAnchor)
        ])

        self.safetyPanel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.safetyPanel.bottomAnchor.constraint(equalTo: self.navigationPanel.bottomAnchor, constant: -2.5),
            self.safetyPanel.leadingAnchor.constraint(equalTo: self.navigationPanel.leadingAnchor, constant: 2.5),
            self.safetyPanel.trailingAnchor.constraint(equalTo: self.navigationPanel.trailingAnchor, constant: -2.5),
            self.safetyPanel.heightAnchor.constraint(equalToConstant: self.safetyPanelHeight)
        ])

        self.safetyDetails.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        self.safetyDetails.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.vertical)

        self.safetyDetails.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        self.safetyDetails.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.vertical)

        self.reportsImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.reportsImage.leadingAnchor.constraint(equalTo: self.reportsPanel.leadingAnchor, constant: 5),
            self.reportsImage.centerYAnchor.constraint(equalTo: self.reportsPanel.centerYAnchor),
            self.reportsImage.widthAnchor.constraint(equalToConstant: self.reportsImageSize),
            self.reportsImage.heightAnchor.constraint(equalToConstant: self.reportsImageSize)
        ])

        self.reportsBadge.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.reportsBadge.topAnchor.constraint(equalTo: self.reportsImage.topAnchor, constant: -4),
            self.reportsBadge.trailingAnchor.constraint(equalTo: self.reportsImage.trailingAnchor, constant: 8),
            self.reportsBadge.widthAnchor.constraint(equalToConstant: self.reportsBadgeSize),
            self.reportsBadge.heightAnchor.constraint(equalToConstant: self.reportsBadgeSize)
        ])

        self.reportsDetails.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.reportsDetails.topAnchor.constraint(equalTo: self.reportsPanel.topAnchor),
            self.reportsDetails.leadingAnchor.constraint(equalTo: self.reportsImage.trailingAnchor, constant: 10),
            self.reportsDetails.trailingAnchor.constraint(equalTo: self.reportsPanel.trailingAnchor),
            self.reportsDetails.bottomAnchor.constraint(equalTo: self.reportsPanel.bottomAnchor)
        ])

        self.thumbsUpButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.thumbsUpButton.trailingAnchor.constraint(equalTo: self.reportsPanel.trailingAnchor, constant: -5),
            self.thumbsUpButton.centerYAnchor.constraint(equalTo: self.reportsPanel.centerYAnchor),
            self.thumbsUpButton.widthAnchor.constraint(equalToConstant: self.reportsImageSize),
            self.thumbsUpButton.heightAnchor.constraint(equalToConstant: self.reportsImageSize)
        ])

        self.thumbsDownButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.thumbsDownButton.trailingAnchor.constraint(equalTo: self.reportsPanel.trailingAnchor, constant: -(self.reportsImageSize + 15)),
            self.thumbsDownButton.centerYAnchor.constraint(equalTo: self.reportsPanel.centerYAnchor),
            self.thumbsDownButton.widthAnchor.constraint(equalToConstant: self.reportsImageSize),
            self.thumbsDownButton.heightAnchor.constraint(equalToConstant: self.reportsImageSize)
        ])

        self.reportsPanel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.reportsPanel.bottomAnchor.constraint(equalTo: self.navigationPanel.bottomAnchor, constant: -2.5),
            self.reportsPanel.leadingAnchor.constraint(equalTo: self.navigationPanel.leadingAnchor, constant: 2.5),
            self.reportsPanel.trailingAnchor.constraint(equalTo: self.navigationPanel.trailingAnchor, constant: -2.5),
            self.reportsPanel.heightAnchor.constraint(equalToConstant: self.reportsPanelHeight)
        ])

        self.reportsPanelAnimated.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.reportsPanelAnimated.topAnchor.constraint(equalTo: self.reportsPanel.topAnchor),
            self.reportsPanelAnimated.leadingAnchor.constraint(equalTo: self.reportsPanel.leadingAnchor),
            self.reportsPanelAnimated.trailingAnchor.constraint(equalTo: self.reportsPanel.trailingAnchor),
            self.reportsPanelAnimated.bottomAnchor.constraint(equalTo: self.reportsPanel.bottomAnchor)
        ])

        // Priority compression and hugging
        self.reportsDetails.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        self.reportsDetails.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.vertical)

        self.reportsDetails.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        self.reportsDetails.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.vertical)
    }

    // MARK: - Layout

    func refreshContentLayout() {

        var requestUpdateLayout: Bool = false

        let array: [NSLayoutConstraint] = self.view.constraints + self.navigationPanel.constraints + self.lanePanel.constraints

        for constraint in array {

            if constraint.isActive && constraint.firstItem === self.view && constraint.firstAttribute == NSLayoutConstraint.Attribute.height
            {

                // Default
                let constant: CGFloat = self.viewHeight()

                if constraint.constant != constant {

                    // MARK:
                    requestUpdateLayout = true

                    // Adjust
                    constraint.constant = constant
                }
            }

            if constraint.isActive && constraint.firstItem === self.lanePanel
                && constraint.firstAttribute == NSLayoutConstraint.Attribute.bottom
            {

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

            if constraint.isActive && constraint.firstItem === self.trafficPanel
                && constraint.firstAttribute == NSLayoutConstraint.Attribute.bottom
            {

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

            if constraint.isActive && constraint.firstItem === self.safetyPanel
                && constraint.firstAttribute == NSLayoutConstraint.Attribute.bottom
            {

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

        var height: CGFloat = self.navigationPanelHeight

        if self.lanePanel.isHidden == false {

            height += self.lanePanelHeight + 2.5
        }

        if self.trafficPanel.isHidden == false {

            height += self.trafficPanelHeight + 2.5
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
            image = turnInstruction.getNextTurnImage(
                size,
                colorActiveInner: UIColor.white,
                colorActiveOuter: UIColor.black,
                colorInactiveInner: UIColor.lightGray,
                colorInactiveOuter: UIColor.lightGray)

            distance = turnInstruction.getDistanceToNextTurnFormatted()
            distanceUnit = turnInstruction.getDistanceToNextTurnUnitFormatted()
            instruction = turnInstruction.getNextTurnInstructionFormatted()
        }

        self.turnImage.image = image

        let fontDist = UIFont.boldSystemFont(ofSize: self.turnDistFontSize)
        let fontDistUnit = UIFont.boldSystemFont(ofSize: self.turnDistUnitFontSize)

        let attrDist = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: fontDist]
        let attrDistUnit = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: fontDistUnit]

        let distStringAttr = NSAttributedString(string: distance, attributes: attrDist)
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

        if let turnInstruction = navigationContext.getNavigationInstruction() {

            let scale = UIScreen.main.scale
            let laneSize = CGSize.init(width: self.lanePanel.frame.size.width * scale, height: self.lanePanel.frame.size.height * scale)

            image = turnInstruction.getLaneImage(
                laneSize, backgroundColor: UIColor.black, activeColor: UIColor.white, inactiveColor: UIColor.lightGray)
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
        let backgroundColor = UIColor.init(red: 255.0 / 255.0, green: 175 / 255.0, blue: 63.0 / 255.0, alpha: 1.0)

        let font = UIFont.boldSystemFont(ofSize: self.turnDistFontSize)
        let fontUnit = UIFont.boldSystemFont(ofSize: self.turnDistUnitFontSize)

        let attrValue = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: font]
        let attrUnit = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: fontUnit]

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

        if !distance.isEmpty {

            let distanceAttr = NSAttributedString(string: distance, attributes: attrValue)
            let distanceUnitAttr = NSAttributedString(string: distanceUnit, attributes: attrUnit)
            attributedText.append(distanceAttr)
            attributedText.append(distanceUnitAttr)
        }

        if !delay.isEmpty {

            if attributedText.length > 0 {

                attributedText.append(stringDoubleSpace)
            }

            let delayAttr = NSAttributedString(string: delay, attributes: attrValue)
            let delayUnitAttr = NSAttributedString(string: delayUnit, attributes: attrUnit)
            attributedText.append(delayAttr)
            attributedText.append(delayUnitAttr)
        }

        if !delayDistance.isEmpty {

            if attributedText.length > 0 {

                attributedText.append(stringDoubleSpace)
            }

            let delayDistanceAttr = NSAttributedString(string: delayDistance, attributes: attrValue)
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

            } else if turnInstruction.hasCurrentRoadInfo() {

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

                    let font = UIFont.boldSystemFont(ofSize: self.turnDistFontSize)
                    let fontUnit = UIFont.boldSystemFont(ofSize: self.turnDistUnitFontSize)

                    let attrDist = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: font]
                    let attrDistUnit = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: fontUnit]

                    let value1 = alarmContext.getDistanceFormatted(with: item)
                    let value2 = alarmContext.getDistanceUnitFormatted(with: item)

                    let distStringAttr = NSAttributedString(string: value1, attributes: attrDist)
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

                    let font = UIFont.boldSystemFont(ofSize: self.turnDistFontSize)
                    let fontUnit = UIFont.boldSystemFont(ofSize: self.turnDistUnitFontSize)

                    let attrDist = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: font]
                    let attrDistUnit = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: fontUnit]

                    let value1 = alarmContext.getDistanceFormatted(with: item)
                    let value2 = alarmContext.getDistanceUnitFormatted(with: item)

                    let distStringAttr = NSAttributedString(string: value1, attributes: attrDist)
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
