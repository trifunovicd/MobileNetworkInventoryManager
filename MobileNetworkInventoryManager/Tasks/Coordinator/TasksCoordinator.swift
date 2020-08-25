//
//  TasksCoordinator.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit
import RxSwift

class TasksCoordinator: NSObject, Coordinator {
    weak var parentCoordinator: ParentCoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    var presenter: UINavigationController
    var controller: TasksViewController!
    
    init(presenter: UINavigationController, userId: Int) {
        self.presenter = presenter
        super.init()
        self.controller = createController(userId: userId)
        self.controller.tabBarItem = UITabBarItem(title: R.string.localizable.tasks(), image: R.image.tasks(), selectedImage: R.image.tasks_filled())
    }
    
    func start() {
        presenter.setupNavigationBar(barTintColor: .systemBlue, titleTextAttributes: [.foregroundColor: UIColor.white], tintColor: .white, barStyle: .black, isTranslucent: false)
        presenter.pushViewController(controller, animated: true)
    }
    
    deinit {
        printDeinit()
    }
}

extension TasksCoordinator {
    func createController(userId: Int) -> TasksViewController {
        let viewModel = TasksViewModel(dependecies: TasksViewModel.Dependecies(subscribeScheduler: ConcurrentDispatchQueueScheduler(qos: .background), coordinatorDelegate: self, taskDetailsDelegate: self, userRepository: UserRepositoryImpl(), taskRepository: TaskRepositoryImpl(), userId: userId))
        return TasksViewController(viewModel: viewModel)
    }
}

extension TasksCoordinator: TaskDetailsDelegate {
    func openTaskDetails(taskDetails: TaskDetails) {
        let viewModel = DetailsViewModel(dependecies: DetailsViewModel.Dependecies(subscribeScheduler: ConcurrentDispatchQueueScheduler(qos: .background), details: taskDetails, locationService: LocationService.instance, screenType: .task))
        let taskDetailsViewController = DetailsViewController(viewModel: viewModel)
        presenter.present(taskDetailsViewController, animated: true, completion: nil)
    }
}

extension TasksCoordinator: CoordinatorDelegate {
    func viewControllerHasFinished() {
        childCoordinators.removeAll()
        controller.removeFromParent()
        parentCoordinator?.childDidFinish(child: self)
    }
}
