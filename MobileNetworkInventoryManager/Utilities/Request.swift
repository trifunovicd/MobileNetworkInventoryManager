//
//  Request.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

enum Urls: String {
    case baseUrl = "http://student.vsmti.hr/dtrifunovic/PIS/json.php"
}

enum DataError: Error {
    case noDataAvailable
    case canNotProcessData
}

enum Action {
    case getAllSites
    case getAllUsers
    case getTasksForUser
}

func makeUrl(username: String, password: String) -> String {
    let url = Urls.baseUrl.rawValue + R.string.localizable.check_if_user_exists(username, password)
    guard let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return url }
    return urlString
}

func makeUrl(action: Action, userId: Int?) -> String {
    var url = Urls.baseUrl.rawValue
    
    switch action {
    case .getAllSites:
        url = url + R.string.localizable.get_all_sites()
    case .getAllUsers:
        url = url + R.string.localizable.get_all_users()
    case .getTasksForUser:
        guard let userId = userId else { break }
        url = url + R.string.localizable.get_tasks_for_user(userId)
    }
    
    return url
}

func getRequest<Data: Codable> (url: String) -> Observable<Data> {
    
    return Observable.create { observer in
        
        let request = AF.request(url).validate().responseJSON { response in
            guard let jsonData = response.data else {
                observer.onError(DataError.noDataAvailable)
                return
            }
            
            do{
                let decoder = JSONDecoder()
                let response = try decoder.decode(Data.self, from: jsonData)

                observer.onNext(response)
                observer.onCompleted()
            }
            catch{
                observer.onError(DataError.canNotProcessData)
            }
        }
        
        return Disposables.create{
            request.cancel()
        }
    }
}
