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

class PoiCategoriesViewController: UITableViewController {
    
    let searchContext = SearchContext.init()
    
    let categoriesContext = GenericCategoriesContext.init()
    
    var categoriesList: [LandmarkCategoryObject] = []
    
    deinit {
        
        NSLog("PoiCategoriesViewController: deinit")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = "Poi Categories"
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.view.backgroundColor = UIColor.systemBackground
        
        self.searchContext.setMaxMatches(20)
        self.searchContext.setSearchMapPOIs(true)
        
        self.refreshList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
    }

    // MARK: - Refresh

    func refreshList() {
        
        self.categoriesList = self.categoriesContext.getCategories()
        
        self.tableView.reloadData()
    }
    
    // MARK: - UITableViewData

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let rows = self.categoriesList.count

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
        
        let category = self.categoriesList[indexPath.row]
        
        let text = category.getName()
        cell.textLabel?.text = text
        
        let description = "id: " + String(category.getIdentifier())
        cell.detailTextLabel?.text = description
    }

    func setupImage(tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        
        let scale = UIScreen.main.scale
        let size = CGSize.init(width: 60.0 * scale, height: 60.0 * scale)
        
        let category = self.categoriesList[indexPath.row]
        
        if let image = category.getImage(size) {
            
            cell.imageView?.image = image
            cell.imageView?.layer.shadowOpacity = 0.8
            cell.imageView?.layer.shadowColor = UIColor.lightGray.cgColor
            
        } else {
            
            cell.imageView?.image = nil
            cell.imageView?.layer.shadowOpacity = 0
            cell.imageView?.layer.shadowColor = nil
        }
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
        
        return .none
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let category = self.categoriesList[indexPath.row]
        
        let success = self.searchContext.setCategory(category)
        
        guard success == true else {
            return
        }
        
        if let viewController = self.navigationController?.viewControllers.first as? ViewController {
            
            self.navigationController?.popViewController(animated: true)
            
            if let mapViewController = viewController.mapViewController {
                
                let location = CoordinatesObject.coordinates(withLatitude: 48.840827, longitude: 2.371899)
                
                mapViewController.removeHighlights()
                
                mapViewController.center(onCoordinates: location, zoomLevel: 60, animationDuration: 1200)
                
                self.searchContext.searchAround(withLocation: location) { (results: [LandmarkObject]) in
                    
                    let settings = HighlightRenderSettings.init()
                    
                    mapViewController.presentHighlights(results, settings: settings)
                }
            }
        }
    }
}
