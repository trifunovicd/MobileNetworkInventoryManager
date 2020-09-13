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
        textField.isSecureTextEntry = true
        textField.rightViewMode = .always
        return textField
    }()
    
    private let togglePasswordButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.show(), for: .normal)
        button.setImage(R.image.hide(), for: .selected)
        button.addTarget(self, action: #selector(togglePassword), for: .touchUpInside)
        return button
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
    
    private let containerView: UIScrollView = {
        let view = UIScrollView()
        view.isScrollEnabled = false
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        return view
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
        unsubscribeFromKeyboardNotifications()
        printDeinit()
    }
    
    @objc private func login() {
        guard let username = usernameTextField.text, let password = passwordTextField.text else { return }
        viewModel.handleLogin(username: username, password: password)
    }
    
    @objc private func togglePassword() {
        togglePasswordButton.isSelected = !togglePasswordButton.isSelected
        passwordTextField.isSecureTextEntry.toggle()
        passwordTextField.becomeFirstResponder()
    }
    
    private func subscribeToKeyboardNotifications() {
       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func unsubscribeFromKeyboardNotifications() {
       NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
       NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
    }
}

private extension LoginViewController {
    func setupLayout() {
        view.backgroundColor = .white
        hideKeyboardWhenTappedAround()
        subscribeToKeyboardNotifications()
        
        let toggleButtonContainer = UIView()
        toggleButtonContainer.frame = CGRect(x: 0, y: 0, width: 30, height: 20)
        togglePasswordButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        toggleButtonContainer.addSubview(togglePasswordButton)
        passwordTextField.rightView = toggleButtonContainer
        
        contentView.addSubviews(avatarImageView, usernameTextField, passwordTextField, loginButton)
        containerView.addSubview(contentView)
        view.addSubview(containerView)
        setConstraints()
    }
    
    func setConstraints() {
        containerView.snp.makeConstraints { (maker) in
            maker.top.leading.trailing.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { (maker) in
            maker.top.leading.trailing.bottom.equalToSuperview()
            maker.centerX.centerY.equalToSuperview()
        }
        
        avatarImageView.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(100)
            maker.centerX.equalToSuperview()
            maker.height.width.equalTo(150)
        }
        
        usernameTextField.snp.makeConstraints { (maker) in
            maker.top.equalTo(avatarImageView.snp.bottom).offset(50)
            maker.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50))
            maker.height.equalTo(40)
        }
        
        passwordTextField.snp.makeConstraints { (maker) in
            maker.top.equalTo(usernameTextField.snp.bottom).offset(15)
            maker.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50))
            maker.height.equalTo(40)
        }
        
        loginButton.snp.makeConstraints { (maker) in
            maker.top.equalTo(passwordTextField.snp.bottom).offset(30)
            maker.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50))
            maker.height.equalTo(40)
        }
    }
}

private extension LoginViewController {
    private func initializeVM() {
        let input = LoginViewModel.Input(loginSubject: PublishSubject())
        let output = viewModel.transform(input: input)
        disposeBag.insert(output.disposables)
        initializeErrorObserver(for: output.alertOfError)
        initializeSpinnerObserver(for: output.spinnerSubject)
    }
    
    func initializeErrorObserver(for subject: PublishSubject<LoginError>) {
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
    
    func initializeSpinnerObserver(for subject: PublishSubject<Bool>) {
        subject
        .asDriver(onErrorJustReturn: false)
        .do(onNext: { [unowned self] shouldShow in
            if shouldShow {
                self.showSpinner(on: self.view)
            } else {
                self.removeSpinner()
            }
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
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nsString: NSString? = textField.text as NSString?
        let updatedString = nsString?.replacingCharacters(in: range, with: string)
        textField.text = updatedString

        //Setting the cursor at the right place
        let selectedRange = NSMakeRange(range.location + string.count, 0)
        let from = textField.position(from: textField.beginningOfDocument, offset: selectedRange.location)
        let to = textField.position(from: from!, offset:selectedRange.length)
        textField.selectedTextRange = textField.textRange(from: from!, to: to!)

        //Sending an action
        textField.sendActions(for: UIControl.Event.editingChanged)

        return false
    }
}

extension LoginViewController {
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            containerView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 15, right: 0)
            containerView.isScrollEnabled = true
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        containerView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        containerView.isScrollEnabled = false
    }
}
