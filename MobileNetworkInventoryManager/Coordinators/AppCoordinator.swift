//
//  AppCoordinator.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit
import RealmSwift

class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    let window: UIWindow
    var presenter: UINavigationController
    var tabController: UITabBarController
    var userId: Int!
    
    init(window: UIWindow) {
        self.window = window
        self.presenter = UINavigationController()
        self.tabController = UITabBarController()
    }
    
    func start() {
        checkForLoggedUser()
    }
    
    private func checkForLoggedUser() {
        do {
            let realm = try Realm()
            
            let user = realm.object(ofType: LoggedUser.self, forPrimaryKey: R.string.localizable.logged_user_key())
            
            guard let loggedUser = user else { showLogin(); return }
            
            if loggedUser.id != 0 {
                userId = loggedUser.id
                startApp()
            }
            else {
                showLogin()
            }
            
        } catch  {
            print(error)
        }
    }
    
    private func showLogin() {
        window.rootViewController = presenter
        window.makeKeyAndVisible()
        
        let loginCoordinator = LoginCoordinator(presenter: presenter)
        loginCoordinator.parentCoordinator = self
        childCoordinators.append(loginCoordinator)
        loginCoordinator.start()
    }
    
    private func startApp() {
        window.rootViewController = tabController
        window.makeKeyAndVisible()
        
        let sitesCoordinator = SitesCoordinator(presenter: UINavigationController(), userId: userId)
        let tasksCoordinator = TasksCoordinator(presenter: UINavigationController(), userId: userId)
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
    }
}


extension AppCoordinator: CoordinatorDelegate {
    
    func childDidFinish(child: Coordinator) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                
                if child is LoginCoordinator {
                    checkForLoggedUser()
                }
                
                break
            }
        }
    }
}
