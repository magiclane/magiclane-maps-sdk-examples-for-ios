// Copyright (C) 2019-2022, General Magic B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of General Magic
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with General Magic.

import Foundation
import GEMKit

class FavoritesViewController: UITableViewController {
    
    var context: LandmarkStoreContext?
    
    var category: LandmarkCategoryObject?
    
    var list: [LandmarkObject]?
    
    // MARK: - Init
    
    public init(context: LandmarkStoreContext, category: LandmarkCategoryObject) {
        
        super.init(style: .plain)
        
        self.context = context
        
        self.category = category
        
        let identifier = category.getIdentifier()
        
        let array = context.getLandmarks(identifier)
        
        self.list = array
    }

    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }

    deinit {
        
        // NSLog("FavoritesViewController: deinit")
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.navigationItem.largeTitleDisplayMode = .never
        
        let title = "Favorites"

        self.title = title
    }

    // MARK: - UITableViewData

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let rows = self.list!.count

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

        return cell!
    }

    func setupText(tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
                
        let landmark = self.list![indexPath.row]
            
        cell.textLabel?.text = landmark.getLandmarkName()
        
        var description = landmark.getLandmarkDescription()
        
        if description.count > 0 {
            
            description += "\n"
        }
        
        let location = String(format:"%.6f", landmark.getCoordinates().latitude) + ", " +
                       String(format:"%.6f", landmark.getCoordinates().longitude)
        
        description += location
        
        cell.detailTextLabel?.text = description
    }

    func setupImage(tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        
        let landmark = self.list![indexPath.row]
        
        let scale = UIScreen.main.scale
        let size = CGSize.init(width: 30.0 * scale, height: 30.0 * scale)

        let image = landmark.getLandmarkImage(size)
        cell.imageView?.image = image
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let landmark = self.list![indexPath.row]
        
        let action = UIContextualAction.init(style: .destructive, title: "Delete", handler: { [weak self] (action, view, completion) in
            
            guard let strongSelf = self else { return }
            
            if let context = strongSelf.context {
                
                if context.removeLandmark(landmark) == true {
                    
                    strongSelf.list?.remove(at: indexPath.row)
                    
                    strongSelf.tableView.reloadData()
                }
            }
            
            completion(true)
        })
        
        let actions = UISwipeActionsConfiguration.init(actions: [action])
        
        return actions
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let landmark = self.list![indexPath.row]
        
        self.navigationController?.popToRootViewController(animated: true)
        
        if let rootViewController = self.navigationController?.viewControllers.first as? ViewController {
            
            rootViewController.presentLandmarkOnMap(landmark: landmark, centerLayout: true)
        }
    }
}

