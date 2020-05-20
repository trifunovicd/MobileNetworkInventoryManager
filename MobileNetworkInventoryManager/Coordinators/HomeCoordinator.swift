//
//  HomeCoordinator.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit

class HomeCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var presenter: UINavigationController
    let controller: HomeViewController
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
        let homeViewController = HomeViewController()
        let homeViewModel = HomeViewModel()
        homeViewController.viewModel = homeViewModel
        self.controller = homeViewController
    }
    
    func start() {
        controller.viewModel.homeCoordinatorDelegate = self
        presenter.pushViewController(controller, animated: true)
    }
}
