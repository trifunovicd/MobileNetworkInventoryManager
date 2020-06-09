//
//  SitesViewModel.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import CoreLocation

class SitesViewModel {
    weak var sitesCoordinatorDelegate: SiteDetailsDelegate?
    var sortView: SortView!
    var filterText: String = ""
    var filterIndex: SitesSelectedScope = .name
    var userId: Int!
    var sites: [Site] = []
    var sitesPreviews: [SitePreview] = []
    var filteredSitesPreviews: [SitePreview] = []
    let sitesRequest = PublishSubject<Void>()
    let fetchFinished = PublishSubject<Void>()
    let alertOfError = PublishSubject<Void>()
    let filterAction = PublishSubject<Bool>()
    let showNavigationButtons = PublishSubject<Bool>()
    let endRefreshing = PublishSubject<Void>()
    let resignResponder = PublishSubject<Void>()

    func initialize() -> Disposable{
        sitesRequest
            .asObservable()
            .flatMap(getSitesObservale)
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success(let data):
                    self?.sites = data.0
                    self?.sitesPreviews = data.1
                    self?.filteredSitesPreviews = data.1
                    self?.endRefreshing.onNext(())
                    self?.getSortSettings()
                case .failure(let error):
                    print(error)
                    self?.endRefreshing.onNext(())
                    self?.alertOfError.onNext(())
                }
            })
    }
    
    private func getSitesObservale() -> Observable<Result<([Site], [SitePreview]), Error>> {
        let sitesObservable: Observable<[Site]> = getRequest(url: makeUrl(action: .getAllSites, userId: nil))
        let userObservable: Observable<[User]> = getRequest(url: makeUrl(action: .getUserData, userId: userId))
        
        var previews: [SitePreview] = []
        
        return Observable.combineLatest(sitesObservable, userObservable, resultSelector: { sites, user in
            
            for site in sites {
                let sitePreview = SitePreview(siteId: site.site_id, mark: site.mark, name: site.name, address: site.address, technology: getTechnology(is2GAvailable: site.is_2G_available, is3GAvailable: site.is_3G_available, is4GAvailable: site.is_4G_available), distance: getDistance(userLocation: (user[0].lat, user[0].lng), siteLocation: (site.lat, site.lng)))
                
                previews.append(sitePreview)
            }
            return (sites, previews)
            
        }).map { (data) -> Result<([Site], [SitePreview]), Error> in
            return Result.success(data)
            
        }.catchError { error -> Observable<Result<([Site], [SitePreview]), Error>> in
            let result = Result<([Site], [SitePreview]), Error>.failure(error)
            return Observable.just(result)
        }
    }
    
    func showSiteDetails(sitePreview: SitePreview) {
        for site in sites {
            if site.site_id == sitePreview.siteId {
                let siteDetails = SiteDetails(siteId: site.site_id, mark: site.mark, name: site.name, address: site.address, technology: sitePreview.technology, distance: sitePreview.distance, lat: site.lat, lng: site.lng, directions: site.directions, powerSupply: site.power_supply)
                
                sitesCoordinatorDelegate?.openSiteDetails(siteDetails: siteDetails)
                break
            }
        }
    }
    
    func setupSortView(frame: CGRect) {
        let sortViewModel = SortViewModel(frame: frame, delegate: self, sortType: .sites)
        sortView = SortView(viewModel: sortViewModel)
    }
    
    func handleTextChange(searchText: String, index: SitesSelectedScope) {
        if searchText.isEmpty {
            filteredSitesPreviews = sitesPreviews
        }
        else {
            filterTableView(index: index, text: searchText)
        }

        filterText = searchText
        filterIndex = index
        
        fetchFinished.onNext(())
    }
    
    private func filterTableView(index: SitesSelectedScope, text: String) {
        switch index {
        case .name:
            filteredSitesPreviews = sitesPreviews.filter({ (site) -> Bool in
                return site.name.lowercased().contains(text.lowercased())
            })
        case .address:
            filteredSitesPreviews = sitesPreviews.filter({ (site) -> Bool in
                return site.address.lowercased().contains(text.lowercased())
            })
        case .tech:
            filteredSitesPreviews = sitesPreviews.filter({ (site) -> Bool in
                return site.technology.lowercased().contains(text.lowercased())
            })
        case .mark:
            filteredSitesPreviews = sitesPreviews.filter({ (site) -> Bool in
                return site.mark.lowercased().contains(text.lowercased())
            })
        }
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
    
    private func getSortSettings() {
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
    
    private func applySettings(sortSettings: SiteSortSettings) {
        guard let order = Order(rawValue: sortSettings.order) else { return }
        sortSitesBy(value: sortSettings.value, order: order)
        sortView.viewModel.settings = (sortSettings.value, sortSettings.order)
    }
    
    private func sortSitesBy(value: Int, order: Order) {
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
    
    private func sortByMark(order: Order) {
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
    
    private func sortByName(order: Order) {
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
    
    private func sortByAddress(order: Order) {
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
    
    private func sortByDistance(order: Order) {
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


extension SitesViewModel: SortDelegate {
    func sortBy(value: Int, order: Int) {
        setSortSettings(value: value, order: order)
    }
}
