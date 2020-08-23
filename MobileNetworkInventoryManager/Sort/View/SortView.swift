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

class SortView: NSObject {
    
    var viewModel: SortViewModel!
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
    
    init(viewModel: SortViewModel) {
        super.init()
        
        self.viewModel = viewModel
        
        picker.delegate = self
        picker.dataSource = self
        
        setup()
        setObservers()
    }
    
    func show() {
        viewModel.showView.onNext(())
    }
    
    private func setup() {
        pickerHeader.addSubviews(sortLabel, doneButton, closeButton)
        
        NSLayoutConstraint.activate([
            sortLabel.centerXAnchor.constraint(equalTo: pickerHeader.centerXAnchor),
            sortLabel.topAnchor.constraint(equalTo: pickerHeader.topAnchor, constant: 8),
            sortLabel.bottomAnchor.constraint(equalTo: pickerHeader.bottomAnchor, constant: -8),
            
            doneButton.centerYAnchor.constraint(equalTo: pickerHeader.centerYAnchor),
            doneButton.trailingAnchor.constraint(equalTo: pickerHeader.trailingAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 20),
            doneButton.widthAnchor.constraint(equalToConstant: 20),
            
            closeButton.centerYAnchor.constraint(equalTo: pickerHeader.centerYAnchor),
            closeButton.leadingAnchor.constraint(equalTo: pickerHeader.leadingAnchor, constant: 16),
            closeButton.heightAnchor.constraint(equalToConstant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 20)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hide))
        transparentView.addGestureRecognizer(tapGesture)
        closeButton.addTarget(self, action: #selector(hide), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(saveChanges), for: .touchUpInside)
    }
    
    private func setObservers() {
        viewModel.showView.subscribe(onNext: { [weak self] in
            self?.showView()
        }).disposed(by: disposeBag)
        
        viewModel.hideView.subscribe(onNext: { [weak self] in
            self?.hideView()
        }).disposed(by: disposeBag)
    }

    private func showView() {
        picker.selectRow(viewModel.settings.value, inComponent: 0, animated: false)
        picker.selectRow(viewModel.settings.order, inComponent: 1, animated: false)
        
        transparentView.frame = viewModel.frame
        viewModel.window?.addSubview(transparentView)
        
        container.frame = CGRect(x: 0, y: viewModel.screenSize.height, width: viewModel.screenSize.width, height: viewModel.height)
        viewModel.window?.addSubview(container)
        
        transparentView.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.8
            self.container.frame = CGRect(x: 0, y: self.viewModel.screenSize.height - self.viewModel.height, width: self.viewModel.screenSize.width, height: self.viewModel.height)
        }, completion: nil)
    }
    
    private func hideView() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.container.frame = CGRect(x: 0, y: self.viewModel.screenSize.height, width: self.viewModel.screenSize.width, height: self.viewModel.height)
        }, completion: { _ in
            self.container.removeFromSuperview()
            self.transparentView.removeFromSuperview()
        })
    }
    
    @objc private func hide() {
        viewModel.hideView.onNext(())
    }
    
    @objc private func saveChanges() {
        viewModel.delegate?.sortBy(value: picker.selectedRow(inComponent: 0), order: picker.selectedRow(inComponent: 1))
        hide()
    }
}

extension SortView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return viewModel.itemsArray.count
        }
        else {
            return viewModel.orderArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return viewModel.itemsArray[row]
        }
        else {
            return viewModel.orderArray[row]
        }
    }
    
}
