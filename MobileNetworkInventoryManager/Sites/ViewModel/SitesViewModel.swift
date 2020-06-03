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
    weak var sitesCoordinatorDelegate: SitesCoordinator?
    var sortView: SortView!
    var filterText: String!
    var filterIndex: SelectedScope!
    var userId: Int!
    var userData: User!
    var sites: [Site] = []
    var sitesPreviews: [SitePreview] = []
    var filteredSitesPreviews: [SitePreview] = []
    let sitesRequest = PublishSubject<Void>()
    let fetchFinished = PublishSubject<Void>()
    let alertOfError = PublishSubject<Void>()
    let filterAction = PublishSubject<Bool>()
    let showNavigationButtons = PublishSubject<Bool>()
    let endRefreshing = PublishSubject<Void>()

    func initialize() -> Disposable{
        sitesRequest
            .asObservable()
            .flatMap(getSitesObservale)
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success(let data):
                    self?.userData = data.0
                    self?.sites = data.1
                    self?.sitesPreviews = data.2
                    self?.filteredSitesPreviews = data.2
                    self?.endRefreshing.onNext(())
                    self?.getSortSettings()
                case .failure(let error):
                    print(error)
                    self?.endRefreshing.onNext(())
                    self?.alertOfError.onNext(())
                }
            })
    }
    
    private func getSitesObservale() -> Observable<Result<(User, [Site], [SitePreview]), Error>> {
        let sitesObservable: Observable<[Site]> = getRequest(url: makeUrl(action: .getAllSites, userId: nil))
        let userObservable: Observable<[User]> = getRequest(url: makeUrl(action: .getUserData, userId: userId))
        
        var previews: [SitePreview] = []
        
        return Observable.combineLatest(sitesObservable, userObservable, resultSelector: { [unowned self] sites, user in
            
            for site in sites {
                let sitePreview = SitePreview(siteId: site.site_id, mark: site.mark, name: site.name, address: site.address, technology: self.getTechnology(is2GAvailable: site.is_2G_available, is3GAvailable: site.is_3G_available, is4GAvailable: site.is_4G_available), distance: self.getDistance(userLocation: (user[0].lat, user[0].lng), siteLocation: (site.lat, site.lng)))
                
                previews.append(sitePreview)
            }
            return (user[0], sites, previews)
            
        }).map { (data) -> Result<(User, [Site], [SitePreview]), Error> in
            return Result.success(data)
            
        }.catchError { error -> Observable<Result<(User, [Site], [SitePreview]), Error>> in
            let result = Result<(User, [Site], [SitePreview]), Error>.failure(error)
            return Observable.just(result)
        }
    }
    
    private func getTechnology(is2GAvailable: Int, is3GAvailable: Int, is4GAvailable: Int) -> String {
        var technology: String = ""
        
        if is2GAvailable == 1 {
            technology = technology + " 2G"
        }
        if is3GAvailable == 1 {
            technology = technology + " 3G"
        }
        if is4GAvailable == 1 {
            technology = technology + " 4G"
        }
        
        technology = String(technology.dropFirst())
        technology = technology.replacingOccurrences(of: " ", with: ", ")
        return technology
    }
    
    private func getDistance(userLocation: (lat: Double, lng: Double), siteLocation: (lat: Double, lng: Double)) -> Double {
        
        let userLocation = CLLocation(latitude: userLocation.lat, longitude: userLocation.lng)
        let siteLocation = CLLocation(latitude: siteLocation.lat, longitude: siteLocation.lng)

        let distance = userLocation.distance(from: siteLocation)
        return distance
    }
    
    
    func setupSortView(frame: CGRect) {
        let sortViewModel = SortViewModel(frame: frame, delegate: self, sortType: .sites)
        sortView = SortView(viewModel: sortViewModel)
    }
    
    func manualRefresh(searchText: String, index: SelectedScope) {
        filterText = searchText
        filterIndex = index
        sitesRequest.onNext(())
    }
    
    func handleTextChange(searchText: String, index: SelectedScope) {
        if searchText.isEmpty {
            filteredSitesPreviews = sitesPreviews
        }
        else {
            filterTableView(index: index, text: searchText)
        }

        fetchFinished.onNext(())
    }
    
    private func filterTableView(index: SelectedScope, text: String) {
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
    
    private func saveSortSettings(value: Int, order: Int) {
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
        
        guard let filterText = filterText, let filterIndex = filterIndex else { fetchFinished.onNext(()); return }
        handleTextChange(searchText: filterText, index: filterIndex)
    }
    
    private func sortByMark(order: Order) {
        if order == .ascending {
            filteredSitesPreviews = filteredSitesPreviews.sorted(by: { (site1, site2) -> Bool in
                return site1.mark < site2.mark
            })
            
            sitesPreviews = sitesPreviews.sorted(by: { (site1, site2) -> Bool in
                return site1.mark < site2.mark
            })
        }
        else {
            filteredSitesPreviews = filteredSitesPreviews.sorted(by: { (site1, site2) -> Bool in
                return site1.mark > site2.mark
            })
            
            sitesPreviews = sitesPreviews.sorted(by: { (site1, site2) -> Bool in
                return site1.mark > site2.mark
            })
        }
    }
    
    private func sortByName(order: Order) {
        if order == .ascending {
            filteredSitesPreviews = filteredSitesPreviews.sorted(by: { (site1, site2) -> Bool in
                return site1.name < site2.name
            })
            
            sitesPreviews = sitesPreviews.sorted(by: { (site1, site2) -> Bool in
                return site1.name < site2.name
            })
        }
        else {
            filteredSitesPreviews = filteredSitesPreviews.sorted(by: { (site1, site2) -> Bool in
                return site1.name > site2.name
            })
            
            sitesPreviews = sitesPreviews.sorted(by: { (site1, site2) -> Bool in
                return site1.name > site2.name
            })
        }
    }
    
    private func sortByAddress(order: Order) {
        if order == .ascending {
            filteredSitesPreviews = filteredSitesPreviews.sorted(by: { (site1, site2) -> Bool in
                return site1.address < site2.address
            })
            
            sitesPreviews = sitesPreviews.sorted(by: { (site1, site2) -> Bool in
                return site1.address < site2.address
            })
        }
        else {
            filteredSitesPreviews = filteredSitesPreviews.sorted(by: { (site1, site2) -> Bool in
                return site1.address > site2.address
            })
            
            sitesPreviews = sitesPreviews.sorted(by: { (site1, site2) -> Bool in
                return site1.address > site2.address
            })
        }
    }
    
    private func sortByDistance(order: Order) {
        if order == .ascending {
            filteredSitesPreviews = filteredSitesPreviews.sorted(by: { (site1, site2) -> Bool in
                return site1.distance < site2.distance
            })

            sitesPreviews = sitesPreviews.sorted(by: { (site1, site2) -> Bool in
                return site1.distance < site2.distance
            })
        }
        else {
            filteredSitesPreviews = filteredSitesPreviews.sorted(by: { (site1, site2) -> Bool in
                return site1.distance > site2.distance
            })

            sitesPreviews = sitesPreviews.sorted(by: { (site1, site2) -> Bool in
                return site1.distance > site2.distance
            })
        }
    }
}


extension SitesViewModel: SortDelegate {
    func sortBy(value: Int, order: Int) {
        saveSortSettings(value: value, order: order)
    }
}
