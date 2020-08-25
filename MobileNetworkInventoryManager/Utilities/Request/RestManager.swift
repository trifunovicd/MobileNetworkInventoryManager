//
//  RestManager.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 12/08/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

public class RestManager {
    public static func getRequest<Data: Codable> (url: String) -> Observable<Data> {
        
        return Observable.create { observer in
            let request = AF.request(url).validate().responseData { response in
                switch response.result {
                case .success(let value):
                    do {
                        let decoder = JSONDecoder()
                        let response = try decoder.decode(Data.self, from: value)

                        observer.onNext(response)
                        observer.onCompleted()
                    }
                    catch {
                        observer.onError(NetworkError.canNotProcessData)
                    }
                case .failure(let error):
                    if let afError = error.asAFError {
                        let error: NetworkError
                        
                        if self.isNotConnectedToInternet(afError) {
                            error = NetworkError.notConnectedToInternet
                        } else {
                            error = NetworkError.noDataAvailable
                        }
                        
                        observer.onError(error)
                    } else {
                        observer.onError(error)
                    }
                }
            }
                
            return Disposables.create{
                request.cancel()
            }
        }
    }

    private static func isNotConnectedToInternet(_ error: AFError) -> Bool {
        switch error {
        case .sessionTaskFailed(let sessionError):
            if let urlError = sessionError as? URLError, urlError.code == .notConnectedToInternet {
                return true
            } else {
                return false
            }
        default:
            return false
        }
    }
}

extension RestManager {
    public static func postRequest(url: String, postString: String) {
        guard let url = URL(string: url) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)

        AF.request(request).validate().responseData { response in
            switch response.result {
            case .success(let data):
                print(data)
            case .failure(let error):
                print(error)
            }
        }
    }
}
