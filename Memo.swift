//
//  Memo.swift
//  VoiceMemo
//
//  Created by Alexey Papin on 02.01.17.
//  Copyright © 2017 Treehouse Island, Inc. All rights reserved.
//

import Foundation
import CloudKit

struct Memo {
    static let entityName = "\(Memo.self)"
    let id: CKRecordID?
    let title: String
    let fileURLString: String
    
}

extension Memo {
    var fileURL: URL {
        return URL(fileURLWithPath: self.fileURLString)
    }
}

extension Memo {
    var persistableRecord: CKRecord {
        let record = CKRecord(recordType: Memo.entityName)
        record.setValue(self.title, forKey: "title")
        let asset = CKAsset(fileURL: self.fileURL)
        record.setValue(asset, forKey: "recording")
        return record
    }
}

extension Memo {
    init?(record: CKRecord) {
        guard
            let title = record["title"] as? String,
            let asset = record["recording"] as? CKAsset else {
                return nil
        }
        self.id = record.recordID
        self.title = title
        self.fileURLString = asset.fileURL.absoluteString
    }
}

extension Memo {
    var track: Data? {
        do {
            let data = try Data(contentsOf: self.fileURL)
            return data
        } catch {
            return nil
        }
    }
}
