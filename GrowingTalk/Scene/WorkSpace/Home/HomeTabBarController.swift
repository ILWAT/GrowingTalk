//
//  HomeNavigationController.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/25/24.
//

import UIKit
import Then

final class HomeTabBarController: UITabBarController {
    //MARK: - Properties
    private let coinShopViewController = UINavigationController(rootViewController: CoinShopViewController()).then { navigationVC in
        navigationVC.tabBarItem = navigationVC.viewControllers.first?.tabBarItem
    }
    
    //MARK: - Initialization
    init() {
        super.init(nibName: nil, bundle: nil)
        self.configureVC()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configure
    private func configureVC() {
        self.tabBar.tintColor = .label
    }

    
    //MARK: - Internal Method
    func appendNavigationWrappingVC(viewControllers: [UIViewController]) {
        var currentlyManagedVC: [UIViewController] = [coinShopViewController]
        
        for viewController in viewControllers {
            let wrappingNaviVC = UINavigationController(rootViewController: viewController)
            wrappingNaviVC.tabBarItem = viewController.tabBarItem
            currentlyManagedVC.insert(wrappingNaviVC, at: 0)
        }
        self.setViewControllers(currentlyManagedVC, animated: true)
    }
}
