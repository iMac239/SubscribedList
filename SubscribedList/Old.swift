//
//  Old.swift
//  SubscribedList
//
//  Created by Ian MacCallum on 7/31/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//

import Foundation

/*


@IBAction func fetchChangedEvents(sender: UIBarButtonItem) {
let token = NSUserDefaults.standardUserDefaults().archivedObjectForKey("ServerChangeToken") as? CKServerChangeToken

let fetchRecordChangesOperation = CKFetchRecordChangesOperation(recordZoneID: CKRecordZone.defaultRecordZone().zoneID, previousServerChangeToken: token)
fetchRecordChangesOperation.fetchRecordChangesCompletionBlock = { token, data, error in
print("token: \(token)")
print("data: \(data)")
print("error: \(error?.localizedDescription)")
NSUserDefaults.standardUserDefaults().setUnarchivedObject(token, forKey: "ServerChangeToken")
}

CloudManager().queue.addOperation(fetchRecordChangesOperation)
}



let cm = CloudManager()
let fetchEventsOperation = FetchEventsOperation()
fetchEventsOperation.database = cm.publicDatabase
fetchEventsOperation.completion = { events, error in
print("completion: \(events?.count), error: \(error?.localizedDescription)")
}
let queue = NSOperationQueue()
queue.addOperation(fetchEventsOperation)









//        let zoneSubscription = CKSubscription(zoneID: CKRecordZoneID(zoneName: <#T##String#>, ownerName: <#T##String#>), options: <#T##CKSubscriptionOptions#>)



//        let cm = CloudManager()
//




*/