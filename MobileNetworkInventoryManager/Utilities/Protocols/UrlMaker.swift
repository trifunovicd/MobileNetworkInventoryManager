//
//  UrlMaker.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 27/08/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

public protocol UrlMaker {
    
}

extension UrlMaker {
    func makeUrl(username: String, password: String) -> String {
        let url = Urls.baseUrlGet.rawValue + R.string.localizable.check_if_user_exists(username, password)
        guard let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return url }
        return urlString
    }

    func makeUrl(action: Action, userId: Int?) -> String {
        var url = Urls.baseUrlGet.rawValue
        
        switch action {
        case .getAllSites:
            url = url + R.string.localizable.get_all_sites()
        case .getAllUsers:
            url = url + R.string.localizable.get_all_users()
        case .getTasksForUser:
            guard let userId = userId else { break }
            url = url + R.string.localizable.get_tasks_for_user(userId)
        case .getUserData:
            guard let userId = userId else { break }
            url = url + R.string.localizable.get_user_data(userId)
        case .getTaskStatus:
            url = url + R.string.localizable.get_task_status()
        case .getSiteStatus:
            url = url + R.string.localizable.get_site_status()
        }
        
        return url
    }
}
