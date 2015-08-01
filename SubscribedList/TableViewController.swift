//
//  ViewController.swift
//  SubscribedList
//
//  Created by Ian MacCallum on 7/30/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//

import UIKit
import CloudKit
import CoreData

class TableViewController: UITableViewController {
    
    let operationQueue = OperationQueue()
    var fetchedResultsController: NSFetchedResultsController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let operation = LoadModelOperation { context in
            // Now that we have a context, build our `FetchedResultsController`.
            dispatch_async(dispatch_get_main_queue()) {
                let request = NSFetchRequest(entityName: Event.entityName)
                request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
                request.fetchLimit = 100
                self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
                self.updateUI()
            }
        }
        operationQueue.addOperation(operation)
    }
    
    private func getEvents(userInitiated: Bool = true) {
        if let context = fetchedResultsController?.managedObjectContext {
            let getEventsOperation = GetEventsOperation(context: context) {
                dispatch_async(dispatch_get_main_queue()) {
                    // Indicate update
                    self.updateUI()
                }
            }
            
            getEventsOperation.userInitiated = userInitiated
            operationQueue.addOperation(getEventsOperation)
        } else {
        }
    }
    
    private func updateUI() {
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Error in the fetched results controller: \(error).")
        }
        tableView.reloadData()
    }
}

// MARK: - UITableView Data Source and Delegate Functions
extension TableViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellID", forIndexPath: indexPath)
        
        if let event = fetchedResultsController?.objectAtIndexPath(indexPath) as? Event {
            cell.textLabel?.text = "\(event.title)"
            cell.detailTextLabel?.text = "\(event.date)"
        }
        
        return cell
    }
}

// MARK: - NSFetchedResultsController Delegate Functions
extension TableViewController: NSFetchedResultsControllerDelegate {
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: NSManagedObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Update:
            tableView.cellForRowAtIndexPath(indexPath!)
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
}
