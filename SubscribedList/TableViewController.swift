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
    
    let fetchedResultsController: NSFetchedResultsController
    let stack: CoreDataStack

    required init?(coder aDecoder: NSCoder) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.stack = appDelegate.stack

        let request = NSFetchRequest(entityName: CDEvent.entityName)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: stack.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)

        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchedResultsController.delegate = self

        updateUI()
    }
    
    @IBAction func addButtonPressed(sender: UIBarButtonItem) {
        
        let controller = UIAlertController(title: "Add Event", message: nil, preferredStyle: .Alert)
        controller.addTextFieldWithConfigurationHandler { textField in
            textField.placeholder = "title"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in
            
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .Default) { action in
            self.createEvent(controller.textFields![0].text ?? "")
        }
        
        controller.addAction(cancelAction)
        controller.addAction(saveAction)
        
        presentViewController(controller, animated: true) {}
    }
    
    func createEvent(title: String, date: NSDate = NSDate(), location: CLLocation? = nil) {

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let record = CKRecord(recordType: "CKEvent")
        record.setObject(title, forKey: "title")
        record.setObject(date, forKey: "date")
        record.setObject(location, forKey: "location")
        
        
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecords, error in
            print("saved \(savedRecords?.count ?? 0) to cloud")
        }
        
        appDelegate.cloud.publicDatabase?.addOperation(operation)
    }

    private func updateUI() {
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error in the fetched results controller: \(error.localizedDescription).")
        }
        tableView.reloadData()
    }
}

// MARK: - UITableView Data Source and Delegate Functions
extension TableViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellID", forIndexPath: indexPath)
        
        if let event = fetchedResultsController.objectAtIndexPath(indexPath) as? CDEvent {
            cell.textLabel?.text = "\(event.title)"
            cell.detailTextLabel?.text = "\(event.date)"
        }
        
        return cell
    }    
}

// MARK: - NSFetchedResultsController Delegate Functions
extension TableViewController: NSFetchedResultsControllerDelegate {

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        print("object changed")
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
}
