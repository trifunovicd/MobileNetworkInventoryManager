//
//  SortViewModel.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 01/06/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class SortViewModel: ViewModelType {
    
    public struct Input {
        let loadDataSubject: ReplaySubject<()>
    }
    
    public struct Output {
        var disposables: [Disposable]
        let showView: PublishSubject<Bool>
        var settings: (value: Int, order: Int)?
        let window = UIApplication.shared.keyWindow
        let screenSize = UIScreen.main.bounds.size
        var height: CGFloat = 260
        let orderArray = [R.string.localizable.ascending(), R.string.localizable.descending()]
        var itemsArray: [String]
    }
    
    public struct Dependecies {
        let subscribeScheduler: SchedulerType
        weak var delegate: SortDelegate?
        let sortType: SortType
        let frame: CGRect
    }
    
    public init(dependecies: Dependecies) {
        self.dependecies = dependecies
    }
    
    var input: Input!
    var output: Output!
    var dependecies: Dependecies

    public func transform(input: Input) -> Output {
        var disposables = [Disposable]()
        disposables.append(initializeLoadDataObservable(for: input.loadDataSubject))
        
        let output = Output(disposables: disposables, showView: PublishSubject(), itemsArray: [])
        
        self.input = input
        self.output = output
        
        return output
    }
}

private extension SortViewModel {
    func initializeLoadDataObservable(for subject: ReplaySubject<()>) -> Disposable {
        return subject.map {[unowned self] (_) -> [String] in
            return self.createItems(sortType: self.dependecies.sortType)
        }
        .observeOn(MainScheduler.instance)
        .subscribeOn(dependecies.subscribeScheduler)
        .subscribe(onNext: { [unowned self] (items) in
            self.output.itemsArray = items
        })
    }
    
    func createItems(sortType: SortType) -> [String] {
        switch sortType {
        case .sites:
            return [R.string.localizable.scope_mark(), R.string.localizable.scope_name(), R.string.localizable.scope_address(), R.string.localizable.distance()]
        case .tasks:
            return [R.string.localizable.scope_date(), R.string.localizable.scope_mark(), R.string.localizable.scope_name(), R.string.localizable.scope_task(), R.string.localizable.distance()]
        }
    }
}
