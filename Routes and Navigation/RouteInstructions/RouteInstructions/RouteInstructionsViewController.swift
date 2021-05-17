// Copyright (C) 2019-2021, General Magic B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of General Magic
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with General Magic.

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
                }
                
                let scale = UIScreen.main.scale
                let size = CGSize.init(width: 40.0 * scale, height: 40.0 * scale)
                
                if let image = routeInstruction.getTurnImage(size,
                                                             colorActiveInner: UIColor.black,
                                                             colorActiveOuter: UIColor.white,
                                                             colorInactiveInner: UIColor.lightGray,
                                                             colorInactiveOuter: UIColor.lightGray) {
                    
                    item.image = image
                }
                
                self.modelData.append(item)
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
                    
                    mapView.center(withRouteInstruction: instruction, zoomLevel: -1, animationDuration: 2600)
                }
            }
        }
    }
}

private class ModelDataItem {
    
    var routeInstruction: RouteInstructionObject?
    
    var title: String = ""
    var description: String = ""
    var image: UIImage?
    var statusText: String = ""
    var statusDescription: String = ""
    
    deinit {
        
        // NSLog("ModelDataItem: deinit")
        
        routeInstruction = nil
    }
}
