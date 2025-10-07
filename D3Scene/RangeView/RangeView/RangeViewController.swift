// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit
import Foundation

enum AvoidTraffic: Int {
    
    case preferFasterRoute
    case preferCurrentRoute
    case off
}

class RangeViewController: UIViewController {
    
    var landmark: LandmarkObject?
    
    var mapViewController: MapViewController?
    
    var rangeView: RangeView?
    
    var model: RangeSettingsModel = RangeSettingsModel(modeType: .car)
    
    var colors: [UIColor : Bool] = [:]
    
    let initialColor: UIColor = UIColor(red: 52/255, green: 119/255, blue: 235/255, alpha: 0.25)

    // MARK: - Init
    
    public init(mapViewController: MapViewController) {
        
        self.mapViewController = mapViewController
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
        NSLog("RangeViewController: deinit")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.setupColors()
        
        self.prepareView()
        
        self.title = "Range"
        
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.showNavigationController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        self.hideNavigationController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        
        guard let mapViewController = self.mapViewController else { return }
        
        if self.model.presentedRoutes.isEmpty == false {
            
            mapViewController.removeRoutes(self.model.getPresentedRangeRoutes())
        }
    }

    // MARK: - Layout
    
    func prepareView() {
        
        guard let mapViewController = self.mapViewController else { return }
        
        self.rangeView = RangeView(model: self.model)
        
        self.rangeView!.didSelectOptionItem = { [weak self] item in
            
            guard let strongSelf = self else { return }
            
            guard let rangeView = strongSelf.rangeView else { return }
            
            let alert = strongSelf.presentOptionsMenu(title: item.title,
                                                      options: item.options,
                                                      selectedIndex: item.chosenOption) { newIndex in
                
                rangeView.updateSettingsOnOption(item: item, newOption: newIndex)
            }
            
            if let alert = alert {
                
                strongSelf.present(alert, animated: true, completion: nil)
            }
        }
        
        self.rangeView!.didSelectTransportMode = { [weak self] in
            
            guard let strongSelf = self else { return }
            guard let rangeView = strongSelf.rangeView else { return }
            
            let alert = strongSelf.presentOptionsMenu(title: "Transport Mode",
                                                      options: ["Car",
                                                                "Pedestrian",
                                                                "Bicycle",
                                                                "Truck"],
                                                      selectedIndex: strongSelf.model.mode.rawValue) { newIndex in
                
                if strongSelf.model.mode.rawValue != newIndex {
                    
                    rangeView.updateTransportModeOnOption(newOption: newIndex)
                }
            }
            
            if let alert = alert {
                
                strongSelf.present(alert, animated: true, completion: nil)
            }
        }
        
        self.rangeView!.onRangeAdded = { [weak self] in
            
            guard let strongSelf = self else { return }
            
            if strongSelf.model.isRangeValueUsed(value: strongSelf.model.rangeValue, transportMode: strongSelf.model.mode) == false {
                
                strongSelf.calculateRangeRoutes()
            }
        }
        
        self.rangeView!.onRangeDeleted = { [weak self] item in
            
            guard let strongSelf = self else { return }
                        
            mapViewController.removeRoutes(item.routes)
            
            strongSelf.colors[item.routeColor] = false
            
            strongSelf.centerOnRoutes(routes: strongSelf.model.getSelectedRangeRoutes())
        }
        
        self.rangeView!.onRangeSelected = { [weak self] item in
            
            guard let _ = self else { return }
            
            if item.isSelected {
                
                // let insets = strongSelf.calculateAreaInset(margin: 10)
                // mapViewController.setEdgeAreaInsets(insets)
                
                mapViewController.presentRoutes(item.routes, withTraffic: nil, showSummary: false, animationDuration: 200)
                
                // mapViewController.setDebugEdgeAreaVisible(true)
                
                if let route = item.routes.first {
                    
                    let renderSettings = MapViewRouteRenderSettings.init()
                    renderSettings.options = Int32(MapViewRouteRenderOption.main.rawValue)
                    renderSettings.fillColor = item.routeColor
                    
                    let preferences = mapViewController.getPreferences()
                    preferences.setRenderSettings(renderSettings, route: route)
                }
                
            } else {
                
                mapViewController.removeRoutes(item.routes)
            }
        }
        
        let controller = UIHostingController.init(rootView: self.rangeView!)
        
        self.addChild(controller)
        self.view.addSubview(controller.view)
        controller.didMove(toParent: self)
        
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        
        let array: [NSLayoutConstraint] = [
            controller.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            controller.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            controller.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -0),
            controller.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -0),
        ]
        NSLayoutConstraint.activate(array)
        
        controller.view.backgroundColor = .systemBackground
    }
    
    func calculateAreaInset(margin: CGFloat = 60) -> UIEdgeInsets {
        
        guard let mapViewController = self.mapViewController else { return .zero }
        
        let defaultMargin = margin
        
        var top = defaultMargin
        let bottom = defaultMargin
        
        let left: CGFloat = defaultMargin / 3
        let right: CGFloat = defaultMargin / 3
        
        let compass = mapViewController.getCompassImageView()
        
        if compass.isHidden == false {
            
            top += compass.frame.size.height + 10
        }
        
        let insets = self.areaEdge(top: top, left: left, bottom: bottom, right: right)
        
        return insets
    }
    
    func areaEdge(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> UIEdgeInsets {
        
        let scale = UIScreen.main.scale
        
        let insets = UIEdgeInsets.init(top: (self.view.safeAreaInsets.top + top) * scale,
                                       left: left * scale,
                                       bottom: (self.view.safeAreaInsets.bottom + bottom) * scale,
                                       right: right * scale)
        
        return insets
    }
    
    // MARK: - Draw Routes
    
    func calculateRangeRoutes() {
        
        guard let mapViewController = self.mapViewController else { return }
        
        guard let locationDetailsLmk = landmark else { return }
        
        let value = NSNumber.init(value: model.rangeType == .time ? Int(model.rangeValue) * 60 : Int(model.rangeValue))
        
        let routePreferences = self.getRoutePreferences(transportMode: model.mode)
        routePreferences.setRouteRanges([value], quality: 100)
        
        let navigationContext = NavigationContext.init(preferences: routePreferences)
        
        self.model.isCalculating = true
        
        navigationContext.calculateRoute(withWaypoints: [locationDetailsLmk], completionHandler: { [weak self] (results: [RouteObject]) in
            
            guard let strongSelf = self else { return }
            
            strongSelf.model.isCalculating = false
            
            if results.count > 0, let route = results.first {
                
                let rangeRouteItem = RangeValueRoutesItem(rangeType: strongSelf.model.rangeType, rangeValue: strongSelf.model.rangeValue, routes: [route], transportMode: strongSelf.model.mode)
                strongSelf.model.addPresentedRoutes(rangeRouteItem)
                
                let color: UIColor = strongSelf.model.presentedRoutes.count > 1 ? (strongSelf.colors.someKey(forValue: false) ?? strongSelf.initialColor) : strongSelf.initialColor
                
                // let insets = strongSelf.calculateAreaInset(margin: 10)
                // mapViewController.setEdgeAreaInsets(insets)
                
                mapViewController.presentRoutes(results, withTraffic: nil, showSummary: false, animationDuration: 800)
                
                // mapViewController.setDebugEdgeAreaVisible(true)
                
                rangeRouteItem.routeColor = color
                strongSelf.colors[color] = true
                
                let renderSettings = MapViewRouteRenderSettings.init()
                renderSettings.options = Int32(MapViewRouteRenderOption.main.rawValue)
                renderSettings.fillColor = color
                
                let preferences = mapViewController.getPreferences()
                preferences.setRenderSettings(renderSettings, route: route)
                
            }
            
            let _ = navigationContext.getRoutePreferencesObject()
        })
    }
    
    // MARK: - UIViewController
    
    override func willMove(toParent parent: UIViewController?) {
        
        super.willMove(toParent: parent)
        
        if parent == nil {
            
            // ..
        }
    }
    
    // MARK: - Utils
    
    func presentOptionsMenu(title: String, options: [String], selectedIndex: Int, completion: @escaping ( _ newIndex: Int) -> Void ) -> UIAlertController? {
        
        guard options.count > 0 else {
            
            completion(selectedIndex)
            
            return nil
        }
        
        let alert = UIAlertController.init(title: "", message: "", preferredStyle: .actionSheet)
        alert.modalPresentationStyle = .fullScreen
        
        for index in 0..<options.count {
            
            let title = options[index]
            
            let action = UIAlertAction.init(title: title, style: .default) { [weak self] action in
                
                guard let _ = self else { return }
                
                completion(index)
            }
            
            if index == selectedIndex {
                
                if let image = UIImage.init(systemName: "checkmark.circle") {
                    
                    action.setValue(image, forKey: "image")
                }
                
            } else {
                
                if let image = UIImage.init(systemName: "circle") {
                    
                    action.setValue(image, forKey: "image")
                }
            }
            
            alert.addAction(action)
        }
        
        let action = UIAlertAction.init(title: LocalizationContext.sharedInstance().getString(.cancel), style: .cancel) { action in
            
            completion(selectedIndex)
        }
        
        alert.addAction(action)
        
        self.setAlertAttributeString(alert: alert, title: "", message: title)
        
        return alert
    }
    
    func setAlertAttributeString(alert: UIAlertController, title: String, message: String) {
        
        let attributesMessage = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .medium),
                                 NSAttributedString.Key.foregroundColor: UIColor.label]
        
        let attributeStringMessage = NSMutableAttributedString.init(string: message, attributes: attributesMessage)
        
        alert.setValue(attributeStringMessage, forKey: "attributedMessage")
    }
    
    func getCorrespondingTransportMode(_ mode: RangeTransportMode) -> RouteTransportMode {
        
        switch mode {
            
        case .car:
            return .car
            
        case .bicycle:
            return .bicycle
            
        case .truck:
            return .lorry
            
        case .pedestrian:
            return .pedestrian
        }
    }
    
    func showNavigationController() {
        
        if let navigationController = self.navigationController {
            
            navigationController.setNavigationBarHidden(false, animated: true)
        }
    }
    
    func hideNavigationController() {
        
        if let navigationController = self.navigationController {
            
            navigationController.setNavigationBarHidden(true, animated: true)
        }
    }
    
    func centerOnRoutes(routes: [RouteObject], animationDuration: Double = 250) {
        
        guard let mapViewController = self.mapViewController else { return }
        
        let routes = mapViewController.getPresentedRoutes()
        
        if routes.count > 0 {
            
            mapViewController.stopFollowingPosition()
            
            // let insets = self.calculateAreaInset(margin: 10)
            // mapViewController.setEdgeAreaInsets(insets)
            
            mapViewController.center(onRoutes: routes, displayMode: .full, animationDuration: animationDuration)
            
            // mapViewController.setDebugEdgeAreaVisible(true)
        }
    }
    
    func getRoutePreferences(transportMode: RangeTransportMode) -> RoutePreferencesObject {
        
        let preferences = RoutePreferencesObject.init()
        
        let time = TimeObject.init()
        time.setLocalTime()
        
        preferences.setTimestamp(time)
        preferences.setTransportMode(self.getCorrespondingTransportMode(transportMode))
        preferences.setAvoidTraffic(true)
        preferences.setBuildTerrainProfile(false)
        
        let settings = model.settings
        
        switch transportMode {
            
        case .car:
            
            if let value = settings[NavigationCarSettingsKey.travelModeKey.rawValue] {
                
                if let type = RouteType(rawValue: value.intValue) {
                    
                    preferences.setRouteType(type)
                }
            }
            
            if let value = settings[NavigationCarSettingsKey.avoidMotorwaysKey.rawValue] {
                
                preferences.setAvoidMotorways(value.boolValue)
            }
            
            if let value = settings[NavigationCarSettingsKey.avoidTollRoadsKey.rawValue] {
                
                preferences.setAvoidTollRoads(value.boolValue)
            }
            
            if let value = settings[NavigationCarSettingsKey.avoidFerriesKey.rawValue] {
                
                preferences.setAvoidFerries(value.boolValue)
            }
            
            if let value = settings[NavigationCarSettingsKey.avoidUnpavedRoadsKey.rawValue] {
                
                preferences.setAvoidUnpavedRoads(value.boolValue)
            }
            
        case .bicycle:
            
            if let value = settings[NavigationBikeSettingsKey.travelModeKey.rawValue] {
                
                preferences.setRouteType(value.intValue == 0 ? .fastest : .economic)
            }
            
            if let value = settings[NavigationBikeSettingsKey.bikeTypeKey.rawValue] {
                
                if let profile = BikeProfile(rawValue: value.intValue) {
                    
                    preferences.setBikeProfile(profile)
                }
            }
            
            if let value = settings[NavigationBikeSettingsKey.avoidFerriesKey.rawValue] {
                
                preferences.setAvoidFerries(value.boolValue)
            }
            
            if let value = settings[NavigationBikeSettingsKey.avoidUnpavedRoadsKey.rawValue] {
                
                preferences.setAvoidUnpavedRoads(value.boolValue)
            }

            if let value = settings[NavigationBikeSettingsKey.avoidHillsKey.rawValue] {
                
                preferences.setFitnessFactor(Float(value.intValue))
            }
            
        case .pedestrian:
            
            if let value = settings[NavigationPedestrianSettingsKey.avoidFerriesKey.rawValue] {
                
                preferences.setAvoidFerries(value.boolValue)
            }
            
            if let value = settings[NavigationPedestrianSettingsKey.avoidUnpavedRoadsKey.rawValue] {
                
                preferences.setAvoidUnpavedRoads(value.boolValue)
            }
            
            preferences.setAvoidTollRoads(false)
            preferences.setRouteType(.fastest)
            
        case .truck:
            
            if let value = settings[NavigationTruckSettingsKey.travelModeKey.rawValue] {
                
                if let type = RouteType(rawValue: value.intValue) {
                    
                    preferences.setRouteType(type)
                }
            }
            
            if let value = settings[NavigationTruckSettingsKey.avoidTrafficKey.rawValue] {
                
                if let type = AvoidTraffic(rawValue: value.intValue) {
                    
                    if type == .off {
                        
                        preferences.setAvoidTraffic(false)
                    }
                }
            }
            
            if let value = settings[NavigationTruckSettingsKey.avoidMotorwaysKey.rawValue] {
                
                preferences.setAvoidMotorways(value.boolValue)
            }
            
            if let value = settings[NavigationTruckSettingsKey.avoidTollRoadsKey.rawValue] {
                
                preferences.setAvoidTollRoads(value.boolValue)
            }
            
            if let value = settings[NavigationTruckSettingsKey.avoidFerriesKey.rawValue] {
                
                preferences.setAvoidFerries(value.boolValue)
            }
            
            if let value = settings[NavigationTruckSettingsKey.avoidUnpavedRoadsKey.rawValue] {
                
                preferences.setAvoidUnpavedRoads(value.boolValue)
            }
        }
        
        return preferences
    }
    
    func setupColors() {
        
        self.colors[self.initialColor] = false
                
        self.colors[UIColor(red: 159/255, green: 122/255, blue: 255/255, alpha: 0.25)] = false
        self.colors[UIColor(red: 195/255, green:  98/255, blue: 217/255, alpha: 0.25)] = false
        self.colors[UIColor(red:  84/255, green:  73/255, blue: 179/255, alpha: 0.25)] = false
        self.colors[UIColor(red: 212/255, green:  59/255, blue: 156/255, alpha: 0.25)] = false
        self.colors[UIColor(red:  72/255, green: 153/255, blue:  70/255, alpha: 0.25)] = false
        self.colors[UIColor(red: 237/255, green:  45/255, blue:  45/255, alpha: 0.25)] = false
        self.colors[UIColor(red: 240/255, green: 160/255, blue:  41/255, alpha: 0.25)] = false
        self.colors[UIColor(red: 245/255, green: 106/255, blue:  47/255, alpha: 0.25)] = false
        self.colors[UIColor(red: 153/255, green:  89/255, blue:  67/255, alpha: 0.25)] = false
    }
}

extension Dictionary where Value: Equatable {
    
    func someKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}

