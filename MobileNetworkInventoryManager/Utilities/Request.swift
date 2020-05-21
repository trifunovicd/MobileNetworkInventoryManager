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
    case baseUrl = "student.vsmti.hr/dtrifunovic/PIS/json.php"
}

enum DataError: Error {
    case noDataAvailable
    case canNotProcessData
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
