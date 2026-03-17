// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import UIKit
import GEMKit

class ViewController: UIViewController, GEMSdkDelegate {

    var mapViewController: MapViewController?

    var mapsContext: MapsContext?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        if let navigationController = self.navigationController {

            let appearance = navigationController.navigationBar.standardAppearance

            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }

        self.mapsContext = MapsContext.init()

        self.createMapView()

        self.mapViewController!.startRender()
        
        self.addMapsButton()
        
        GEMSdk.shared().delegate = self
    }
    
    // MARK: - Map View

    func createMapView() {

        self.mapViewController = MapViewController.init()
        self.mapViewController!.view.backgroundColor = UIColor.systemBackground

        self.addChild(self.mapViewController!)
        self.view.addSubview(self.mapViewController!.view)
        self.mapViewController!.didMove(toParent: self)

        self.mapViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.mapViewController!.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.mapViewController!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.mapViewController!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.mapViewController!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }

    // MARK: - Map Style

    func addMapsButton() {

        let image = UIImage.init(systemName: "map")
        let barButton = UIBarButtonItem.init(image: image, style: .done, target: self, action: #selector(openMaps))
        self.navigationItem.rightBarButtonItem = barButton
    }

    @objc func openMaps() {

        let viewController = MapsViewController.init(context: self.mapsContext!)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func addPrepareTestButton() {
        
        let barButton = UIBarButtonItem.init(title: "Prepare Test", style: .done, target: self, action: #selector(prepareTestingScenario))
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    // MARK: - GEMSdkDelegate
    
    func shouldUpdateWorldwideRoadMap(for status: ContentStoreOnlineSupportStatus) -> Bool {

        let value = (status == .expiredData || status == .oldData)

        print("shouldUpdateWorldwideRoadMap:%@", value ? "YES" : "NO")

        if value == false {
            
            self.addPrepareTestButton()
        }
        
        return value
    }
    
    func updateWorldwideRoadMapFinished(_ success: Bool) {

        print("updateWorldwideRoadMapFinished, success:%@", success ? "YES" : "NO")
        
        self.addPrepareTestButton()
    }
    
    func onWorldwideRoadMapVersionUpdated() {
        
        print("onWorldwideRoadMapVersionUpdated")
        
        self.addPrepareTestButton()
    }
    
    // Show the test preparation button only when map is up to date to ensure correct resource handling.
    func onConnectionStatusUpdated(_ connected: Bool) {
        
        print("onConnectionStatusUpdated:%@", connected ? "Connected" : "No connection")
        
        if connected {
            
            self.mapsContext!.checkForUpdate { status in 
                
                if status == .upToDate {
                    
                    self.addPrepareTestButton()
                }
            }
        }
    }
    
    // MARK: - Utils
    
    // Hack for this example to simulate the need of a map update. After this has been called
    // the screen should flash for a moment and a map with old data will be loaded.
    @objc func prepareTestingScenario() {
        
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let resourceURL = documentsURL.appendingPathComponent("Data/Res")
        let mapsURL = documentsURL.appendingPathComponent("Data/Maps")
        
        let oldOfflineMapURL = Bundle.main.url(forResource: "AndorraOSM_2021Q1", withExtension: "cmap")!
        let oldWorldMapURL = Bundle.main.url(forResource: "WM_7_406", withExtension: "map")!
        
        do {
            // Offline Map
            let mapsFiles = try FileManager.default.contentsOfDirectory(atPath: mapsURL.path())
            
            if let offlineMapFile = mapsFiles.first(where: { $0.hasPrefix("AndorraOSM") }) {
                
                try FileManager.default.removeItem(at: mapsURL.appendingPathComponent(offlineMapFile))
            }
            
            if let data = try? Data(contentsOf: oldOfflineMapURL) {
                
                try data.write(to: mapsURL.appending(component: oldOfflineMapURL.lastPathComponent))
            }
            
            // Comment out the above code under // Offline Map if you want to test the automatic update process without the use of offline maps,
            // but make sure to delete the existing offline maps manually or by reinstalling the app.
            
            // World Map
            let resourceFiles = try FileManager.default.contentsOfDirectory(atPath: resourceURL.path())
            
            if let resourceFile = resourceFiles.first(where: {
                
                let pref = $0.hasPrefix("WM_")
                
                return pref
            }) {
                
                try FileManager.default.removeItem(at: resourceURL.appendingPathComponent(resourceFile))
            }
                
            if let data = try? Data(contentsOf: oldWorldMapURL) {
                
                try data.write(to: resourceURL.appending(component: oldWorldMapURL.lastPathComponent))
            }
            
            self.reinitSDKAndCreateMap()
            
        } catch {
            
            print(error.localizedDescription)
        }
    }
    
    // Clean the map and reinitialize SDK to make sure the map update process is triggered. ONLY FOR DEMONSTRATION PURPOSES.
    func reinitSDKAndCreateMap() {
        
        self.navigationItem.leftBarButtonItem = nil
        
        self.mapViewController!.stopRender()
        self.mapViewController!.view.removeFromSuperview()
        self.mapViewController!.destroy()
        self.mapViewController = nil
        
        GEMSdk.shared().cleanDestroy()
        GEMSdk.shared().initSdk(getProjectApiToken())
        GEMSdk.shared().delegate = self
        
        self.createMapView()
        self.mapViewController!.startRender()
        
        self.mapsContext = MapsContext.init()
    }
}
