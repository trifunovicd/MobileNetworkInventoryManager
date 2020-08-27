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

public class UserViewController: UIViewController, AlertView {
    
    private let viewModel: UserViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    private let userLocationButton: UIButton = {
        let button = UIButton()
        let image = R.image.gps()?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.setImage(R.image.gps_filled(), for: .highlighted)
        button.backgroundColor = .white
        button.tintColor = .systemBlue
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
        button.addTarget(self, action: #selector(showLocation), for: .touchUpInside)
        return button
    }()
    
    private let tableView: UITableView = {
        let view = UITableView()
        view.register(DetailsTableViewCell.self, forCellReuseIdentifier: DetailsTableViewCell.identifier)
        view.register(HeaderTitleView.self, forHeaderFooterViewReuseIdentifier: HeaderTitleView.identifier)
        view.estimatedRowHeight = UITableView.automaticDimension
        view.rowHeight = UITableView.automaticDimension
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.separatorStyle = .none
        view.bounces = false
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        return view
    }()
    
    public init(viewModel: UserViewModel) {
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
        setup()
        initializeVM()
        viewModel.input.loadDataSubject.onNext(())
    }
}

private extension UserViewController {
    func setup() {
        navigationItem.setRightBarButton(UIBarButtonItem(image: R.image.logout(), style: .plain, target: self, action: #selector(handleLogout)), animated: true)
        navigationItem.setLeftBarButton(UIBarButtonItem(image: R.image.refresh(), style: .plain, target: self, action: #selector(handleRefresh)), animated: true)
        mapView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        setupLayout()
    }
    
    func setupLayout() {
        view.backgroundColor = .white
        navigationItem.title = R.string.localizable.user()

        userLocationButton.frame = CGRect(origin: CGPoint(x: view.frame.width - 40, y: 255), size: CGSize(width: 35, height: 35))
        mapView.addSubview(userLocationButton)

        view.addSubviews(mapView, tableView)
        setConstraints()
    }
    
    func setConstraints() {
        mapView.snp.makeConstraints { (maker) in
            maker.top.leading.trailing.equalToSuperview()
            maker.height.equalTo(300)
        }
        
        tableView.snp.makeConstraints { (maker) in
            maker.top.equalTo(mapView.snp.bottom)
            maker.leading.trailing.bottom.equalToSuperview()
        }
    }
}

private extension UserViewController {
    func initializeVM() {
        let input = UserViewModel.Input(loadDataSubject: ReplaySubject.create(bufferSize: 1))
        let output = viewModel.transform(input: input)
        disposeBag.insert(output.disposables)
        subscribeToScreenData()
        initializeAddUserMarkerObserver(for: output.addUserMarker)
        initializeCenterMapViewObserver(for: output.centerMapView)
        initializeErrorObserver(for: output.alertOfError)
    }

    func subscribeToScreenData() {
        viewModel.output.screenData
        .observeOn(MainScheduler.instance)
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .subscribe(onNext: { [unowned self] (data) in
            self.tableView.reloadData()
            if !data.isEmpty {
                self.viewModel.output.addUserMarker.onNext(())
            }
        })
        .disposed(by: disposeBag)
    }
    
    func initializeAddUserMarkerObserver(for subject: PublishSubject<()>) {
        subject
        .observeOn(MainScheduler.instance)
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .subscribe(onNext: { [unowned self] in
            self.addUserMarker()
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
}

private extension UserViewController {
    
    @objc func handleLogout() {
        viewModel.logout()
    }
    
    @objc func handleRefresh() {
        viewModel.input.loadDataSubject.onNext(())
    }
    
    @objc func showLocation() {
        mapView.showsUserLocation = true
        mapView.removeAnnotations(mapView.annotations)
        viewModel.shouldFollowUser = true
        
        guard let coordinate = viewModel.dependecies.locationService.locationManager.location?.coordinate else { return }
        viewModel.output.centerMapView.onNext(coordinate)
    }

    func addUserMarker() {
        mapView.showsUserLocation = false
        mapView.removeAnnotations(mapView.annotations)
        viewModel.shouldFollowUser = false
        
        let userLocation = MKPointAnnotation()
        userLocation.title = R.string.localizable.my_location()
        userLocation.coordinate = CLLocationCoordinate2D(latitude: viewModel.output.userData.lat, longitude: viewModel.output.userData.lng)
        mapView.addAnnotation(userLocation)
        
        viewModel.output.centerMapView.onNext(userLocation.coordinate)
    }

    func centerMapView(coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(region, animated: true)
    }
}

extension UserViewController: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.output.screenData.value.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.output.screenData.value[section].items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = viewModel.output.screenData.value[indexPath.section]
        let item = section.items[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailsTableViewCell.identifier, for: indexPath) as? DetailsTableViewCell else {
            fatalError(R.string.localizable.cell_error(DetailsTableViewCell.identifier))
        }
        
        cell.configure(label: item.data.label, text: item.data.text)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = viewModel.output.screenData.value[section]
        
        if !section.headerTitle.isEmpty {
            guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderTitleView.identifier) as? HeaderTitleView else {
                fatalError(R.string.localizable.cell_error(HeaderTitleView.identifier))
            }
            header.configureCell(with: section.headerTitle)
            return header
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section = viewModel.output.screenData.value[section]
        
        if !section.headerTitle.isEmpty {
            return UITableView.automaticDimension
        }
        return 0
    }
}

extension UserViewController: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
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
