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
		}
	}

	func refreshRooms() {
		self.xmppController.fetchMUCLightRooms()
	}
	
	func start(userJID: String, userPassword: String, server: String) {
		guard let jid = XMPPJID.jidWithString(userJID) else { return }
		self.xmppController = XMPPController(hostName: server,
		                                     userJID: jid,
		                                     password: userPassword)
	}
}

extension ViewController: XMPPMUCLightDelegate {

	func xmppMUCLight(sender: XMPPMUCLight, didDiscoverRooms rooms: [DDXMLElement], forServiceNamed serviceName: String) {
		print(rooms)
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
