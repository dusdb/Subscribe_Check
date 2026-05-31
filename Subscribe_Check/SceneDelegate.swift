//
//  SceneDelegate.swift
//  Subscribe_Check
//
//  Created by yeonwoo on 2026/05/17.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }

        // 탭바 색상
        UITabBar.appearance().tintColor = AppColors.primary
        UITabBar.appearance().unselectedItemTintColor = AppColors.textSecondary
        UITabBar.appearance().backgroundColor = .white

        // 네비게이션 바 색상
        UINavigationBar.appearance().tintColor = AppColors.primary
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }

    func sceneWillResignActive(_ scene: UIScene) {
        
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        
    }


}

