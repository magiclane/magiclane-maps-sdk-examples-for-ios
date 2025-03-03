// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: BSD-3-Clause
//
// Contact Magic Lane at <info@magiclane.com> for commercial licensing options.

import UIKit
import GEMKit

class ItemProjection: NSObject {
    
    var title: NSAttributedString = NSAttributedString.init(string: "")
    var details: NSAttributedString = NSAttributedString.init(string: "")
    var object: ProjectionObject?
}

class ViewController: UIViewController, MapViewControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var mapViewController: MapViewController?
    var projectionContext: ProjectionContext?
    
    var tableView: UITableView?
    var buttonExit: UIButton?
    var modelData: [ItemProjection] = []
    var selectedLandmark: LandmarkObject?
    
    deinit {
        
        if let controller = mapViewController {
            
            controller.destroy()
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let navigationController = self.navigationController {
            
            let appearance = navigationController.navigationBar.standardAppearance
            
            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }
        
        self.title = "Projections"
        
        self.projectionContext = ProjectionContext.init()
        
        self.createMapView()
        
        self.addTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.mapViewController!.startRender()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        let location = CoordinatesObject.coordinates(withLatitude: 53.592590, longitude: 9.924337) // Hamburg
        
        self.mapViewController!.center(onCoordinates: location, zoomLevel: 70, animationDuration: 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        self.mapViewController!.stopRender()
    }
    
    // MARK: - Map View
    
    func createMapView() {
        
        self.mapViewController = MapViewController.init()
        self.mapViewController!.delegate = self
        self.mapViewController!.view.backgroundColor = UIColor.systemBackground
        
        self.addChild(self.mapViewController!)
        self.view.addSubview(self.mapViewController!.view)
        self.mapViewController!.didMove(toParent: self)
        
        self.mapViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.mapViewController!.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            self.mapViewController!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            self.mapViewController!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -0),
            self.mapViewController!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -0),
        ])
    }
    
    // MARK: - TableView
    
    func addTableView() {
        
        self.tableView = UITableView.init(frame: self.view.frame, style: .insetGrouped)
        self.tableView!.isHidden = true
        self.tableView!.dataSource = self
        self.tableView!.delegate = self
        
        self.view.addSubview(self.tableView!)
        
        self.tableView!.translatesAutoresizingMaskIntoConstraints = false
        let constraintLeft = NSLayoutConstraint( item: self.tableView!, attribute: NSLayoutConstraint.Attribute.leading,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading,
                                                 multiplier: 1.0, constant: 0.0)
        
        var constraintRight = NSLayoutConstraint( item: self.tableView!, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  multiplier: 1.0, constant: -0.0)
        
        var constraintBottom = NSLayoutConstraint( item: self.tableView!, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: self.view, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   multiplier: 1.0, constant: -0.0)
        
        var constraintHeight = NSLayoutConstraint( item: self.tableView!, attribute: NSLayoutConstraint.Attribute.height,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                   multiplier: 1.0, constant: 360.0)
        
        NSLayoutConstraint.activate([constraintLeft, constraintRight, constraintBottom, constraintHeight])
        
        let size: CGFloat = 50
        
        let buttonExit = UIButton.init(type: .system)
        buttonExit.isHidden = true
        buttonExit.setImage(UIImage.init(systemName: "xmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)), for: .normal)
        buttonExit.addTarget(self, action: #selector(closeTableView), for: .touchUpInside)
        buttonExit.layer.shadowColor = UIColor.darkGray.cgColor
        buttonExit.layer.shadowOpacity = 0.8
        buttonExit.backgroundColor = UIColor.systemBackground
        buttonExit.layer.cornerRadius = size / 2
        
        self.buttonExit = buttonExit
                
        self.view.addSubview(buttonExit)
        
        buttonExit.translatesAutoresizingMaskIntoConstraints = false
        constraintRight = NSLayoutConstraint( item: buttonExit, attribute: NSLayoutConstraint.Attribute.trailing,
                                              relatedBy: NSLayoutConstraint.Relation.equal,
                                              toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing,
                                              multiplier: 1.0, constant: -5.0)
        
        constraintBottom = NSLayoutConstraint( item: buttonExit, attribute: NSLayoutConstraint.Attribute.bottom,
                                               relatedBy: NSLayoutConstraint.Relation.equal,
                                               toItem: self.tableView!, attribute: NSLayoutConstraint.Attribute.top,
                                               multiplier: 1.0, constant: size + 5)
        
        let constraintWidth = NSLayoutConstraint( item: buttonExit, attribute: NSLayoutConstraint.Attribute.width,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                  multiplier: 1.0, constant: size)
        
        constraintHeight = NSLayoutConstraint( item: buttonExit, attribute: NSLayoutConstraint.Attribute.height,
                                               relatedBy: NSLayoutConstraint.Relation.equal,
                                               toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                               multiplier: 1.0, constant: size)
        
        NSLayoutConstraint.activate([constraintRight, constraintBottom, constraintWidth, constraintHeight])
    }
    
    // MARK: - MapViewControllerDelegate
    
    func mapViewController(_ mapViewController: MapViewController, didSelectLandmarks landmarks: [LandmarkObject], onTouch point: CGPoint) {
        
        guard let landmark = landmarks.first else { return }
        
        self.handleSelection(landmark: landmark)
    }
    
    func mapViewController(_ mapViewController: MapViewController, didSelectLandmarks landmarks: [LandmarkObject], onLongTouch point: CGPoint) {
        
        guard let landmark = landmarks.first else { return }
        
        self.handleSelection(landmark: landmark)
    }
    
    func mapViewController(_ mapViewController: MapViewController, didSelectStreets streets: [LandmarkObject], onTouch point: CGPoint) {
        
        guard let landmark = streets.first else { return }
        
        self.handleSelection(landmark: landmark)
    }
    
    func mapViewController(_ mapViewController: MapViewController, didSelectStreets streets: [LandmarkObject], onLongTouch point: CGPoint) {
        
        guard let landmark = streets.first else { return }
        
        self.handleSelection(landmark: landmark)
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let count = self.modelData.count
        
        return count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if let lmk = self.selectedLandmark {
            
            return lmk.getLandmarkName()
        }
        
        return ""
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "defaultCellId"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        if cell == nil {
            
            cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: identifier)
            
            cell!.textLabel!.numberOfLines = 0
            cell!.detailTextLabel!.numberOfLines = 0
        }
        
        let item = self.modelData[indexPath.row]
        
        cell!.textLabel?.attributedText = item.title
        cell!.detailTextLabel?.attributedText = item.details
        
        return cell!
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Utils
    
    func handleSelection(landmark: LandmarkObject) {
        
        self.modelData.removeAll()
        
        let attributesMessage = self.getStringAttributes()
        
        let coordinates = landmark.getCoordinates()
        
        if coordinates.isValid() {
            
            let details = NSAttributedString.init(string: "Latitude: \(coordinates.latitude)\nLongitude: \(coordinates.longitude)", attributes: attributesMessage)
            
            let item = ItemProjection.init()
            item.title = self.getString(title: "World Geodetic System:")
            item.details = details
            self.modelData.append(item)
        }
        
        self.convertFrom(coordinates: coordinates, toType: .mgrs) { error, details in
            
            let item = ItemProjection.init()
            item.title = self.getString(title: "Military Grid Reference System:")
            item.details = self.getString(title: "", description: "Not supported.")
            
            if error == .kNoError {
                
                item.details = details
            }
            
            self.modelData.append(item)
            self.tableView!.reloadData()
        }
        
        self.convertFrom(coordinates: coordinates, toType: .bng) { error, details in
            
            let item = ItemProjection.init()
            item.title = self.getString(title: "British National Grid:")
            item.details = self.getString(title: "", description: "Not supported.")
            
            if error == .kNoError {
                
                item.details = details
            }
            
            self.modelData.append(item)
            self.tableView!.reloadData()
        }
        
        self.convertFrom(coordinates: coordinates, toType: .lam) { error, details in
            
            let item = ItemProjection.init()
            item.title = self.getString(title: "Lambert 93")
            item.details = self.getString(title: "", description: "Not supported.")
            
            if error == .kNoError {
                
                item.details = details
            }
            
            self.modelData.append(item)
            self.tableView!.reloadData()
        }
        
        self.convertFrom(coordinates: coordinates, toType: .utm) { error, details in
            
            let item = ItemProjection.init()
            item.title = self.getString(title: "Universal Transverse Mercator:")
            item.details = self.getString(title: "", description: "Not supported.")
            
            if error == .kNoError {
                
                item.details = details
            }
            
            self.modelData.append(item)
            self.tableView!.reloadData()
        }
        
        self.convertFrom(coordinates: coordinates, toType: .gk) { error, details in
            
            let item = ItemProjection.init()
            item.title = self.getString(title: "Gauss-Krueger")
            item.details = self.getString(title: "", description: "Not supported.")
            
            if error == .kNoError {
                
                item.details = details
            }
            
            self.modelData.append(item)
            self.tableView!.reloadData()
        }
        
        self.convertFrom(coordinates: coordinates, toType: .W3W) { error, details in
            
            let item = ItemProjection.init()
            item.title = self.getString(title: "What 3 Words")
            item.details = self.getString(title: "", description: "Not supported.")
            
            if error == .kNoError {
                
                item.details = details
            }
            
            self.modelData.append(item)
            self.tableView!.reloadData()
        }
        
        // let text = landmark.getLandmarkName()
        // let scale = UIScreen.main.scale
        // let image = landmark.getLandmarkImage(CGSize.init(width: 40*scale, height: 40*scale))
        
        self.highlight(landmark: landmark)
        
        self.selectedLandmark = landmark
        
        self.tableView!.reloadData()
        self.tableView!.isHidden = false
        self.buttonExit!.isHidden = false
    }
    
    func highlight(landmark: LandmarkObject) {
        
        let settings = HighlightRenderSettings.init()
        settings.showPin = true
        settings.imageSize = 7
        
        if landmark.isContourGeograficAreaEmpty() == false {
            
            settings.options = Int32( HighlightOption.showLandmark.rawValue | HighlightOption.overlap.rawValue | HighlightOption.showContour.rawValue )
            settings.contourInnerColor = UIColor.white
            settings.contourOuterColor = UIColor.systemBlue
        }
        
        self.mapViewController!.presentHighlights([landmark], settings: settings, highlightId: 0)
        
        if self.selectedLandmark == nil {
            
            self.mapViewController!.center(onCoordinates: landmark.getCoordinates(), zoomLevel: 70, animationDuration: 400)
        }
    }
    
    func getMapViewCenterPoint() -> CGPoint {
        
        guard let mapViewController = self.mapViewController else { return .zero }
        
        let scale = UIScreen.main.scale
        
        let center = mapViewController.view.center
        
        let point = CGPoint.init(x: center.x * scale, y: center.y * scale)
        
        return point
    }
    
    func convertFrom(coordinates: CoordinatesObject, toType: ProjectionType, completionHandler: ( @escaping (_ error: SDKErrorCode, _ details: NSAttributedString) -> Void)  ) {
        
        guard let projectionContext = self.projectionContext else { return }
        
        let fromProj = ProjectionWGS84Object.init(coordinates: coordinates)
        
        var toProj: ProjectionObject?
        
        switch toType {
            
        case .bng:
            toProj = ProjectionBNGObject.init()
            
        case .lam:
            toProj = ProjectionLAMObject.init()
            
        case .utm:
            toProj = ProjectionUTMObject.init()
            
        case .mgrs:
            toProj = ProjectionMGRSObject.init()
            
        case .gk:
            toProj = ProjectionGKObject.init()
            
        case .W3W:
            //
            // Token is available at: https://developer.what3words.com
            //
            /* toProj = ProjectionW3WObject(token: "") */
            break
            
        default:
            completionHandler(SDKErrorCode.kNotSupported, NSMutableAttributedString.init())
        }
        
        if let toProj = toProj {
            
            let attributesMessage = self.getStringAttributes()
            
            projectionContext.convert(fromProj, to: toProj) { error in
                
                let details = NSMutableAttributedString.init()
                
                if error == .kNoError {
                    
                    switch toProj.getType() {
                        
                    case .bng:
                        if let toProj = toProj as? ProjectionBNGObject {
                            
                            let easting  = toProj.getEasting()
                            let northing = toProj.getNorthing()
                            let gridRef  = toProj.getGridReference()
                            
                            details.append(NSMutableAttributedString.init(string: "Easting: \(easting)", attributes: attributesMessage))
                            details.append(NSMutableAttributedString.init(string: "\nNorthing: \(northing)", attributes: attributesMessage))
                            details.append(NSMutableAttributedString.init(string: "\nGrid: \(gridRef)", attributes: attributesMessage))
                        }
                        
                    case .lam:
                        if let toProj = toProj as? ProjectionLAMObject {
                            
                            let x = toProj.getX()
                            let y = toProj.getY()
                            
                            details.append(NSMutableAttributedString.init(string: "X: \(x)", attributes: attributesMessage))
                            details.append(NSMutableAttributedString.init(string: "\nY: \(y)", attributes: attributesMessage))
                        }
                        
                    case .utm:
                        if let toProj = toProj as? ProjectionUTMObject {
                            
                            let x    = toProj.getX()
                            let y    = toProj.getY()
                            let zone = toProj.getZone()
                            let hemisphere = toProj.getHemisphere() == .north ? "North" : "South"
                            
                            details.append(NSMutableAttributedString.init(string: "X: \(x)", attributes: attributesMessage))
                            details.append(NSMutableAttributedString.init(string: "\nY: \(y)", attributes: attributesMessage))
                            details.append(NSMutableAttributedString.init(string: "\nZone: \(zone)", attributes: attributesMessage))
                            details.append(NSMutableAttributedString.init(string: "\nHemisphere: \(hemisphere)", attributes: attributesMessage))
                        }
                        
                    case .mgrs:
                        if let toProj = toProj as? ProjectionMGRSObject {
                            
                            let easting  = toProj.getEasting()
                            let northing = toProj.getNorthing()
                            let zone     = toProj.getZone()
                            let letters  = toProj.getSq100kIdentifier()
                            
                            details.append(NSMutableAttributedString.init(string: "Easting: \(easting)", attributes: attributesMessage))
                            details.append(NSMutableAttributedString.init(string: "\nNorthing: \(northing)", attributes: attributesMessage))
                            details.append(NSMutableAttributedString.init(string: "\nZone: \(zone)", attributes: attributesMessage))
                            details.append(NSMutableAttributedString.init(string: "\n100,000 meter square id: \(letters)", attributes: attributesMessage))
                        }
                        
                    case .gk:
                        if let toProj = toProj as? ProjectionGKObject {
                            
                            let easting  = toProj.getEasting()
                            let northing = toProj.getNorthing()
                            let zone     = toProj.getZone()
                            
                            details.append(NSMutableAttributedString.init(string: "Easting: \(easting)", attributes: attributesMessage))
                            details.append(NSMutableAttributedString.init(string: "\nNorthing: \(northing)", attributes: attributesMessage))
                            details.append(NSMutableAttributedString.init(string: "\nZone: \(zone)", attributes: attributesMessage))
                        }
                        
                    case .W3W:
                        if let toProj = toProj as? ProjectionW3WObject {
                            
                            let words = toProj.getWords()
                            
                            details.append(NSMutableAttributedString.init(string: "Words: \(words)", attributes: attributesMessage))
                        }
                        
                    default:
                        break
                    }
                }
                
                completionHandler(error, details)
            }
        }
    }
    
    func getTitleAttributes() -> [NSAttributedString.Key : NSObject] {
        
        let attributesMessage = [NSAttributedString.Key.font: UIFont.monospacedSystemFont(ofSize: 15, weight: .bold),
                                 NSAttributedString.Key.foregroundColor: UIColor.label]
        
        return attributesMessage
    }
    
    func getDescriptionAttributes() -> [NSAttributedString.Key : NSObject] {
        
        let attributesMessage = [NSAttributedString.Key.font: UIFont.monospacedSystemFont(ofSize: 15, weight: .semibold),
                                 NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel]
        
        return attributesMessage
    }
    
    func getStringAttributes() -> [NSAttributedString.Key : NSObject] {
        
        let attributesMessage = [NSAttributedString.Key.font: UIFont.monospacedSystemFont(ofSize: 15, weight: .medium),
                                 NSAttributedString.Key.foregroundColor: UIColor.label]
        
        return attributesMessage
    }
    
    @objc func closeTableView() {
        
        self.tableView!.isHidden = true
        self.buttonExit!.isHidden = true
        
        self.mapViewController!.removeHighlights()
        
        self.selectedLandmark = nil
    }
    
    func getString(title: String, description: String = "") -> NSAttributedString {
        
        let string = NSMutableAttributedString.init()
        string.append(NSAttributedString.init(string: title, attributes: self.getTitleAttributes()))
        
        if description.count > 0 {
            
            if title.count > 0 {
                
                string.append(NSAttributedString.init(string: "\n", attributes: self.getDescriptionAttributes()))
            }
            
            string.append(NSAttributedString.init(string: description, attributes: self.getDescriptionAttributes()))
        }
        
        return string
    }
}
