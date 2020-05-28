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

class SitesViewModel {
    weak var sitesCoordinatorDelegate: SitesCoordinator?
    var userId: Int!
    var sites: [Site] = []
    var sitesPreviews: [SitePreview] = []
    let sitesRequest = PublishSubject<Void>()
    let fetchFinished = PublishSubject<Void>()
    let alertOfError = PublishSubject<Void>()
    

    func initialize() -> Disposable{
        sitesRequest
            .asObservable()
            .flatMap(getSitesObservale)
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success(let data):
                    self?.sites.append(contentsOf: data.0)
                    self?.sitesPreviews.append(contentsOf: data.1)
                    self?.fetchFinished.onNext(())
                case .failure(let error):
                    print(error)
                    self?.alertOfError.onNext(())
                }
            })
    }
    
    private func getSitesObservale() -> Observable<Result<([Site], [SitePreview]), Error>> {
        let observable: Observable<[Site]> = getRequest(url: makeUrl(action: .getAllSites, userId: nil))
        var previews: [SitePreview] = []
        
        return observable.map { [unowned self] (sites) -> Result<([Site], [SitePreview]), Error> in
            
            for site in sites {
                let sitePreview = SitePreview(siteId: site.site_id, internaOznaka: site.interna_oznaka, naziv: site.naziv, adresa: site.adresa, tehnologija: self.getTechnology(is2GAvailable: site.is_2G_available, is3GAvailable: site.is_3G_available, is4GAvailable: site.is_4G_available))
                
                previews.append(sitePreview)
            }
            
            return Result.success((sites, previews))
        }.catchError { (error) -> Observable<Result<([Site], [SitePreview]), Error>> in
            let result = Result<([Site], [SitePreview]), Error>.failure(error)
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
}
