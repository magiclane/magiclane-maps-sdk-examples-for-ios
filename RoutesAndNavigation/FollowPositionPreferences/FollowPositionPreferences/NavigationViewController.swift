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

    let signPostImage = UIImageView.init()

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

        self.signPostImage.contentMode = .scaleAspectFit
        self.signPostImage.isHidden = true
        self.signPostImage.layer.masksToBounds = true
        self.signPostImage.backgroundColor = UIColor.black
        self.turnInstruction.addSubview(self.signPostImage)

        self.navigationPanel.backgroundColor = UIColor.init(red: 20 / 255, green: 20 / 255, blue: 20 / 255, alpha: 1.0)
        self.navigationPanel.layer.cornerRadius = 8.0
        self.navigationPanel.layer.shadowColor = UIColor.gray.cgColor
        self.navigationPanel.layer.shadowOpacity = 0.8

        self.navigationPanel.addSubview(self.turnView)
        self.navigationPanel.addSubview(self.lanePanel)
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
        self.signPostImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.signPostImage.topAnchor.constraint(equalTo: self.turnInstruction.topAnchor, constant: 2.5),
            self.signPostImage.leadingAnchor.constraint(equalTo: self.turnInstruction.leadingAnchor),
            self.signPostImage.trailingAnchor.constraint(equalTo: self.turnInstruction.trailingAnchor, constant: -2.5),
            self.signPostImage.bottomAnchor.constraint(equalTo: self.turnInstruction.bottomAnchor, constant: -2.5)
        ])
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
}
