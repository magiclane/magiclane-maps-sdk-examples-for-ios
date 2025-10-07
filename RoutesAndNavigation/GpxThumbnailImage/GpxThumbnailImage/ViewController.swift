// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import UIKit
import GEMKit

class ViewController: UIViewController, GEMSdkDelegate {
    
    var mapViewController: MapViewController?
    
    let thumbnailSize = CGSizeMake(300, 200)
    
    var statusLabel: UILabel?
    
    var screenshotCompletion: (() -> Void)?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let navigationController = self.navigationController {
            
            let appearance = navigationController.navigationBar.standardAppearance
            
            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }
        
        GEMSdk.shared().delegate = self
        
        self.title = "GPX Thumbnail"
        
        self.addButton()
        self.addLabel()
    }
    
    // MARK: - Generate Thumbnail Button
    
    func addButton() {
        
        let barButton = UIBarButtonItem.init(title: "Generate", style: .done, target: self, action: #selector(generateButtonAction(button:)))
        
        barButton.isEnabled = GEMSdk.shared().isOnlineConnection()
        
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func refreshGenerateButton(enable: Bool) {
        
        if let button = self.navigationItem.rightBarButtonItem {
            
            button.isEnabled = enable
        }
    }
    
    @objc
    func generateButtonAction(button: UIBarButtonItem) {
        
        // guard let fileURL = Bundle.main.url(forResource: "test", withExtension: "gpx") else { return }
        
        guard let fileURL = Bundle.main.url(forResource: "test_route", withExtension: "gpx") else { return }
        
        guard let data = NSData.init(contentsOf: fileURL) as Data? else { return }
        
        button.isEnabled = false
        
        self.prepareMapView()
        
        self.showPath(buffer: data)
    }
    
    // MARK: - GEMSdkDelegate
    
    func shouldUpdateWorldwideRoadMap(for status: ContentStoreOnlineSupportStatus) -> Bool {
        
        let value = (status == .expiredData || status == .oldData)
        
        self.updateStatus(message: "Map Update Available")
        
        self.refreshGenerateButton(enable: !value)
        
        return value
    }
    
    func updateWorldwideRoadMapFinished(_ success: Bool) {
        
        self.updateStatus(message: "Ready to Generate Thumbnail")
        
        self.refreshGenerateButton(enable: true)
    }
    
    func onConnectionStatusUpdated(_ connected: Bool) {
        
        NSLog("onConnectionStatusUpdated:%@", connected ? "Connected" : "No connection" )
        
        self.updateStatus(message: connected ? "" : "No Internet Connection")
        
        self.refreshGenerateButton(enable: connected)
    }
    
    // MARK: - Utils
    
    func prepareMapView() {
        
        guard self.mapViewController == nil else { return }
        
        self.updateStatus(message: "Prepare Map View")
        
        self.mapViewController = MapViewController.init()
        self.mapViewController!.view.backgroundColor = UIColor.systemBackground
        
        self.mapViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        let array: [NSLayoutConstraint] = [
            self.mapViewController!.view.widthAnchor.constraint(equalToConstant: self.thumbnailSize.width),
            self.mapViewController!.view.heightAnchor.constraint(equalToConstant: self.thumbnailSize.height),
        ]
        NSLayoutConstraint.activate(array)
        
        self.mapViewController!.view.layoutIfNeeded()
        self.mapViewController!.startRender()
        
        let preferences = self.mapViewController!.getPreferences()
        preferences.setMapLabelsFading(false)
        preferences.setTrafficVisibility(false)
    }
    
    func cleanMapView() {
        
        guard self.mapViewController != nil else { return }
        
        self.mapViewController?.stopRender()
        self.mapViewController?.destroy()
        self.mapViewController?.delegate = nil
        self.mapViewController = nil
    }
    
    func showPath(buffer: Data) {
        
        guard let mapViewController = self.mapViewController else { return }
        
        guard  let collection = mapViewController.getPaths() else { return }
        
        let path = PathObject.init(dataBuffer: buffer, format: .gpx)
        
        let array = path.getCoordinates()
        
        if array.count > 1 {
            
            let imageDatabase = ImageDatabaseObject.init()
            
            var lmks: [LandmarkObject] = []
            
            if let start = array.first {
                
                let lmk = LandmarkObject.init()
                lmk.setCoordinates(start)
                
                if let object = imageDatabase.getImageById(54008) { // pin start
                    
                    lmk.setImage(object)
                }
                
                lmks.append(lmk)
                
                if let stop = array.last {
                    
                    let lmk = LandmarkObject.init()
                    lmk.setCoordinates(stop)
                    
                    if let object = imageDatabase.getImageById(54006) { // pin end
                        
                        lmk.setImage(object)
                    }
                    
                    lmks.append(lmk)
                }
            }
            
            let settings = HighlightRenderSettings.init()
            settings.imageSize = 4
            
            mapViewController.presentHighlights(lmks, settings: settings)
        }
        
        let colorBorder = UIColor.black
        let colorInner  = UIColor.orange
        
        let success = collection.add(path, colorBorder: colorBorder, colorInner: colorInner, szBorder: 0.5, szInner: 1.1)
        
        if success {
            
            if let area = path.getArea() {
                
                let insets = self.calculateInsets()
                
                mapViewController.setEdgeAreaInsets(insets)
                
                mapViewController.center(onArea: area, zoomLevel: -1, animationDuration: 10) { [weak self] finished in
                    
                    guard let strongSelf = self else { return }
                    
                    strongSelf.disableOverlays()
                    
                    strongSelf.waitingMapTiles() { finished in
                        
                        strongSelf.makeScreenshot()
                    }
                }
            }
        }
    }
    
    func calculateInsets() -> UIEdgeInsets {
        
        let scale = UIScreen.main.scale
        
        let margin: CGFloat = 30
        
        let insets = UIEdgeInsets.init(top: margin * scale, left: margin * scale, bottom: margin * scale, right: margin * scale)

        return insets
    }
    
    func updateStatus(message: String) {
        
        guard let label = self.statusLabel else { return }
        
        label.text = message
    }
    
    func waitingMapTiles(completion: @escaping (_ finished: Bool) -> Void) {
        
        guard let mapViewController = self.mapViewController else { return }
        
        self.updateStatus(message: "Waiting data...")
        
        mapViewController.setOnMapViewRendered { [weak self] transitionStatus, cameraStatus in
            
            if transitionStatus == .complete && cameraStatus == .stationary {
                
                guard let strongSelf = self else { return }
                
                strongSelf.mapViewController?.resetOnMapViewRenderedCompletion()
                
                completion(true)
            }
        }
    }
    
    func disableOverlays() {
        
        let context = OverlayServiceContext.init()
        context.disableOverlay(Int32(CommonOverlayIdentifier.safety.rawValue))
        context.disableOverlay(Int32(CommonOverlayIdentifier.socialReports.rawValue))
    }
    
    func makeScreenshot() {
        
        guard let mapViewController = self.mapViewController else { return }
        
        print("makeScreenshot")
        
        self.updateStatus(message: "Done.")
        
        Task() {
            
            let image = mapViewController.snapshotImage(with: self.thumbnailSize, capture: .zero)
            
            let tag = 100
            
            if let imageView = self.view.viewWithTag(tag) as? UIImageView {
                
                imageView.image = image
                
            } else {
                
                let imageView = UIImageView.init()
                imageView.tag = tag
                imageView.image = image
                imageView.contentMode = .scaleAspectFit
                imageView.layer.borderWidth = 1
                imageView.layer.borderColor = UIColor.black.cgColor
                imageView.layer.cornerRadius = 4
                
                self.view.addSubview(imageView)
                imageView.translatesAutoresizingMaskIntoConstraints = false
                let array: [NSLayoutConstraint] = [
                    imageView.widthAnchor.constraint(equalToConstant: self.thumbnailSize.width),
                    imageView.heightAnchor.constraint(equalToConstant: self.thumbnailSize.height),
                    imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
                    imageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0),
                ]
                NSLayoutConstraint.activate(array)
            }
        }
    }
    
    func addLabel() {
        
        guard self.statusLabel == nil else { return }
        
        self.statusLabel = UILabel.init()
        self.statusLabel?.text = "Waiting Internet Connection"
        self.statusLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        self.view.addSubview(self.statusLabel!)
        
        self.statusLabel?.translatesAutoresizingMaskIntoConstraints = false
        let array: [NSLayoutConstraint] = [
            self.statusLabel!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            self.statusLabel!.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 30),
        ]
        NSLayoutConstraint.activate(array)
    }
}
