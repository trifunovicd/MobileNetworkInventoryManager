//
//  SortView.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 01/06/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class SortView: NSObject {
    
    let viewModel: SortViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let transparentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        return view
    }()
    
    private let sortLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20)
        label.text = R.string.localizable.sort()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton()
        let image = #imageLiteral(resourceName: "done").withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        let image = #imageLiteral(resourceName: "close").withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let pickerHeader: UIView = {
        let header = UIView()
        header.backgroundColor = .systemBlue
        return header
    }()
    
    private let picker: UIPickerView = {
        let picker = UIPickerView()
        picker.showsSelectionIndicator = true
        picker.selectRow(0, inComponent: 0, animated: false)
        picker.backgroundColor = .white
        return picker
    }()
    
    private lazy var container: UIStackView = {
        let container = UIStackView(arrangedSubviews: [pickerHeader, picker])
        container.axis = .vertical
        return container
    }()
    
    public init(viewModel: SortViewModel) {
        self.viewModel = viewModel
        super.init()
        setup()
        initializeVM()
        viewModel.input.loadDataSubject.onNext(())
    }
    
    deinit {
        printDeinit()
    }
    
    func show() {
        viewModel.output.showView.onNext(true)
    }
}

private extension SortView {
    func setup() {
        picker.delegate = self
        picker.dataSource = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hide))
        transparentView.addGestureRecognizer(tapGesture)
        closeButton.addTarget(self, action: #selector(hide), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(saveChanges), for: .touchUpInside)
        
        setupLayout()
    }
    
    func setupLayout() {
        pickerHeader.addSubviews(sortLabel, doneButton, closeButton)
        setConstraints()
    }
    
    func setConstraints() {
        sortLabel.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.top.bottom.equalToSuperview().inset(8)
        }
        
        doneButton.snp.makeConstraints { (maker) in
            maker.centerY.equalToSuperview()
            maker.trailing.equalToSuperview().offset(-16)
            maker.height.width.equalTo(20)
        }
        
        closeButton.snp.makeConstraints { (maker) in
            maker.centerY.equalToSuperview()
            maker.leading.equalToSuperview().offset(16)
            maker.height.width.equalTo(20)
        }
    }
}

private extension SortView {
    func initializeVM() {
        let input = SortViewModel.Input(loadDataSubject: ReplaySubject.create(bufferSize: 1))
        let output = viewModel.transform(input: input)
        disposeBag.insert(output.disposables)
        initializeShowViewObserver(for: output.showView)
    }
    
    func initializeShowViewObserver(for subject: PublishSubject<Bool>) {
        subject
        .asDriver(onErrorJustReturn: false)
        .do(onNext: { [unowned self] shouldShow in
            if shouldShow {
                self.showView()
            } else {
                self.hideView()
            }
        })
        .drive()
        .disposed(by: disposeBag)
    }
}

private extension SortView {
    
    @objc func hide() {
        viewModel.output.showView.onNext(false)
    }
    
    @objc func saveChanges() {
        viewModel.dependecies.delegate?.sortBy(value: picker.selectedRow(inComponent: 0), order: picker.selectedRow(inComponent: 1))
        hide()
    }
    
    func showView() {
        picker.selectRow(viewModel.output.settings.value, inComponent: 0, animated: false)
        picker.selectRow(viewModel.output.settings.order, inComponent: 1, animated: false)
        
        transparentView.frame = viewModel.dependecies.frame
        viewModel.output.window?.addSubview(transparentView)
        
        container.frame = CGRect(x: 0, y: viewModel.output.screenSize.height, width: viewModel.output.screenSize.width, height: viewModel.output.height)
        viewModel.output.window?.addSubview(container)
        
        transparentView.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.8
            self.container.frame = CGRect(x: 0, y: self.viewModel.output.screenSize.height - self.viewModel.output.height, width: self.viewModel.output.screenSize.width, height: self.viewModel.output.height)
        }, completion: nil)
    }
    
    func hideView() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.container.frame = CGRect(x: 0, y: self.viewModel.output.screenSize.height, width: self.viewModel.output.screenSize.width, height: self.viewModel.output.height)
        }, completion: { _ in
            self.container.removeFromSuperview()
            self.transparentView.removeFromSuperview()
        })
    }
}

extension SortView: UIPickerViewDelegate, UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return viewModel.output.itemsArray.count
        } else {
            return viewModel.output.orderArray.count
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return viewModel.output.itemsArray[row]
        } else {
            return viewModel.output.orderArray[row]
        }
    }
}
