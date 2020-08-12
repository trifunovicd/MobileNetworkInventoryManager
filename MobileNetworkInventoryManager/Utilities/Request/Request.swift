//
//  Request.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

enum Urls: String {
    case baseUrlGet = "http://student.vsmti.hr/dtrifunovic/PIS/json.php"
    case baseUrlPost = "http://student.vsmti.hr/dtrifunovic/PIS/action.php"
}

enum DataError: Error {
    case noDataAvailable
    case canNotProcessData
}

enum Action {
    case getAllSites
    case getAllUsers
    case getTasksForUser
    case getUserData
    case getTaskStatus
}

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

func postRequest(url: String, postString: String) {
    guard let url = URL(string: url) else { return }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = postString.data(using: .utf8)

    AF.request(request).validate().responseJSON { response in
        switch response.result {
        case .success(let data):
            print(data)
        case .failure(let error):
            print(error)
        }
    }
}
