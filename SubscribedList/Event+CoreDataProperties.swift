//
//  Event+CoreDataProperties.swift
//  SubscribedList
//
//  Created by Ian MacCallum on 7/30/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension Event {

    @NSManaged var recordID: NSObject?
    @NSManaged var title: String?
    @NSManaged var date: NSDate?
    @NSManaged var location: NSObject?

}
