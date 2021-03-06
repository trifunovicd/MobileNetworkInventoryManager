//
//  DetailsViewController.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 06/06/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MapKit

public class DetailsViewController: UIViewController, TransformData, AlertView {

    private let viewModel: DetailsViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
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
        button.addTarget(self, action: #selector(showLocation(_:)), for: .touchUpInside)
        return button
    }()
    
    private let siteLocationButton: UIButton = {
        let button = UIButton()
        let image = R.image.marker()?.withRenderingMode(.alwaysTemplate)
        let selectedImage = R.image.marker_filled()?.withRenderingMode(.alwaysTemplate)
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
        let image = R.image.close_modal()?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.black.withAlphaComponent(0.5)
        button.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
        return button
    }()
    
    private let distanceView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.gray.cgColor
        view.backgroundColor = .white
        return view
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    private let tableView: UITableView = {
        let view = UITableView()
        view.register(DetailsTableViewCell.self, forCellReuseIdentifier: DetailsTableViewCell.identifier)
        view.register(HeaderTitleView.self, forHeaderFooterViewReuseIdentifier: HeaderTitleView.identifier)
        view.estimatedRowHeight = UITableView.automaticDimension
        view.rowHeight = UITableView.automaticDimension
        view.backgroundColor = .white
        view.separatorStyle = .none
        view.bounces = false
        return view
    }()
    
    private let completedButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.completed(), for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(completed), for: .touchUpInside)
        return button
    }()
    
    public init(viewModel: DetailsViewModel) {
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
        initializeVM()
        setup()
        viewModel.input.loadDataSubject.onNext(())
    }
}

private extension DetailsViewController {
    func setup() {
        mapView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        setupLayout()
     }
     
    func setupLayout() {
        view.backgroundColor = .white
        
        userLocationButton.frame = CGRect(origin: CGPoint(x: view.frame.width - 40, y: 255), size: CGSize(width: 35, height: 35))
        siteLocationButton.frame = CGRect(origin: CGPoint(x: view.frame.width - 40, y: 215), size: CGSize(width: 35, height: 35))
        mapView.addSubviews(userLocationButton, siteLocationButton)
        
        if let taskDetails = viewModel.dependecies.details as? TaskDetails {
            viewModel.output.taskId = taskDetails.taskId
            let closingTime = taskDetails.taskClosingTime
            if closingTime.isEmpty {
                completedButton.isHidden = false
                tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
            } else {
                completedButton.isHidden = true
                tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
            }
        } else {
            completedButton.isHidden = true
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        }

        view.addSubviews(mapView, closeButton, distanceView, distanceLabel, tableView, completedButton)
        setConstraints()
    }
    
    func setConstraints() {
        mapView.snp.makeConstraints { (maker) in
            maker.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            maker.height.equalTo(300)
        }
        
        closeButton.snp.makeConstraints { (maker) in
            maker.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(8)
            maker.height.width.equalTo(30)
        }
        
        distanceView.snp.makeConstraints { (maker) in
            maker.top.leading.equalTo(view.safeAreaLayoutGuide).inset(UIEdgeInsets(top: 10, left: 8, bottom: 0, right: 0))
            maker.trailing.equalTo(distanceLabel.snp.trailing).offset(8)
        }
        
        distanceLabel.snp.makeConstraints { (maker) in
            maker.top.leading.bottom.equalTo(distanceView).inset(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 0))
        }
        
        tableView.snp.makeConstraints { (maker) in
            maker.top.equalTo(mapView.snp.bottom)
            maker.leading.trailing.bottom.equalToSuperview()
        }
        
        completedButton.snp.makeConstraints { (maker) in
            maker.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(15)
            maker.height.equalTo(45)
        }
    }
}

private extension DetailsViewController {
    func initializeVM() {
        let input = DetailsViewModel.Input(loadDataSubject: ReplaySubject.create(bufferSize: 1), completeTaskSubject: PublishSubject())
        let output = viewModel.transform(input: input)
        disposeBag.insert(output.disposables)
        subscribeToScreenData()
        initializeCloseModalObserver(for: output.closeModal)
        initializeAddSiteMarkerObserver(for: output.addSiteMarker)
        initializeCenterMapViewObserver(for: output.centerMapView)
        initializeUpdateDistanceObserver(for: output.updateDistance)
        initializeAlertObserver(for: output.alertSubject)
        initializeSpinnerObserver(for: output.spinnerSubject)
    }
    
    func initializeAlertObserver(for subject: PublishSubject<AlertType>) {
        subject
        .observeOn(MainScheduler.instance)
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .subscribe(onNext: { [unowned self] (type) in
            switch type {
            case .error:
                let alert = self.getAlert(title: R.string.localizable.error_alert_title(), message: R.string.localizable.post_error_alert_message(), actionTitle: R.string.localizable.alert_ok_action())
                self.present(alert, animated: true, completion: nil)
            case .action:
                let alert = self.getActionAlert(title: R.string.localizable.complete_task_title(), message: R.string.localizable.complete_task_message(), actionTitle: R.string.localizable.yes_action(), cancelTitle: R.string.localizable.no_action(), subject: self.viewModel.input.completeTaskSubject, event: self.viewModel.output.taskId)
                self.present(alert, animated: true, completion: nil)
            }
        })
        .disposed(by: disposeBag)
    }

    func subscribeToScreenData() {
        viewModel.output.screenData
        .observeOn(MainScheduler.instance)
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .subscribe(onNext: { [unowned self] (_) in
            self.distanceLabel.text = self.viewModel.dependecies.details.siteDistance.getDistanceString()
            self.tableView.reloadData()
            self.viewModel.output.addSiteMarker.onNext(())
        })
        .disposed(by: disposeBag)
    }
    
    func initializeCloseModalObserver(for subject: PublishSubject<()>) {
        subject
        .observeOn(MainScheduler.instance)
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .subscribe(onNext: { [unowned self] in
            self.dismiss(animated: true, completion: nil)
        })
        .disposed(by: disposeBag)
    }
    
    func initializeAddSiteMarkerObserver(for subject: PublishSubject<()>) {
        subject
        .observeOn(MainScheduler.instance)
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .subscribe(onNext: { [unowned self] in
            self.addSiteMarker()
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
    
    func initializeUpdateDistanceObserver(for subject: PublishSubject<CLLocationCoordinate2D>) {
        subject
        .observeOn(MainScheduler.instance)
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .subscribe(onNext: { [unowned self] coordinate in
            self.updateDistance(coordinate: coordinate)
        })
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

private extension DetailsViewController {
    @objc func completed() {
        viewModel.output.alertSubject.onNext(.action)
    }
    
    @objc func closeModal() {
        viewModel.output.closeModal.onNext(())
    }
    
    @objc func showLocation(_ sender: UIButton) {
        if sender == siteLocationButton {
            let coordinate = CLLocationCoordinate2D(latitude: viewModel.dependecies.details.siteLat, longitude: viewModel.dependecies.details.siteLng)
            viewModel.output.centerMapView.onNext(coordinate)
            viewModel.output.shouldFollowUser = false
        }
        else {
            guard let coordinate = viewModel.dependecies.locationService.locationManager.location?.coordinate else { return }
            viewModel.output.centerMapView.onNext(coordinate)
            viewModel.output.shouldFollowUser = true
        }
    }
    
    func addSiteMarker() {
        let siteLocation = MKPointAnnotation()
        siteLocation.title = viewModel.dependecies.details.siteName
        siteLocation.coordinate = CLLocationCoordinate2D(latitude: viewModel.dependecies.details.siteLat, longitude: viewModel.dependecies.details.siteLng)
        mapView.addAnnotation(siteLocation)
        
        viewModel.output.centerMapView.onNext(siteLocation.coordinate)
    }
    
    func centerMapView(coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(region, animated: true)
    }
    
    func updateDistance(coordinate: CLLocationCoordinate2D) {
        let distance = self.getDistance(userLocation: (coordinate.latitude, coordinate.longitude), siteLocation: (viewModel.dependecies.details.siteLat, viewModel.dependecies.details.siteLng))
        distanceLabel.text = distance.getDistanceString()
    }
}

extension DetailsViewController: UITableViewDelegate, UITableViewDataSource {
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
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.tintColor = .white
        return view
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
}

extension DetailsViewController: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "SiteLocationAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }

        return annotationView
    }
}
