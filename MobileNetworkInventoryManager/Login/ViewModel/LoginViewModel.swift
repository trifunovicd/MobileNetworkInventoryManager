//
//  LoginViewModel.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift

public class LoginViewModel: ViewModelType {
    
    public struct Input {
        let loginSubject: PublishSubject<(String, String)>
    }
    
    public struct Output {
        var disposables: [Disposable]
        let alertOfError: PublishSubject<LoginError>
        let spinnerSubject: PublishSubject<Bool>
    }
    
    public struct Dependecies {
        let subscribeScheduler: SchedulerType
        weak var loginCoordinatorDelegate: CoordinatorDelegate?
        let userRepository: UserRepository
    }
    
    public init(dependecies: Dependecies) {
        self.dependecies = dependecies
    }

    var input: Input!
    var output: Output!
    var dependecies: Dependecies

    public func transform(input: Input) -> Output {
        var disposables = [Disposable]()
        disposables.append(initializeLoginObserver(for: input.loginSubject))
        
        let output = Output(disposables: disposables, alertOfError: PublishSubject(), spinnerSubject: PublishSubject())
        
        self.input = input
        self.output = output
        
        return output
    }
    
    public func handleLogin(username: String, password: String) {
        if username.isEmpty || password.isEmpty {
            self.output.alertOfError.onNext(.missingFields)
        } else {
            self.input.loginSubject.onNext((username, password))
        }
    }
}

private extension LoginViewModel {
    func initializeLoginObserver(for subject: PublishSubject<(String, String)>) -> Disposable {
        return subject.flatMap {[unowned self] (username, password) -> Observable<DataWrapper<[Login]>> in
            self.output.spinnerSubject.onNext(true)
            return self.dependecies.userRepository.login(username: username, password: password)
        }
        .observeOn(MainScheduler.instance)
        .subscribeOn(dependecies.subscribeScheduler)
        .subscribe(onNext: { [unowned self] (dataWrapper) in
            self.output.spinnerSubject.onNext(false)
            guard let safeData = dataWrapper.data else {
                self.handleError(error: dataWrapper.error)
                return
            }
            if safeData.isEmpty {
                self.output.alertOfError.onNext(.failedLogin)
            } else {
                self.setLoggedUser(userId: safeData[0].user_id)
            }
        })
    }
    
    func setLoggedUser(userId: Int) {
        let loggedUser = LoggedUser()
        loggedUser.id = userId
        
        do {
            let realm = try Realm()
            
            try realm.write {
                realm.add(loggedUser, update: .modified)
            }
            
            self.dependecies.loginCoordinatorDelegate?.viewControllerHasFinished()
        } catch  {
            print(error)
        }
    }
    
    func handleError(error: Error?) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .canNotProcessData:
                self.output.alertOfError.onNext(.failedLoad(text: R.string.localizable.cannot_process_data()))
            case .noDataAvailable:
                self.output.alertOfError.onNext(.failedLoad(text: R.string.localizable.no_data_available()))
            case .notConnectedToInternet:
                self.output.alertOfError.onNext(.failedLoad(text: R.string.localizable.no_internet_connection()))
            }
        } else {
            self.output.alertOfError.onNext(.failedLoad(text: .empty))
        }
    }
}
