//
//  MapCoordinator.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit

class MapCoordinator: Coordinator {
    weak var parentCoordinator: CoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    var presenter: UINavigationController
    let controller: MapViewController
    
    init(presenter: UINavigationController, userId: Int) {
        self.presenter = presenter
        let mapViewController = MapViewController()
        let mapViewModel = MapViewModel()
        mapViewModel.userId = userId
        mapViewController.viewModel = mapViewModel
        mapViewController.tabBarItem = UITabBarItem(title: R.string.localizable.map(), image: #imageLiteral(resourceName: "map"), selectedImage: #imageLiteral(resourceName: "map-filled"))
        mapViewController.view.backgroundColor = .white
        mapViewController.navigationItem.title = R.string.localizable.map()
        self.controller = mapViewController
    }
    
    func start() {
        presenter.setupNavigationBar(barTintColor: .systemBlue, titleTextAttributes: [.foregroundColor: UIColor.white], tintColor: .white, barStyle: .black, isTranslucent: false)
        controller.viewModel.mapCoordinatorDelegate = self
        presenter.pushViewController(controller, animated: true)
    }
}


extension MapCoordinator: SiteDetailsDelegate {
    func openSiteDetails(siteDetails: SiteDetails) {
        let siteDetailsViewController = SiteDetailsViewController()
        let siteDetailsViewModel = SiteDetailsViewModel()
        siteDetailsViewModel.siteDetails = siteDetails
        siteDetailsViewController.viewModel = siteDetailsViewModel
        presenter.present(siteDetailsViewController, animated: true, completion: nil)
    }
}


extension MapCoordinator: ViewControllerDelegate {
    func viewControllerHasFinished() {
        childCoordinators.removeAll()
        controller.removeFromParent()
        parentCoordinator?.childDidFinish(child: self)
    }
}
