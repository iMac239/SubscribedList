//
//  CKRecordExtension.swift
//  SubscribedList
//
//  Created by Ian MacCallum on 9/18/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//

import Foundation
import CloudKit

extension CKRecord {
    func toDict() -> [String: CKRecordValue] {
        var dict: [String: CKRecordValue] = [:]
        allKeys().forEach { dict[$0] = self[$0] }
        return dict
    }
}

