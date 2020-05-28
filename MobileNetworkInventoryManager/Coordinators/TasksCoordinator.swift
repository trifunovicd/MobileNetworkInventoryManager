//
//  TasksCoordinator.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit

class TasksCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var presenter: UINavigationController
    let controller: TasksViewController
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
        let tasksViewController = TasksViewController()
        let tasksViewModel = TasksViewModel()
        tasksViewController.viewModel = tasksViewModel
        tasksViewController.tabBarItem = UITabBarItem(title: R.string.localizable.tasks(), image: #imageLiteral(resourceName: "tasks"), selectedImage: #imageLiteral(resourceName: "tasks-filled"))
        tasksViewController.view.backgroundColor = .white
        tasksViewController.navigationItem.title = R.string.localizable.tasks()
        self.controller = tasksViewController
    }
    
    func start() {
        presenter.setupNavigationBar(barTintColor: .systemBlue, titleTextAttributes: [.foregroundColor: UIColor.white], tintColor: .white, barStyle: .black, isTranslucent: false)
        controller.viewModel.tasksCoordinatorDelegate = self
        presenter.pushViewController(controller, animated: true)
    }
}
