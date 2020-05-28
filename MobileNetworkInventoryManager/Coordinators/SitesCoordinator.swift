//
//  SitesCoordinator.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit

class SitesCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var presenter: UINavigationController
    let controller: SitesTableViewController
    
    init(presenter: UINavigationController, userId: Int) {
        self.presenter = presenter
        let sitesViewController = SitesTableViewController()
        let sitesViewModel = SitesViewModel()
        sitesViewModel.userId = userId
        sitesViewController.viewModel = sitesViewModel
        sitesViewController.tabBarItem = UITabBarItem(title: R.string.localizable.sites(), image: #imageLiteral(resourceName: "sites"), selectedImage: #imageLiteral(resourceName: "sites-filled"))
        sitesViewController.view.backgroundColor = .white
        sitesViewController.navigationItem.title = R.string.localizable.sites()
        self.controller = sitesViewController
    }
    
    func start() {
        presenter.setupNavigationBar(barTintColor: .systemBlue, titleTextAttributes: [.foregroundColor: UIColor.white], tintColor: .white, barStyle: .black, isTranslucent: false)
        controller.viewModel.sitesCoordinatorDelegate = self
        presenter.pushViewController(controller, animated: true)
    }
}
