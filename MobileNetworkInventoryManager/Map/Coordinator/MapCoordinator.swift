//
//  MapCoordinator.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit
import RxSwift

class MapCoordinator: NSObject, Coordinator {
    weak var parentCoordinator: ParentCoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    var presenter: UINavigationController
    let controller: MapViewController
    
    init(presenter: UINavigationController, userId: Int) {
        self.presenter = presenter
        let mapViewController = MapViewController()
        let mapViewModel = MapViewModel()
        mapViewModel.userId = userId
        mapViewController.viewModel = mapViewModel
        mapViewController.tabBarItem = UITabBarItem(title: R.string.localizable.map(), image: R.image.map(), selectedImage: R.image.map_filled())
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
        let viewModel = DetailsViewModel(dependecies: DetailsViewModel.Dependecies(subscribeScheduler: ConcurrentDispatchQueueScheduler(qos: .background), details: siteDetails, locationService: LocationService.instance, screenType: .site))
        let siteDetailsViewController = DetailsViewController(viewModel: viewModel)
        presenter.present(siteDetailsViewController, animated: true, completion: nil)
    }
}


extension MapCoordinator: CoordinatorDelegate {
    func viewControllerHasFinished() {
        childCoordinators.removeAll()
        controller.removeFromParent()
        parentCoordinator?.childDidFinish(child: self)
    }
}
