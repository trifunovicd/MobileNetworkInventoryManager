//
//  SiteDetailsViewController.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 04/06/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa

class SiteDetailsViewController: UIViewController {

    var viewModel: SiteDetailsViewModel!
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    private let userLocationButton: MKUserTrackingButton = {
        let button = MKUserTrackingButton()
        button.backgroundColor = .white
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
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
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let directionsLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.directions()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let directionsText: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setupLayout()
        setObservers()
        viewModel.viewLoaded.onNext(())
    }
    
    private func setupLayout() {
        view.backgroundColor = .white
        
        userLocationButton.mapView = mapView
        userLocationButton.frame = CGRect(origin: CGPoint(x: view.frame.width - 40, y: 255), size: CGSize(width: 35, height: 35))
        mapView.addSubview(userLocationButton)
        
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let containerScrollView = UIView()
        containerScrollView.backgroundColor = .white
        containerScrollView.translatesAutoresizingMaskIntoConstraints = false

        containerScrollView.addSubviews(views: [directionsLabel, directionsText])
        scrollView.addSubview(containerScrollView)
        view.addSubviews(views: [mapView, closeButton, distanceView, distanceLabel, scrollView])
        
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
            
            directionsLabel.topAnchor.constraint(equalTo: containerScrollView.topAnchor),
            directionsLabel.leadingAnchor.constraint(equalTo: containerScrollView.leadingAnchor, constant: 16),
            directionsLabel.trailingAnchor.constraint(equalTo: containerScrollView.trailingAnchor, constant: -16),
            
            directionsText.topAnchor.constraint(equalTo: directionsLabel.bottomAnchor, constant: 16),
            directionsText.leadingAnchor.constraint(equalTo: containerScrollView.leadingAnchor, constant: 16),
            directionsText.trailingAnchor.constraint(equalTo: containerScrollView.trailingAnchor, constant: -16),
            directionsText.bottomAnchor.constraint(equalTo: containerScrollView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setObservers() {
        viewModel.viewLoaded.subscribe(onNext: { [weak self] in
            self?.configure()
        }).disposed(by: disposeBag)
        
        viewModel.addSiteMarker.subscribe(onNext: { [weak self] in
            self?.addSiteMarker()
        }).disposed(by: disposeBag)
        
        viewModel.checkLocationServices.subscribe(onNext: { [weak self] in
            self?.checkLocationServices()
        }).disposed(by: disposeBag)
        
        viewModel.setupLocationManager.subscribe(onNext: { [weak self] in
            self?.setupLocationManager()
        }).disposed(by: disposeBag)
        
        viewModel.checkLocationAuthorization.subscribe(onNext: { [weak self] in
            self?.checkLocationAuthorization()
        }).disposed(by: disposeBag)
        
        viewModel.locationAuthorized.subscribe(onNext: { [weak self] in
            self?.locationAuthorized()
        }).disposed(by: disposeBag)
        
        viewModel.locationNotDetermined.subscribe(onNext: { [weak self] in
            self?.locationManager.requestWhenInUseAuthorization()
        }).disposed(by: disposeBag)
        
        viewModel.alertOfLocationOff.subscribe(onNext: { [weak self] in
            let alert = getAlert(title: R.string.localizable.location_off_alert_title(), message: R.string.localizable.location_off_alert_message(), actionTitle: R.string.localizable.alert_ok_action())
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.present(alert, animated: true, completion: nil)
            }
        }).disposed(by: disposeBag)
        
        viewModel.alertOfLocationDenied.subscribe(onNext: { [weak self] in
            let alert = getAlert(title: R.string.localizable.location_denied_alert_title(), message: R.string.localizable.location_denied_alert_message(), actionTitle: R.string.localizable.alert_ok_action())
            self?.present(alert, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        viewModel.alertOfLocationRestricted.subscribe(onNext: { [weak self] in
            let alert = getAlert(title: R.string.localizable.location_restricted_alert_title(), message: R.string.localizable.location_restricted_alert_message(), actionTitle: R.string.localizable.alert_ok_action())
            self?.present(alert, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        viewModel.closeModal.subscribe(onNext: { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
    
    @objc private func closeModal() {
        viewModel.closeModal.onNext(())
    }
    
    private func configure() {
        directionsText.text = viewModel.siteDetails.directions
        distanceLabel.text = viewModel.siteDetails.distance.getDistanceString()
        
        viewModel.addSiteMarker.onNext(())
        viewModel.checkLocationServices.onNext(())
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            viewModel.setupLocationManager.onNext(())
            viewModel.checkLocationAuthorization.onNext(())
        }
        else {
            viewModel.alertOfLocationOff.onNext(())
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            viewModel.locationAuthorized.onNext(())
        case .denied:
            viewModel.alertOfLocationDenied.onNext(())
        case .notDetermined:
            viewModel.locationNotDetermined.onNext(())
        case .restricted:
            viewModel.alertOfLocationRestricted.onNext(())
        case .authorizedAlways:
            break
        @unknown default:
            break
        }
    }
    
    private func locationAuthorized() {
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
    }
    
    private func addSiteMarker() {
        let siteLocation = MKPointAnnotation()
        siteLocation.title = viewModel.siteDetails.name
        siteLocation.coordinate = CLLocationCoordinate2D(latitude: viewModel.siteDetails.lat, longitude: viewModel.siteDetails.lng)
        mapView.addAnnotation(siteLocation)
        
        let region = MKCoordinateRegion.init(center: siteLocation.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)
    }
}


extension SiteDetailsViewController: MKMapViewDelegate {
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


extension SiteDetailsViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        viewModel.checkLocationAuthorization.onNext(())
    }
}
