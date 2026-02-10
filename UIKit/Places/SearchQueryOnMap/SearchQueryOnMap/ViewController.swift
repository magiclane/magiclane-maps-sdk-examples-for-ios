// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import UIKit
import GEMKit

class ViewController: UIViewController {

    var mapViewController: MapViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        if let navigationController = self.navigationController {

            let appearance = navigationController.navigationBar.standardAppearance

            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }

        self.createMapView()

        self.mapViewController!.startRender()

        self.addSearch()
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

    // MARK: - Search

    func addSearch() {

        let image1 = UIImage.init(systemName: "magnifyingglass")
        let image2 = UIImage.init(systemName: "clear")
        let image3 = UIImage.init(systemName: "mappin.and.ellipse")
        let image4 = UIImage.init(systemName: "line.horizontal.3")

        let barButton1 = UIBarButtonItem.init(image: image1, style: .done, target: self, action: #selector(searchButton))

        let barButton2 = UIBarButtonItem.init(image: image2, style: .done, target: self, action: #selector(cleanMap))

        let barButton3 = UIBarButtonItem.init(image: image3, style: .done, target: self, action: #selector(searchNearbyButton))

        let barButton4 = UIBarButtonItem.init(image: image4, style: .done, target: self, action: #selector(searchInParallelButton))

        self.navigationItem.rightBarButtonItems = [barButton1, barButton3, barButton4]
        self.navigationItem.leftBarButtonItems = [barButton2]
    }

    @objc func searchButton() {
        
        self.mapViewController!
            .search(withQuery: "Paris") { [weak self] (results: [LandmarkObject]) in
                
                guard let strongSelf = self else { return }
                
                if let landmark = results.first {
                    
                    strongSelf.mapViewController!.removeHighlights()
                    
                    let settings = HighlightRenderSettings.init()
                    settings.showPin = true
                    settings.imageSize = 7
                    
                    if landmark.isContourGeograficAreaEmpty() == false {
                        
                        settings.options = Int32(
                            HighlightOption.showLandmark.rawValue | HighlightOption.overlap.rawValue | HighlightOption.showContour.rawValue)
                        settings.contourInnerColor = UIColor.white
                        settings.contourOuterColor = UIColor.systemBlue
                    }
                    
                    strongSelf.mapViewController!.presentHighlights([landmark], settings: settings)
                    
                    strongSelf.mapViewController!.center(onCoordinates: landmark.getCoordinates(), zoomLevel: -1, animationDuration: 1200)
                }
            }
    }

    @objc func searchNearbyButton() {

        self.mapViewController!
            .searchAround { [weak self] (results: [LandmarkObject]) in

                guard let strongSelf = self else { return }

                if let landmark = results.first {

                    strongSelf.mapViewController!.removeHighlights()

                    let settings = HighlightRenderSettings.init()
                    settings.showPin = true
                    settings.imageSize = 7

                    if landmark.isContourGeograficAreaEmpty() == false {

                        settings.options = Int32(
                            HighlightOption.showLandmark.rawValue | HighlightOption.overlap.rawValue | HighlightOption.showContour.rawValue)
                        settings.contourInnerColor = UIColor.white
                        settings.contourOuterColor = UIColor.systemBlue
                    }

                    strongSelf.mapViewController!.presentHighlights([landmark], settings: settings, highlightId: 0)

                    strongSelf.mapViewController!.center(onCoordinates: landmark.getCoordinates(), zoomLevel: -1, animationDuration: 1200)
                }
            }
    }

    @objc func searchInParallelButton() {

        self.mapViewController!
            .search(withQuery: "Starbucks") { (results: [LandmarkObject]) in

                for landmark in results {

                    NSLog("landmark name:%@", landmark.getLandmarkName())
                }
            }

        self.mapViewController!
            .search(withQuery: "Hotels") { (results: [LandmarkObject]) in

                for landmark in results {

                    NSLog("landmark name:%@", landmark.getLandmarkName())
                }
            }

        self.mapViewController!
            .searchAround { (results: [LandmarkObject]) in

                for landmark in results {

                    NSLog("landmark name:%@", landmark.getLandmarkName())
                }
            }
    }

    @objc func cleanMap(item: UIBarButtonItem) {

        self.mapViewController!.removeHighlights()
    }
}
