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

public class MapViewController: UIViewController, AlertView {

    private let viewModel: MapViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: [R.string.localizable.sites(), R.string.localizable.users()])
        if #available(iOS 13.0, *) {
            control.backgroundColor = .systemBlue
            control.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemBlue], for: .selected)
            control.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        }
        control.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        return control
    }()
    
    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        return mapView
    }()
    
    public init(viewModel: MapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        printDeinit()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setup()
        initializeVM()
        viewModel.input.loadDataSubject.onNext(())
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent{
            viewModel.dependecies.coordinatorDelegate?.viewControllerHasFinished()
        }
    }
}

private extension MapViewController {
    func setup() {
        navigationItem.setRightBarButton(UIBarButtonItem(image: R.image.gps(), style: .plain, target: self, action: #selector(showLocation)), animated: true)
        navigationItem.setLeftBarButton(UIBarButtonItem(image: R.image.refresh(), style: .plain, target: self, action: #selector(handleRefresh)), animated: true)
        segmentedControl.selectedSegmentIndex = viewModel.segmentedIndex
        view.backgroundColor = .white
        navigationItem.title = R.string.localizable.map()
        setupLayout()
    }
    
    func setupLayout() {
        view.addSubviews(segmentedControl, mapView)
        setConstraints()
    }
    
    func setConstraints() {
        segmentedControl.snp.makeConstraints { (maker) in
            maker.top.leading.trailing.equalToSuperview().inset(16)
        }
        
        mapView.snp.makeConstraints { (maker) in
            maker.top.equalTo(segmentedControl.snp.bottom).offset(16)
            maker.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    @objc func handleRefresh() {
        viewModel.input.loadDataSubject.onNext(())
    }
    
    @objc func showLocation() {
        viewModel.shouldFollowUser = true
        
        guard let coordinate = viewModel.dependecies.locationService.locationManager.location?.coordinate else { return }
        viewModel.output.centerMapView.onNext(coordinate)
    }
    
    @objc func handleSegmentChange() {
        viewModel.handleSegmentedOptionChange(index: segmentedControl.selectedSegmentIndex)
    }
    
    func addMarker(data: Any) {
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

    func centerMapView(coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(region, animated: true)
    }
}

private extension MapViewController {
    func initializeVM() {
        let input = MapViewModel.Input(loadDataSubject: ReplaySubject.create(bufferSize: 1), siteDetailsSubject: PublishSubject())
        let output = viewModel.transform(input: input)
        disposeBag.insert(output.disposables)
        initializeErrorObserver(for: output.alertOfError)
        initializeAddMarkerObserver(for: output.addMarker)
        initializeRemoveMarkersObserver(for: output.removeMarkers)
        initializeCenterMapViewObserver(for: output.centerMapView)
        initializeFitMapViewObserver(for: output.fitMapView)
    }

    func initializeErrorObserver(for subject: PublishSubject<LoadError>) {
        subject
        .asDriver(onErrorJustReturn: .failedLoad(text: .empty))
        .do(onNext: { [unowned self] (error) in
            let alert: UIAlertController
            switch error {
            case .failedLoad(let text):
                alert = self.getAlert(title: R.string.localizable.error_alert_title(), message: R.string.localizable.error_alert_message(text), actionTitle: R.string.localizable.alert_ok_action())
            }
            self.present(alert, animated: true, completion: nil)
        })
        .drive()
        .disposed(by: disposeBag)
    }
    
    func initializeAddMarkerObserver(for subject: PublishSubject<Any>) {
        subject
        .observeOn(MainScheduler.instance)
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .subscribe(onNext: { [unowned self] data in
            self.addMarker(data: data)
        })
        .disposed(by: disposeBag)
    }
    
    func initializeRemoveMarkersObserver(for subject: PublishSubject<()>) {
        subject
        .observeOn(MainScheduler.instance)
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .subscribe(onNext: { [unowned self] in
            self.mapView.removeAnnotations(self.mapView.annotations)
        })
        .disposed(by: disposeBag)
    }
    
    func initializeCenterMapViewObserver(for subject: PublishSubject<CLLocationCoordinate2D>) {
        subject
        .observeOn(MainScheduler.instance)
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .subscribe(onNext: { [unowned self] coordinate in
            self.centerMapView(coordinate: coordinate)
        })
        .disposed(by: disposeBag)
    }
    
    func initializeFitMapViewObserver(for subject: PublishSubject<()>) {
        subject
        .observeOn(MainScheduler.instance)
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .subscribe(onNext: { [unowned self] in
            self.mapView.fitMapViewToAnnotaionList()
        })
        .disposed(by: disposeBag)
    }
}

extension MapViewController: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
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
    
    public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
            guard let annotationView = view.annotation as? MyPointAnnotation else { return }
            
            if let siteId = annotationView.siteIdentifier {
                viewModel.input.siteDetailsSubject.onNext(siteId)
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
