//
//  LoginViewController.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

public class LoginViewController: UIViewController, AlertView {
    
    let viewModel: LoginViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let avatarImageView: UIImageView = {
        let view = UIImageView(image: R.image.avatar())
        return view
    }()
    
    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = R.string.localizable.username()
        textField.backgroundColor = .white
        textField.setLeftPaddingPoints(10)
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.gray.cgColor
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = R.string.localizable.password()
        textField.backgroundColor = .white
        textField.setLeftPaddingPoints(10)
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.gray.cgColor
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.login(), for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(login), for: .touchUpInside)
        return button
    }()
    
    public init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        initializeVM()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    deinit {
        printDeinit()
    }
    
    @objc func login() {
        guard let username = usernameTextField.text, let password = passwordTextField.text else { return }
        viewModel.handleLogin(username: username, password: password)
    }
}

private extension LoginViewController {
    func setupLayout() {
        view.backgroundColor = .white
        hideKeyboardWhenTappedAround()
        view.addSubviews(avatarImageView, usernameTextField, passwordTextField, loginButton)
        setConstraints()
    }
    
    func setConstraints() {
        avatarImageView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(100)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(150)
        }
        
        usernameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(avatarImageView.snp.bottom).offset(50)
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50))
            make.height.equalTo(40)
        }
        
        passwordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(usernameTextField.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50))
            make.height.equalTo(40)
        }
        
        loginButton.snp.makeConstraints { (make) in
            make.top.equalTo(passwordTextField.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50))
            make.height.equalTo(40)
        }
    }
}

private extension LoginViewController {
    private func initializeVM() {
        let input = LoginViewModel.Input(loginSubject: PublishSubject())
        let output = viewModel.transform(input: input)
        disposeBag.insert(output.disposables)
        initializeErrorObserver(for: output.alertOfError)
    }
    
    func initializeErrorObserver(for subject: PublishSubject<LoginError>){
        subject
            .asDriver(onErrorJustReturn: .failedLoad(text: .empty))
        .do(onNext: { [unowned self] (error) in
            let alert: UIAlertController
            
            switch error {
            case .failedLoad(let text):
                alert = self.getAlert(title: R.string.localizable.error_alert_title(), message: R.string.localizable.error_alert_message(text), actionTitle: R.string.localizable.alert_ok_action())
            case .failedLogin:
                alert = self.getAlert(title: R.string.localizable.failed_login_alert_title(), message: R.string.localizable.failed_login_alert_message(), actionTitle: R.string.localizable.alert_ok_action())
            case .missingFields:
                alert = self.getAlert(title: R.string.localizable.missing_data_alert_title(), message: R.string.localizable.missing_data_alert_message(), actionTitle: R.string.localizable.alert_ok_action())
            }
            
            self.present(alert, animated: true, completion: nil)
        })
        .drive()
        .disposed(by: disposeBag)
    }
}

extension LoginViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        login()
        return true
    }
}
