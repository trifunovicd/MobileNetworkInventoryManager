//
//  SitesCoordinator.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit
import RxSwift

public class SitesCoordinator: NSObject, Coordinator {
    weak var parentCoordinator: ParentCoordinatorDelegate?
    public var childCoordinators: [Coordinator] = []
    public var presenter: UINavigationController
    var controller: SitesTableViewController!
    
    init(presenter: UINavigationController, userId: Int) {
        self.presenter = presenter
        super.init()
        self.controller = createController(userId: userId)
        self.controller.tabBarItem = UITabBarItem(title: R.string.localizable.sites(), image: R.image.sites(), selectedImage: R.image.sites_filled())
    }
    
    public func start() {
        presenter.setupNavigationBar(barTintColor: .systemBlue, titleTextAttributes: [.foregroundColor: UIColor.white], tintColor: .white, barStyle: .black, isTranslucent: false)
        presenter.pushViewController(controller, animated: true)
    }
    
    deinit {
        printDeinit()
    }
}

extension SitesCoordinator {
    func createController(userId: Int) -> SitesTableViewController {
        let viewModel = SitesViewModel(dependecies: SitesViewModel.Dependecies(subscribeScheduler: ConcurrentDispatchQueueScheduler(qos: .background), coordinatorDelegate: self, siteDetailsDelegate: self, userRepository: UserRepositoryImpl(), siteRepository: SiteRepositoryImpl(), userId: userId))
        return SitesTableViewController(viewModel: viewModel)
    }
}

extension SitesCoordinator: SiteDetailsDelegate {
    public func openSiteDetails(siteDetails: SiteDetails) {
        let viewModel = DetailsViewModel(dependecies: DetailsViewModel.Dependecies(subscribeScheduler: ConcurrentDispatchQueueScheduler(qos: .background), details: siteDetails, locationService: LocationService.instance, screenType: .site))
        let siteDetailsViewController = DetailsViewController(viewModel: viewModel)
        presenter.present(siteDetailsViewController, animated: true, completion: nil)
    }
}

extension SitesCoordinator: CoordinatorDelegate {
    public func viewControllerHasFinished() {
        childCoordinators.removeAll()
        controller.removeFromParent()
        parentCoordinator?.childDidFinish(child: self)
    }
}
