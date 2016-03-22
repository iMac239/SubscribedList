//
//  Extensions.swift
//  SubscribedList
//
//  Created by Ian MacCallum on 7/30/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//

import Foundation
import UIKit

extension NSUserDefaults {
    func setUnarchivedObject(object: AnyObject?, forKey key: String) {
        if let object = object {
            let data = NSKeyedArchiver.archivedDataWithRootObject(object)
            setObject(data, forKey: key)
        } else {
            setObject(nil, forKey: key)
        }
    }
    
    func archivedObjectForKey(key: String) -> AnyObject? {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey(key) as? NSData, object = NSKeyedUnarchiver.unarchiveObjectWithData(data) {
            return object
        } else {
            return nil
        }
    }
}