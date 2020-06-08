//
//  UserCoordinator.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit

class UserCoordinator: Coordinator {
    weak var parentCoordinator: CoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    var presenter: UINavigationController
    let controller: UserViewController
    
    init(presenter: UINavigationController, userId: Int) {
        self.presenter = presenter
        let userViewController = UserViewController()
        let userViewModel = UserViewModel()
        userViewModel.userId = userId
        userViewController.viewModel = userViewModel
        userViewController.tabBarItem = UITabBarItem(title: R.string.localizable.user(), image: #imageLiteral(resourceName: "user"), selectedImage: #imageLiteral(resourceName: "user-filled"))
        userViewController.view.backgroundColor = .white
        userViewController.navigationItem.title = R.string.localizable.user()
        self.controller = userViewController
    }
    
    func start() {
        presenter.setupNavigationBar(barTintColor: .systemBlue, titleTextAttributes: [.foregroundColor: UIColor.white], tintColor: .white, barStyle: .black, isTranslucent: false)
        controller.viewModel.userCoordinatorDelegate = self
        presenter.pushViewController(controller, animated: true)
    }
}


extension UserCoordinator: ViewControllerDelegate {
    func viewControllerHasFinished() {
        childCoordinators.removeAll()
        controller.removeFromParent()
        parentCoordinator?.childDidFinish(child: self)
    }
}
