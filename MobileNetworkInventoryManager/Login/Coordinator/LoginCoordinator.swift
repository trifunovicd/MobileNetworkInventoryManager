//
//  LoginCoordinator.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit
import RxSwift

public class LoginCoordinator: NSObject, Coordinator {
    weak var parentCoordinator: ParentCoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    var presenter: UINavigationController
    var controller: LoginViewController!
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
        super.init()
        self.controller = createController()
    }
    
    func start() {
        presenter.setNavigationBarHidden(true, animated: false)
        presenter.pushViewController(controller, animated: true)
    }
    
    deinit {
        printDeinit()
    }
}

extension LoginCoordinator {
    func createController() -> LoginViewController {
        let viewModel = LoginViewModel(dependecies: LoginViewModel.Dependecies(subscribeScheduler: ConcurrentDispatchQueueScheduler(qos: .background), loginCoordinatorDelegate: self, userRepository: UserRepositoryImpl()))
        return LoginViewController(viewModel: viewModel)
    }
}

extension LoginCoordinator: CoordinatorDelegate {
    func viewControllerHasFinished() {
        childCoordinators.removeAll()
        controller.removeFromParent()
        parentCoordinator?.childDidFinish(child: self)
    }
}
