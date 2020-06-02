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
    var userId: Int!
    var userData: User!
    var sites: [Site] = []
    var sitesPreviews: [SitePreview] = []
    var filteredSitesPreviews: [SitePreview] = []
    let sitesRequest = PublishSubject<Void>()
    let fetchFinished = PublishSubject<Void>()
    let alertOfError = PublishSubject<Void>()
    let searchClicked = PublishSubject<Void>()
    let sortClicked = PublishSubject<Void>()

    func initialize() -> Disposable{
        sitesRequest
            .asObservable()
            .flatMap(getSitesObservale)
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success(let data):
                    self?.userData = data.0
                    self?.sites.append(contentsOf: data.1)
                    self?.sitesPreviews.append(contentsOf: data.2)
                    self?.filteredSitesPreviews.append(contentsOf: data.2)
                    self?.getSortSettings()
                case .failure(let error):
                    print(error)
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
    
    
    private func getSortSettings() {
        do {
            let realm = try Realm()
            
            let settings = realm.object(ofType: SiteSortSettings.self, forPrimaryKey: R.string.localizable.site_sort_key())
            
            if let sortSettings = settings {
                sortSitesBy(value: sortSettings.value, order: Order(rawValue: sortSettings.order)!)
                sortView.viewModel.settings = (sortSettings.value, sortSettings.order)
            }
            else {
                let sortSettings = SiteSortSettings()
                sortSitesBy(value: sortSettings.value, order: Order(rawValue: sortSettings.order)!)
                sortView.viewModel.settings = (sortSettings.value, sortSettings.order)
            }
            
            
        } catch  {
            print(error)
        }
    }
    
    
    private func saveSortSettings(value: Int, order: Order) {
        let sortSettings = SiteSortSettings()
        sortSettings.value = value
        sortSettings.order = order.rawValue
        
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
    
    
    private func sortSitesBy(value: Int, order: Order) {
        switch value {
        case SitesSortType.mark.rawValue:
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
        case SitesSortType.name.rawValue:
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
        case SitesSortType.address.rawValue:
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
        case SitesSortType.distance.rawValue:
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
        default:
            print("")
        }
        
        fetchFinished.onNext(())
    }
}


extension SitesViewModel: SortDelegate {
    func sortBy(value: Int, order: Order) {
        saveSortSettings(value: value, order: order)
    }
}
