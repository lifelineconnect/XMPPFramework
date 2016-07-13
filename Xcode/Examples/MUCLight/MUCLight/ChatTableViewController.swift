//
//  ChatTableViewController.swift
//  MUCLight
//
//  Created by Andres on 7/13/16.
//  Copyright © 2016 Inaka. All rights reserved.
//

import UIKit
import XMPPFramework

class ChatTableViewController: UITableViewController {

	weak var roomLight: XMPPRoomLight!
	weak var xmppController: XMPPController!
	var fetchedResultsController: NSFetchedResultsController!

    override func viewDidLoad() {
        super.viewDidLoad()
		self.title = roomLight.roomname()
		
		self.fetchedResultsController = self.createFetchedResultsController()
    }

	func createFetchedResultsController() -> NSFetchedResultsController {
		let groupContext = self.xmppController.xmppRoomLightCoreDataStorage.mainThreadManagedObjectContext
		let entity = NSEntityDescription.entityForName("XMPPRoomLightMessageCoreDataStorageObject", inManagedObjectContext: groupContext)
		let roomJID = self.roomLight!.roomJID.bare()
		
		let predicate = NSPredicate(format: "roomJIDStr = %@", roomJID)
		let sortDescriptor = NSSortDescriptor(key: "localTimestamp", ascending: false)
		
		let request = NSFetchRequest()
		request.entity = entity
		request.predicate = predicate
		request.sortDescriptors = [sortDescriptor]
		
		let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: groupContext, sectionNameKeyPath: nil, cacheName: nil)
		controller.delegate = self
		try! controller.performFetch()
		
		return controller
	}
}

extension ChatTableViewController {
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return self.fetchedResultsController.sections!.count
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.fetchedResultsController.sections!.first!.numberOfObjects
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = self.tableView.dequeueReusableCellWithIdentifier("ChatCellIdentifier")!
		let message = self.fetchedResultsController.objectAtIndexPath(indexPath) as! XMPPRoomLightMessageCoreDataStorageObject
		cell.textLabel?.text = message.streamBareJidStr
		cell.detailTextLabel?.text = message.body
		cell.backgroundColor = message.isFromMe ? UIColor.whiteColor() : UIColor(red: 246.0/255.0, green: 232/255.0, blue: 234/255.0, alpha: 1.0)
		return cell
	}
}

extension ChatTableViewController: NSFetchedResultsControllerDelegate {

	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
		self.tableView.reloadData()
	}

}
