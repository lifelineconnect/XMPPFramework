//
//  RoomDetailsTableViewController.swift
//  MUCLight
//
//  Created by Andres Canal on 7/15/16.
//  Copyright © 2016 Inaka. All rights reserved.
//

import UIKit
import XMPPFramework
import MBProgressHUD

class RoomDetailsTableViewController: UITableViewController {

	weak var roomLight: XMPPRoomLight!
	var members = Array<(name: String, affiliation: String)>()

    override func viewDidLoad() {
        super.viewDidLoad()
		self.roomLight.addDelegate(self, delegateQueue: dispatch_get_main_queue())
		
		let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
		hud.labelText = "Signing in..."

		self.roomLight.fetchMembersList()
	}

	override func viewWillDisappear(animated: Bool) {
		self.roomLight.removeDelegate(self)
	}
}

extension RoomDetailsTableViewController {

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return members.count
	}

	@IBAction func close(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = self.tableView.dequeueReusableCellWithIdentifier("RoomDetailsCellIdentifier")!
		let member = members[indexPath.row]

		cell.textLabel?.text = member.name
		cell.detailTextLabel?.text = member.affiliation
		return cell
	}
}

extension RoomDetailsTableViewController: XMPPRoomLightDelegate {

	func xmppRoomLight(sender: XMPPRoomLight, didFetchMembersList items: [DDXMLElement]) {
		self.members = items.map { (element) in
			return (name: element.attributeForName("affiliation")!.stringValue!, affiliation: element.stringValue!)
		}
		self.tableView.reloadData()
		MBProgressHUD.hideHUDForView(self.view, animated: true)
	}

	func xmppRoomLight(sender: XMPPRoomLight, didFailToFetchMembersList iq: XMPPIQ) {
		let hud = MBProgressHUD.allHUDsForView(self.view).first as! MBProgressHUD
		hud.mode = .Text
		hud.labelText = "Problem fetching rooms"
		hud.hide(true, afterDelay: 1.5)
	}

}