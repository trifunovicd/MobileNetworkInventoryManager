//
//  SitesViewModel.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import CoreLocation

public class SitesViewModel: ViewModelType {
    
    public struct Input {
        let sitesSubject: ReplaySubject<()>
        let siteDetailsSubject: PublishSubject<SitePreview>
    }
    
    public struct Output {
        var disposables: [Disposable]
        let alertOfError: PublishSubject<LoadError>
        var filteredSitesPreviews: BehaviorRelay<[SitePreview]>
        var sortView: SortView!
        let filterAction: PublishSubject<Bool>
        let showNavigationButtons: PublishSubject<Bool>
        let endRefreshing: PublishSubject<()>
        let resignResponder: PublishSubject<()>
    }
    
    public struct Dependecies {
        let subscribeScheduler: SchedulerType
        weak var coordinatorDelegate: CoordinatorDelegate?
        weak var siteDetailsDelegate: SiteDetailsDelegate?
        let userRepository: UserRepository
        let siteRepository: SiteRepository
        var userId: Int!
    }
    
    public init(dependecies: Dependecies) {
        self.dependecies = dependecies
    }

    var input: Input!
    var output: Output!
    var dependecies: Dependecies
    
    private var sites: [Site] = []
    private var sitesPreviews: [SitePreview] = []
    private var filterText: String = ""
    private var filterIndex: SitesSelectedScope = .name
    
    public func transform(input: Input) -> Output {
        var disposables = [Disposable]()
        disposables.append(initializeSitesObservable(for: input.sitesSubject))
        disposables.append(initializeSiteDetailsObservable(for: input.siteDetailsSubject))
        let output = Output(disposables: disposables, alertOfError: PublishSubject(), filteredSitesPreviews: BehaviorRelay.init(value: []), filterAction: PublishSubject(), showNavigationButtons: PublishSubject(), endRefreshing: PublishSubject(), resignResponder: PublishSubject())
        
        self.input = input
        self.output = output
        
        return output
    }
    
    func setupSortView(frame: CGRect) {
        let sortViewModel = SortViewModel(frame: frame, delegate: self, sortType: .sites)
        output.sortView = SortView(viewModel: sortViewModel)
    }
}

private extension SitesViewModel {
    func initializeSitesObservable(for subject: ReplaySubject<()>) -> Disposable {
        return subject.flatMap {[unowned self] (_) -> Observable<DataWrapper<([Site], [SitePreview])>> in
            return self.combineObservables(sitesObservable: self.dependecies.siteRepository.getSites(), userObservable: self.dependecies.userRepository.getUserData(userId: self.dependecies.userId))
        }
        .observeOn(MainScheduler.instance)
        .subscribeOn(dependecies.subscribeScheduler)
        .subscribe(onNext: { [unowned self] (dataWrapper) in
            guard let safeData = dataWrapper.data else {
                self.output.endRefreshing.onNext(())
                self.handleError(error: dataWrapper.error)
                return
            }
            self.sites = safeData.0
            self.sitesPreviews = safeData.1
            self.output.endRefreshing.onNext(())
            self.getSortSettings()
        })
    }
    
    func combineObservables(sitesObservable: Observable<DataWrapper<[Site]>>, userObservable: Observable<DataWrapper<[User]>>) -> Observable<DataWrapper<([Site], [SitePreview])>> {
            
            var previews: [SitePreview] = []
            
            return Observable<DataWrapper<([Site], [SitePreview])>>.combineLatest(sitesObservable, userObservable, resultSelector: { sitesWrapper, userWrapper in
                
                if let sites = sitesWrapper.data, let user = userWrapper.data {
                    for site in sites {
                        let sitePreview = SitePreview(siteId: site.site_id, mark: site.mark, name: site.name, address: site.address, technology: getTechnology(is2GAvailable: site.is_2G_available, is3GAvailable: site.is_3G_available, is4GAvailable: site.is_4G_available), distance: getDistance(userLocation: (user[0].lat, user[0].lng), siteLocation: (site.lat, site.lng)))
                        
                        previews.append(sitePreview)
                    }
                    return DataWrapper(data: (sites, previews), error: nil)
                }
                guard let sitesNetError = sitesWrapper.error as? NetworkError,
                    let userNetError = userWrapper.error as? NetworkError,
                    sitesNetError == .notConnectedToInternet || userNetError == .notConnectedToInternet else {
                        return DataWrapper(data: nil, error: NetworkError.noDataAvailable)
                }
                return DataWrapper(data: nil, error: NetworkError.notConnectedToInternet)
            })
        }
    
    func handleError(error: Error?) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .notConnectedToInternet:
                self.output.alertOfError.onNext(.failedLoad(text: R.string.localizable.no_internet_connection()))
            default:
                self.output.alertOfError.onNext(.failedLoad(text: .empty))
            }
        } else {
            self.output.alertOfError.onNext(.failedLoad(text: .empty))
        }
    }
}

private extension SitesViewModel {
    func getSortSettings() {
        do {
            let realm = try Realm()
            
            let settings = realm.object(ofType: SiteSortSettings.self, forPrimaryKey: R.string.localizable.site_sort_key())
            
            if let sortSettings = settings {
                applySettings(sortSettings: sortSettings)
            }
            else {
                let sortSettings = SiteSortSettings()
                applySettings(sortSettings: sortSettings)
            }
        } catch  {
            print(error)
        }
    }
    
    func applySettings(sortSettings: SiteSortSettings) {
        guard let order = Order(rawValue: sortSettings.order) else { return }
        sortSitesBy(value: sortSettings.value, order: order)
        output.sortView.viewModel.settings = (sortSettings.value, sortSettings.order)
    }
    
    func sortSitesBy(value: Int, order: Order) {
        switch value {
        case SitesSortType.mark.rawValue:
            sortByMark(order: order)
        case SitesSortType.name.rawValue:
            sortByName(order: order)
        case SitesSortType.address.rawValue:
            sortByAddress(order: order)
        case SitesSortType.distance.rawValue:
            sortByDistance(order: order)
        default:
            sortByMark(order: order)
        }
        
        handleTextChange(searchText: filterText, index: filterIndex)
    }
    
    func sortByMark(order: Order) {
        if order == .ascending {
            sitesPreviews = sitesPreviews.sorted(by: { (site1, site2) -> Bool in
                return site1.mark < site2.mark
            })
        }
        else {
            sitesPreviews = sitesPreviews.sorted(by: { (site1, site2) -> Bool in
                return site1.mark > site2.mark
            })
        }
    }
    
    func sortByName(order: Order) {
        if order == .ascending {
            sitesPreviews = sitesPreviews.sorted(by: { (site1, site2) -> Bool in
                return site1.name < site2.name
            })
        }
        else {
            sitesPreviews = sitesPreviews.sorted(by: { (site1, site2) -> Bool in
                return site1.name > site2.name
            })
        }
    }
    
    func sortByAddress(order: Order) {
        if order == .ascending {
            sitesPreviews = sitesPreviews.sorted(by: { (site1, site2) -> Bool in
                return site1.address < site2.address
            })
        }
        else {
            sitesPreviews = sitesPreviews.sorted(by: { (site1, site2) -> Bool in
                return site1.address > site2.address
            })
        }
    }
    
    func sortByDistance(order: Order) {
        if order == .ascending {
            sitesPreviews = sitesPreviews.sorted(by: { (site1, site2) -> Bool in
                return site1.distance < site2.distance
            })
        }
        else {
            sitesPreviews = sitesPreviews.sorted(by: { (site1, site2) -> Bool in
                return site1.distance > site2.distance
            })
        }
    }
}

private extension SitesViewModel {
    func initializeSiteDetailsObservable(for subject: PublishSubject<SitePreview>) -> Disposable{
        return subject
        .observeOn(MainScheduler.instance)
        .subscribeOn(dependecies.subscribeScheduler)
        .subscribe(onNext: {[unowned self] (sitePreview) in
            self.showSiteDetails(sitePreview: sitePreview)
        })
    }
    
    func showSiteDetails(sitePreview: SitePreview) {
        for site in sites {
            if site.site_id == sitePreview.siteId {
                let siteDetails = SiteDetails(siteId: site.site_id, siteMark: site.mark, siteName: site.name, siteAddress: site.address, siteTechnology: sitePreview.technology, siteDistance: sitePreview.distance, siteLat: site.lat, siteLng: site.lng, siteDirections: site.directions, sitePowerSupply: site.power_supply)
                
                dependecies.siteDetailsDelegate?.openSiteDetails(siteDetails: siteDetails)
                break
            }
        }
    }
}

public extension SitesViewModel {
    func handleTextChange(searchText: String, index: SitesSelectedScope) {
        if searchText.isEmpty {
            output.filteredSitesPreviews.accept(sitesPreviews)
        }
        else {
            filterTableView(index: index, text: searchText)
        }

        filterText = searchText
        filterIndex = index
    }
    
    private func filterTableView(index: SitesSelectedScope, text: String) {
        switch index {
        case .name:
            output.filteredSitesPreviews.accept(sitesPreviews.filter({ (site) -> Bool in
                    return site.name.lowercased().contains(text.lowercased())
            }))
        case .address:
            output.filteredSitesPreviews.accept(sitesPreviews.filter({ (site) -> Bool in
                return site.address.lowercased().contains(text.lowercased())
            }))
        case .tech:
            output.filteredSitesPreviews.accept(sitesPreviews.filter({ (site) -> Bool in
                return site.technology.lowercased().contains(text.lowercased())
            }))
        case .mark:
            output.filteredSitesPreviews.accept(sitesPreviews.filter({ (site) -> Bool in
                return site.mark.lowercased().contains(text.lowercased())
            }))
        }
    }
}

extension SitesViewModel: SortDelegate {
    func sortBy(value: Int, order: Int) {
        setSortSettings(value: value, order: order)
    }
    
    private func setSortSettings(value: Int, order: Int) {
        let sortSettings = SiteSortSettings()
        sortSettings.value = value
        sortSettings.order = order
        
        do {
            let realm = try Realm()
            
            try realm.write {
                realm.add(sortSettings, update: .modified)
            }
            
            getSortSettings()
        } catch  {
            print(error)
        }
    }
}
