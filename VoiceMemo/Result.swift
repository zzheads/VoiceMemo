//
//  Result.swift
//  VoiceMemo
//
//  Created by Alexey Papin on 03.01.17.
//  Copyright © 2017 Treehouse Island, Inc. All rights reserved.
//

import Foundation

protocol MemoErrorType: Error {
    var description: String { get }
}

enum Result<T> {
    case Success(T)
    case Failure(MemoErrorType)
}
