//
//  LogInViewController.swift
//  MUCLight
//
//  Created by Andres Canal on 7/12/16.
//  Copyright © 2016 Inaka. All rights reserved.
//

import UIKit
import XMPPFramework
import MBProgressHUD

class LogInViewController: UIViewController {

	@IBOutlet weak var userJIDLabel: UITextField!
	@IBOutlet weak var userPasswordLabel: UITextField!
	@IBOutlet weak var serverLabel: UITextField!
	@IBOutlet weak var errorLabel: UILabel!

	weak var delegate:LogInViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
	}

	@IBAction func logInAction(sender: AnyObject) {
		if self.userJIDLabel.text?.characters.count == 0
		  || self.userPasswordLabel.text?.characters.count == 0
		  || self.serverLabel.text?.characters.count == 0 {
				
			self.errorLabel.text = "Something is missing or wrong!"
			return
		}

		guard let _ = XMPPJID.jidWithString(self.userJIDLabel.text!) else {
			self.errorLabel.text = "Username is not a jid!"
			return
		}

		let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
		hud.labelText = "Signing in..."
		
		self.delegate?.didTouchLogIn(self, userJID: self.userJIDLabel.text!, userPassword: self.userPasswordLabel.text!, server: self.serverLabel.text!)
	}
	
	func showErrorMessage() {
		let hud = MBProgressHUD.allHUDsForView(self.view).first as! MBProgressHUD
		hud.mode = .Text
		hud.labelText = "Wrong password or username"
		hud.hide(true, afterDelay: 1.5)
	}

}

protocol LogInViewControllerDelegate: class {
	func didTouchLogIn(sender: LogInViewController, userJID: String, userPassword: String, server: String)
}
