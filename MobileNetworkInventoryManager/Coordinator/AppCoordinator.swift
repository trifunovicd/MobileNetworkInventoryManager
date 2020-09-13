//
//  AppCoordinator.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit
import RealmSwift

public class AppCoordinator: Coordinator {
    public var childCoordinators: [Coordinator] = []
    let window: UIWindow
    public var presenter: UINavigationController
    let tabController: UITabBarController
    let locationService: LocationService
    var userId: Int!
    var sitesCoordinator: SitesCoordinator!
    var tasksCoordinator: TasksCoordinator!
    var mapCoordinator: MapCoordinator!
    var userCoordinator: UserCoordinator!
    
    init(window: UIWindow) {
        self.window = window
        self.presenter = UINavigationController()
        self.tabController = UITabBarController()
        self.locationService = LocationService.instance
    }
    
    public func start() {
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
        addChildCoordinator(childCoordinator: loginCoordinator)
        loginCoordinator.start()
    }
    
    private func startApp() {
        window.rootViewController = tabController
        window.makeKeyAndVisible()
        
        sitesCoordinator = SitesCoordinator(presenter: UINavigationController(), userId: userId)
        tasksCoordinator = TasksCoordinator(presenter: UINavigationController(), userId: userId)
        mapCoordinator = MapCoordinator(presenter: UINavigationController(), userId: userId)
        userCoordinator = UserCoordinator(presenter: UINavigationController(), userId: userId)
        
        sitesCoordinator.parentCoordinator = self
        tasksCoordinator.parentCoordinator = self
        mapCoordinator.parentCoordinator = self
        userCoordinator.parentCoordinator = self
        
        addChildCoordinator(childCoordinator: sitesCoordinator)
        addChildCoordinator(childCoordinator: tasksCoordinator)
        addChildCoordinator(childCoordinator: mapCoordinator)
        addChildCoordinator(childCoordinator: userCoordinator)

        sitesCoordinator.start()
        tasksCoordinator.start()
        mapCoordinator.start()
        userCoordinator.start()
        
        let tabBarList = [sitesCoordinator.presenter, tasksCoordinator.presenter, mapCoordinator.presenter, userCoordinator.presenter]

        tabController.viewControllers = tabBarList
        
        locationService.userId = userId
        locationService.start()
    }
    
    private func removeTabControllers() {
        sitesCoordinator.viewControllerHasFinished()
        tasksCoordinator.viewControllerHasFinished()
        mapCoordinator.viewControllerHasFinished()
        
        sitesCoordinator = nil
        tasksCoordinator = nil
        mapCoordinator = nil
        userCoordinator = nil
        
        tabController.viewControllers?.removeAll()
    }
}


extension AppCoordinator: ParentCoordinatorDelegate {
    public func childDidFinish(child: Coordinator) {
        removeChildCoordinator(childCoordinator: child)

        if child is LoginCoordinator {
            checkForLoggedUser()
        }
        
        if child is UserCoordinator {
            removeTabControllers()
            checkForLoggedUser()
        }
    }
}
