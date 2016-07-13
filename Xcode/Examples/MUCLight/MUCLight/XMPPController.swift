//
//  XMPPController.swift
//  Mangosta
//
//  Created by Andres Canal on 6/29/16.
//  Copyright © 2016 Inaka. All rights reserved.
//

import Foundation
import XMPPFramework

class XMPPController: NSObject {

	var xmppStream: XMPPStream
	var xmppReconnect: XMPPReconnect
	var xmppRoomLightCoreDataStorage: XMPPRoomLightCoreDataStorage
	var xmppMUCLight: XMPPMUCLight

	var xmppRoster: XMPPRoster
	var xmppRosterStorage: XMPPRosterCoreDataStorage
	
	let mucLightDomain: String
	let hostName: String
	let userJID: XMPPJID
	let hostPort: UInt16
	let password: String

	init(hostName: String, userJID: XMPPJID, hostPort: UInt16 = 5222, password: String) {
		self.hostName = hostName
		self.userJID = userJID
		self.hostPort = hostPort
		self.password = password

		self.xmppRosterStorage = XMPPRosterCoreDataStorage()
		self.xmppRoster = XMPPRoster(rosterStorage: self.xmppRosterStorage)
		self.xmppRoster.autoFetchRoster = true;
		
		self.xmppStream = XMPPStream()
		self.xmppReconnect = XMPPReconnect()
		self.xmppMUCLight = XMPPMUCLight()
		
		self.xmppRoomLightCoreDataStorage = XMPPRoomLightCoreDataStorage(databaseFilename: "\(self.userJID).muclight.sqlite", storeOptions: nil)

		// Activate xmpp modules
		self.xmppReconnect.activate(self.xmppStream)
		self.xmppMUCLight.activate(self.xmppStream)
		self.xmppRoster.activate(self.xmppStream)
		
		// Stream Settings
		self.xmppStream.hostName = hostName
		self.xmppStream.hostPort = hostPort
		self.xmppStream.startTLSPolicy = XMPPStreamStartTLSPolicy.Allowed
		self.xmppStream.myJID = userJID

		self.mucLightDomain = "muclight.\(userJID.domain)"

		super.init()

		self.xmppStream.addDelegate(self, delegateQueue: dispatch_get_main_queue())
	}

	func connect() {
		if !self.xmppStream.isDisconnected() {
			return
		}

		try! self.xmppStream.connectWithTimeout(XMPPStreamTimeoutNone)
	}

	func disconnect() {
		self.xmppStream.disconnect()
	}
	
	func fetchMUCLightRooms() {
		self.xmppMUCLight.discoverRoomsForServiceNamed(self.mucLightDomain)
	}

	deinit {
		self.xmppStream.removeDelegate(self)
		self.xmppReconnect.deactivate()
		self.xmppRoster.deactivate()
		self.xmppStream.disconnect()
	}
}

extension XMPPController: XMPPStreamDelegate {

	func xmppStreamDidConnect(stream: XMPPStream!) {
		print("Stream: Connected")
		try! stream.authenticateWithPassword(self.password)
	}

	func xmppStreamDidAuthenticate(sender: XMPPStream!) {
		self.xmppStream.sendElement(XMPPPresence())
		print("Stream: Authenticated")
	}
	
	func xmppStream(sender: XMPPStream!, didNotAuthenticate error: DDXMLElement!) {
		print("Stream: Fail to Authenticate")
	}
}
