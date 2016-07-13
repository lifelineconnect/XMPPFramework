//
//  InputView.swift
//  MUCLight
//
//  Created by Andres Canal on 7/14/16.
//  Copyright © 2016 Inaka. All rights reserved.
//

import UIKit

class InputView: UIView, UITextViewDelegate {

	@IBOutlet weak var inputText: UITextView!
	@IBOutlet weak var sendButton: UIButton!
	let initialInputTextHeight:CGFloat = 30.0
	weak var delegate: InputViewDelegate?

	var previousHeight:CGFloat = 0

	override func awakeFromNib() {
		super.awakeFromNib()
		autoresizingMask = .FlexibleHeight
		self.inputText.delegate = self
	}

	override func intrinsicContentSize() -> CGSize {
		var exactSize = self.inputText.sizeThatFits(CGSizeMake(self.inputText.frame.size.width, CGFloat.max))

		if exactSize.height > 80 {
			self.inputText.scrollEnabled = true
			exactSize = CGSizeMake(self.inputText.frame.size.width, self.previousHeight)
		} else {
			self.inputText.scrollEnabled = false
			self.previousHeight = exactSize.height
		}

		return CGSize(width: UIViewNoIntrinsicMetric, height: exactSize.height)
	}

	func textViewDidChange(textView: UITextView) {
		self.resizeView()
	}

	private func resizeView() {
		UIView.animateWithDuration(0.2) {
			self.invalidateIntrinsicContentSize()
			self.superview?.setNeedsLayout()
			self.superview?.layoutIfNeeded()
		}
	}

	@IBAction func sendButton(sender: UIButton) {
		self.delegate?.sendButtonTouch(self.inputText.text)
		self.inputText.scrollEnabled = false // I need to set this here so autolayout can set the height correctly (only when scroll is disabled)
		self.inputText.text = ""
		self.resizeView()
	}
}

protocol InputViewDelegate: class {
	func sendButtonTouch(text: String)
}