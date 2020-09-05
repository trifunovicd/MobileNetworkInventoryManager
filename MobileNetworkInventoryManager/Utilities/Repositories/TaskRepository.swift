//
//  TaskRepository.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 22/08/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
import RxSwift

public class TaskRepositoryImpl: TaskRepository, UrlMaker {
    public func getTasks(userId: Int) -> Observable<DataWrapper<[Task]>> {
        let observable: Observable<[Task]> = RestManager.getRequest(url: makeUrl(action: .getTasksForUser, userId: userId))
        return observable.mapToDataWrapperAndHandleError()
    }
    
    public func getTaskStatuses() -> Observable<DataWrapper<[TaskStatus]>> {
        let observable: Observable<[TaskStatus]> = RestManager.getRequest(url: makeUrl(action: .getTaskStatus, userId: nil))
        return observable.mapToDataWrapperAndHandleError()
    }
    
    public func setTaskStatus(taskId: Int) -> Observable<Int> {
        let postString = R.string.localizable.update_task_status(taskId, Date().getMSSQLVariant())
        let observable: Observable<Int> = RestManager.postRequest(url: Urls.baseUrlPost.rawValue, postString: postString)
        return observable
    }
}

public protocol TaskRepository {
    func getTasks(userId: Int) -> Observable<DataWrapper<[Task]>>
    func getTaskStatuses() -> Observable<DataWrapper<[TaskStatus]>>
    func setTaskStatus(taskId: Int) -> Observable<Int>
}
