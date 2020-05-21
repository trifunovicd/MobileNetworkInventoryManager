//
//  UserCoordinator.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit

class UserCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var presenter: UINavigationController
    let controller: UserViewController
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
        let userViewController = UserViewController()
        let userViewModel = UserViewModel()
        userViewController.viewModel = userViewModel
        userViewController.tabBarItem = UITabBarItem(title: R.string.localizable.user(), image: #imageLiteral(resourceName: "user"), selectedImage: #imageLiteral(resourceName: "user-filled"))
        userViewController.view.backgroundColor = .white
        userViewController.navigationItem.title = R.string.localizable.user()
        self.controller = userViewController
    }
    
    func start() {
        setupNavigationBar()
        controller.viewModel.userCoordinatorDelegate = self
        presenter.pushViewController(controller, animated: true)
    }
    
    private func setupNavigationBar() {
        presenter.navigationBar.barTintColor = .systemBlue
        presenter.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        presenter.navigationBar.tintColor = UIColor.white
        presenter.navigationBar.barStyle = .black
        presenter.navigationBar.isTranslucent = false
    }
}
