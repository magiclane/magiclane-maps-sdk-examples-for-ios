// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: BSD-3-Clause
//
// Contact Magic Lane at <info@magiclane.com> for commercial licensing options.

import UIKit
import Foundation
import GEMKit

class RouteInstructionsViewController: UITableViewController {
    
    var route: RouteObject?
    
    fileprivate var modelData: [ModelDataItem] = []
    
    // MARK: - Init
    
    public init(route: RouteObject) {
        
        super.init(style: .plain)

        self.route = route
    }

    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    deinit {
        
        // NSLog("RouteInstructionsViewController: deinit")
        
        modelData.removeAll()
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = "Route Instructions"
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
        
        // 1
        let segmentList = self.route!.getSegments();
        
        for segment in segmentList {
            
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
                
                self.modelData.append(item)
            }
        }
        
        // 2
        if let timeDistance = self.route!.getTimeDistance() {
            
            let routeLength = timeDistance.getTotalDistance()
            
            let trafficEvents = self.route!.getTrafficEvents()
            
            for event in trafficEvents {
                
                if event.hasTrafficEvent(onDistance: routeLength) {
                    
                    let item = ModelDataItem.init()
                    item.routeTrafficEvent = event
                    
                    if let img = event.getImage(imgSize) {
                        
                        item.image = img
                    }
                    
                    let title = event.getDescription()
                    let distance = event.getDistanceFormatted()
                    let distanceUnit = event.getDistanceUnitFormatted()
                    
                    let delay = event.getDelayTimeFormatted()
                    let delayUnit = event.getDelayTimeUnitFormatted()
                    
                    let delayDistance = event.getDelayDistanceFormatted()
                    let delayDistanceUnit = event.getDelayDistanceUnitFormatted()
                    
                    var description = ""
                    
                    if let from = event.getFromLandmark(), from.getLandmarkName().count > 0 {
                        
                        description = from.getLandmarkName()
                    }
                    
                    if let to = event.getToLandmark(), to.getLandmarkName().count > 0 {
                        
                        description += "\n" + to.getLandmarkName()
                    }
                    
                    item.title = delay + delayUnit + ", " + delayDistance + delayDistanceUnit + " (" + title + ")"
                    item.description = description
                    item.statusText = distance
                    item.statusDescription = distanceUnit
                    item.sortKey = Int(routeLength) - Int(event.getDistanceToDestination())
                    
                    self.modelData.append(item)
                }
            }
            
            if trafficEvents.count > 0 {
                
                self.modelData.sort(by: { $0.sortKey < $1.sortKey })
            }
        }
    }
    
    // MARK: - UITableViewData
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let rows = self.modelData.count
        
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
        
        self.setupText(tableView: tableView, cell: cell!, indexPath: indexPath)
        
        self.setupImage(tableView: tableView, cell: cell!, indexPath: indexPath)
        
        self.setupAccessoryView(tableView: tableView, cell: cell!, indexPath: indexPath)
        
        return cell!
    }
    
    func setupText(tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        
        let item = self.modelData[indexPath.row]
        
        let text = item.title
        cell.textLabel?.text = text
        
        let description = item.description
        cell.detailTextLabel?.text = description
    }
    
    func setupImage(tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        
        let item = self.modelData[indexPath.row]
        
        cell.imageView?.image = item.image
    }
    
    func setupAccessoryView(tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        
        let item = self.modelData[indexPath.row]
        
        let statusText = item.statusText
        let statusDesc = item.statusDescription
        
        let size = CGSize.init(width: 60, height: 40)

        let accessoryView = UIView.init()
        accessoryView.frame = CGRect.init(origin: CGPoint.zero, size: size)

        let frameL1 = CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: CGSize.init(width: 60, height: 22))
        let frameL2 = CGRect.init(origin: CGPoint.init(x: 0, y: 22), size: CGSize.init(width: 60, height: 18))

        let labelText   = UILabel.init(frame: frameL1)
        labelText.text = statusText
        labelText.textAlignment = .right

        let labelDetail = UILabel.init(frame: frameL2)
        labelDetail.text = statusDesc
        labelDetail.textAlignment = .right
        labelDetail.font = UIFont.preferredFont(forTextStyle: .footnote)

        accessoryView.addSubview(labelText)
        accessoryView.addSubview(labelDetail)

        cell.accessoryView = accessoryView
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let viewController = self.navigationController?.viewControllers.first as? ViewController {
            
            if let mapView = viewController.mapViewController {
                
                let item = self.modelData[indexPath.row]
                
                if let instruction = item.routeInstruction {
                    
                    self.navigationController?.popToRootViewController(animated: true)
                    
                    mapView.center(onRouteInstruction: instruction, zoomLevel: -1, animationDuration: 2600)
                    
                } else if let event = item.routeTrafficEvent {
                    
                    self.navigationController?.popToRootViewController(animated: true)
                    
                    mapView.center(onRouteTrafficEvent: event, zoomLevel: -1, animationDuration: 2000)
                }
            }
        }
    }
}

private class ModelDataItem {
    
    var routeInstruction: RouteInstructionObject?
    var routeTrafficEvent: RouteTrafficEventObject?
    
    var title: String = ""
    var description: String = ""
    var image: UIImage?
    var statusText: String = ""
    var statusDescription: String = ""
    var sortKey: Int = 0
    
    deinit {
        
        // NSLog("ModelDataItem: deinit")
        
        routeInstruction = nil
    }
}
