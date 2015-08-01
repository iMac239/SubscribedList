//
//  CloudManager.swift
//  SubscribedList
//
//  Created by Ian MacCallum on 7/30/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//

import Foundation
import CloudKit

class FetchEventsOperation: CKQueryOperation {
    var fetchedEvents = [CKRecord]()
    var completion: ((events: [CKRecord]?, error: NSError?) -> Void)?
    override func start() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Event", predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)

        executeQueryOperation(queryOperation)
        print("a")
        super.start()
    }
    
    func executeQueryOperation(queryOperation: CKQueryOperation) {
        queryOperation.recordFetchedBlock = { record in
            self.fetchedEvents.append(record)
        }
        
        print("b")
        queryOperation.queryCompletionBlock = { cursor, error in
            print("c")
            if let error = error {
                self.completion?(events: self.fetchedEvents, error: error)
            } else if let cursor = cursor {
                let fetchMoreRecords = CKQueryOperation(cursor: cursor)
                self.executeQueryOperation(fetchMoreRecords)
            } else {
                self.completion?(events: self.fetchedEvents, error: nil)
            }
        }
        
        database?.addOperation(queryOperation)
    }
}

class CloudManager {
    let queue = NSOperationQueue()
    let container = CKContainer.defaultContainer()
    var publicDatabase: CKDatabase?
    
    init() {
        publicDatabase = container.publicCloudDatabase
    }
        
    func checkSubscribed(completion: (subscription: CKSubscription?, error: NSError?) -> Void) {
        
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("SubscriptionID") as? NSData, subscription = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? CKSubscription {
            completion(subscription: subscription, error: nil)
        } else {
            let predicate = NSPredicate(format: "date > %@", NSDate())
            let createSubscription = CKSubscription(recordType: "Event", predicate: predicate, options: .FiresOnRecordCreation)
            publicDatabase?.saveSubscription(createSubscription) { (subscription, error) in
                guard let subscription = subscription else {
                    completion(subscription: nil, error: error)
                    return
                }
                
                completion(subscription: subscription, error: nil)
                let data = NSKeyedArchiver.archivedDataWithRootObject(subscription)
                NSUserDefaults.standardUserDefaults().setObject(data, forKey: "SubscriptionID")
            }
        }
    }
}


/*

if let ckErr = CKErrorCode(rawValue: err.code) {

switch ckErr {
case .AssetFileModified:
print("AssetFileModified")
case .AssetFileNotFound:
print("AssetFileNotFound")
case .BadContainer:
print("BadContainer")
case .BadDatabase:
print("BadDatabase")
case .BatchRequestFailed:
print("BatchRequestFailed")
case .ChangeTokenExpired:
print("ChangeTokenExpired")
case .ConstraintViolation:
print("ConstraintViolation")
case .IncompatibleVersion:
print("IncompatibleVersion")
case .InternalError:
print("InternalError")
case .InvalidArguments:
print("InvalidArguments")
case .LimitExceeded:
print("LimitExceeded")
case .MissingEntitlement:
print("MissingEntitlement")
case .NetworkFailure:
print("NetworkFailure")
case .NetworkUnavailable:
print("NetworkUnavailable")
case .NotAuthenticated:
print("NotAuthenticated")
case .OperationCancelled:
print("OperationCancelled")
case .PartialFailure:
print("PartialFailure")
case .PermissionFailure:
print("PermissionFailure")
case .QuotaExceeded:
print("QuotaExceeded")
case .RequestRateLimited:
print("RequestRateLimited")
case .ResultsTruncated:
print("ResultsTruncated")
case .ServerRecordChanged:
print("ServerRecordChanged")
case .ServerRejectedRequest:
print("ServerRejectedRequest")
case .ServiceUnavailable:
print("ServiceUnavailable")
case .UnknownItem:
print("UnknownItem")
case .UserDeletedZone:
print("UserDeletedZone")
case .ZoneBusy:
print("ZoneBusy")
case .ZoneNotFound:
print("ZoneNotFound")
}
}


*/

