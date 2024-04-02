// Copyright (C) 2019-2024, General Magic B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of General Magic
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with General Magic.

import Foundation
import Charts
import GEMKit
import SwiftUI

class RouteProfileViewController: UIViewController {
    
    let contentView = UIView.init()
    let scrollView = UIScrollView.init()
    
    var route: RouteObject?
    var mapViewController: MapViewController?
    
    var elevationChart: ElevationChartViewController?
    var surfaceChart: SurfacesChartViewController?
    var roadChart: RoadsChartViewController?
    var steepnessChart: SteepnessChartViewController?
    
    let sliderChartSize: CGFloat = 140
    
    let exitButton = UIButton.init(type: .system)
    let titleLabel = UILabel.init()
    let titleImage = UIImageView.init()
    
    let separatingLine = UIView.init()
    
    let titleHeight = 65.0
    
    public init() {
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
        NSLog("RouteProfileViewController: deinit")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.contentView.backgroundColor = .secondarySystemGroupedBackground
        self.scrollView.backgroundColor = .systemGroupedBackground
        self.titleLabel.text = "Route Profile"
        
        if let img = UIImage(systemName: "chart.xyaxis.line")?.withRenderingMode(.alwaysOriginal).withTintColor(.label) {
            
            self.titleImage.image = img
            self.titleImage.sizeToFit()
        }
        
        self.prepareCharts()
        self.prepareLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    // MARK: - Preparing
    
    func prepareCharts() {
        
        self.elevationChart = ElevationChartViewController()
        self.elevationChart!.mapViewController = self.mapViewController
        self.elevationChart!.route = self.route
        self.elevationChart!.didSelectValue = { [weak self] in
            
            guard let strongSelf = self else { return }
            
            strongSelf.surfaceChart?.removeHighlightedPaths()
            strongSelf.roadChart?.removeHighlightedPaths()
            strongSelf.steepnessChart?.removeHighlightedPaths()
        }
        
        self.surfaceChart = SurfacesChartViewController()
        self.surfaceChart!.mapViewController = self.mapViewController
        self.surfaceChart!.route = self.route
        self.surfaceChart!.didSelectValue = { [weak self] in
            
            guard let strongSelf = self else { return }
            
            strongSelf.roadChart?.removeHighlightedPaths()
            strongSelf.steepnessChart?.removeHighlightedPaths()
            
            strongSelf.elevationChart?.resetChartData()
        }
        
        self.roadChart = RoadsChartViewController()
        self.roadChart!.mapViewController = self.mapViewController
        self.roadChart!.route = self.route
        self.roadChart!.didSelectValue = { [weak self] in
            
            guard let strongSelf = self else { return }
            
            strongSelf.surfaceChart?.removeHighlightedPaths()
            strongSelf.steepnessChart?.removeHighlightedPaths()
            
            strongSelf.elevationChart?.resetChartData()
        }
        
        self.steepnessChart = SteepnessChartViewController()
        self.steepnessChart!.mapViewController = self.mapViewController
        self.steepnessChart!.route = self.route
        self.steepnessChart!.didSelectValue = { [weak self] in
            
            guard let strongSelf = self else { return }
            
            strongSelf.surfaceChart?.removeHighlightedPaths()
            strongSelf.roadChart?.removeHighlightedPaths()
            
            strongSelf.elevationChart?.resetChartData()
        }
    }
    
    func prepareLayout() {
        
        guard let elevationChart = self.elevationChart else { return }
        guard let surfaceChart = self.surfaceChart else { return }
        guard let roadChart = self.roadChart else { return }
        guard let steepnessChart = self.steepnessChart else { return }
        
        self.contentView.layer.cornerRadius = 20.0
        self.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        self.view.layer.cornerRadius = 20.0
        self.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.view.layer.shadowColor = UIColor.darkGray.cgColor
        self.view.layer.shadowOpacity = 0.4
        
        self.contentView.addSubview(self.exitButton)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.titleImage)
        self.contentView.addSubview(self.separatingLine)
        
        self.view.addSubview(self.contentView)
        self.view.addSubview(self.scrollView)
        
        self.scrollView.addSubview(elevationChart.view)
        self.scrollView.addSubview(surfaceChart.view)
        self.scrollView.addSubview(roadChart.view)
        self.scrollView.addSubview(steepnessChart.view)
        
        let configuration = UIImage.SymbolConfiguration(pointSize: 28)
        
        if let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: configuration) {
            
            let img = image.withRenderingMode(.alwaysTemplate)
            
            self.exitButton.setImage(img, for: .normal)
            
            self.exitButton.tintColor = UIColor.lightGray
        }
        
        self.exitButton.isHidden = true
        self.exitButton.addTarget(self, action: #selector(exitButtonPressed), for: .touchUpInside)
        self.exitButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.exitButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 0),
            self.exitButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10),
            self.exitButton.widthAnchor.constraint(equalToConstant: 40),
            self.exitButton.heightAnchor.constraint(equalToConstant: 40),
        ])
        
        self.titleLabel.numberOfLines = 4
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 20),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.titleImage.trailingAnchor, constant: 10),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.exitButton.leadingAnchor, constant: 0),
        ])
        
        self.titleImage.contentMode = .scaleAspectFit
        self.titleImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.titleImage.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor, constant: 0),
            self.titleImage.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15),
            self.titleImage.heightAnchor.constraint(equalToConstant: 35),
            self.titleImage.widthAnchor.constraint(equalToConstant: 35)
        ])
        
        self.separatingLine.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        
        self.separatingLine.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.separatingLine.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 20.0),
            self.separatingLine.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),
            self.separatingLine.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
            self.separatingLine.heightAnchor.constraint(equalToConstant: 2.0)
        ])

        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.contentView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            self.contentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            self.contentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            
            // Close layout
            self.contentView.bottomAnchor.constraint(equalTo: separatingLine.bottomAnchor, constant: 0),
        ])
        
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        let scrollConstraints: [NSLayoutConstraint] = [
            self.scrollView.topAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0),
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
        ]
        NSLayoutConstraint.activate(scrollConstraints)
        
        scrollConstraints[0].priority = .defaultLow
        
        elevationChart.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            elevationChart.view.topAnchor.constraint(equalTo: self.scrollView.topAnchor, constant: 0),
            elevationChart.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 5),
            elevationChart.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -5)
        ])
        
        surfaceChart.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            surfaceChart.view.topAnchor.constraint(equalTo: elevationChart.view.bottomAnchor, constant: 20),
            surfaceChart.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            surfaceChart.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            surfaceChart.view.heightAnchor.constraint(equalToConstant: sliderChartSize)
        ])
        
        roadChart.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            roadChart.view.topAnchor.constraint(equalTo: surfaceChart.view.bottomAnchor, constant: 20),
            roadChart.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            roadChart.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            roadChart.view.heightAnchor.constraint(equalToConstant: sliderChartSize),
        ])
        
        steepnessChart.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            steepnessChart.view.topAnchor.constraint(equalTo: roadChart.view.bottomAnchor, constant: 20),
            steepnessChart.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            steepnessChart.view.heightAnchor.constraint(equalToConstant: sliderChartSize),
            steepnessChart.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            steepnessChart.view.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor, constant: -10),
        ])
    }
    
    // MARK: - Refresh
    
    func refreshWithRoute(_ route: RouteObject) {
        
        self.route = route
        
        if let elevationChart = self.elevationChart {
            
            elevationChart.refreshWithRoute(route)
        }
        
        if let surfaceChart = self.surfaceChart {
            
            surfaceChart.refreshWithRoute(route)
        }
        
        if let roadChart = self.roadChart {
            
            roadChart.refreshWithRoute(route)
        }
        
        if let steepnessChart = self.steepnessChart {
            
            steepnessChart.refreshWithRoute(route)
        }
        
        self.centerPresentedRoutes()
        
        self.mapViewController!.removeHighlight(defaultLandmarksHighlightId)
    }
    
    func centerPresentedRoutes() {
        
        guard let mapViewController = self.mapViewController else { return }
        
        let routes = mapViewController.getPresentedRoutes()
        
        if routes.count > 0 {
            
            mapViewController.stopFollowingPosition()
            
            let insets = self.areaEdge(margin: 70)
            
            mapViewController.setEdgeAreaInsets(insets)
            
            mapViewController.center(onRoutes: routes, displayMode: .full, animationDuration: 1400)
        }
    }
    
    func areaEdge(margin: CGFloat) -> UIEdgeInsets {
        
        guard let mapViewController = self.mapViewController else { return .zero }
        
        let scale = UIScreen.main.scale
        
        let insets = UIEdgeInsets.init(top: (mapViewController.view.safeAreaInsets.top + margin) * scale,
                                       left: margin * scale,
                                       bottom: (mapViewController.view.safeAreaInsets.bottom + bottomViewHeight) * scale,
                                       right: margin * scale)
        
        return insets
    }
    
    func removeHighlightedPaths() {
        
        if let surfaceChart = self.surfaceChart {
            
            surfaceChart.removeHighlightedPaths()
        }
        
        if let roadChart = self.roadChart {
            
            roadChart.removeHighlightedPaths()
        }
        
        if let steepnessChart = self.steepnessChart {
            
            steepnessChart.removeHighlightedPaths()
        }
    }
    
    func onMapZoomed() {
        
        guard let elevationChart = self.elevationChart else { return }
        
        elevationChart.refreshOnMapZoomed()
    }
    
    // MARK: - Rotation
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        self.view.alpha = 0
        
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in
            
            self.view.alpha = 1
        })
    }
    
    func removeLandmarkFromMap() {
        
        self.mapViewController!.removeHighlight(defaultLandmarksHighlightId)
    }
    
    func clean() {
        
        self.elevationChart?.clean()
        
        self.elevationChart?.view.removeFromSuperview()
        self.surfaceChart?.view.removeFromSuperview()
        self.roadChart?.view.removeFromSuperview()
        self.steepnessChart?.view.removeFromSuperview()
        
        self.elevationChart = nil
        self.surfaceChart  = nil
        self.roadChart = nil
        self.steepnessChart = nil
        
        self.scrollView.removeFromSuperview()
        self.separatingLine.removeFromSuperview()
        self.contentView.removeFromSuperview()
        
        self.mapViewController = nil
        self.route = nil
    }
    
    @objc func exitButtonPressed() {
        
    }
}
