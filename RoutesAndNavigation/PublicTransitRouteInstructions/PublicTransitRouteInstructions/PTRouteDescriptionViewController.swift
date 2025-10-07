// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import UIKit
import Foundation
import GEMKit

class PTRouteDescriptionViewController: UITableViewController {
    
    var route: RouteObject?
    
    fileprivate var modelData: [ModelDataSection] = []
    
    // MARK: - Init
    
    public init(route: RouteObject) {
        
        super.init(style: .insetGrouped)

        self.route = route
    }

    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    deinit {
        
        NSLog("PTRouteDescriptionViewController: deinit")
        
        modelData.removeAll()
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = "Route Description Public Transport"
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.view.backgroundColor = UIColor.systemBackground
        
        self.prepareModelData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
    }
    
    // MARK: - Model Data
    
    func prepareModelData() {
        
        guard self.route != nil else {
            return
        }
        
        let scale = UIScreen.main.scale
        let imgSize = CGSize.init(width: 40.0 * scale, height: 40.0 * scale)
        
        let segmentList = self.route!.getSegments();
        
        for segment in segmentList {
            
            guard let segmentPT = segment as? PTRouteSegmentObject else {
                continue
            }
            
            guard segmentPT.isSignificant() else {
                continue
            }
            
            let section = ModelDataSection.init()
            section.area = segment.getGeographicArea()
            
            if segment.isCommon() {
                
                let t1 = segmentPT.getDepartureTimeFormatted()
                let t2 = segmentPT.getDepartureTimeUnitFormatted()
                
                let transitType = segmentPT.getTransitType()
                
                var image = UIImage.init(systemName: "tram")
                
                if transitType == .bus {
                    
                    image = UIImage.init(systemName: "bus")
                    
                } else if transitType == .underground {
                    
                    image = UIImage.init(systemName: "tram.tunnel.fill")
                }
                
                section.departureTime = "Departure: " + t1 + t2
                section.image = image
                
                let color = segmentPT.getLineColor()
                section.color = color.withAlphaComponent(0.4)
                
            } else {
                
                section.image = UIImage.init(systemName: "figure.walk")
                
                let d1 = segment.getTimeDistance()!.getTotalDistanceFormatted()
                let d2 = segment.getTimeDistance()!.getTotalDistanceUnitFormatted()
                
                let t1 = segment.getTimeDistance()!.getTotalTimeFormatted()
                let t2 = segment.getTimeDistance()!.getTotalTimeUnitFormatted()
                
                section.departureTime = d1 + d2 + " (" + t1 + t2 + ")"
            }
            
            let instructionList = segment.getInstructions()
            
            for routeInstruction in instructionList {
                
                let item = ModelDataItem.init()
                item.routeInstruction = routeInstruction
                
                if routeInstruction.hasTurnInfo() {
                    
                    item.title = routeInstruction.getTurnInstruction()
                }
                
                if routeInstruction.hasFollowRoadInfo() {
                    
                    item.description = routeInstruction.getFollowRoadInstruction()
                }
                
                if let timeDistance = routeInstruction.getTraveledTimeDistance() {
                    
                    item.statusText = timeDistance.getTotalDistanceFormatted()
                    item.statusDescription = timeDistance.getTotalDistanceUnitFormatted()
                    
                    item.sortKey = Int(timeDistance.getTotalDistance())
                }
                
                if let turn = routeInstruction.getTurnDetails() {
                    
                    if let image = turn.getTurnImage(imgSize,
                                                     colorActiveInner: UIColor.black,
                                                     colorActiveOuter: UIColor.white,
                                                     colorInactiveInner: UIColor.lightGray,
                                                     colorInactiveOuter: UIColor.lightGray) {
                        
                        item.image = image
                    }
                }
                
                section.dataItems.append(item)
            }
            
            self.modelData.append(section)
        }
    }
    
    // MARK: - UITableViewData
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.modelData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let rows = self.modelData[section].dataItems.count
        
        return rows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "defaultCellId"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        if cell == nil {
            
            cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: identifier)
            
            cell!.textLabel!.numberOfLines = 0
            cell!.detailTextLabel!.numberOfLines = 0
        }
                
        let view = UIView.init()
        view.backgroundColor = UIColor.lightGray
        cell!.selectedBackgroundView = view
        
        let color = self.modelData[indexPath.section].color
        cell!.backgroundColor = color
        
        self.setupText(tableView: tableView, cell: cell!, indexPath: indexPath)
        
        self.setupImage(tableView: tableView, cell: cell!, indexPath: indexPath)
        
        self.setupAccessoryView(tableView: tableView, cell: cell!, indexPath: indexPath)
        
        return cell!
    }
    
    func setupText(tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        
        let item = self.modelData[indexPath.section].dataItems[indexPath.row]
        
        let text = item.title
        cell.textLabel?.text = text
        
        let description = item.description
        cell.detailTextLabel?.text = description
    }
    
    func setupImage(tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        
        let item = self.modelData[indexPath.section].dataItems[indexPath.row]
        
        cell.imageView?.image = item.image
    }
    
    func setupAccessoryView(tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        
        let item = self.modelData[indexPath.section].dataItems[indexPath.row]
        
        let statusText = item.statusText
        let statusDesc = item.statusDescription
        
        let size = CGSize.init(width: 40, height: 40)
        
        let accessoryView = UIView.init()
        accessoryView.frame = CGRect.init(origin: CGPoint.zero, size: size)
        accessoryView.backgroundColor = UIColor.clear
        
        let frameL1 = CGRect.init(origin: CGPoint.init(x: 0, y: 0),  size: CGSize.init(width: size.width, height: 22))
        let frameL2 = CGRect.init(origin: CGPoint.init(x: 0, y: 22), size: CGSize.init(width: size.width, height: 18))
        
        let labelText   = UILabel.init(frame: frameL1)
        labelText.backgroundColor = UIColor.clear
        labelText.text = statusText
        labelText.textAlignment = .right
        labelText.font = UIFont.systemFont(ofSize: 15)

        let labelDetail = UILabel.init(frame: frameL2)
        labelDetail.backgroundColor = UIColor.clear
        labelDetail.text = statusDesc
        labelDetail.textAlignment = .right
        labelDetail.font = UIFont.preferredFont(forTextStyle: .footnote)

        accessoryView.addSubview(labelText)
        accessoryView.addSubview(labelDetail)
        
        cell.accessoryView = accessoryView
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 66
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let item = self.modelData[section]
        
        let view = HeaderView.init()
        view.imageView.image = item.image
        view.label.text = item.departureTime
        view.prepareLayout()
        view.sectionId = section
        
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(sectionTapAction))
        view.addGestureRecognizer(gesture)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let viewController = self.navigationController?.viewControllers.first as? ViewController {
            
            if let mapView = viewController.mapViewController {
                
                let item = self.modelData[indexPath.section].dataItems[indexPath.row]
                
                if let instruction = item.routeInstruction {
                    
                    self.navigationController?.popToRootViewController(animated: true)
                    
                    mapView.center(onRouteInstruction: instruction, zoomLevel: -1, animationDuration: 2000)
                }
            }
        }
    }
    
    @objc func sectionTapAction(gesture: UIGestureRecognizer) {
        
        guard let sectionView = gesture.view as? HeaderView else {
            
            return
        }
        
        if let viewController = self.navigationController?.viewControllers.first as? ViewController {
            
            if let mapView = viewController.mapViewController {
                
                let view = self.modelData[sectionView.sectionId]
                
                if let area = view.area {
                    
                    self.navigationController?.popToRootViewController(animated: true)
                    
                    mapView.center(onArea: area, zoomLevel: -1, animationDuration: 2000)
                }
            }
        }
    }
}

private class ModelDataSection {
    
    var area: RectangleGeographicAreaObject?
    
    var dataItems: [ModelDataItem] = []
    
    var image: UIImage?
    var departureTime: String = "Empty"
    var color: UIColor = UIColor.clear
    
    deinit {
        
        NSLog("ModelDataSection: deinit")
    }
}

private class ModelDataItem {
        
    var routeInstruction: RouteInstructionObject?
    
    var title: String = ""
    var description: String = ""
    var image: UIImage?
    var statusText: String = ""
    var statusDescription: String = ""
    var sortKey: Int = 0
    
    deinit {
        
        NSLog("ModelDataItem: deinit")
        
        routeInstruction = nil
    }
}

private class HeaderView: UIView {
    
    var sectionId: Int = 0
    
    let backgroundView = UIView.init()
    let imageView = UIImageView.init()
    let label = UILabel.init()
    
    func prepareLayout() {
        
        self.backgroundView.layer.cornerRadius = 8.0
        self.backgroundView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.16)
        
        self.imageView.contentMode = .scaleAspectFit
        
        self.label.font = UIFont.boldSystemFont(ofSize: 16)
        
        self.addSubview(self.backgroundView)
        self.addSubview(self.imageView)
        self.addSubview(self.label)
        
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.backgroundView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5.0),
            self.backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0.0),
            self.backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -0.0),
            self.backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2.0),
        ])
        
        let size: CGFloat = 40
        
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0.0),
            self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15.0),
            
            self.imageView.widthAnchor.constraint(equalToConstant: size),
            self.imageView.heightAnchor.constraint(equalToConstant: size)
        ])
        
        self.label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.label.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.0),
            self.label.leadingAnchor.constraint(equalTo: self.imageView.trailingAnchor, constant: 10.0),
            self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -0.0),
            self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -0.0),
        ])
        
        /*imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.red.cgColor
        label.layer.borderWidth = 2
        label.layer.borderColor = UIColor.red.cgColor */
    }
}
