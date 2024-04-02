// Copyright (C) 2019-2024, Magic Lane B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of Magic Lane
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with Magic Lane.

import UIKit
import GEMKit

class ViewController: UIViewController, UISearchBarDelegate, MapViewControllerDelegate {
    
    var mapViewController: MapViewController?
    var navigationContext: NavigationContext?
    
    let buttonConfiguration = UIImage.SymbolConfiguration(pointSize: 26, weight: .semibold)
    
    var path: PathObject?
    
    var drawButton: UIButton?
    var visualEffectView: UIView?
    var statusLabel: UILabel?
    var showHideButton: UIButton?
    var routeType: RouteTransportMode = .bicycle
    
    var marketCollections: [MarkerCollectionObject] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.mapViewController = self.createMapViewController()
        
        self.setCustomStyle()
        
        self.refreshTitleViewButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        guard let mapViewController = self.mapViewController else { return }
        
        mapViewController.startRender()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        guard let mapViewController = self.mapViewController else { return }
        
        if mapViewController.view.alpha == 0 {
            
            let coordinates = CoordinatesObject.coordinates(withLatitude: 45.462514, longitude: 9.188443) // Milano
            
            mapViewController.center(onCoordinates: coordinates, zoomLevel: 70, animationDuration: 0)
            
            UIView.animate(withDuration: 0.25) {
                
                mapViewController.view.alpha = 1
                
            } completion: { finished in
                
                self.addDrawButton()
                self.addStatusButton()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        guard let mapViewController = self.mapViewController else { return }
        
        mapViewController.stopRender()
    }
    
    // MARK: - Map View
    
    func createMapViewController() -> MapViewController {
        
        let viewController = MapViewController.init()
        viewController.view.alpha = 0
        viewController.view.backgroundColor = UIColor.systemBackground
        viewController.delegate = self
        
        self.addChild(viewController)
        self.view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
            viewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            viewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -0),
            viewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -0),
        ])
        
        return viewController
    }
    
    // MARK: - Drawing
    
    func addDrawButton() {
        
        guard let mapViewController = self.mapViewController else { return }
        
        let image = UIImage.init(systemName: "hand.draw", withConfiguration: self.buttonConfiguration)
        
        let button = UIButton.init(type: .system)
        button.configuration = .bordered()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.image = image
        button.configuration?.baseBackgroundColor = UIColor.systemBackground
        button.layer.shadowOpacity = 0.6
        button.layer.shadowColor = UIColor.systemGray.cgColor
        
        let action = UIAction { _ in
            
            mapViewController.removeAllRoutes()
            mapViewController.removeAllMarkers()
            
            let state = mapViewController.getTouchViewBehaviour()
            
            if state == .default && self.path == nil {
                
                button.isHidden = true
                
                mapViewController.hideCompass()
                
                mapViewController.view.layer.borderWidth = 16
                mapViewController.view.layer.borderColor = UIColor.gray.withAlphaComponent(0.26).cgColor
                
                mapViewController.setTouchViewBehaviour(.fingerDraw) { coordinates in
                    
                    self.marketCollections = mapViewController.getAvailableMarkers()
                    
                    self.refreshPencilImage()
                    
                    let attributes = AttributeContainer([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 22, weight: .semibold)])
                    button.configuration?.attributedTitle = AttributedString("Clear", attributes: attributes)
                    button.configuration?.image = nil
                    button.isHidden = false
                    
                    guard coordinates.count > 0 else { return }
                    
                    mapViewController.view.layer.borderColor = nil
                    mapViewController.view.layer.borderWidth = 0
                    
                    mapViewController.setTouchViewBehaviour(.default)
                    
                    self.refreshTitleViewButton(enabled: false)
                    
                    let path = PathObject.init(coordinates: coordinates)
                    
                    if let lmk = RouteBookmarksObject.setWaypointTrackData(path) {
                        
                        self.path = path
                        
                        self.calculateRoute(with: [lmk])
                    }
                }
                
            } else {
                
                self.marketCollections.removeAll()
                
                if let navigationContext = self.navigationContext {
                 
                    navigationContext.cancelCalculateRoute()
                }
                
                if let view = self.visualEffectView {
                    
                    view.isHidden = true
                }
                
                mapViewController.showCompass()
                mapViewController.setTouchViewBehaviour(.default)
                
                button.configuration?.image = image
                button.configuration?.attributedTitle = nil
                
                self.path = nil
                
                self.refreshShareTrack()
                
                self.refreshTitleViewButton(enabled: true)
            }
        }
        
        button.addAction(action, for: .touchUpInside)
        
        mapViewController.view.addSubview(button)
        
        let size: CGFloat = 70
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: mapViewController.view.safeAreaLayoutGuide.topAnchor, constant: 15),
            button.leadingAnchor.constraint(equalTo: mapViewController.view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: size),
            button.heightAnchor.constraint(equalToConstant: size)
        ])
        
        self.drawButton = button
    }
    
    // MARK: - Navigation
    
    func createNavigationContext() -> NavigationContext? {
        
        let preferences = RoutePreferencesObject.init()
        preferences.setRouteType(.fastest)
        preferences.setIgnoreRestrictionsOverTrack(true)
        
        preferences.setAccurateTrackMatch(false) // only for track data
        
        switch self.routeType {
            
        case .pedestrian:
            preferences.setTransportMode(.pedestrian)
            
        default:
            preferences.setTransportMode(.bicycle)
        }
        
        let navigationContext = NavigationContext.init(preferences: preferences)
        
        return navigationContext
    }
    
    func calculateRoute(with waypoints: [LandmarkObject]) {
        
        guard let navigationContext = self.createNavigationContext() else { return }
        
        self.navigationContext = navigationContext
        
        navigationContext.calculateRoute(withWaypoints: waypoints) { routeStatus in
            
            self.refreshStatus(routeStatus: routeStatus)
            
        } completionHandler: { [weak self] results, code in
            
            guard let strongSelf = self else { return }
            
            guard let mapViewController = strongSelf.mapViewController else { return }
            
            mapViewController.showCompass()
            
            if results.count > 0, let route = results.first {
                
                let insets = strongSelf.areaEdge(margin: 60)
                
                mapViewController.setEdgeAreaInsets(insets)
                
                mapViewController.presentRoutes(results, withTraffic: nil, showSummary: true, animationDuration: 1600)
                
                let preferences = mapViewController.getPreferences()
                
                if let settings = preferences.getRenderSettings(route) {
                    
                    settings.textSize  = 3.2
                    settings.imageSize = 3.2
                    
                    preferences.setRenderSettings(settings, route: route)
                }
                
                if let button = strongSelf.showHideButton {
                    
                    button.isHidden = false
                }
            }
            
            strongSelf.refreshShareTrack()
        }
    }
    
    // MARK: - Share GPX Track
    
    func refreshShareTrack() {
        
        let image = UIImage.init(systemName: "square.and.arrow.up")
        
        let barItem = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(sharePathButton))
        
        self.navigationItem.rightBarButtonItem = self.path != nil ? barItem : nil
    }
    
    @objc
    func sharePathButton() {
        
        guard let path = self.path else { return }
        
        guard let data = path.export(as: .gpx) else { return }
        
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let name = "Track.gpx"
        
        let fileURL = documentsURL.appendingPathComponent(name)
        
        let success = FileManager.default.createFile(atPath: fileURL.path, contents: data)
        
        if success {
            
            let activityItems: [Any] = [fileURL]
            let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: [])
            activityController.completionWithItemsHandler = { (type, completed, items, error) in }
            
            self.present(activityController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Button
    
    func addStatusButton() {
        
        guard let mapViewController = self.mapViewController else { return }
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        visualEffectView.layer.cornerRadius = 8.0
        visualEffectView.layer.masksToBounds = true
        visualEffectView.isHidden = true
        
        var size: CGFloat = 70
        
        mapViewController.view.addSubview(visualEffectView)
        
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            visualEffectView.bottomAnchor.constraint(equalTo: mapViewController.view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            visualEffectView.leadingAnchor.constraint(equalTo: mapViewController.view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            visualEffectView.trailingAnchor.constraint(equalTo: mapViewController.view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            visualEffectView.heightAnchor.constraint(equalToConstant: size)
        ])
        
        self.visualEffectView = visualEffectView
        
        let label = UILabel.init()
        label.textAlignment = .center
        
        visualEffectView.contentView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: visualEffectView.topAnchor, constant: 0),
            label.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor, constant: 0),
            label.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor, constant: 0),
            label.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor, constant: 0),
        ])
        
        self.statusLabel = label
        
        let button = UIButton.init(type: .system)
        button.configuration = .borderless()
        button.configuration?.image = self.getPencilImage()
        button.isHidden = true
        
        let action = UIAction { _ in
            
            if mapViewController.getAvailableMarkers().count == 0 {
                
                if let collection = self.marketCollections.first {
                    
                    mapViewController.addMarker(collection)
                }
                
            } else {
                
                mapViewController.removeAllMarkers()
            }
            
            self.refreshPencilImage()
        }
        
        button.addAction(action, for: .touchUpInside)
        
        visualEffectView.contentView.addSubview(button)
        
        size = 50
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: visualEffectView.centerYAnchor, constant: 0),
            button.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor, constant: -10),
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: size),
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: size),
        ])
        
        self.showHideButton = button
    }
    
    func refreshStatus(routeStatus: RouteStatus) {
        
        guard let statusLabel = self.statusLabel else { return }
        
        statusLabel.isHidden = false
        
        let attributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 24, weight: .semibold)]
        
        var attributedTitle = NSAttributedString(string: "");
        
        switch routeStatus {
            
        case.calculating:
            attributedTitle = NSAttributedString(string: "Calculating", attributes: attributes)
            
        case .uninitialized:
            attributedTitle = NSAttributedString(string: "Uninitialized", attributes: attributes)
            
        case .waitingInternetConnection:
            attributedTitle = NSAttributedString(string: "Waiting Internet Connection", attributes: attributes)
            
        case .ready:
            attributedTitle = NSAttributedString(string: "Ready", attributes: attributes)
            
        case .error:
            attributedTitle = NSAttributedString(string: "Error", attributes: attributes)
            
        default:
            break
        }
        
        statusLabel.attributedText = attributedTitle
        
        if let view = self.visualEffectView {
            
            view.isHidden = false
        }
    }
    
    // MARK: - Utils
    
    func areaEdge(margin: CGFloat) -> UIEdgeInsets {
        
        let scale = UIScreen.main.scale
        
        let insets = UIEdgeInsets.init(top: (self.view.safeAreaInsets.top + margin) * scale,
                                       left: margin * scale,
                                       bottom: (self.view.safeAreaInsets.bottom + margin) * scale,
                                       right: margin * scale)
        
        return insets
    }
    
    func refreshPencilImage() {
        
        guard let showHideButton = self.showHideButton else { return }
        
        showHideButton.configuration?.image = getPencilImage()
    }
    
    func getPencilImage() -> UIImage? {
        
        guard let mapViewController = self.mapViewController else { return nil }
        
        var palettes = [UIColor.black, UIColor.systemOrange, UIColor.clear]
        
        if mapViewController.getAvailableMarkers().count == 0 {
            
            palettes = [UIColor.black, UIColor.clear, UIColor.clear]
        }
        
        if let image = UIImage.init(systemName: "pencil.and.outline", withConfiguration: self.buttonConfiguration) {
            
            let img = image.applyingSymbolConfiguration(.init(paletteColors: palettes))
            
            return img
        }
        
        return nil
    }
    
    func createTitleViewButton() -> UIButton {
        
        let configuration = UIImage.SymbolConfiguration(pointSize: 26)
        
        let currentType = self.routeType
        
        let typeBike = UIAction(title: "Bike", image: UIImage.init(systemName: "bicycle", withConfiguration: configuration),
                                state: .off ,handler: { [weak self] action in
            
            guard let strongSelf = self else { return }
            
            strongSelf.routeType = .bicycle
            
            strongSelf.refreshTitleViewButton()
        })
        
        let typePedestrian = UIAction(title: "Pedestrian", image: UIImage.init(systemName: "figure.walk", withConfiguration: configuration),
                                      state: .off ,handler: { [weak self] action in
            
            guard let strongSelf = self else { return }
            
            strongSelf.routeType = .pedestrian
            
            strongSelf.refreshTitleViewButton()
        })
        
        if currentType == .pedestrian {
            
            typePedestrian.state = .on
            
        } else {
            
            typeBike.state = .on
        }
        
        
        let orderActions: [UIMenuElement] = [typeBike, typePedestrian]
        
        let orderSubMenu = UIMenu(options: .displayInline, children: orderActions)
        
        let children: [UIMenuElement] = [orderSubMenu]
        
        let menu = UIMenu(options: .displayInline, children: children)
        
        let title = self.routeType == .bicycle ?  "Bike Route" : "Pedestrian Route"
        let image = UIImage.init(systemName: "chevron.down.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18))
        let attributes = AttributeContainer([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .regular)])
        
        let button = UIButton.init(type: .system)
        button.configuration = .gray()
        button.configuration!.attributedTitle = AttributedString(title, attributes: attributes)
        button.configuration!.titleAlignment = .leading
        button.configuration!.image = image
        button.configuration!.imagePlacement = .trailing
        button.configuration!.imagePadding = 8.0
        button.configuration!.background.cornerRadius = 10.0
        
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
        button.isContextMenuInteractionEnabled = true
        button.sizeToFit()
        
        return button
    }
    
    func refreshTitleViewButton() {
        
        self.navigationItem.titleView = self.createTitleViewButton()
    }
    
    func refreshTitleViewButton(enabled: Bool) {
        
        if let button = self.navigationItem.titleView as? UIButton {
            
            button.isEnabled = enabled
        }
    }
    
    func setCustomStyle() {
        
        guard let mapViewController = self.mapViewController else { return }
        
        if let url = Bundle.main.url(forResource: "CustomBasic", withExtension: "style") {
            
            if let data = NSData.init(contentsOf: url) as Data? {
                
                mapViewController.applyStyle(withStyleBuffer: data, smoothTransition: false)
            }
        }
    }
    
    // MARK: - MapViewControllerDelegate
    
    func mapViewController(_ mapViewController: MapViewController, onPinch startPoint1: CGPoint, startPoint2: CGPoint,
                           toPoint1 endPoint1: CGPoint, toPoint2 endPoint2: CGPoint,
                           center: CGPoint) {
        
        guard let button = self.drawButton else { return }
        
        let zoomLevel = mapViewController.getZoomLevel()
        
        button.isHidden = (zoomLevel > 90 || zoomLevel < 15)
    }
}
