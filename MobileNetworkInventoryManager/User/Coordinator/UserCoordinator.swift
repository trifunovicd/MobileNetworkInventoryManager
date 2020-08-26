//
//  UserCoordinator.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit
import RxSwift

class UserCoordinator: NSObject, Coordinator {
    weak var parentCoordinator: ParentCoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    var presenter: UINavigationController
    var controller: UserViewController!
    
    init(presenter: UINavigationController, userId: Int) {
        self.presenter = presenter
        super.init()
        self.controller = createController(userId: userId)
        self.controller.tabBarItem = UITabBarItem(title: R.string.localizable.user(), image: R.image.user(), selectedImage: R.image.user_filled())
    }
    
    func start() {
        presenter.setupNavigationBar(barTintColor: .systemBlue, titleTextAttributes: [.foregroundColor: UIColor.white], tintColor: .white, barStyle: .black, isTranslucent: false)
        presenter.pushViewController(controller, animated: true)
    }
    
    deinit {
        printDeinit()
    }
}

extension UserCoordinator {
    func createController(userId: Int) -> UserViewController {
        let viewModel = UserViewModel(dependecies: UserViewModel.Dependecies(subscribeScheduler: ConcurrentDispatchQueueScheduler(qos: .background), coordinatorDelegate: self, userRepository: UserRepositoryImpl(), locationService: LocationService.instance, userId: userId))
        return UserViewController(viewModel: viewModel)
    }
}

extension UserCoordinator: CoordinatorDelegate {
    func viewControllerHasFinished() {
        childCoordinators.removeAll()
        controller.removeFromParent()
        parentCoordinator?.childDidFinish(child: self)
    }
}
