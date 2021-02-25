//
//  SceneDelegate.swift
//  VideoCallAgora
//
//  Created by Roman Mizin on 2/23/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        window.rootViewController = JoinViewController()
        window.makeKeyAndVisible()
    }
}
