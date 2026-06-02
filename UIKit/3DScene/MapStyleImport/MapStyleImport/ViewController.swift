// SPDX-FileCopyrightText: 2023-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

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
        NSLayoutConstraint.activate([
            self.mapViewController!.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.mapViewController!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.mapViewController!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.mapViewController!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }

    // MARK: - MapViewControllerDelegate

    func mapViewController(_ mapViewController: MapViewController, onMapStyleChanged identifier: Int) {

        guard let mapStyleContext = self.mapStyleContext else { return }

        self.saveSelectedMapStyleIdentifier(identifier: identifier)

        self.label.text = "Unknown map style"

        if let item = mapStyleContext.getItemById(identifier) {

            var text = item.getName()

            if !text.isEmpty {

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
        NSLayoutConstraint.activate([
            self.label.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            self.label.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            self.label.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -15)
        ])
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

        } catch {}

        return nil
    }

    func presentImportDialog(fileURL: URL, type: UTType, completion: @escaping (_ approved: Bool) -> Void) -> UIAlertController {

        let title = "Import"

        let action1 = UIAlertAction.init(title: "Import Map Style", style: .default) { action in

            completion(true)
        }

        let action2 = UIAlertAction.init(title: "Cancel", style: .cancel) { action in }

        let message = fileURL.lastPathComponent

        let controller = UIAlertController.init(title: title, message: message, preferredStyle: .actionSheet)
        controller.addAction(action1)
        controller.addAction(action2)

        let attributesTitle = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .semibold)]
        let attributesMessage = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .semibold)]

        let mutableAttributedTitle = NSMutableAttributedString.init(string: "")
        mutableAttributedTitle.append(NSAttributedString.init(string: title, attributes: attributesTitle))

        let newLine = NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 5)])

        let mutableAttributedMessage = NSMutableAttributedString.init(string: "")
        mutableAttributedMessage.append(newLine)
        mutableAttributedMessage.append(NSAttributedString.init(string: message, attributes: attributesMessage))

        controller.setValue(mutableAttributedTitle, forKey: "attributedTitle")
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

        } catch {}
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
