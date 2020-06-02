//
//  LoginCoordinator.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit

class LoginCoordinator: Coordinator {
    weak var parentCoordinator: CoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    var presenter: UINavigationController
    let controller: LoginViewController
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
        let loginViewController = LoginViewController()
        let loginViewModel = LoginViewModel()
        loginViewController.viewModel = loginViewModel
        self.controller = loginViewController
    }
    
    func start() {
        controller.viewModel.loginCoordinatorDelegate = self
        presenter.pushViewController(controller, animated: true)
    }
}


extension LoginCoordinator: ViewControllerDelegate {
    func viewControllerHasFinished() {
        childCoordinators.removeAll()
        controller.removeFromParent()
        parentCoordinator?.childDidFinish(child: self)
    }
}
