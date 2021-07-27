// Copyright (C) 2019-2021, General Magic B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of General Magic
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with General Magic.

import UIKit
import GEMKit

class ViewController: UIViewController, MapViewControllerDelegate {
    
    var mapViewController: MapViewController?
    
    var favoriteContext: LandmarkStoreContext?
    var favoriteCategory: LandmarkCategoryObject?
    
    let mapInfoLabel = UILabel.init()
    let saveButton = UIButton.init(type: .system)
    let closeButton = UIButton.init(type: .system)
    
    var selectedLandmark: LandmarkObject?
    
    deinit {
        
        if let controller = mapViewController {
            
            controller.destroy()
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.createMapView()
        self.createStore()
        
        self.addMapInfo()
        self.addListButton()
        
        let location = GeoLocation.coordinates(withLatitude: 37.77903, longitude: -122.41991)
        self.mapViewController!.center(on: location, zoomLevel: 72, animationDuration: 1000)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.mapViewController!.startRender()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        self.mapViewController!.stopRender()
    }
    
    // MARK: - Map View
    
    func createMapView() {
        
        self.mapViewController = MapViewController.init()
        self.mapViewController!.view.backgroundColor = UIColor.systemBackground
        self.mapViewController!.delegate = self
        
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
    
    // MARK: - Store
    
    func createStore() {
        
        let name = "My Category"
        
        self.favoriteContext = LandmarkStoreContext.init(name: "Favorites")
        self.favoriteContext!.addCategory( LandmarkCategoryObject.init(name: name) )
        
        self.favoriteCategory = self.getCategory(withName: name, context: self.favoriteContext)
    }
    
    func getCategory(withName: String, context: LandmarkStoreContext?) -> LandmarkCategoryObject? {
        
        guard let currentContext = context else {
            
            return nil
        }
        
        let array = currentContext.getCategories()
        
        for category in array {
            
            let categoryName = category.getName()
            
            if categoryName == withName {
                
                return category
            }
        }
        
        return nil
    }
    
    func isLandmark(landmark: LandmarkObject, availableIn context: LandmarkStoreContext) -> LandmarkObject? {
        
        var lmk: LandmarkObject?
        
        let radius: Double = 5 // meters
        
        let area = RectangleGeographicAreaObject.init(location: landmark.getLandmarkGeoLocation(), horizontalRadius: radius, verticalRadius: radius)
        
        let list = context.getLandmarksWithRectangleGeographicArea(area)
        
        if list.count > 0 {
            
            lmk = list.first
        }
        
        return lmk
    }
    
    // MARK: - Map Info
    
    func addMapInfo() {

        let size: CGFloat = 50
        
        if let image = UIImage.init(systemName: "xmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize:30)) {
            
            self.closeButton.setImage(image, for: .normal)
            self.closeButton.backgroundColor = UIColor.systemBackground
            self.closeButton.layer.cornerRadius = size/2
        }
        
        self.closeButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        
        if let image = UIImage.init(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize:26)) {
        
            let img = image.withRenderingMode(.alwaysTemplate).withTintColor(UIColor.red)
            
            self.saveButton.setImage(img, for: .normal)
            self.saveButton.tintColor = UIColor.red
        }
        
        self.saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        self.saveButton.setTitleColor(UIColor.white, for: .normal)
        self.saveButton.layer.masksToBounds = true
        self.saveButton.layer.cornerRadius = 8.0
        self.saveButton.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        // self.saveButton.layer.borderWidth = 1
        // self.saveButton.layer.borderColor = UIColor.darkGray.cgColor
        
        self.mapInfoLabel.numberOfLines = 0
        self.mapInfoLabel.backgroundColor = UIColor.systemBackground
        self.mapInfoLabel.layer.masksToBounds = true
        self.mapInfoLabel.layer.cornerRadius = 8.0
        
        let borderView = UIView.init()
        borderView.layer.shadowColor = UIColor.lightGray.cgColor
        borderView.layer.shadowOpacity = 0.8
        
        borderView.addSubview(self.mapInfoLabel)
        borderView.addSubview(self.saveButton)
        borderView.addSubview(self.closeButton)
        
        self.view.addSubview(borderView)
        
        self.mapInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.mapInfoLabel.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: 0.0),
            self.mapInfoLabel.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: -0.0),
            self.mapInfoLabel.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: 0),
            self.mapInfoLabel.topAnchor.constraint(equalTo: borderView.topAnchor, constant: 0),
        ])
        
        self.saveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.saveButton.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: -2.5),
            self.saveButton.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: -2.5),
            self.saveButton.widthAnchor.constraint(equalToConstant: size),
            self.saveButton.heightAnchor.constraint(equalToConstant: size)
        ])
        
        self.closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.closeButton.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: 10.0),
            self.closeButton.topAnchor.constraint(equalTo: borderView.topAnchor, constant: -size/2),
            self.closeButton.widthAnchor.constraint(equalToConstant: size),
            self.closeButton.heightAnchor.constraint(equalToConstant: size)
        ])
        
        borderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            borderView.heightAnchor.constraint(equalToConstant: 100),
            borderView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            borderView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            borderView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
        ])
        
        self.mapInfoLabel.superview!.isHidden = true
    }
    
    @objc func saveButtonAction(button: UIButton) {
        
        guard let landmark = self.selectedLandmark else {
            return
        }
        
        var iconName = "heart"
        
        let lmk = self.isLandmark(landmark: landmark, availableIn: self.favoriteContext!)
        
        if lmk != nil {
            
            let success = self.favoriteContext!.removeLandmark(lmk!)
            
            iconName = success ? "heart" : "heart.fill"
            
            NSLog("saveButtonAction, removeLandmark success:%@", success ? "Yes":"No")
            
        } else {
            
            let categoryId = self.favoriteCategory!.getIdentifier()
            
            let success = self.favoriteContext!.addLandmark(landmark, toCategoryId: categoryId)
            
            if success {
                
                iconName = "heart.fill"
                
                self.mapViewController!.showLandmarks(fromCategory: self.favoriteCategory!, context: self.favoriteContext!)
            }
            
            NSLog("saveButtonAction, addLandmark success:%@", success ? "Yes":"No")
        }
        
        if let image = UIImage.init(systemName: iconName, withConfiguration: UIImage.SymbolConfiguration(pointSize:26)) {
            
            let img = image.withRenderingMode(.alwaysTemplate).withTintColor(UIColor.red)
            
            button.setImage(img, for: .normal)
        }
        
        self.printDebugInfo()
    }
    
    @objc func closeButtonAction() {
        
        self.selectedLandmark = nil
        
        self.mapInfoLabel.superview!.isHidden = true
        
        self.mapViewController!.removeHighlights()
    }
    
    // MARK: - Favorites List
    
    func addListButton() {
        
        let barButton = UIBarButtonItem.init(image: UIImage.init(systemName: "list.star"), style: .done, target: self, action: #selector(showList))
        
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func showList() {
        
        let viewController = FavoritesViewController.init(context: self.favoriteContext!, category: self.favoriteCategory!)
        
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    // MARK: - MapViewControllerDelegate
    
    func mapViewController(_ mapViewController: MapViewController, didSelectLandmark landmark: LandmarkObject, onTouch point: CGPoint) {
        
        self.presentLandmarkOnMap(landmark: landmark, centerLayout: false)
    }
    
    func mapViewController(_ mapViewController: MapViewController, didSelectLandmark landmark: LandmarkObject, onLongTouch point: CGPoint) {
        
        self.presentLandmarkOnMap(landmark: landmark, centerLayout: false)
    }
    
    func mapViewController(_ mapViewController: MapViewController, didSelectRoute route: RouteObject) {
                
    }
    
    func mapViewController(_ mapViewController: MapViewController, didSelectStreets streets: [LandmarkObject]) {
        
    }
    
    func mapViewController(_ mapViewController: MapViewController, onTouch point: CGPoint) {
        
    }
    
    func mapViewController(_ mapViewController: MapViewController, onMove startPoint: CGPoint, to endPoint: CGPoint) {
        
    }
    
    func presentLandmarkOnMap(landmark: LandmarkObject, centerLayout: Bool) {
        
        self.selectedLandmark = landmark
        
        let scale = UIScreen.main.scale
        
        let text     = " " + landmark.getLandmarkName() + " " + landmark.getLandmarkDescription()
        let location = " " + String(format:"%.6f", landmark.getLandmarkGeoLocation().latitude) + ", " +
                             String(format:"%.6f", landmark.getLandmarkGeoLocation().longitude)
        
        let font1 = UIFont.boldSystemFont(ofSize: 14)
        let font2 = UIFont.systemFont(ofSize: 12)
        
        let attr1 = [NSAttributedString.Key.foregroundColor: UIColor.label, NSAttributedString.Key.font: font1]
        let attr2 = [NSAttributedString.Key.foregroundColor: UIColor.label, NSAttributedString.Key.font: font2]
        
        let stringAttr1 = NSAttributedString(string: text, attributes: attr1)
        let stringAttr2 = NSAttributedString(string: location, attributes: attr2)
        
        let attributedText = NSMutableAttributedString.init()
        
        if let image = landmark.getLandmarkImage(CGSize.init(width: 30*scale, height: 30*scale)) {
            
            let attachment = NSTextAttachment()
            attachment.image = image
            attachment.bounds = CGRect(x: 0, y: (font1.capHeight - image.size.height).rounded() / 2, width: image.size.width, height: image.size.height)
            
            attributedText.append(NSAttributedString.init(attachment: attachment))
        }
        
        attributedText.append(stringAttr1)
        attributedText.append(NSAttributedString(string:"\n"))
        attributedText.append(NSAttributedString(string:"\n"))
        attributedText.append(stringAttr2)
        
        self.mapInfoLabel.attributedText = attributedText
        self.mapInfoLabel.superview!.isHidden = false
        
        if let context = self.favoriteContext {
            
            let lmk = self.isLandmark(landmark: landmark, availableIn: context)
            
            let iconName =  (lmk != nil) ? "heart.fill": "heart"
            
            if let image = UIImage.init(systemName: iconName, withConfiguration: UIImage.SymbolConfiguration(pointSize:26)) {
                
                let img = image.withRenderingMode(.alwaysTemplate).withTintColor(UIColor.red)
                
                self.saveButton.setImage(img, for: .normal)
            }
        }
        
        self.mapViewController!.removeHighlights()
        
        self.mapViewController!.presentHighlight(landmark, contourColor: UIColor.systemRed, centerLayout: centerLayout, animationDuration: 600)
    }
    
    // MARK: - Debug
    
    func printDebugInfo() {
        
        var landmarks = self.favoriteContext!.getLandmarks()
        
        NSLog("Total landmarks count:%d", landmarks.count)
        
        for landmark in landmarks {
            
            NSLog("landmark name:%@", landmark.getLandmarkName())
        }
        
        let identifier = self.favoriteCategory!.getIdentifier()
        
        landmarks = self.favoriteContext!.getLandmarks(identifier)
        
        NSLog("Total landmarks from category:%@, count:%d", self.favoriteCategory!.getName(), landmarks.count)
        
        for landmark in landmarks {
            
            NSLog("landmark name:%@", landmark.getLandmarkName())
        }
    }
}
