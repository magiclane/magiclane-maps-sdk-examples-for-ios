// Copyright (C) 2019-2024, Magic Lane B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of Magic Lane
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with Magic Lane.

import UIKit
import Foundation
import GEMKit

class DownloadMapsViewController: UITableViewController, ContentStoreObjectDelegate {
    
    var kProgressViewTag = 100
    
    var mapsContext: MapsContext?
    
    var mapsList: [ContentStoreObject] = []
    
    deinit {
        
        NSLog("DownloadMapsViewController: deinit")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = "Maps"
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.view.backgroundColor = UIColor.systemBackground
        
        self.mapsContext = MapsContext.init()
        
        self.refreshWithLocalMaps()
        self.refreshWithOnlineMaps()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
    }

    // MARK: - Refresh

    func refreshWithOnlineMaps() {

        self.mapsContext!.getOnlineList(completionHandler: { [weak self] array in

            guard let weakSelf = self else {
                return
            }
            
            if array.count > 0 {
                
                weakSelf.mapsList = array
                
                weakSelf.tableView.reloadData()
            }
        })
    }
    
    func refreshWithLocalMaps() {
        
        self.mapsList = self.mapsContext!.getLocalList()
    }

    // MARK: - UITableViewData

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let rows = self.mapsList.count

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
        
        cell!.selectionStyle = .default
        
        let object = self.mapsList[indexPath.row]
        
        if object.getStatus() == .completed {
            
            cell!.selectionStyle = .none
        }

        self.setupText(tableView: tableView, cell: cell!, indexPath: indexPath)

        self.setupImage(tableView: tableView, cell: cell!, indexPath: indexPath)

        self.setupAccessoryView(tableView: tableView, cell: cell!, indexPath: indexPath)

        return cell!
    }

    func setupText(tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        
        let object = self.mapsList[indexPath.row]
        
        let text = object.getName()
        cell.textLabel?.text = text
        
        let description = object.getTotalSizeFormatted()
        cell.detailTextLabel?.text = description
    }

    func setupImage(tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        
        let scale = UIScreen.main.scale
        let size = CGSize.init(width: 60.0 * scale, height: 60.0 * scale)
        
        let object = self.mapsList[indexPath.row]
        
        if let code = object.getCountryCodes().first {
            
            if let image = self.mapsContext!.getCountryFlag(withIsoCode: code, size: size) {
                
                cell.imageView?.image = image
                cell.imageView?.layer.shadowOpacity = 0.8
                cell.imageView?.layer.shadowColor = UIColor.lightGray.cgColor
                
            } else {
                
                cell.imageView?.image = nil
                cell.imageView?.layer.shadowOpacity = 0
                cell.imageView?.layer.shadowColor = nil
            }
        }
    }

    func setupAccessoryView(tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        
        let object = self.mapsList[indexPath.row]
        
        let status = object.getStatus()
        
        var value: Float = 0
        var color = UIColor.systemBlue
        
        if status == .downloadRunning {
            
            value = Float(object.getDownloadProgress())/100.0
            
        } else if status == .completed {
            
            value = 1; color = UIColor.systemGreen
        }
        
        if let progressBar = cell.contentView.viewWithTag(kProgressViewTag) as? UIProgressView {
            
            progressBar.progress = value
            progressBar.tintColor = color
            
            return
        }
        
        let progressBar = UIProgressView.init(progressViewStyle: .bar)
        progressBar.tag = kProgressViewTag
        progressBar.progress = value
        progressBar.tintColor = color
        
        cell.contentView.addSubview(progressBar)
        
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        let constraintLeft = NSLayoutConstraint( item: progressBar, attribute: NSLayoutConstraint.Attribute.leading,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: cell.textLabel, attribute: NSLayoutConstraint.Attribute.leading,
                                                 multiplier: 1.0, constant: 0.0)
        
        let constraintBottom = NSLayoutConstraint( item: progressBar, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: cell.contentView, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   multiplier: 1.0, constant: -0.0)
        
        let constraintRight = NSLayoutConstraint( item: progressBar, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: cell.contentView, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  multiplier: 1.0, constant: -0.0)
        
        let constraintHeight = NSLayoutConstraint( item: progressBar, attribute: NSLayoutConstraint.Attribute.height,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                   multiplier: 1.0, constant: 2.0)
        
        NSLayoutConstraint.activate([constraintLeft, constraintBottom, constraintRight, constraintHeight])
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return nil
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction.init(style: .destructive, title: "Delete", handler: { (action, view, completion) in
            
            let object = self.mapsList[indexPath.row]
            
            if object.canDeleteContent() {
                
                object.deleteContent()
                
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
            
            completion(true)
        })
        
        let actions = UISwipeActionsConfiguration.init(actions: [action])
        
        return actions
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let object = self.mapsList[indexPath.row]
        object.delegate = self
        
        let status = object.getStatus()
        
        if status == .downloadRunning {
            
            object.pauseDownload()
            
        } else if status == .unavailable || status == .paused {
            
            object.download(withAllowCellularNetwork: true) { (success: Bool) in }
        }
    }
    
    // MARK: - ContentStoreObjectDelegate
    
    func contentStoreObject(_ object: ContentStoreObject, notifyStart hasProgress: Bool) {
        
    }
    
    func contentStoreObject(_ object: ContentStoreObject, notifyProgress progress: Int32) {
        
        if let row = self.mapsList.firstIndex(of: object) {
            
            let indexPath = IndexPath.init(row: row, section: 0)
            
            if let cell = self.tableView.cellForRow(at: indexPath) {
                
                if let view = cell.contentView.viewWithTag(kProgressViewTag) as? UIProgressView {
                    
                    let value: Float = Float(progress)/100.0
                    
                    view.progress = value
                }
            }
        }
    }
    
    func contentStoreObject(_ object: ContentStoreObject, notifyComplete success: Bool) {
        
    }
    
    func contentStoreObject(_ object: ContentStoreObject, notifyStatusChanged status: ContentStoreObjectStatus) {
        
        if status == .completed {
            
            if let row = self.mapsList.firstIndex(of: object) {
                
                let indexPath = IndexPath.init(row: row, section: 0)
                
                if let cell = self.tableView.cellForRow(at: indexPath) {
                    
                    if let view = cell.contentView.viewWithTag(kProgressViewTag) as? UIProgressView {
                        
                        view.tintColor = UIColor.systemGreen
                    }
                }
            }
        }
    }
}
