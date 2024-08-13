// Copyright (C) 2019-2023, Magic Lane B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of Magic Lane
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with Magic Lane.

import UIKit
import Foundation
import GEMKit

class MapsViewController: UITableViewController, ContentStoreObjectDelegate, ContentUpdateDelegate {
    
    var kProgressViewTag = 100
    
    var mapsContext: MapsContext?
    
    var offlineList: [ContentStoreObject] = []
    var onlineList: [ContentStoreObject] = []
    
    // MARK: - Init
    
    public init(context: MapsContext) {
        
        super.init(style: .insetGrouped)
        
        self.mapsContext = context
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    deinit {
        
        NSLog("MapsViewController: deinit")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let context = self.mapsContext, context.isUpdateStarted() {
            
            context.delegateUpdate = self
        }
        
        self.title = "Map ver. " + self.mapsContext!.getWorldMapVersion()
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.view.backgroundColor = UIColor.systemBackground
        
        self.addCheckUpdate()
        
        self.refreshWithLocalMaps()
        self.refreshWithOnlineMaps()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
    }
    
    // MARK: - Refresh

    func refreshWithOnlineMaps() {

        self.onlineList.removeAll()
        
        self.mapsContext!.getOnlineList(completionHandler: { [weak self] array in

            guard let weakSelf = self else {
                return
            }
            
            if array.count > 0 {
                
                for object in array {
                    
                    object.delegate = self
                    
                    weakSelf.onlineList.append(object)
                }
                
                weakSelf.tableView.reloadData()
            }
        })
    }
    
    func refreshWithLocalMaps() {
        
        self.offlineList.removeAll()
        
        for object in self.mapsContext!.getLocalList() {
            
            self.offlineList.append(object)
        }
    }
    
    func addCheckUpdate() {
        
        var buttons: [UIBarButtonItem] = []
        
        buttons.append( UIBarButtonItem.init(title: "Check Update", style: .plain, target: self, action: #selector(checkForUpdate(button:))) )
        
        self.navigationItem.rightBarButtonItems = buttons
    }
    
    @objc func checkForUpdate(button: UIBarButtonItem) {
        
        guard let context = self.mapsContext else {
            return
        }
        
        context.checkForUpdate { (status: ContentStoreOnlineSupportStatus) in
            
            if status == .upToDate {
                
                let action = UIAlertAction.init(title: "Ok", style: .default) { action in }
                let alert = UIAlertController.init(title: "Info", message: "World Map is up to date.", preferredStyle: .alert)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                
            } else if status == .oldData || status == .expiredData {
                
                let action1 = UIAlertAction.init(title: "Update", style: .default) { [weak self] action in
                    
                    guard let strongSelf = self else { return }
                    
                    let activity = UIActivityIndicatorView.init(style: .medium)
                    let button = UIBarButtonItem.init(customView: activity)
                    strongSelf.navigationItem.rightBarButtonItem = button
                    
                    activity.startAnimating()
                    
                    strongSelf.updateMaps()
                }
                
                let action2 = UIAlertAction.init(title: "Later", style: .default) { action in }
                
                let alert = UIAlertController.init(title: "Update Available", message: "", preferredStyle: .alert)
                alert.addAction(action2)
                alert.addAction(action1)
                
                let message1 = "New World Map available"
                var message2 = ", \nSize: " + context.getUpdateSizeFormatted()
                
                if context.getUpdateSize() == 0 {
                    message2 = ""
                }
                
                let message3 = ". Do you want to update?"
                let attributes1 = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.label]
                let attributes2 = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.label]
                let attributeString = NSMutableAttributedString.init(string: message1, attributes: attributes1)
                attributeString.append(NSMutableAttributedString.init(string: message2, attributes: attributes2))
                attributeString.append(NSMutableAttributedString.init(string: message3, attributes: attributes1))
                alert.setValue(attributeString, forKey: "attributedMessage")
                
                self.present(alert, animated: true, completion: nil)
                                
                self.tableView.reloadData()
            }
        }
    }
    
    func updateMaps() {
        
        guard let context = self.mapsContext else {
            return
        }
        
        context.delegateUpdate = self
        
        context.update(withAllowCellularNetwork: true) { [weak self] success in
            
            guard let strongSelf = self else { return }
            
            strongSelf.updateFinished(success: success)
        }
    }
    
    func updateFinished(success: Bool) {
        
        guard let context = self.mapsContext else {
            
            return
        }
        
        let title   = success ? "Update Completed" : "Update Error"
        let message = success ? "New Map version: " + context.getWorldMapVersion() : ""
        
        let action = UIAlertAction.init(title: "Ok", style: .default) { action in }
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
        let time: DispatchTime = .now() + 1.0
        
        DispatchQueue.main.asyncAfter(deadline: time) {
            
            self.refreshWithLocalMaps()
            self.refreshWithOnlineMaps()
            
            self.tableView.reloadData()
            
            self.title = "Map ver. " + context.getWorldMapVersion()
        }
        
        self.navigationItem.titleView = nil
        
        self.navigationItem.rightBarButtonItems = []
    }
    
    func addCancelUpdate() {
        
        var buttons: [UIBarButtonItem] = []
        
        buttons.append( UIBarButtonItem.init(title: "Cancel Update", style: .plain, target: self, action: #selector(cancelUpdate(button:))) )
        
        self.navigationItem.rightBarButtonItems = buttons
    }

    @objc func cancelUpdate(button: UIBarButtonItem) {
        
        guard let context = self.mapsContext else {
            return
        }
        
        context.cancelUpdate()
        
        self.navigationItem.rightBarButtonItems = []
    }
    
    // MARK: - UITableViewData
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rows = 0
        
        if section == 0 {
            
            rows = self.offlineList.count
            
        } else {
            
            rows = self.onlineList.count
        }
        
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
        cell!.accessoryView = nil
        
        var array: [ContentStoreObject] = []
        
        if indexPath.section == 0 {
            
            array = self.offlineList
            
        } else {
            
            array = self.onlineList
        }
        
        guard array.count > 0 else {
            return cell!
        }
        
        let object = array[indexPath.row]
        
        if object.getStatus() == .completed {
            
            cell!.selectionStyle = .none
        }

        self.setupText(tableView: tableView, cell: cell!, indexPath: indexPath, object: object)

        self.setupImage(tableView: tableView, cell: cell!, indexPath: indexPath, object: object)

        self.setupAccessoryView(tableView: tableView, cell: cell!, indexPath: indexPath, object: object)

        return cell!
    }

    func setupText(tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath, object: ContentStoreObject) {

        let text = object.getName()
        cell.textLabel?.text = text
        
        let description = object.getTotalSizeFormatted()
        
        var statusString = ""
        
        if indexPath.section == 0 {
            
            statusString = "\nStatus: "
            
            let status = object.getStatus()
            
            switch status {
            
            case .unavailable:
                statusString += "Unavailable"
                
            case .completed:
                statusString += "Completed"
                
            case .paused:
                statusString += "Paused"
                
            case .downloadQueued:
                statusString += "Download Queued"
                
            case .downloadWaiting:
                statusString += "Download Waiting"
                
            case .downloadWaitingFreeNetwork:
                statusString += "Download Waiting Free Network"
                
            case .downloadRunning:
                statusString += "Download Running"
                
            case .updateWaiting:
                statusString += "Update Waiting"
                
            default:
                break
            }
        }
        
        var version = ""
        
        if indexPath.section == 0 {
            
            version = "\nCurrent Version: " + object.getClientVersion()
            
            if object.isUpdatable() {
                
                version += "\nNew version available: " + object.getUpdateVersion()
            }
        }
        
        cell.detailTextLabel?.text = description + statusString + version
    }

    func setupImage(tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath, object: ContentStoreObject) {
        
        let scale = UIScreen.main.scale
        let size = CGSize.init(width: 60.0 * scale, height: 60.0 * scale)
        
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

    func setupAccessoryView(tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath, object: ContentStoreObject) {
        
        if indexPath.section == 0 {
            
            if let progressBar = cell.contentView.viewWithTag(kProgressViewTag) as? UIProgressView {
                
                progressBar.isHidden = true
            }
            
            let view = UIImageView.init()
            
            let isUpdatable = object.isUpdatable()
            
            if isUpdatable {
                
                let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .semibold)
                
                if let image = UIImage.init(systemName: "exclamationmark.triangle.fill", withConfiguration: configuration) {
                    
                    view.image = image.withRenderingMode(.alwaysTemplate)
                    view.tintColor = UIColor.orange.withAlphaComponent(0.7)
                    view.sizeToFit()
                    view.layer.shadowOpacity = 0.4
                    view.layer.shadowColor = UIColor.lightGray.cgColor
                }
            }
            
            cell.accessoryView = view
            
            return
        }
        
        let status = object.getStatus()
        
        var value: Float = 0
        var color = UIColor.systemBlue
        var isHidden = false
        
        if status == .unavailable {
            
            isHidden = true
            
        } else if status == .completed {
            
            value = 1; color = UIColor.systemGreen;
            
        } else {
            
            let progress = object.getDownloadProgress()
            
            if progress > 0 {
                
                isHidden = false
                value = Float(progress)/100.0
            }
        }
        
        if let progressBar = cell.contentView.viewWithTag(kProgressViewTag) as? UIProgressView {
            
            progressBar.progress = value
            progressBar.tintColor = color
            progressBar.isHidden = isHidden
            
            return
        }
        
        let progressBar = UIProgressView.init(progressViewStyle: .bar)
        progressBar.tag = kProgressViewTag
        progressBar.progress = value
        progressBar.tintColor = color
        progressBar.isHidden = isHidden
        
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
        
        if section == 0 {
            
            var string = "Local Maps: "
            
            if self.offlineList.count > 0 {
                
                string = string + String(format: "%d", self.offlineList.count)
            }
            
            return string
        }
        
        return "Online Maps:"
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        if indexPath.section == 1 {
            
            return .none
        }
        
        let object = self.offlineList[indexPath.row]
        
        if object.canDeleteContent() {
            
            return .delete
        }
        
        return .none
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if indexPath.section == 1 {
            
            return nil
        }
        
        let object = self.offlineList[indexPath.row]
        
        if object.canDeleteContent() {
            
            let action = UIContextualAction.init(style: .destructive, title: "Delete", handler: { [weak self] (action, view, completion) in
                
                guard let strongSelf = self else { return }
                
                object.deleteContent()
                
                if let index = strongSelf.offlineList.firstIndex(of:object) {
                    
                    strongSelf.offlineList.remove(at: index)
                }
                
                strongSelf.tableView.reloadData()
                
                completion(true)
            })
            
            let actions = UISwipeActionsConfiguration.init(actions: [action])
            
            return actions
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
                
        if indexPath.section == 0 {
            
            return
        }
        
        let object = self.onlineList[indexPath.row]
        
        let status = object.getStatus()
        
        if status == .downloadRunning {
            
            object.pauseDownload()
            
            self.tableView.reloadSections(IndexSet.init(integer: 0), with: .none)
            
        } else if status == .unavailable || status == .paused {
            
            object.download(withAllowCellularNetwork: true) { (success: Bool) in }
        }
    }
    
    // MARK: - ContentStoreObjectDelegate
    
    func contentStoreObject(_ object: ContentStoreObject, notifyStart hasProgress: Bool) {
        
        NSLog("ContentStoreObject: notifyStart hasProgress:%@", hasProgress ? "YES": "NO")
        
        if self.offlineList.contains(object) == false {
            
            self.offlineList.append(object)
        }
        
        self.tableView.reloadSections(IndexSet.init(integer: 0), with: .none)
    }
    
    func contentStoreObject(_ object: ContentStoreObject, notifyProgress progress: Int32) {
        
        NSLog("ContentStoreObject: notifyProgress progress:%d", progress)
        
        if let row = self.onlineList.firstIndex(of: object) {
            
            let indexPath = IndexPath.init(row: row, section: 1)
            
            if let cell = self.tableView.cellForRow(at: indexPath) {
                
                if let view = cell.contentView.viewWithTag(kProgressViewTag) as? UIProgressView {
                    
                    let value: Float = Float(progress)/100.0
                    
                    view.progress = value
                    view.isHidden = false
                }
            }
        }
    }
    
    func contentStoreObject(_ object: ContentStoreObject, notifyComplete success: Bool) {
        
        NSLog("ContentStoreObject: notifyComplete success:%@, getStatus:%d", success ? "YES": "NO", object.getStatus().rawValue)
        
        if object.getStatus() == .completed {
            
            if let row = self.onlineList.firstIndex(of: object) {
                
                let indexPath = IndexPath.init(row: row, section: 1)
                
                if let cell = self.tableView.cellForRow(at: indexPath) {
                    
                    if let view = cell.contentView.viewWithTag(kProgressViewTag) as? UIProgressView {
                        
                        view.progress = 1
                        view.tintColor = UIColor.systemGreen
                    }
                }
            }
            
            self.tableView.reloadSections(IndexSet.init(integer: 0), with: .none)
        }
    }
    
    func contentStoreObject(_ object: ContentStoreObject, notifyStatusChanged status: ContentStoreObjectStatus) {
        
    }
    
    // MARK: - ContentUpdateDelegate
    
    func contextUpdate(_ context: NSObject, notifyStart hasProgress: Bool) {
        
        self.prepareUpdateBar()
        
        self.addCancelUpdate()
    }
    
    func contextUpdate(_ context: NSObject, notifyProgress progress: Int32) {
        
        if self.navigationItem.titleView == nil {
            
            self.addCancelUpdate()
            
            self.prepareUpdateBar()
        }
        
        let value: Float = Float(progress)/100.0
        
        if let masterView = self.navigationItem.titleView {
            
            if let label = masterView.viewWithTag(15) as? UILabel {
                
                label.text = String(format: "%d", progress) + "%"
            }
            
            if let progressBar = masterView.viewWithTag(16) as? UIProgressView {
                
                progressBar.progress = value
            }
        }
    }
    
    func contextUpdate(_ context: NSObject, notifyComplete success: Bool) {
        
        self.updateFinished(success: success)
    }
    
    func contextUpdate(_ context: NSObject, notifyStatusChanged status: ContentUpdateStatus) {
        
    }
    
    // MARK: - Utils
    
    func prepareUpdateBar() {
        
        self.navigationItem.titleView = nil
        
        let masterView = UIView.init()
        
        let label = UILabel.init()
        label.tag = 15
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        
        let progressBar = UIProgressView.init(progressViewStyle: .bar)
        progressBar.tag = 16
        progressBar.trackTintColor = UIColor.lightGray.withAlphaComponent(0.5)
        progressBar.progress = 0
        progressBar.clipsToBounds = true
        progressBar.layer.cornerRadius = 4.0
        
        masterView.addSubview(label)
        masterView.addSubview(progressBar)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        let constraintTop = NSLayoutConstraint( item: label, attribute: NSLayoutConstraint.Attribute.bottom,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: progressBar, attribute: NSLayoutConstraint.Attribute.top,
                                                  multiplier: 1.0, constant: 0.0)
        
        var constraintWidth = NSLayoutConstraint( item: label, attribute: NSLayoutConstraint.Attribute.width,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: masterView, attribute: NSLayoutConstraint.Attribute.width,
                                                  multiplier: 1.0, constant: 0)
        
        NSLayoutConstraint.activate([constraintTop, constraintWidth])
        
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        constraintWidth = NSLayoutConstraint( item: progressBar, attribute: NSLayoutConstraint.Attribute.width,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: masterView, attribute: NSLayoutConstraint.Attribute.width,
                                                  multiplier: 1.0, constant: 0)
        
        var constraintHeight = NSLayoutConstraint( item: progressBar, attribute: NSLayoutConstraint.Attribute.height,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                   multiplier: 1.0, constant: 8)

        let constraintBottom = NSLayoutConstraint( item: progressBar, attribute: NSLayoutConstraint.Attribute.bottom,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: masterView, attribute: NSLayoutConstraint.Attribute.bottom,
                                                  multiplier: 1.0, constant: 0)
        
        NSLayoutConstraint.activate([constraintWidth, constraintHeight, constraintBottom])
        
        masterView.translatesAutoresizingMaskIntoConstraints = false
        constraintWidth = NSLayoutConstraint( item: masterView, attribute: NSLayoutConstraint.Attribute.width,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                  multiplier: 1.0, constant: 120.0)
        
        constraintHeight = NSLayoutConstraint( item: masterView, attribute: NSLayoutConstraint.Attribute.height,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                   multiplier: 1.0, constant: 32)
        
        NSLayoutConstraint.activate([constraintWidth, constraintHeight])
        
        masterView.sizeToFit()
        // masterView.layer.borderWidth = 1
        // masterView.layer.borderColor = UIColor.red.cgColor
        
        self.navigationItem.titleView = masterView
    }
}

