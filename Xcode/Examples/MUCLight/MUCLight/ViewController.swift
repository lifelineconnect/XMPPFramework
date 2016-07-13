//
//  ViewController.swift
//  MUCLight
//
//  Created by Andres Canal on 7/12/16.
//  Copyright © 2016 Inaka. All rights reserved.
//

import UIKit
import XMPPFramework

class ViewController: UITableViewController {

	var logInPresented = false
	var roomsLight = [XMPPRoomLight]()
	weak var logInViewController: LogInViewController?

	var xmppController: XMPPController! {
		didSet {
			self.xmppController.xmppStream.addDelegate(self, delegateQueue: dispatch_get_main_queue())
			self.xmppController.xmppMUCLight.addDelegate(self, delegateQueue: dispatch_get_main_queue())
			self.xmppController.connect()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.tableView.delegate = self
		self.tableView.dataSource = self
		self.tableView.allowsMultipleSelectionDuringEditing = false
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		if !self.logInPresented {
			self.logInPresented = true
			self.performSegueWithIdentifier("LogInViewController", sender: nil)
		}
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "LogInViewController" {
			let viewController = segue.destinationViewController as! LogInViewController
			viewController.delegate = self
		} else if segue.identifier == "ChatTableViewController" {
			let viewController = segue.destinationViewController as! ChatTableViewController
			viewController.roomLight = (sender as! XMPPRoomLight)
			viewController.xmppController = self.xmppController
		}
	}

	@IBAction func createNewRoomAction(sender: UIBarButtonItem) {
		let alertController = UIAlertController.textFieldAlertController("New room name", message: nil) { (roomname) in
			guard let rName = roomname else { return }

			let xmppRoomLight = XMPPRoomLight(JID: XMPPJID.jidWithString(self.xmppController.mucLightDomain)!, roomname: rName)
			xmppRoomLight.activate(self.xmppController.xmppStream)
			xmppRoomLight.createRoomLightWithMembersJID(nil)
		}

		self.presentViewController(alertController, animated: true, completion: nil)
	}

	func refreshRooms() {
		self.xmppController.fetchMUCLightRooms()
	}

	func refreshTable(rooms: [DDXMLElement]) {
		let roomLightStorage = self.xmppController.xmppRoomLightCoreDataStorage
		let xmppStream = self.xmppController.xmppStream

		rooms.forEach { (roomElement) in
			guard let jidString = roomElement.attributeForName("jid")?.stringValue,
				let roomName = roomElement.attributeForName("name")?.stringValue,
				let roomJID = XMPPJID.jidWithString(jidString) else { return }
			
			if !self.roomsLight.contains({ $0.roomJID.full() == jidString }) {
				let room = XMPPRoomLight(roomLightStorage: roomLightStorage, jid: roomJID, roomname: roomName, dispatchQueue: nil)
				room.activate(xmppStream)
				room.addDelegate(self, delegateQueue: dispatch_get_main_queue())
				self.roomsLight.append(room)
			}
		}
		
		self.tableView.reloadData()
	}

	func start(userJID: String, userPassword: String, server: String) {
		guard let jid = XMPPJID.jidWithString(userJID) else { return }
		self.xmppController = XMPPController(hostName: server,
		                                     userJID: jid,
		                                     password: userPassword)
	}

}

extension ViewController {

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.roomsLight.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = self.tableView.dequeueReusableCellWithIdentifier("RoomCellIdentifier")!
		let room = self.roomsLight[indexPath.row]

		cell.textLabel?.text = room.roomname()
		cell.detailTextLabel?.text = room.roomJID.full()
		
		return cell
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let room = self.roomsLight[indexPath.row]
		self.performSegueWithIdentifier("ChatTableViewController", sender: room)
	}
	
	override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
		
		let leave = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Leave"){(UITableViewRowAction,NSIndexPath) in
			self.roomsLight[indexPath.row].leaveRoomLight()
		}
		leave.backgroundColor = UIColor.orangeColor()
		return [leave]
	}
}

extension ViewController: XMPPMUCLightDelegate {

	func xmppMUCLight(sender: XMPPMUCLight, didDiscoverRooms rooms: [DDXMLElement], forServiceNamed serviceName: String) {
		self.refreshTable(rooms)
	}
	
	func xmppMUCLight(sender: XMPPMUCLight, changedAffiliation affiliation: String, roomJID: XMPPJID) {
		self.refreshRooms()
	}

}

extension ViewController: XMPPRoomLightDelegate {

	func xmppRoomLight(sender: XMPPRoomLight, didLeaveRoomLight iq: XMPPIQ) {
		if let index = self.roomsLight.indexOf(sender) {
			self.roomsLight.removeAtIndex(index)
		}
		self.tableView.reloadData()
	}
}

extension ViewController: XMPPStreamDelegate {

	func xmppStreamDidAuthenticate(sender: XMPPStream!) {
		self.logInViewController?.dismissViewControllerAnimated(true, completion: nil)
		self.refreshRooms()
	}

	func xmppStream(sender: XMPPStream!, didNotAuthenticate error: DDXMLElement!) {
		self.logInViewController?.showErrorMessage()
	}
}

extension ViewController: LogInViewControllerDelegate {

	func didTouchLogIn(sender: LogInViewController, userJID: String, userPassword: String, server: String) {
		self.logInViewController = sender
		self.start(userJID, userPassword: userPassword, server: server)
	}

}
