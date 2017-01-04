//
//  QueryType.swift
//  VoiceMemo
//
//  Created by Alexey Papin on 03.01.17.
//  Copyright © 2017 Treehouse Island, Inc. All rights reserved.
//

import Foundation
import CloudKit

enum QueryType {
    case All
}

extension QueryType {
    var query: CKQuery {
        switch self {
        case .All:
            let allPredicate = NSPredicate(value: true)
            let query = CKQuery(recordType: Memo.entityName, predicate: allPredicate)
            query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            return query
        }
    }
}
