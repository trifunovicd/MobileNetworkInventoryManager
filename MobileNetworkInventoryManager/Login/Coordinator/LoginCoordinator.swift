//
//  LoginCoordinator.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit

class LoginCoordinator: Coordinator {
    weak var parentCoordinator: ParentCoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    var presenter: UINavigationController
    let controller: LoginViewController
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
        let loginViewModel = LoginViewModel()
        let loginViewController = LoginViewController()
        loginViewController.viewModel = loginViewModel
        self.controller = loginViewController
    }
    
    func start() {
        controller.viewModel.loginCoordinatorDelegate = self
        presenter.pushViewController(controller, animated: true)
    }
}


extension LoginCoordinator: CoordinatorDelegate {
    func viewControllerHasFinished() {
        childCoordinators.removeAll()
        controller.removeFromParent()
        parentCoordinator?.childDidFinish(child: self)
    }
}
