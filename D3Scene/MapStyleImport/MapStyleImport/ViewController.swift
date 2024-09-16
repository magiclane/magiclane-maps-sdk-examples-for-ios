// Copyright (C) 2019-2024, Magic Lane B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of Magic Lane
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with Magic Lane.

import UIKit
import GEMKit
import UniformTypeIdentifiers

class ViewController: UIViewController, MapViewControllerDelegate {
    
    var mapViewController: MapViewController?
    
    var mapStyleContext: MapStyleContext?
    
    var label = UILabel.init()
    
    let mapStyleUTType = UTType.init("com.demo.app.map.style")
    
    let userDefaultMapStyleSelectedKey = "com.demo.app.mapStyle.identifier"
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let navigationController = self.navigationController {
            
            let appearance = navigationController.navigationBar.standardAppearance
            
            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }
        
        self.createMapView()
        
        self.mapViewController!.startRender()
        
        self.addLabelText()
        
        self.mapStyleContext = MapStyleContext.init()
        
        self.applyMapStyle()
    }
    
    // MARK: - Map View
    
    func createMapView() {
        
        self.mapViewController = MapViewController.init()
        self.mapViewController!.view.backgroundColor = UIColor.systemBackground
        self.mapViewController!.delegate = self
        
        self.addChild(self.mapViewController!)
        self.view.addSubview(self.mapViewController!.view)
        self.mapViewController!.didMove(toParent: self)
        
        self.mapViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        let constraintTop = NSLayoutConstraint( item: self.mapViewController!.view!, attribute: NSLayoutConstraint.Attribute.top,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self.view, attribute: NSLayoutConstraint.Attribute.top,
                                                multiplier: 1.0, constant: 0)
        
        let constraintLeft = NSLayoutConstraint( item: self.mapViewController!.view!, attribute: NSLayoutConstraint.Attribute.leading,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading,
                                                 multiplier: 1.0, constant: 0)
        
        let constraintBottom = NSLayoutConstraint( item: self.mapViewController!.view!, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: self.view, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   multiplier: 1.0, constant: -0)
        
        let constraintRight = NSLayoutConstraint( item: self.mapViewController!.view!, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  multiplier: 1.0, constant: -0)
        
        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintBottom, constraintRight])
    }
    
    // MARK: - MapViewControllerDelegate
    
    func mapViewController(_ mapViewController: MapViewController, onMapStyleChanged identifier: Int) {
        
        guard let mapStyleContext = self.mapStyleContext else { return }
        
        self.saveSelectedMapStyleIdentifier(identifier: identifier)
        
        self.label.text = "Unknown map style."
        
        if let item = mapStyleContext.getItemById(identifier) {
            
            var text = item.getName()
            
            if text.count > 0 {
                
                text += ", id:\(item.getIdentifier())"
                
            } else {
                
                text = "id:\(item.getIdentifier())"
            }
            
            self.label.text = text
        }
        
        self.label.isHidden = false
    }
    
    // MARK: - Label
    
    func addLabelText() {
        
        self.label.font = UIFont.boldSystemFont(ofSize: 18)
        self.label.numberOfLines = 0
        self.label.backgroundColor = UIColor.systemBackground
        self.label.isHidden = true
        self.label.textAlignment = .center
        
        self.view.addSubview(self.label)
        
        self.label.translatesAutoresizingMaskIntoConstraints = false
        let constraintLeft = NSLayoutConstraint( item: self.label, attribute: NSLayoutConstraint.Attribute.leading,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading,
                                                 multiplier: 1.0, constant: 15.0)
        
        let constraintBottom = NSLayoutConstraint( item: self.label, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: self.view.safeAreaLayoutGuide, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   multiplier: 1.0, constant: -15.0)
        
        let constraintRight = NSLayoutConstraint( item: self.label, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  multiplier: 1.0, constant: -15.0)
        
        NSLayoutConstraint.activate([constraintLeft, constraintBottom, constraintRight])
    }
    
    // MARK: - Import
    
    func handleImport(contexts: Set<UIOpenURLContext>) {
        
        for context in contexts {
            
            let fileURL = context.url
            
            if fileURL.isFileURL {
                
                if let utType = self.isFileSupported(fileURL: fileURL) {
                    
                    let controller = self.presentImportDialog(fileURL: fileURL, type: utType) { approved in
                        
                        if approved {
                            
                            self.startImporting(fileURL: fileURL, type: utType)
                        }
                    }
                    
                    self.present(controller, animated: true)
                    
                    break
                }
            }
        }
    }
    
    func startImporting(fileURL: URL, type: UTType) {
        
        guard let mapViewController = self.mapViewController else { return }
        
        if type == self.mapStyleUTType {
            
            if let data = NSData.init(contentsOf: fileURL) as Data? {
                
                self.saveMapStyleFile(fromURL: fileURL)
                
                mapViewController.applyStyle(withStyleBuffer: data, smoothTransition: false)
            }
        }
    }
    
    func isFileSupported(fileURL: URL) -> UTType? {
        
        do {
            
            let resourceValues = try fileURL.resourceValues(forKeys: [.contentTypeKey])
            
            if let type = resourceValues.contentType {
                
                if type == self.mapStyleUTType {
                    
                    return type
                }
            }
            
        } catch { }
        
        return nil
    }
    
    func presentImportDialog(fileURL: URL, type: UTType, completion: @escaping (_ approved: Bool) -> Void ) -> UIAlertController {
        
        let title = "Import"
        
        let action1 = UIAlertAction.init(title: "Import Map Style", style: .default) { action in
            
            completion(true)
        }
        
        let action2 = UIAlertAction.init(title: "Cancel", style: .cancel) { action in }
        
        let message = fileURL.lastPathComponent
        
        let controller = UIAlertController.init(title: title, message: message, preferredStyle: .actionSheet)
        controller.addAction(action1)
        controller.addAction(action2)
        
        let attributesTitle   = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .semibold)]
        let attributesMessage = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .semibold)]
        
        let mutableAttributedTitle = NSMutableAttributedString.init(string: "")
        mutableAttributedTitle.append(NSAttributedString.init(string: title, attributes: attributesTitle))
        
        let newLine = NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 5)])
        
        let mutableAttributedMessage = NSMutableAttributedString.init(string: "")
        mutableAttributedMessage.append(newLine)
        mutableAttributedMessage.append(NSAttributedString.init(string: message, attributes: attributesMessage))
        
        controller.setValue(mutableAttributedTitle,   forKey: "attributedTitle")
        controller.setValue(mutableAttributedMessage, forKey: "attributedMessage")
        
        return controller
    }
    
    func saveMapStyleFile(fromURL: URL) {
        
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let toURL = documentsURL.appendingPathComponent("Data/SceneRes/" + fromURL.lastPathComponent)
        
        do {
            
            if FileManager.default.fileExists(atPath: toURL.path) {
                
                try FileManager.default.removeItem(at: toURL)
            }
            
            try FileManager.default.copyItem(at: fromURL, to: toURL)
            
        } catch { }
    }
    
    // MARK: - Map Style
    
    func getSelectedMapStyleIdentifier() -> Int {
        
        let defaults = UserDefaults.standard
        
        let value = defaults.integer(forKey: self.userDefaultMapStyleSelectedKey)
        
        return value
    }
    
    func saveSelectedMapStyleIdentifier(identifier: Int) {
        
        let defaults = UserDefaults.standard
        
        defaults.set(identifier, forKey: self.userDefaultMapStyleSelectedKey)
    }
    
    func applyMapStyle() {
        
        guard let mapViewController = self.mapViewController else { return }
        
        let identifier = self.getSelectedMapStyleIdentifier()
        
        if identifier != 0 {
            
            mapViewController.applyStyle(withStyleIdentifier: identifier, smoothTransition: false)
            
        } else {
            
            if let url = Bundle.main.url(forResource: "Basic1Oldtime", withExtension: "style") {
                
                if let type = self.mapStyleUTType {
                    
                    self.startImporting(fileURL: url, type: type)
                }
            }
        }
    }
}
