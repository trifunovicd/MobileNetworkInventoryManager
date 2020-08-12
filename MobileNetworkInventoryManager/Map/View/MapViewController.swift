//
//  MapViewController.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MapKit

class MapViewController: UIViewController {

    var viewModel: MapViewModel!
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: [R.string.localizable.sites(), R.string.localizable.users()])
        if #available(iOS 13.0, *) {
            control.backgroundColor = .systemBlue
            control.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemBlue], for: .selected)
            control.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        }
        control.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setup()

        viewModel.initialize().disposed(by: disposeBag)
        viewModel.itemsRequest.onNext(())
    }
    
    @objc private func handleRefresh() {
        viewModel.itemsRequest.onNext(())
    }
    
    @objc private func showLocation() {
        viewModel.shouldFollowUser = true
        
        guard let coordinate = viewModel.locationService.locationManager.location?.coordinate else { return }
        viewModel.centerMapView.onNext(coordinate)
    }
    
    @objc private func handleSegmentChange() {
        viewModel.handleSegmentedOptionChange(index: segmentedControl.selectedSegmentIndex)
    }
    
    private func setup() {
        navigationItem.setRightBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "gps"), style: .plain, target: self, action: #selector(showLocation)), animated: true)
        navigationItem.setLeftBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "refresh"), style: .plain, target: self, action: #selector(handleRefresh)), animated: true)
        segmentedControl.selectedSegmentIndex = viewModel.segmentedIndex
        
        setupLayout()
        setObservers()
    }
    
    private func setupLayout() {
        view.addSubviews(views: [segmentedControl, mapView])
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            mapView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setObservers() {
        viewModel.alertOfError.subscribe(onNext: { [weak self] in
            let alert = getAlert(title: R.string.localizable.error_alert_title(), message: R.string.localizable.error_alert_message(), actionTitle: R.string.localizable.alert_ok_action())
            self?.present(alert, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        viewModel.addMarker.subscribe(onNext: { [weak self] data in
            self?.addMarker(data: data)
        }).disposed(by: disposeBag)
        
        viewModel.removeMarkers.subscribe(onNext: { [weak self] in
            guard let annotations = self?.mapView.annotations else {return}
            self?.mapView.removeAnnotations(annotations)
        }).disposed(by: disposeBag)
        
        viewModel.centerMapView.subscribe(onNext: { [weak self] coordinate in
            self?.centerMapView(coordinate: coordinate)
        }).disposed(by: disposeBag)
        
        viewModel.fitMapView.subscribe(onNext: { [weak self] in
            self?.mapView.fitMapViewToAnnotaionList()
        }).disposed(by: disposeBag)
    }
    
    private func addMarker(data: Any) {
        let location = MyPointAnnotation()
        
        if let site = data as? Site {
            location.title = site.name
            location.subtitle = site.address
            location.siteIdentifier = site.site_id
            location.coordinate = CLLocationCoordinate2D(latitude: site.lat, longitude: site.lng)
        }
        else if let user = data as? UserPreview {
            location.title = user.name + " " + user.surname
            location.subtitle = user.distance
            location.recorded = user.recorded.getDateFromString()?.getStringFromDate()
            location.distance = user.distance
            location.showDistance = false
            location.coordinate = CLLocationCoordinate2D(latitude: user.lat, longitude: user.lng)
        }
        
        mapView.addAnnotation(location)
    }

    private func centerMapView(coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(region, animated: true)
    }
}


extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MyPointAnnotation else { return nil }

        let identifier = "LocationAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
            
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            annotationView?.rightCalloutAccessoryView = button
            
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
            guard let annotationView = view.annotation as? MyPointAnnotation else { return }
            
            if let siteId = annotationView.siteIdentifier {
                viewModel.showSiteDetails(siteId: siteId)
            }
            else {
                guard let showDistance = annotationView.showDistance else { return }
                if showDistance {
                    annotationView.subtitle = annotationView.distance
                    annotationView.showDistance = false
                }
                else {
                    annotationView.subtitle = annotationView.recorded
                    annotationView.showDistance = true
                }
            }
        }
    }
}
