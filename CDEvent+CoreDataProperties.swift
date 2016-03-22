//
//  Event+CoreDataProperties.swift
//  SubscribedList
//
//  Created by Ian MacCallum on 8/3/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData
import CoreLocation
import CloudKit

extension CDEvent: Event {
    
    @NSManaged var recordID: CKRecordID?
    @NSManaged var date: NSDate?
    @NSManaged var location: CLLocation?
    @NSManaged var title: String?

}
