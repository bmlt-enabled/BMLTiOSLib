//
//  SendMessageViewController.swift
//  BMLTiOSLib
//
//  Created by MAGSHARE
//
//  https://bmlt.magshare.net/bmltioslib/
//
//  This software is licensed under the MIT License.
//  Copyright (c) 2017 MAGSHARE
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit
import BMLTiOSLib

/* ###################################################################################################################################### */
/**
 */
public class SendMessageViewController: BaseTestViewController, UITextViewDelegate {
    var meetingObject: BMLTiOSLibMeetingNode! = nil
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendMessageButton: UIButton!
    
    /* ################################################################## */
    /**
     */
    @IBAction func addressTextFieldChanged(_ sender: UITextField) {
        self.sendMessageButton.isEnabled = false
        if let emailAddress = self.emailAddressTextField.text {
            if let message = self.messageTextView.text {
                if !emailAddress.isEmpty && !message.isEmpty {
                    self.sendMessageButton.isEnabled = true
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func sendMessageButtonHit(_ sender: UIButton) {
        if let emailAddress = self.emailAddressTextField.text {
            if let message = self.messageTextView.text {
                sendMessageButton.isEnabled = false
                self.meetingObject.sendMessageToMeetingContact(fromAddress: emailAddress, messageBody: message)
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    public func textViewDidChange(_ textView: UITextView) {
        self.addressTextFieldChanged(self.emailAddressTextField)
    }
    
    /* ################################################################## */
    /**
     */
    func closeUpShop(_ inAction: UIAlertAction) {
        _ = self.navigationController!.popViewController(animated: true)
    }
    
    /* ################################################################## */
    /**
     */
    public func sendMessageUpdate(wasSuccessful: Bool) {
        sendMessageButton.isEnabled = true
        let alertController = UIAlertController(title: NSLocalizedString("Message Send Complete", comment: ""), message: (wasSuccessful ? "Message sent successfully." : "Message send failed."), preferredStyle: .alert)
        
        let handler = self.closeUpShop
        
        let cancelAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: (wasSuccessful ? handler : nil))
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
