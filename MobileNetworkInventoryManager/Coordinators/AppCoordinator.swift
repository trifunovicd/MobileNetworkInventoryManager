//
//  AppCoordinator.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit

class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    let window: UIWindow
    var presenter: UINavigationController
    
    init(window: UIWindow) {
        self.window = window
        self.presenter = UINavigationController()
    }
    
    func start() {
        window.rootViewController = presenter
        window.makeKeyAndVisible()
        let loginCoordinator = LoginCoordinator(presenter: presenter)
        loginCoordinator.parentCoordinator = self
        childCoordinators.append(loginCoordinator)
        loginCoordinator.start()
    }
    
    func startApp() {
        let tabController = UITabBarController()

        let sitesCoordinator = SitesCoordinator(presenter: UINavigationController())
        let tasksCoordinator = TasksCoordinator(presenter: UINavigationController())
        let mapCoordinator = MapCoordinator(presenter: UINavigationController())
        let userCoordinator = UserCoordinator(presenter: UINavigationController())
        
        childCoordinators.append(sitesCoordinator)
        childCoordinators.append(tasksCoordinator)
        childCoordinators.append(mapCoordinator)
        childCoordinators.append(userCoordinator)

        sitesCoordinator.start()
        tasksCoordinator.start()
        mapCoordinator.start()
        userCoordinator.start()

        let tabBarList = [sitesCoordinator.presenter, tasksCoordinator.presenter, mapCoordinator.presenter, userCoordinator.presenter]

        tabController.viewControllers = tabBarList
        
        window.rootViewController = tabController
        window.makeKeyAndVisible()
    }
}


extension AppCoordinator: CoordinatorDelegate {
    
    func childDidFinish(child: Coordinator) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                
                if child is LoginCoordinator {
                    startApp()
                }
                
                break
            }
        }
    }
}
