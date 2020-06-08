//
//  UserViewController.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.


import UIKit
import RxSwift
import RxCocoa

class UserViewController: UIViewController {
    
    var viewModel: UserViewModel!
    private let disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        viewModel.initialize().disposed(by: disposeBag)
        viewModel.userRequest.onNext(())
        
    }
    
    @objc private func handleLogout() {
        viewModel.logout()
    }
    
    @objc private func handleRefresh() {
        viewModel.userRequest.onNext(())
    }
    
    private func setup() {
        navigationItem.setRightBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "logout"), style: .plain, target: self, action: #selector(handleLogout)), animated: true)
        navigationItem.setLeftBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "refresh"), style: .plain, target: self, action: #selector(handleRefresh)), animated: true)
        
        setObservers()
    }
    
    private func setObservers() {
        viewModel.fetchFinished.subscribe(onNext: { [weak self] in
            self?.configure()
        }).disposed(by: disposeBag)
        
        viewModel.alertOfError.subscribe(onNext: { [weak self] in
            let alert = getAlert(title: R.string.localizable.error_alert_title(), message: R.string.localizable.error_alert_message(), actionTitle: R.string.localizable.alert_ok_action())
            self?.present(alert, animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
    
    private func configure() {
        print(viewModel.userData!)
    }
    
}
