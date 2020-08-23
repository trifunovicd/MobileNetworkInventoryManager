//
//  TaskDetailsViewController.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 06/06/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MapKit

class TaskDetailsViewController: UIViewController {

    var viewModel: TaskDetailsViewModel!
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    private let userLocationButton: UIButton = {
        let button = UIButton()
        let image = #imageLiteral(resourceName: "gps").withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.setImage(#imageLiteral(resourceName: "gps-filled"), for: .highlighted)
        button.backgroundColor = .white
        button.tintColor = .systemBlue
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
        button.addTarget(self, action: #selector(showLocation(_:)), for: .touchUpInside)
        return button
    }()
    
    private let siteLocationButton: UIButton = {
        let button = UIButton()
        let image = #imageLiteral(resourceName: "marker").withRenderingMode(.alwaysTemplate)
        let selectedImage = #imageLiteral(resourceName: "marker-filled").withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.setImage(selectedImage, for: .highlighted)
        button.backgroundColor = .white
        button.tintColor = .systemRed
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
        button.addTarget(self, action: #selector(showLocation(_:)), for: .touchUpInside)
        return button
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        let image = #imageLiteral(resourceName: "close-modal").withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.black.withAlphaComponent(0.5)
        button.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let distanceView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.gray.cgColor
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let openingTimeLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.task_opening_time()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let openingTimeText: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let closingTimeLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.task_closing_time()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let closingTimeText: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let taskStatusLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.task_status()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let taskStatusText: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let taskCategoryLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.task_category()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let taskCategoryText: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let taskDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.task_description()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let taskDescriptionText: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let markLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.site_mark()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let markText: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.site_name()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameText: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.site_address()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addressText: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let techLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.site_tech()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let techText: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let powerLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.site_power()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let powerText: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let directionsLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.site_directions()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let directionsText: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let showSiteDetailsLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.show_site_details()
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let siteDetailsLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.site_details()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let hideSiteDetailsLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.hide_site_details()
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let siteDetailsView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        viewModel.viewLoaded.onNext(())
    }
    
    private func setup() {
        mapView.delegate = self
        
        let showTapGesture = UITapGestureRecognizer(target: self, action: #selector(siteDetailsAction(_:)))
        let hideTapGesture = UITapGestureRecognizer(target: self, action: #selector(siteDetailsAction(_:)))
        showSiteDetailsLabel.addGestureRecognizer(showTapGesture)
        hideSiteDetailsLabel.addGestureRecognizer(hideTapGesture)
        
        setupLayout()
        setObservers()
    }
    
    private func setupLayout() {
        view.backgroundColor = .white
        
        userLocationButton.frame = CGRect(origin: CGPoint(x: view.frame.width - 40, y: 255), size: CGSize(width: 35, height: 35))
        siteLocationButton.frame = CGRect(origin: CGPoint(x: view.frame.width - 40, y: 215), size: CGSize(width: 35, height: 35))
        mapView.addSubviews(userLocationButton, siteLocationButton)
        
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let containerScrollView = UIView()
        containerScrollView.backgroundColor = .white
        containerScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let siteDetailsStackView = UIStackView(arrangedSubviews: [showSiteDetailsLabel, siteDetailsLabel, siteDetailsView, hideSiteDetailsLabel])
        siteDetailsStackView.axis = .vertical
        siteDetailsStackView.spacing = 16
        siteDetailsStackView.backgroundColor = .white
        siteDetailsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        siteDetailsView.addSubviews(markLabel, markText, nameLabel, nameText, addressLabel, addressText, techLabel, techText, powerLabel, powerText, directionsLabel, directionsText)
        containerScrollView.addSubviews(openingTimeLabel, openingTimeText, closingTimeLabel, closingTimeText, taskStatusLabel, taskStatusText, taskCategoryLabel, taskCategoryText, taskDescriptionLabel, taskDescriptionText, siteDetailsStackView)
        scrollView.addSubview(containerScrollView)
        view.addSubviews(mapView, closeButton, distanceView, distanceLabel, scrollView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.heightAnchor.constraint(equalToConstant: 300),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            
            distanceView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            distanceView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            distanceView.trailingAnchor.constraint(equalTo: distanceLabel.trailingAnchor, constant: 8),
            
            distanceLabel.topAnchor.constraint(equalTo: distanceView.topAnchor, constant: 4),
            distanceLabel.leadingAnchor.constraint(equalTo: distanceView.leadingAnchor, constant: 8),
            distanceLabel.bottomAnchor.constraint(equalTo: distanceView.bottomAnchor, constant: -4),
            
            scrollView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 30),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerScrollView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerScrollView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerScrollView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerScrollView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerScrollView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            openingTimeLabel.topAnchor.constraint(equalTo: containerScrollView.topAnchor),
            openingTimeLabel.leadingAnchor.constraint(equalTo: containerScrollView.leadingAnchor, constant: 16),
            openingTimeLabel.trailingAnchor.constraint(equalTo: containerScrollView.trailingAnchor, constant: -16),
            
            openingTimeText.topAnchor.constraint(equalTo: openingTimeLabel.bottomAnchor, constant: 8),
            openingTimeText.leadingAnchor.constraint(equalTo: containerScrollView.leadingAnchor, constant: 16),
            openingTimeText.trailingAnchor.constraint(equalTo: containerScrollView.trailingAnchor, constant: -16),
            
            closingTimeLabel.topAnchor.constraint(equalTo: openingTimeText.bottomAnchor, constant: 16),
            closingTimeLabel.leadingAnchor.constraint(equalTo: containerScrollView.leadingAnchor, constant: 16),
            closingTimeLabel.trailingAnchor.constraint(equalTo: containerScrollView.trailingAnchor, constant: -16),
            
            closingTimeText.topAnchor.constraint(equalTo: closingTimeLabel.bottomAnchor, constant: 8),
            closingTimeText.leadingAnchor.constraint(equalTo: containerScrollView.leadingAnchor, constant: 16),
            closingTimeText.trailingAnchor.constraint(equalTo: containerScrollView.trailingAnchor, constant: -16),
            
            taskStatusLabel.topAnchor.constraint(equalTo: closingTimeText.bottomAnchor, constant: 16),
            taskStatusLabel.leadingAnchor.constraint(equalTo: containerScrollView.leadingAnchor, constant: 16),
            taskStatusLabel.trailingAnchor.constraint(equalTo: containerScrollView.trailingAnchor, constant: -16),
            
            taskStatusText.topAnchor.constraint(equalTo: taskStatusLabel.bottomAnchor, constant: 8),
            taskStatusText.leadingAnchor.constraint(equalTo: containerScrollView.leadingAnchor, constant: 16),
            taskStatusText.trailingAnchor.constraint(equalTo: containerScrollView.trailingAnchor, constant: -16),
            
            taskCategoryLabel.topAnchor.constraint(equalTo: taskStatusText.bottomAnchor, constant: 16),
            taskCategoryLabel.leadingAnchor.constraint(equalTo: containerScrollView.leadingAnchor, constant: 16),
            taskCategoryLabel.trailingAnchor.constraint(equalTo: containerScrollView.trailingAnchor, constant: -16),
            
            taskCategoryText.topAnchor.constraint(equalTo: taskCategoryLabel.bottomAnchor, constant: 8),
            taskCategoryText.leadingAnchor.constraint(equalTo: containerScrollView.leadingAnchor, constant: 16),
            taskCategoryText.trailingAnchor.constraint(equalTo: containerScrollView.trailingAnchor, constant: -16),
            
            taskDescriptionLabel.topAnchor.constraint(equalTo: taskCategoryText.bottomAnchor, constant: 16),
            taskDescriptionLabel.leadingAnchor.constraint(equalTo: containerScrollView.leadingAnchor, constant: 16),
            taskDescriptionLabel.trailingAnchor.constraint(equalTo: containerScrollView.trailingAnchor, constant: -16),
            
            taskDescriptionText.topAnchor.constraint(equalTo: taskDescriptionLabel.bottomAnchor, constant: 8),
            taskDescriptionText.leadingAnchor.constraint(equalTo: containerScrollView.leadingAnchor, constant: 16),
            taskDescriptionText.trailingAnchor.constraint(equalTo: containerScrollView.trailingAnchor, constant: -16),
            
            siteDetailsStackView.topAnchor.constraint(equalTo: taskDescriptionText.bottomAnchor, constant: 30),
            siteDetailsStackView.leadingAnchor.constraint(equalTo: containerScrollView.leadingAnchor, constant: 16),
            siteDetailsStackView.trailingAnchor.constraint(equalTo: containerScrollView.trailingAnchor, constant: -16),
            siteDetailsStackView.bottomAnchor.constraint(equalTo: containerScrollView.bottomAnchor, constant: -30),
            
            markLabel.topAnchor.constraint(equalTo: siteDetailsView.topAnchor),
            markLabel.leadingAnchor.constraint(equalTo: siteDetailsView.leadingAnchor),
            markLabel.trailingAnchor.constraint(equalTo: siteDetailsView.trailingAnchor),
            
            markText.topAnchor.constraint(equalTo: markLabel.bottomAnchor, constant: 8),
            markText.leadingAnchor.constraint(equalTo: siteDetailsView.leadingAnchor),
            markText.trailingAnchor.constraint(equalTo: siteDetailsView.trailingAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: markText.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: siteDetailsView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: siteDetailsView.trailingAnchor),
            
            nameText.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nameText.leadingAnchor.constraint(equalTo: siteDetailsView.leadingAnchor),
            nameText.trailingAnchor.constraint(equalTo: siteDetailsView.trailingAnchor),
            
            addressLabel.topAnchor.constraint(equalTo: nameText.bottomAnchor, constant: 16),
            addressLabel.leadingAnchor.constraint(equalTo: siteDetailsView.leadingAnchor),
            addressLabel.trailingAnchor.constraint(equalTo: siteDetailsView.trailingAnchor),
            
            addressText.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 8),
            addressText.leadingAnchor.constraint(equalTo: siteDetailsView.leadingAnchor),
            addressText.trailingAnchor.constraint(equalTo: siteDetailsView.trailingAnchor),
            
            techLabel.topAnchor.constraint(equalTo: addressText.bottomAnchor, constant: 16),
            techLabel.leadingAnchor.constraint(equalTo: siteDetailsView.leadingAnchor),
            techLabel.trailingAnchor.constraint(equalTo: siteDetailsView.trailingAnchor),
            
            techText.topAnchor.constraint(equalTo: techLabel.bottomAnchor, constant: 8),
            techText.leadingAnchor.constraint(equalTo: siteDetailsView.leadingAnchor),
            techText.trailingAnchor.constraint(equalTo: siteDetailsView.trailingAnchor),
            
            powerLabel.topAnchor.constraint(equalTo: techText.bottomAnchor, constant: 16),
            powerLabel.leadingAnchor.constraint(equalTo: siteDetailsView.leadingAnchor),
            powerLabel.trailingAnchor.constraint(equalTo: siteDetailsView.trailingAnchor),
            
            powerText.topAnchor.constraint(equalTo: powerLabel.bottomAnchor, constant: 8),
            powerText.leadingAnchor.constraint(equalTo: siteDetailsView.leadingAnchor),
            powerText.trailingAnchor.constraint(equalTo: siteDetailsView.trailingAnchor),
            
            directionsLabel.topAnchor.constraint(equalTo: powerText.bottomAnchor, constant: 16),
            directionsLabel.leadingAnchor.constraint(equalTo: siteDetailsView.leadingAnchor),
            directionsLabel.trailingAnchor.constraint(equalTo: siteDetailsView.trailingAnchor),
            
            directionsText.topAnchor.constraint(equalTo: directionsLabel.bottomAnchor, constant: 8),
            directionsText.leadingAnchor.constraint(equalTo: siteDetailsView.leadingAnchor),
            directionsText.trailingAnchor.constraint(equalTo: siteDetailsView.trailingAnchor),
            directionsText.bottomAnchor.constraint(equalTo: siteDetailsView.bottomAnchor)
        ])
    }
    
    private func setObservers() {
        viewModel.viewLoaded.subscribe(onNext: { [weak self] in
            self?.configure()
        }).disposed(by: disposeBag)
        
        viewModel.addSiteMarker.subscribe(onNext: { [weak self] in
            self?.addSiteMarker()
        }).disposed(by: disposeBag)
        
        viewModel.centerMapView.subscribe(onNext: { [weak self] coordinate in
            self?.centerMapView(coordinate: coordinate)
        }).disposed(by: disposeBag)
        
        viewModel.updateDistance.subscribe(onNext: { [weak self] coordinate in
            self?.updateDistance(coordinate: coordinate)
        }).disposed(by: disposeBag)
        
        viewModel.siteDetailsAction.subscribe(onNext: { [weak self] shouldShow in
            self?.handleShowSiteDetails(shouldShow: shouldShow)
        }).disposed(by: disposeBag)
        
        viewModel.closeModal.subscribe(onNext: { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
    
    @objc private func closeModal() {
        viewModel.closeModal.onNext(())
    }
    
    @objc private func showLocation(_ sender: UIButton) {
        if sender == siteLocationButton {
            let coordinate = CLLocationCoordinate2D(latitude: viewModel.taskDetails.siteLat, longitude: viewModel.taskDetails.siteLng)
            viewModel.centerMapView.onNext(coordinate)
            viewModel.shouldFollowUser = false
        }
        else {
            guard let coordinate = viewModel.locationService.locationManager.location?.coordinate else { return }
            viewModel.centerMapView.onNext(coordinate)
            viewModel.shouldFollowUser = true
        }
    }
    
    @objc private func siteDetailsAction(_ sender: UIGestureRecognizer) {
        if let view = sender.view as? UILabel, view == showSiteDetailsLabel {
            viewModel.siteDetailsAction.onNext(true)
        }
        else {
            viewModel.siteDetailsAction.onNext(false)
        }
    }
    
    private func handleShowSiteDetails(shouldShow: Bool) {
        if shouldShow {
            hideSiteDetailsLabel.alpha = 0
            siteDetailsView.alpha = 0
            siteDetailsLabel.textColor = .darkText
            
            showSiteDetailsLabel.isHidden = true
            siteDetailsLabel.isHidden = false
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .showHideTransitionViews, animations: {
                self.siteDetailsView.isHidden = false
                self.hideSiteDetailsLabel.isHidden = false
                self.siteDetailsView.alpha = 1
                self.hideSiteDetailsLabel.alpha = 1
            }, completion: nil)
        }
        else {
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .showHideTransitionViews, animations: {
                self.hideSiteDetailsLabel.alpha = 0
                self.siteDetailsView.alpha = 0
                self.hideSiteDetailsLabel.isHidden = true
                self.siteDetailsView.isHidden = true
                self.siteDetailsLabel.textColor = .white
            }, completion: { _ in
                self.siteDetailsLabel.isHidden = true
                self.showSiteDetailsLabel.isHidden = false
            })
        }
    }
    
    private func configure() {
        distanceLabel.text = viewModel.taskDetails.siteDistance.getDistanceString()
        openingTimeText.text = !viewModel.taskDetails.taskOpeningTime.isEmpty ? viewModel.taskDetails.taskOpeningTime : "-"
        closingTimeText.text = !viewModel.taskDetails.taskClosingTime.isEmpty ? viewModel.taskDetails.taskClosingTime : "-"
        taskStatusText.text = viewModel.taskDetails.taskStatusName
        taskCategoryText.text = viewModel.taskDetails.taskCategoryName
        taskDescriptionText.text = viewModel.taskDetails.taskDescription
        markText.text = viewModel.taskDetails.siteMark
        nameText.text = viewModel.taskDetails.siteName
        addressText.text = viewModel.taskDetails.siteAddress
        techText.text = viewModel.taskDetails.siteTechnology
        powerText.text = viewModel.taskDetails.sitePowerSupply
        directionsText.text = viewModel.taskDetails.siteDirections
        
        viewModel.addSiteMarker.onNext(())
    }
    
    private func addSiteMarker() {
        let siteLocation = MKPointAnnotation()
        siteLocation.title = viewModel.taskDetails.siteName
        siteLocation.coordinate = CLLocationCoordinate2D(latitude: viewModel.taskDetails.siteLat, longitude: viewModel.taskDetails.siteLng)
        mapView.addAnnotation(siteLocation)
        
        viewModel.centerMapView.onNext(siteLocation.coordinate)
    }
    
    private func centerMapView(coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(region, animated: true)
    }
    
    private func updateDistance(coordinate: CLLocationCoordinate2D) {
        let distance = getDistance(userLocation: (coordinate.latitude, coordinate.longitude), siteLocation: (viewModel.taskDetails.siteLat, viewModel.taskDetails.siteLng))
        distanceLabel.text = distance.getDistanceString()
    }
    
}


extension TaskDetailsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "SiteLocationAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }

        return annotationView
    }
}
