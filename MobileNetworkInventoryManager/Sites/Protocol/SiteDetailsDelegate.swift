//
//  SiteDetailsDelegate.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 04/06/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

protocol SiteDetailsDelegate: AnyObject {
    func openSiteDetails(siteDetails: SiteDetails)
}
