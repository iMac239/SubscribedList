//
//  CKEvent.swift
//  SubscribedList
//
//  Created by Ian MacCallum on 9/21/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//

import Foundation
import CloudKit

struct CKEvent: Event {
    let record: CKRecord
    
    init(record: CKRecord) {
        self.record = record
        recordID = self.record.recordID
    }
    
    init() {
        self.record = CKRecord(recordType: "CKEvent")
        recordID = self.record.recordID
    }
    
    var title: String? {
        get {
            return record.objectForKey("title") as? String
        }
        set {
            record.setObject(newValue, forKey: "title")
        }
    }
    var date: NSDate? {
        get {
            return record.objectForKey("date") as? NSDate
        }
        set {
            record.setObject(newValue, forKey: "date")
        }
    }
    var location: CLLocation? {
        get {
            return record.objectForKey("location") as? CLLocation
        }
        set {
            record.setObject(newValue, forKey: "location")
        }
    }
    var recordID: CKRecordID?
}