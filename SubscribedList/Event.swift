//
//  EventProtocol.swift
//  SubscribedList
//
//  Created by Ian MacCallum on 9/21/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//

import Foundation
import CloudKit

protocol Event {
    var recordID: CKRecordID? { get set }
    var date: NSDate? { get set }
    var location: CLLocation? { get set }
    var title: String? { get set }
}