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
        
        let predicate = NSPredicate(value: true)
        let subscription = CKSubscription(recordType: "CKEvent",
            predicate: predicate,
            options: [.FiresOnRecordCreation, .FiresOnRecordDeletion, .FiresOnRecordUpdate])
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = "An event has been created, updated, or deleted!"
        notificationInfo.shouldBadge = false
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        cloud.publicDatabase?.fetchSubscriptionWithID(subscription.subscriptionID) { existingSubscription, error in
            
            if let _ = existingSubscription {
                print("subscription exists")
            } else {
                self.cloud.publicDatabase?.saveSubscription(subscription) { returnRecord, error in
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
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {

        let aps = userInfo["aps"] as! [String : AnyObject]
        print(aps)
        
        let ca = aps["content-available"]
        print(ca)
        
        
        if application.applicationState == .Inactive || application.applicationState == .Active {
            
            
            let cloudKitNotification = CKNotification(fromRemoteNotificationDictionary: userInfo  as! [String: NSObject])
            if cloudKitNotification.notificationType == .Query {
                let queryNotification = cloudKitNotification as! CKQueryNotification
                if let id = queryNotification.recordID {
                    switch queryNotification.queryNotificationReason {
                    case .RecordCreated:
                        print("created")
                        cloud.fetchRecord(id)
                        
                    case .RecordDeleted:
                        print("deleted")
                        
                    case .RecordUpdated:
                        print("update")
                    }
                }
            }
            
            
        } else {
            print("Background")
        }
        
        completionHandler(UIBackgroundFetchResult.NewData)
    }
 }