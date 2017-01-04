//
//  CloudPersistenceManager.swift
//  VoiceMemo
//
//  Created by Alexey Papin on 03.01.17.
//  Copyright © 2017 Treehouse Island, Inc. All rights reserved.
//

import Foundation
import CloudKit

enum PersistenceError: MemoErrorType {
    case SaveFailed(description: String)
    case InsufficientInformation
    case InvalidData
    case QueryFailed(description: String)
    
    var description: String {
        switch self {
        case .SaveFailed(let description): return "Save Failed: \(description)"
        case .QueryFailed(let description): return "Query Failed: \(description)"
        default: return String(describing: self)
        }
    }
}

class CloudPersistenceManager {
    let privateDatabase = CKContainer.default().privateCloudDatabase
    
    func save(memo: Memo, completion: @escaping (Result<Memo>) -> Void) {
        let record = memo.persistableRecord
        self.privateDatabase.save(record) { record, error in
            guard let record = record else {
                if let error = error {
                    let persistenceError = PersistenceError.SaveFailed
                    completion(.Failure(persistenceError(description: error.localizedDescription)))
                } else {
                    let persistenceError = PersistenceError.InsufficientInformation
                    completion(.Failure(persistenceError))
                }
                return
            }
            guard let memo = Memo(record: record) else {
                let error = PersistenceError.InvalidData
                completion(.Failure(error))
                return
            }
            completion(.Success(memo))
        }
    }
    
    func performQuery(query: CKQuery, completion: @escaping (Result<[Memo]>) -> Void) {
        self.privateDatabase.perform(query, inZoneWith: nil) { records, error in
            guard let records = records else {
                if let error = error {
                    let persistenceError = PersistenceError.QueryFailed(description: error.localizedDescription)
                    completion(.Failure(persistenceError))
                } else {
                    let persistenceError = PersistenceError.InsufficientInformation
                    completion(.Failure(persistenceError))
                }
                return
            }
            
            let memos = records.flatMap { Memo(record: $0) }
            completion(.Success(memos))
        }
    }
    
    func fetch(recordId: CKRecordID, completion: @escaping (Result<Memo>) -> Void) {
        self.privateDatabase.fetch(withRecordID: recordId) { record, error in
            guard let record = record else {
                if let error = error {
                    let persistenceError = PersistenceError.QueryFailed(description: error.localizedDescription)
                    completion(.Failure(persistenceError))
                } else {
                    let persistenceError = PersistenceError.InsufficientInformation
                    completion(.Failure(persistenceError))
                }
                return
            }
            guard let memo = Memo(record: record) else {
                let error = PersistenceError.InvalidData
                completion(.Failure(error))
                return
            }
            completion(.Success(memo))
        }
    }
}







