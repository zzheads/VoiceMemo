//
//  DataProvider.swift
//  VoiceMemo
//
//  Created by Alexey Papin on 03.01.17.
//  Copyright © 2017 Treehouse Island, Inc. All rights reserved.
//

import Foundation
import CloudKit

protocol DataProviderDelegate: class {
    func processUpdates(updates: [DataProviderUpdate<Memo>])
    func providerFailedWithError(error: MemoErrorType)
}

enum DataProviderUpdate<T> {
    case Insert(T)
}

class DataProvider {
    let manager = CloudPersistenceManager()
    var updates = [DataProviderUpdate<Memo>]()
    
    private weak var delegate: DataProviderDelegate?
    
    init(delegate: DataProviderDelegate?) {
        self.delegate = delegate
    }
    
    func performQuery(type: QueryType) {
        self.manager.performQuery(query: type.query) { result in
            self.processResult(result: result)
        }
    }
    
    func fetch(recordId: CKRecordID) {
        self.manager.fetch(recordId: recordId) { result in
            self.processResult(result: result)
        }
    }
    
    func save(memo: Memo) {
        self.manager.save(memo: memo) { result in
            self.processResult(result: result)
        }
    }
    
    private func processResult(result: Result<[Memo]>) {
        DispatchQueue.main.async {
            switch result {
            case .Success(let memos):
                self.updates = memos.map { DataProviderUpdate.Insert($0) }
                guard let delegate = self.delegate else {
                    return
                }
                delegate.processUpdates(updates: self.updates)
            case .Failure(let error):
                print(error.description)
                guard let delegate = self.delegate else {
                    return
                }
                delegate.providerFailedWithError(error: error)
            }
        }
    }
    
    private func processResult(result: Result<Memo>) {
        DispatchQueue.main.async {
            switch result {
            case .Success(let memo):
                self.updates = [DataProviderUpdate.Insert(memo)]
                guard let delegate = self.delegate else {
                    return
                }
                delegate.processUpdates(updates: self.updates)
            case .Failure(let error):
                print(error.description)
                guard let delegate = self.delegate else {
                    return
                }
                delegate.providerFailedWithError(error: error)
            }
        }
    }
}


