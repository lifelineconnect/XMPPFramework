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

	@IBOutlet weak var buttonNavigationTitle: UIButton!
	@IBOutlet weak var roomSubject: UILabel!
	@IBOutlet var chatInputView: InputView!
	@IBOutlet weak var tableHeaderView: UIView!
	weak var roomLight: XMPPRoomLight!
	weak var xmppController: XMPPController!
	var fetchedResultsController: NSFetchedResultsController!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.buttonNavigationTitle.setTitle(self.roomLight.roomname(), forState: .Normal)
		self.fetchedResultsController = self.createFetchedResultsController()
		self.chatInputView.delegate = self
		
		self.roomLight.addDelegate(self, delegateQueue: dispatch_get_main_queue())
		self.roomLight.getConfiguration()

		let gesture = UITapGestureRecognizer(target: self, action: #selector(self.tappedHeaderView(_:)))
		self.tableHeaderView.addGestureRecognizer(gesture)
		
		self.tableView.estimatedRowHeight = 50
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.tableFooterView = UIView()
    }
	
	func tappedHeaderView(sender: UIGestureRecognizer) {
		let alertController = UIAlertController.textFieldAlertController("Invite User", message: nil) { (name) in
			guard let newName = name else { return }
			self.roomLight.changeRoomSubject(newName)
			
			self.becomeFirstResponder()
		}
		
		self.navigationController!.presentViewController(alertController, animated: true, completion: nil)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		self.roomLight.removeDelegate(self)
	}

	func createFetchedResultsController() -> NSFetchedResultsController {
		let groupContext = self.xmppController.xmppRoomLightCoreDataStorage.mainThreadManagedObjectContext
		let entity = NSEntityDescription.entityForName("XMPPRoomLightMessageCoreDataStorageObject", inManagedObjectContext: groupContext)
		let roomJID = self.roomLight!.roomJID.bare()

		let predicate = NSPredicate(format: "roomJIDStr = %@", roomJID)
		let sortDescriptor = NSSortDescriptor(key: "localTimestamp", ascending: true)

		let request = NSFetchRequest()
		request.entity = entity
		request.predicate = predicate
		request.sortDescriptors = [sortDescriptor]

		let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: groupContext, sectionNameKeyPath: nil, cacheName: nil)
		controller.delegate = self
		try! controller.performFetch()

		return controller
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "RoomDetailsTableViewController" {
			let navController = segue.destinationViewController as! UINavigationController
			let viewController = navController.viewControllers[0] as! RoomDetailsTableViewController
			viewController.roomLight = 	self.roomLight
		}
	}

	@IBAction func addUserAction(sender: AnyObject) {
		let alertController = UIAlertController.textFieldAlertController("Invite User", message: nil) { (user) in
			guard let theUser = user, userJID = XMPPJID.jidWithString(theUser) else { return }
			self.roomLight.addUsers([userJID])

			self.becomeFirstResponder()
		}

		self.navigationController!.presentViewController(alertController, animated: true, completion: nil)
	}
	
	func changeSubject(newSubject: String) {
		if newSubject.characters.count == 0 {
			self.roomSubject.text = "- no subject -"
		} else {
			self.roomSubject.text = newSubject
		}
	}
}

extension ChatTableViewController: InputViewDelegate {

	override var inputAccessoryView: InputView {
		return self.chatInputView
	}

	override func canBecomeFirstResponder() -> Bool {
		return true
	}

	func sendButtonTouch(text: String) {
		self.roomLight.sendMessageWithBody(text)
	}
}

extension ChatTableViewController: XMPPRoomLightDelegate {

	func xmppRoomLight(sender: XMPPRoomLight, didGetConfiguration iqResult: XMPPIQ) {
		self.changeSubject(sender.subject())
	}

	func xmppRoomLight(sender: XMPPRoomLight, didSetConfiguration iqResult: XMPPIQ) {
		self.changeSubject(sender.subject())
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
		let cell = self.tableView.dequeueReusableCellWithIdentifier("ChatCellIdentifierCustom") as! ChatTableViewCell
		let message = self.fetchedResultsController.objectAtIndexPath(indexPath) as! XMPPRoomLightMessageCoreDataStorageObject
		cell.userLabel.text = message.streamBareJidStr
		cell.bodyLabel.text = message.body
		cell.backgroundColor = message.isFromMe ? UIColor.whiteColor() : UIColor(red: 246.0/255.0, green: 232/255.0, blue: 234/255.0, alpha: 1.0)
		return cell
	}

}

extension ChatTableViewController: NSFetchedResultsControllerDelegate {

	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
		self.tableView.reloadData()
		
		let lastIndex = NSIndexPath(forRow: self.fetchedResultsController.sections!.first!.numberOfObjects - 1, inSection: 0)
		self.tableView.scrollToRowAtIndexPath(lastIndex, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
	}
}
