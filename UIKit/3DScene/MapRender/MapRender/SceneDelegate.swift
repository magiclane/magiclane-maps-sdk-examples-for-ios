// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import UIKit
import GEMKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard (scene as? UIWindowScene) != nil else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {

        GEMSdk.shared().appDidBecomeActive()

        if let navigationController = window?.rootViewController as? UINavigationController,
           let viewController = navigationController.viewControllers.first as? ViewController {

            if let mapView = viewController.mapViewController {

                mapView.startRender()
            }
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {

        GEMSdk.shared().appDidEnterBackground()

        if let navigationController = window?.rootViewController as? UINavigationController,
           let viewController = navigationController.viewControllers.first as? ViewController {

            if let mapView = viewController.mapViewController {

                mapView.stopRender()
            }
        }
    }
}
