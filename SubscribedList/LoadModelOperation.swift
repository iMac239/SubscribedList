/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file contains the code to create the Core Data stack.
*/

import CoreData

/**
    An `Operation` subclass that loads the Core Data stack. If this operation fails, 
    it will produce an `AlertOperation` that will offer to retry the operation.
*/
class LoadModelOperation: Operation {
    // MARK: Properties
    let loadHandler: NSManagedObjectContext -> Void
    
    // MARK: - Core Data stack
    lazy var url: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1].URLByAppendingPathComponent("SingleViewCoreData.sqlite")
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("SubscribedList", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)

        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    init(loadHandler: NSManagedObjectContext -> Void) {
        self.loadHandler = loadHandler
        super.init()
        addCondition(MutuallyExclusive<LoadModelOperation>())
    }
    
    override func execute() {
        
        var error = createStore(persistentStoreCoordinator, atURL: url)

        if persistentStoreCoordinator.persistentStores.isEmpty {
            destroyStore(persistentStoreCoordinator, atURL: url)
            error = createStore(persistentStoreCoordinator, atURL: url)
        }
        
        if persistentStoreCoordinator.persistentStores.isEmpty {
            print("Error creating SQLite store: \(error).")
            print("Falling back to `.InMemory` store.")
            error = createStore(persistentStoreCoordinator, atURL: nil, type: NSInMemoryStoreType)
        }
        
        if !persistentStoreCoordinator.persistentStores.isEmpty {
            loadHandler(managedObjectContext)
            error = nil
        }
        
        finishWithError(error)
    }
    
    private func createStore(persistentStoreCoordinator: NSPersistentStoreCoordinator, atURL URL: NSURL?, type: String = NSSQLiteStoreType, options: [NSObject : AnyObject]? = nil) -> NSError? {
        var error: NSError?
        do {
            try persistentStoreCoordinator.addPersistentStoreWithType(type, configuration: nil, URL: URL, options: nil)
        } catch let storeError as NSError {
            error = storeError
        }
        return error
    }
    
    private func destroyStore(persistentStoreCoordinator: NSPersistentStoreCoordinator, atURL URL: NSURL, type: String = NSSQLiteStoreType) {
        do {
            if #available(iOS 9.0, *) {
                let _ = try persistentStoreCoordinator.destroyPersistentStoreAtURL(URL, withType: type, options: nil)
            } else {
                // Fallback on earlier versions
            }
        }
        catch { }
    }
    
    override func finished(errors: [NSError]) {
        guard let firstError = errors.first where userInitiated else { return }
        
        let alert = AlertOperation()
        alert.title = "Unable to load database"
        alert.message = "An error occurred while loading the database. \(firstError.localizedDescription). Please try again later."
        
        // No custom action for this button.
        alert.addAction("Retry Later", style: .Cancel)
        
        // Declare this as a local variable to avoid capturing self in the closure below.
        let handler = loadHandler
        
        alert.addAction("Retry Now") { alertOperation in
            let retryOperation = LoadModelOperation(loadHandler: handler)
            retryOperation.userInitiated = true
            alertOperation.produceOperation(retryOperation)
        }

        produceOperation(alert)
    }
}
