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
    var controller: MapViewController!
    
    init(presenter: UINavigationController, userId: Int) {
        self.presenter = presenter
        super.init()
        self.controller = createController(userId: userId)
        self.controller.tabBarItem = UITabBarItem(title: R.string.localizable.map(), image: R.image.map(), selectedImage: R.image.map_filled())
    }
    
    func start() {
        presenter.setupNavigationBar(barTintColor: .systemBlue, titleTextAttributes: [.foregroundColor: UIColor.white], tintColor: .white, barStyle: .black, isTranslucent: false)
        presenter.pushViewController(controller, animated: true)
    }
    
    deinit {
        printDeinit()
    }
}

extension MapCoordinator {
    func createController(userId: Int) -> MapViewController {
        let viewModel = MapViewModel(dependecies: MapViewModel.Dependecies(subscribeScheduler: ConcurrentDispatchQueueScheduler(qos: .background), coordinatorDelegate: self, mapCoordinatorDelegate: self, userRepository: UserRepositoryImpl(), siteRepository: SiteRepositoryImpl(), locationService: LocationService.instance, userId: userId))
        return MapViewController(viewModel: viewModel)
    }
}

extension MapCoordinator: SiteDetailsDelegate {
    func openSiteDetails(siteDetails: SiteDetails) {
        let viewModel = DetailsViewModel(dependecies: DetailsViewModel.Dependecies(subscribeScheduler: ConcurrentDispatchQueueScheduler(qos: .background), taskRepository: TaskRepositoryImpl(), details: siteDetails, locationService: LocationService.instance, screenType: .site))
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
