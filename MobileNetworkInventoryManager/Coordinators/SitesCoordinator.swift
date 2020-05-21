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
    let controller: SitesViewController
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
        let sitesViewController = SitesViewController()
        let sitesViewModel = SitesViewModel()
        sitesViewController.viewModel = sitesViewModel
        sitesViewController.tabBarItem = UITabBarItem(title: R.string.localizable.sites(), image: #imageLiteral(resourceName: "sites"), selectedImage: #imageLiteral(resourceName: "sites-filled"))
        sitesViewController.view.backgroundColor = .white
        sitesViewController.navigationItem.title = R.string.localizable.sites()
        self.controller = sitesViewController
    }
    
    func start() {
        setupNavigationBar()
        controller.viewModel.sitesCoordinatorDelegate = self
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
