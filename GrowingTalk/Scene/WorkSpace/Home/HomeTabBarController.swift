//
//  HomeNavigationController.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/25/24.
//

import UIKit

final class HomeTabBarController: UITabBarController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.configureVC()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureVC() {
        self.tabBar.tintColor = .label
    }
    
    func appendNavigationWrappingVC(viewControllers: [UIViewController]) {
        var currentlyManagedVC: [UIViewController] = self.viewControllers ?? []
        
        for viewController in viewControllers {
            let wrappingNaviVC = UINavigationController(rootViewController: viewController)
            wrappingNaviVC.tabBarItem = viewController.tabBarItem
            currentlyManagedVC.append(wrappingNaviVC)
        }
        
        self.setViewControllers(currentlyManagedVC, animated: true)
    }
}
