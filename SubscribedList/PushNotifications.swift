//
//  AppDelegateCoreDataStack.swift
//  SubscribedList
//
//  Created by Ian MacCallum on 7/30/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

extension AppDelegate {
    
    func subscribeForRemoteNotifications() {
        let cm = CloudManager()
        let predicate = NSPredicate(value: true)
        let subscription = CKSubscription(recordType: "Event",
            predicate: predicate,
            options: [.FiresOnRecordCreation, .FiresOnRecordDeletion, .FiresOnRecordUpdate])
        
        let notificationInfo = CKNotificationInfo()
        
        notificationInfo.alertBody = "A new House was added"
        notificationInfo.shouldBadge = true
        
        subscription.notificationInfo = notificationInfo
        
        cm.publicDatabase?.fetchSubscriptionWithID(subscription.subscriptionID) { existingSubscription, error in
            if let _ = existingSubscription {
                print("subscription exists")
            } else {
                cm.publicDatabase?.saveSubscription(subscription) { returnRecord, error in
                    if let err = error {
                        print("subscription failed %@", err.code)
                    } else {
                        print("successfully registered")
                    }
                }
            }
        }
    }
    
    
    func registerForNotifications(application: UIApplication) {
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {

    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("remote notification")
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("ServerChangeToken") as? CKServerChangeToken
        
        let fetchRecordChangesOperation = CKFetchRecordChangesOperation(recordZoneID: CKRecordZone.defaultRecordZone().zoneID, previousServerChangeToken: token)
        fetchRecordChangesOperation.fetchRecordChangesCompletionBlock = { token, data, error in
            
        }
        
        
        let cloudKitNotification = CKNotification(fromRemoteNotificationDictionary: userInfo  as! [String: NSObject])
        
        
        if cloudKitNotification.notificationType == .Query {
            let queryNotification = cloudKitNotification as! CKQueryNotification
            let id = queryNotification.recordID
            print(id)
            
            switch queryNotification.queryNotificationReason {
            case .RecordCreated:
                print("created")
            case .RecordDeleted:
                print("deleted")
            case .RecordUpdated:
                print("update")
            }
        }
    }
    
    
}