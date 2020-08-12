//
//  UserViewController.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.


import UIKit
import RxSwift
import RxCocoa
import MapKit

class UserViewController: UIViewController {
    
    var viewModel: UserViewModel!
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let mapView: MKMapView = {
        let mapView = MKMapView()
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
        button.addTarget(self, action: #selector(showLocation), for: .touchUpInside)
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.user_name()
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
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.user_username()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let usernameText: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let recordedLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.user_recorded()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let recordedText: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
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
        
        setupLayout()
        setObservers()
    }
    
    private func setupLayout() {
        view.backgroundColor = .white

        userLocationButton.frame = CGRect(origin: CGPoint(x: view.frame.width - 40, y: 255), size: CGSize(width: 35, height: 35))
        mapView.addSubview(userLocationButton)

        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let containerScrollView = UIView()
        containerScrollView.backgroundColor = .white
        containerScrollView.translatesAutoresizingMaskIntoConstraints = false

        containerScrollView.addSubviews(views: [nameLabel, nameText, usernameLabel, usernameText, recordedLabel, recordedText])
        scrollView.addSubview(containerScrollView)
        view.addSubviews(views: [mapView, scrollView])

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.heightAnchor.constraint(equalToConstant: 300),

            scrollView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 30),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            containerScrollView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerScrollView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerScrollView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerScrollView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerScrollView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            nameLabel.topAnchor.constraint(equalTo: containerScrollView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: containerScrollView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: containerScrollView.trailingAnchor, constant: -16),

            nameText.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nameText.leadingAnchor.constraint(equalTo: containerScrollView.leadingAnchor, constant: 16),
            nameText.trailingAnchor.constraint(equalTo: containerScrollView.trailingAnchor, constant: -16),

            usernameLabel.topAnchor.constraint(equalTo: nameText.bottomAnchor, constant: 16),
            usernameLabel.leadingAnchor.constraint(equalTo: containerScrollView.leadingAnchor, constant: 16),
            usernameLabel.trailingAnchor.constraint(equalTo: containerScrollView.trailingAnchor, constant: -16),

            usernameText.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            usernameText.leadingAnchor.constraint(equalTo: containerScrollView.leadingAnchor, constant: 16),
            usernameText.trailingAnchor.constraint(equalTo: containerScrollView.trailingAnchor, constant: -16),

            recordedLabel.topAnchor.constraint(equalTo: usernameText.bottomAnchor, constant: 16),
            recordedLabel.leadingAnchor.constraint(equalTo: containerScrollView.leadingAnchor, constant: 16),
            recordedLabel.trailingAnchor.constraint(equalTo: containerScrollView.trailingAnchor, constant: -16),

            recordedText.topAnchor.constraint(equalTo: recordedLabel.bottomAnchor, constant: 8),
            recordedText.leadingAnchor.constraint(equalTo: containerScrollView.leadingAnchor, constant: 16),
            recordedText.trailingAnchor.constraint(equalTo: containerScrollView.trailingAnchor, constant: -16),
            recordedText.bottomAnchor.constraint(equalTo: containerScrollView.bottomAnchor, constant: -16)
        ])
    }

    private func setObservers() {
        viewModel.fetchFinished.subscribe(onNext: { [weak self] in
            self?.configure()
        }).disposed(by: disposeBag)

        viewModel.alertOfError.subscribe(onNext: { [weak self] in
            let alert = getAlert(title: R.string.localizable.error_alert_title(), message: R.string.localizable.error_alert_message(), actionTitle: R.string.localizable.alert_ok_action())
            self?.present(alert, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        viewModel.addUserMarker.subscribe(onNext: { [weak self] in
            self?.addUserMarker()
        }).disposed(by: disposeBag)
        
        viewModel.centerMapView.subscribe(onNext: { [weak self] coordinate in
            self?.centerMapView(coordinate: coordinate)
        }).disposed(by: disposeBag)
    }

    @objc private func showLocation() {
        mapView.showsUserLocation = true
        mapView.removeAnnotations(mapView.annotations)
        viewModel.shouldFollowUser = true
        
        guard let coordinate = viewModel.locationService.locationManager.location?.coordinate else { return }
        viewModel.centerMapView.onNext(coordinate)
    }

    private func configure() {
        nameText.text = viewModel.userData.name + " " + viewModel.userData.surname
        usernameText.text = viewModel.userData.username
        recordedText.text = viewModel.userData.recorded.getDateFromString()?.getStringFromDate()
        
        viewModel.addUserMarker.onNext(())
    }
    
    private func addUserMarker() {
        mapView.showsUserLocation = false
        mapView.removeAnnotations(mapView.annotations)
        viewModel.shouldFollowUser = false
        
        let userLocation = MKPointAnnotation()
        userLocation.title = R.string.localizable.my_location()
        userLocation.coordinate = CLLocationCoordinate2D(latitude: viewModel.userData.lat, longitude: viewModel.userData.lng)
        mapView.addAnnotation(userLocation)
        
        viewModel.centerMapView.onNext(userLocation.coordinate)
    }

    private func centerMapView(coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(region, animated: true)
    }
}


extension UserViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "UserLocationAnnotation"
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
