//
//  CloudManager.swift
//  SubscribedList
//
//  Created by Ian MacCallum on 7/30/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//

import Foundation
import CloudKit
import CoreData
import UIKit


class CKManager {
    let queue = NSOperationQueue()
    let container = CKContainer.defaultContainer()
    var publicDatabase: CKDatabase?
    
    init() {
        publicDatabase = container.publicCloudDatabase
    }
    
    func fetchRecord(recordID: CKRecordID) {
        publicDatabase?.fetchRecordWithID(recordID, completionHandler: { record, error in
                self.saveEventRecord(record)
            
        })
    }
    
    func saveEventRecord(record: CKRecord?) {
        print("saving record")
        
        guard let record = record else { return }
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let newEvent = NSEntityDescription.insertNewObjectForEntityForName(CDEvent.entityName, inManagedObjectContext: appDelegate.stack.managedObjectContext) as? CDEvent
        
        newEvent?.recordID = record.recordID
        newEvent?.title = record.objectForKey("title") as? String
        newEvent?.date = record.objectForKey("date") as? NSDate
        newEvent?.location = record.objectForKey("location") as? CLLocation

        dispatch_async(dispatch_get_main_queue()) {
            try? appDelegate.stack.managedObjectContext.save()
        }
    }
    
    func fetchRecords(ids: [CKRecordID]) {
        print("fetching records")
        let operation = CKFetchRecordsOperation(recordIDs: ids)
        operation.fetchRecordsCompletionBlock = { dict, error in
            print("fetched records: \(dict)")
            dict?.forEach { self.saveEventRecord($0.1) }
        }
        queue.addOperation(operation)
    }
    
    func fetchAllRecords() {
        let query = CKQuery(recordType: "CKEvent", predicate: NSPredicate(value: true))
        
        let operation = CKQueryOperation(query: query)
        operation.queryCompletionBlock = {cursor, error in
            guard error != nil else {
                return
            }
            
        }
        
       publicDatabase?.addOperation(operation)
    }

    
    func checkSubscribed(completion: (subscription: CKSubscription?, error: NSError?) -> Void) {
        
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("SubscriptionID") as? NSData, subscription = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? CKSubscription {
            completion(subscription: subscription, error: nil)
        } else {
            let predicate = NSPredicate(format: "date > %@", NSDate())
            let createSubscription = CKSubscription(recordType: "CKEvent", predicate: predicate, options: .FiresOnRecordCreation)
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
