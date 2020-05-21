//
//  MapCoordinator.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit

class MapCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var presenter: UINavigationController
    let controller: MapViewController
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
        let mapViewController = MapViewController()
        let mapViewModel = MapViewModel()
        mapViewController.viewModel = mapViewModel
        mapViewController.tabBarItem = UITabBarItem(title: R.string.localizable.map(), image: #imageLiteral(resourceName: "map"), selectedImage: #imageLiteral(resourceName: "map-filled"))
        mapViewController.view.backgroundColor = .white
        mapViewController.navigationItem.title = R.string.localizable.map()
        self.controller = mapViewController
    }
    
    func start() {
        setupNavigationBar()
        controller.viewModel.mapCoordinatorDelegate = self
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
