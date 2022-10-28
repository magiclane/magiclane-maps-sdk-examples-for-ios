// Copyright (C) 2019-2022, General Magic B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of General Magic
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with General Magic.

import UIKit
import Foundation
import GEMKit

class StylesViewController: UITableViewController, ContentStoreObjectDelegate {
    
    var kProgressViewTag = 100
    
    var mapStyleContext: MapStyleContext?
    
    var contentStoreList: [ContentStoreObject] = []
    
    deinit {
        
        NSLog("StylesViewController: deinit")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = "Map Styles"
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.view.backgroundColor = UIColor.systemBackground
        
        self.mapStyleContext = MapStyleContext.init()
        
        self.refreshWithLocalMaps()
        self.refreshWithOnlineMaps()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
    }

    // MARK: - Refresh

    func refreshWithOnlineMaps() {

        self.mapStyleContext!.getOnlineList(completionHandler: { [weak self] array in

            guard let weakSelf = self else {
                return
            }
            
            if array.count > 0 {
                
                weakSelf.contentStoreList = array
                
                weakSelf.tableView.reloadData()
            }
        })
    }
    
    func refreshWithLocalMaps() {
        
        self.contentStoreList = self.mapStyleContext!.getLocalList()
    }

    // MARK: - UITableViewData

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let rows = self.contentStoreList.count

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
        
        let object = self.contentStoreList[indexPath.row]
        
        let text = object.getName()
        cell.textLabel?.text = text
        
        let description = object.getTotalSizeFormatted()
        cell.detailTextLabel?.text = description
    }
    
    func setupImage(tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        
        let object = self.contentStoreList[indexPath.row]
        
        if let image = object.getImagePreview(480.0) {
            
            cell.imageView?.image = image
            cell.imageView?.contentMode = .scaleAspectFit
            cell.imageView?.layer.shadowOpacity = 0.8
            cell.imageView?.layer.shadowColor = UIColor.lightGray.cgColor
            cell.imageView?.layer.borderWidth = 1.6
            cell.imageView?.layer.borderColor = UIColor.lightGray.cgColor
            
        } else {
            
            cell.imageView?.image = nil
            cell.imageView?.layer.shadowOpacity = 0
            cell.imageView?.layer.shadowColor = nil
        }
    }
    
    func setupAccessoryView(tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        
        let object = self.contentStoreList[indexPath.row]
        
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
        
        return 160.0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 160.0
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        let object = self.contentStoreList[indexPath.row]
        
        if object.canDeleteContent() {
            
            return .delete
        }
        
        return .none
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let object = self.contentStoreList[indexPath.row]
        
        if object.canDeleteContent() {
            
            let action = UIContextualAction.init(style: .destructive, title: "Delete", handler: { [weak self] (action, view, completion) in
                
                guard let strongSelf = self else { return }
                
                object.deleteContent()
                
                strongSelf.tableView.reloadRows(at: [indexPath], with: .fade)
                
                completion(true)
            })
            
            let actions = UISwipeActionsConfiguration.init(actions: [action])
            
            return actions
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let object = self.contentStoreList[indexPath.row]
        object.delegate = self
        
        let status = object.getStatus()
        
        if status == .downloadRunning {
            
            object.pauseDownload()
            
        } else if status == .unavailable || status == .paused {
            
            object.download(withAllowCellularNetwork: false) { (success: Bool) in }
            
        } else if status == .completed {
            
            if let rootViewController = self.navigationController?.viewControllers.first as? ViewController, let mapView = rootViewController.mapViewController {
                
                self.navigationController?.popViewController(animated: true)
                
                mapView.applyStyle(withStyleIdentifier: object.getIdentifier(), smoothTransition: true)
            }
        }
    }
    
    // MARK: - ContentStoreObjectDelegate
    
    func contentStoreObject(_ object: ContentStoreObject, notifyStart hasProgress: Bool) {
        
    }
    
    func contentStoreObject(_ object: ContentStoreObject, notifyProgress progress: Int32) {
        
        if let row = self.contentStoreList.firstIndex(of: object) {
            
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
            
            if let row = self.contentStoreList.firstIndex(of: object) {
                
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

