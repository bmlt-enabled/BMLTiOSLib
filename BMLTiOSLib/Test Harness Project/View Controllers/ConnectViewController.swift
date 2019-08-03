//
//  ConnectViewController.swift
//  BMLTiOSLib
//
//  Created by BMLT-Enabled
//
//  https://bmlt.app/
//
//  This software is licensed under the MIT License.
//  Copyright (c) 2017 BMLT-Enabled
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
public class ConnectViewController: UIViewController, BMLTiOSLibDelegate, UITextViewDelegate {
    var myTabController: TestTabController! = nil
    var weAreConnecting: Bool               = false

    @IBOutlet weak var urlEditText: UITextField!
    @IBOutlet weak var resultText: UITextView!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var testButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    /* ################################################################## */
    /**
     Displays the given error in an alert with an "OK" button.
     
     - parameter inTitle: a string to be displayed as the title of the alert. It is localized by this method.
     - parameter inMessage: a string to be displayed as the message of the alert. It is localized by this method.
     */
    func displayErrorAlert(_ inTitle: String, inMessage: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: NSLocalizedString(inTitle, comment: ""), message: NSLocalizedString(inMessage, comment: ""), preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertAction.Style.cancel, handler: nil)
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
            
            if self.weAreConnecting {
                self.weFailedToConnect()
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.wereNotConnected()
    }
    
    /* ################################################################## */
    /**
     */
    func wereNotConnected() {
        self.weAreConnecting = false
        self.connectButton.setTitle("CONNECT", for: UIControl.State.normal)
        self.connectButton.isHidden = false
        self.urlEditText.isEnabled = true
        self.resultText.isHidden = true
        self.resultText.text = ""
        self.activityIndicator.isHidden = true
        self.testButton.isEnabled = false
        self.view.backgroundColor = UIColor.darkGray
    }
    
    /* ################################################################## */
    /**
     */
    func wereConnecting() {
        self.weAreConnecting = true
        self.connectButton.isHidden = true
        self.urlEditText.isEnabled = false
        self.resultText.text = ""
        self.resultText.isHidden = true
        self.activityIndicator.isHidden = false
        self.testButton.isEnabled = false
    }
    
    /* ################################################################## */
    /**
     */
    func wereConnected() {
        self.weAreConnecting = false
        self.connectButton.setTitle("DISCONNECT", for: UIControl.State.normal)
        self.urlEditText.isEnabled = false
        self.connectButton.isHidden = false
        self.resultText.isHidden = false
        self.activityIndicator.isHidden = true
        self.testButton.isEnabled = true
        self.view.backgroundColor = UIColor.black
    }
    
    /* ################################################################## */
    /**
     */
    func weFailedToConnect() {
        self.wereNotConnected()
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func connectButtonHit(_ sender: UIButton) {
        if let appDel = UIApplication.shared.delegate as? BMLTiOSLibTesterAppDelegate {
            if "CONNECT" == sender.title(for: UIControl.State.normal) {
                self.wereConnecting()
                appDel._libraryObject = BMLTiOSLib(inRootServerURI: self.urlEditText.text!, inDelegate: self)
            } else {
                appDel._libraryObject = nil
                self.wereNotConnected()
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        self.myTabController = segue.destination as? TestTabController
    }
    
    // MARK: - BMLTiOSLibDelegate Methods -
    
    /* ################################################################## */
    /**
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter serverIsValid: true, if the server is properly available and the BMLTiOSLib instance is properly initialized. If it is false, you should stop using the BMLTiOSLib instance.
     */
    public func bmltLibInstance(_ inLibInstance: BMLTiOSLib, serverIsValid: Bool) {
        var resultString: String = ""
        
        if serverIsValid {
            resultString = "Successful Instantiation.\n\n"
            
            resultString += "    Server Version: " + inLibInstance.versionAsString + " (" + String(inLibInstance.versionAsInt) + ")\n\n"
            
            resultString += "    Server can"

            if !inLibInstance.isAdminAvailable {
                resultString += "not"
            }
            
            resultString += " be Semantically Administered.\n\n"
            
            resultString += ("    Distance Units: " + ((inLibInstance.distanceUnitsString == "km") ? "Kilometers" : (inLibInstance.distanceUnitsString == "mi") ? "Miles" : "ERROR!") + "\n")
            
            resultString += "\n    Server can"
            
            if !inLibInstance.emailMeetingContactsEnabled {
                resultString += "not"
            }
            
            resultString += " send emails to meeting contacts"
            
            if inLibInstance.emailMeetingContactsEnabled {
                resultString += ", and will"
                
                if !inLibInstance.emailServiceBodyAdminsEnabled {
                    resultString += " not"
                }
                
                resultString += " send copies to Service body Admins.\n\n"
            } else {
                resultString += ".\n\n"
            }
            
            resultString += "    Meeting Change Depth: " + String(inLibInstance.changeDepth) + " changes\n\n"
            
            resultString += "    Server Google API Key: " + inLibInstance.googleAPIKey + "\n\n"
            
            resultString += "    Languages:\n"
            for lang in inLibInstance.availableServerLanguages {
                if lang.isDefault {
                    resultString += "        * "
                } else {
                    resultString += "          "
                }
                resultString += lang.langKey
                resultString += " (" + lang.langName + ")\n"
            }
            
            resultString += "\n    Service Bodies:\n"
            for sb in inLibInstance.serviceBodies {
                resultString += "        " + sb.name + "\n"
            }
            
            resultString += "\n    All Server Formats:\n"
            for fmt in inLibInstance.allPossibleFormats.sorted(by: { $0.key < $1.key }) {
                resultString += "        " + fmt.key! + " (" + String(fmt.id) + ") " + fmt.name! + "\n"
            }
            
            resultString += "\n    Meeting Field Keys:\n"
            for key in inLibInstance.availableMeetingValueKeys {
                resultString += "        " + key + "\n"
            }
            
            self.wereConnected()
        } else {
            self.displayErrorAlert("BMLTiOSLib Connection Error!", inMessage: inLibInstance.errorString)
            self.weFailedToConnect()
        }
        
        self.resultText.text = resultString
    }
    
    /* ################################################################## */
    /**
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter loginChangedTo: True, if the user is successfully logged in. False, otherwise.
     */
    public func bmltLibInstance(_ inLibInstance: BMLTiOSLib, loginChangedTo: Bool) {
        // Belt and suspenders. We must be allowed to semantically administer.
        if !inLibInstance.isAdminAvailable && loginChangedTo {
            print("*** BIG ERROR! Semantic admin is off, but we \"successfully\" logged in!")
        } else {
            self.myTabController.updateLogin()
        }
    }
    
    /* ################################################################## */
    /**
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter errorOccurred: The error that occurred.
     */
    public func bmltLibInstance(_ inLibInstance: BMLTiOSLib, errorOccurred: Error) {
        self.displayErrorAlert("BMLTiOSLib Error!", inMessage: errorOccurred.localizedDescription)
    }
    
    /* ################################################################## */
    /**
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter formatSearchResults: The format search results. An Array of format objects.
     - parameter isAllUsedFormats: If true, then this is all possible formats on the server; not just those used in meetings.
     */
    public func bmltLibInstance(_ inLibInstance: BMLTiOSLib, formatSearchResults: [BMLTiOSLibFormatNode], isAllUsedFormats: Bool) {
        self.myTabController.updateFormatSearchResults(inFormats: formatSearchResults, isAllUsedFormats: isAllUsedFormats)
    }
    
    /* ################################################################## */
    /**
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter meetingSearchResults: An array of meeting objects.
     */
    public func bmltLibInstance(_ inLibInstance: BMLTiOSLib, meetingSearchResults: [BMLTiOSLibMeetingNode]) {
        self.myTabController.updateMeetingSearchResults(inMeetings: meetingSearchResults)
    }
    
    /* ################################################################## */
    /**
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter changeListResults: An array of change objects.
     */
    public func bmltLibInstance(_ inLibInstance: BMLTiOSLib, changeListResults: [BMLTiOSLibChangeNode]) {
        self.myTabController.updateChangeResults(inChanges: changeListResults)
    }
    
    /* ################################################################## */
    /**
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter newMeetingAdded: Meeting object.
     */
    public func bmltLibInstance(_ inLibInstance: BMLTiOSLib, newMeetingAdded: BMLTiOSLibEditableMeetingNode) {
        self.myTabController.updateMeetingSearchResults(inMeetings: [newMeetingAdded])
    }
    
    /* ################################################################## */
    /**
     Called when a new meeting has been rolled back to a previous version.
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter meetingRolledback: Meeting object.
     */
    public func bmltLibInstance(_ inLibInstance: BMLTiOSLib, meetingRolledback: BMLTiOSLibEditableMeetingNode) {
        self.myTabController.updateMeetingSearchResults(inMeetings: [meetingRolledback])
    }
    
    /* ################################################################## */
    /**
     Called when a message has been sent to a meeting contact.
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter sendMessageSuccessful,: true, if the operation was successful.
     */
    public func bmltLibInstance(_ inLibInstance: BMLTiOSLib, sendMessageSuccessful: Bool) {
        self.myTabController.updateMessageSent(sendMessageSuccessful)
    }
    
    /* ################################################################## */
    /**
     Called when a meeting has been edited.
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter adminMeetingChangeComplete,: If successful, this will be the changes made to the meeting. nil, if failed.
     */
    public func bmltLibInstance(_ inLibInstance: BMLTiOSLib, adminMeetingChangeComplete: BMLTiOSLibChangedMeeting!) {
        self.myTabController.updateMeetingChanges(adminMeetingChangeComplete: adminMeetingChangeComplete)
    }
 
    // MARK: - UITextFieldDelegate Handlers -
    
    /* ################################################################## */
    /**
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.connectButtonHit(self.connectButton)
        return true
    }
    
    /* ################################################################## */
    /**
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter deleteMeetingSuccessful,: true, if the operation was successful.
     */
    public func bmltLibInstance(_ inLibInstance: BMLTiOSLib, deleteMeetingSuccessful: Bool) {
        self.myTabController.updateDeletedMeeting(deleteMeetingSuccessful)
    }
}
