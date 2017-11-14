//
//  BMLTiOSLib.swift
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

import Foundation
import CoreLocation

/* ###################################################################################################################################### */
// MARK: - Main Library Interface Class Delegate Protocol -
/* ###################################################################################################################################### */
/**
 This protocol is required for any class that wants to control an instance of BMLTiOSLib.
 
 Only 2 of these functions are required:
 
    - func bmltLibInstance(_ inLibInstance: BMLTiOSLib, serverIsValid: Bool)
    - func bmltLibInstance(_ inLibInstance: BMLTiOSLib, errorOccurred error: Error)
 
 All the rest are optional.

 These are all called in the main thread.
 */
@objc public protocol BMLTiOSLibDelegate {
    /** The following methods are required */
    
    /* ################################################################## */
    /**
     **REQUIRED**
     
     Indicates whether or not the server pointed to via the URI is a valid server (the connection was successful).
     
     This will be called after the Root Server connection sequence has completed.
     
     This connection sequence consists of:
     
     - Determining the fundamental validity of the URI (Connects to a Root Server). The Root Server MUST run SSL (HTTPS).
     - Determining the fundamental validity of the Root Server (Correct version, supports the proper set of default keys).
     - Loading the full set of available formats (They may not all be in actual use by meetings).
     - Loading the entire set of Service bodies.
     - Loading the entire set of languages available on the Root Server.
     
     By the time this method has been called with serverIsValid as true, the BMLTiOSLib has the following properties set and valid:
     
     - searchCriteria (This will be empty and clear, but available for access).
     - distanceUnits and distanceUnitsString
     - availableMeetingValueKeys (This contains the Dictionary key strings that can access various meeting properties).
     - emailMeetingContactsEnabled (True, if the Server is set to allow emails to be sent to meeting contacts).
     - emailServiceBodyAdminsEnabled (True, if these emails will CC the Service Body Admin for that Service body, as well as the meeting contact -They may be the same email address).
     - changeDepth (The number of changes saved per meeting).
     - googleAPIKey (The API key for the Root Server -May not be useful for most other Servers).
     - delegate (That will be the object that was passed in as delegate when the instance was created).
     - rootServerURI
     - versionAsString and versionAInt
     - isAdminAvailable (True, if Semantic Administration is available).
     - defaultLocation (The Root Server's default central location).
     - serviceBodies (This is a "flat" Array of the Service bodies, with no hierarchy).
     - hierarchicalServiceBodies (This maps out the Service bodies in the hierarchy they occupy on the Root Server, and this is just one node with children only -no parents or Service body). The children are all the top-level (sb_owner == 0, or "parentless") Service bodies. The hierarchy is designed to be "crawled."
     - allPossibleFormats (an Array of format objects available -May not all be used by the meetings).
     - availableServerLanguages (an Array of language objects).
     
     You can't call any of the BMLTiOSLib communication instance methods until this callback has been invoked with a serverIsValid value of true.
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter inServerIsValid: A Bool, true, if the server was successfully connected. If false, you must reinstantiate BMLTiOSLib. You can't re-use the same instance.
     */
    func bmltLibInstance(_ inLibInstance: BMLTiOSLib, serverIsValid: Bool)
    
    /* ################################################################## */
    /**
     **REQUIRED**
     
     Called if there is an error.
     
     The error String will be a key for localization, and will be pretty much worthless on its own.
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter error: The error that occurred.
     */
    func bmltLibInstance(_ inLibInstance: BMLTiOSLib, errorOccurred error: Error)
    
    /** The following methods are optional */
    
    /* ################################################################## */
    /**
     **OPTIONAL**
     
     Returns the result of a meeting search.
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter meetingSearchResults: An array of meeting objects, representing the results of a search.
     */
    @objc optional func bmltLibInstance(_ inLibInstance: BMLTiOSLib, meetingSearchResults: [BMLTiOSLibMeetingNode])
    
    /* ################################################################## */
    /**
     **OPTIONAL**
     
     Returns the result of a format search.
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter formatSearchResults: An array of format objects.
     - parameter isAllUsedFormats: This is true, if this is the "all used formats" call, where we generate objects that reflect the formats actually used by any meetings in the entire database (as opposed to simply "available, but not used").
     */
    @objc optional func bmltLibInstance(_ inLibInstance: BMLTiOSLib, formatSearchResults: [BMLTiOSLibFormatNode], isAllUsedFormats: Bool)
    
    /* ################################################################## */
    /**
     **OPTIONAL**
     
     Returns the result of a change list request.
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter changeListResults: An array of change objects.
     */
    @objc optional func bmltLibInstance(_ inLibInstance: BMLTiOSLib, changeListResults: [BMLTiOSLibChangeNode])
    
    /* ################################################################## */
    /**
     **OPTIONAL**
     
     Returns the result of a change list request for deleted-only meetings.
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter deletedChangeListResults: An array of change objects.
     */
    @objc optional func bmltLibInstance(_ inLibInstance: BMLTiOSLib, deletedChangeListResults: [BMLTiOSLibChangeNode])
    
    /* ################################################################## */
    /**
     **OPTIONAL**
     
     Indicates whether or not a Semantic Admin log in or out occurred.
     
     This actually is called when the login state changes (or doesn't change when change is expected).
     This is called in response to a login or logout. It is always called, even if
     the login state did not change.
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter loginChangedTo: A Bool, true, if the session is currently connected.
     */
    @objc optional func bmltLibInstance(_ inLibInstance: BMLTiOSLib, loginChangedTo: Bool)
    
    /* ################################################################## */
    /**
     **OPTIONAL**
     
     Called when a new meeting has been added, or a deleted meeting has been restored.
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter newMeetingAdded: Meeting object.
     */
    @objc optional func bmltLibInstance(_ inLibInstance: BMLTiOSLib, newMeetingAdded: BMLTiOSLibEditableMeetingNode)
    
    /* ################################################################## */
    /**
     **OPTIONAL**
     
     Called when a meeting has been rolled back to a previous version.
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter meetingRolledback: Meeting object.
     */
    @objc optional func bmltLibInstance(_ inLibInstance: BMLTiOSLib, meetingRolledback: BMLTiOSLibEditableMeetingNode)
    
    /* ################################################################## */
    /**
     **OPTIONAL**
     
     Called when a meeting has been edited.
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter adminMeetingChangeComplete: If successful, this will be the changes made to the meeting. nil, if failed.
     */
    @objc optional func bmltLibInstance(_ inLibInstance: BMLTiOSLib, adminMeetingChangeComplete: BMLTiOSLibChangedMeeting!)
    
    /* ################################################################## */
    /**
     **OPTIONAL**
     
     Called when a new meeting has been deleted.
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter deleteMeetingSuccessful: true, if the operation was successful.
     */
    @objc optional func bmltLibInstance(_ inLibInstance: BMLTiOSLib, deleteMeetingSuccessful: Bool)
    
    /* ################################################################## */
    /**
     **OPTIONAL**
     
     Called when a message has been sent to a meeting contact.
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter sendMessageSuccessful: true, if the operation was successful.
     */
    @objc optional func bmltLibInstance(_ inLibInstance: BMLTiOSLib, sendMessageSuccessful: Bool)
}

/* ###################################################################################################################################### */
// MARK: - Main Library Interface Class -
/* ###################################################################################################################################### */
/**
 This class represents the public interface to the BMLTiOSLib framework.
 
 This class needs to be instantiated with a URI to a valid Root Server (the same URI used to log in), and a BMLTiOSLibDelegate object.
 
 Instantiation immediately starts a communication process, and the result will be reflected in the delegate's bmltLibInstance(_:BMLTiOSLib,serverIsValid:Bool) callback.
 
 If this instance fails to connect to a valid Root Server, it should be deleted, and reinstantiated for a new connection.
 
 Once a connection is established, the HTTP session is maintained until the instance is deinstantiated.
 
 The session is required to be maintained for Semantic Administration. You cannot share a session across instances of BMLTiOSLib.
 
 BASIC SERVER INFORMATION:
 
 Once you have successfully connected (established a session) to the Root Server, this instance will have some fundamental information available about that server.
 This information can be accessed by calling the following instance properties:

 - distanceUnits and distanceUnitsString (This is the distance unit used for the server -Km or Mi).

 - availableMeetingValueKeys (This contains the Dictionary key strings that can access various meeting properties).

 - emailMeetingContactsEnabled (True, if the Server is set to allow emails to be sent to meeting contacts).

 - emailServiceBodyAdminsEnabled (True, if these emails will CC the Service Body Admin for that Service body, as well as the meeting contact -They may be the same email address).

 - changeDepth (The number of changes saved per meeting).

 - googleAPIKey (The API key for the Root Server -May not be useful for most other Servers).

 - delegate (That will be the object that was passed in as delegate when the instance was created).

 - versionAsString and versionAInt (The server version)

 - isAdminAvailable (True, if Semantic Administration is available).

 - defaultLocation (The Root Server's default central location).

 - serviceBodies (This is a "flat" Array of the Service bodies, with no hierarchy).

 - hierarchicalServiceBodies (This maps out the Service bodies in the hierarchy they occupy on the Root Server, and this is just one node with children only -no parents or Service body).

 - allPossibleFormats (an Array of format objects available -May not all be used by the meetings).

 - availableServerLanguages (an Array of language objects).

 MEETING SEARCHES:
 
 The way that you do a meeting search with this class, is to acquire the instance's searchCriteria object, and use its various properties to set up your desired search.
 
 Once that is done, you call this class instance's performMeetingSearch(_:BMLTiOSLibSearchCriteria.SearchCriteriaExtent) method, indicating whether you want just meetings,
 just the formats used by the meetings in the search results, or both.
 
 Once the search is complete, this class will call your delegate routines:
 
    bmltLibInstance(_:BMLTiOSLib,meetingSearchResults:[BMLTiOSLibMeetingNode]) is called with the results of the meeting search.
    bmltLibInstance(_:BMLTiOSLib,formatSearchResults:[BMLTiOSLibFormatNode],isAllUsedFormats:Bool) is called with the results of the format search.
 
 Either or both may be called, depending on what you requested when you called performMeetingSearch(_:BMLTiOSLibSearchCriteria.SearchCriteriaExtent).
 If there are no results, they will be called with empty Arrays.
 
 MEETING CHANGES:
 
 You can query for meeting changes, including deleted meetings (and you can restore deleted meetings if you are an authorized administrator).
 
 You do this by calling one of these methods:
 
 - getAllMeetingChanges(meetingID:Int?)
 
 - getAllMeetingChanges(serviceBodyID:Int?)
 
 - getAllMeetingChanges(meeting:BMLTiOSLibMeetingNode?)
 
 - getAllMeetingChanges(fromDate:Date?,toDate:Date?)
 
 - getAllMeetingChanges(fromDate:Date?,toDate:Date?,meetingID:Int?)
 
 - getAllMeetingChanges(fromDate:Date?,toDate:Date?,serviceBodyID:Int?)
 
 - getAllMeetingChanges(fromDate:Date?,toDate:Date?,serviceBodyID:Int?,meetingID:Int?)
 
 - getAllMeetingChanges(fromDate:Date?,toDate:Date?,serviceBodyID:Int?,meetingID:Int?,userID:Int?)
 
 - getDeletedMeetingChanges()
 
 - getDeletedMeetingChanges(serviceBodyID:Int?)
 
 - getDeletedMeetingChanges(fromDate:Date?,toDate:Date?,serviceBodyID:Int?)

 After calling one of the above methods, your delegate is called back with the bmltLibInstance(_:BMLTiOSLib,changeListResults:[BMLTiOSLibChangeNode]) method; which will have an Array of the requested change objects.
 
 You can then use these objects to revert meetings, or restore deleted meetings.
 
 ROLLING BACK AND UNDELETING MEETINGS:

 Selecting the "saveMeetingToBeforeThisChange()" of a change or editable meeting object will use the restore deleted or rollback function of the Semantic Admin interface.
 We do allow you to take the "before" record of the meeting (found in the "json_data" JSON response, or the "beforeObject" property of the change record object), and save that.
 This allows you to add new changes (as opposed to simply accepting the whole change in a rollback, you can choose to only take certain changes).
 It also gives a better change record in the meeting history. Instead of a curt "Meeting was rolled back to a previous version.", you now have a list of the exact fields that were changed.
 Remember that the "beforeObject" and "afterObject" properties are fully-qualified meeting objects, and, if editable, can be saved, which overwrites whatever is currently in the database (It's exactly like saving a changed meeting record).
 You revert a meeting by calling the "revertMeetingToBeforeThisChange()" method of the change record object concerned. It's quite simple.

 NEW MEETINGS:
 
 Creating new meetings is easy (as long as you are logged in as an administrator, and have sufficient rights to create a meeting).
 
 You create an instance of BMLTiOSLibEditableMeetingNode with an ID of 0 (the default). Then, when you call saveChanges(), it will create a new meeting.
 
 When you create a new meeting, or restore a deleted meeting, your delegate is called with the bmltLibInstance(_:BMLTiOSLib,newMeetingAdded:BMLTiOSLibEditableMeetingNode) method.
 The newMeetingAdded parameter will contain an object that models the newly-created meeting (including the new ID, if it was a brand-new meeting).
 
 SENDING MESSAGES TO MEETING CONTACTS:
 
 In some Root Servers, the administrator can choose to enable the ability for users of the site to send messages to designated contacts for meetings (or the Service Body Administrator responsible for the meeting).
 In these cases, the message is received as an email, but the sender does not send an email. Instead, they use a method of the BMLTiOSLibMeetingNode class, called sendMessageToMeetingContact(fromAddress:String,messageBody:String). The message is sent in the background.
 
 When the message has been sent, your delegate is called with the bmltLibInstance(_:BMLTiOSLib,sendMessageSuccessful:Bool) method.
 
 ADMINISTRATION:
 
 In order to perform administration on the Root Server, you need to log in with the adminLogin(loginID:String,password:String) method. The login will remain valid for the
 lifetime of this object (and its connection session), or until the adminLogout() method is called.
 
 Results of meeting searches will return the meeting objects as instances of BMLTiOSLibEditableMeetingNode instead of BMLTiOSLibEditableNode. is will depend on the edit
 rights that the login has for the given meeting. If you cannot edit the meeting, then the instance will be of BMLTiOSLibMeetingNode, instead of BMLTiOSLibEditableMeetingNode.
 
 If the instance is BMLTiOSLibEditableMeetingNode, the instance's isEditable property will return true.
 
 If the instance is of the BMLTiOSLibEditableMeetingNode class, you can cast it to that class, and manipulate the public properties. Once the properties have been set, you can
 then call the saveChanges() method for that instance, and the meeting will be saved.
 
 Until the saveChanges() method is called, the meeting changes are not sent to the server.
 
 Once the meeting has been saved, your delegate will receive a call to its bmltLibInstance(_:BMLTiOSLib,adminMeetingChangeComplete:BMLTiOSLibChangedMeeting!) with an object that
 will contain whatever fields of the meeting changed, with the "before" and "after" values (always Strings).
 
 You can also delete a meeting, by calling the delete() method (The deletion happens immediately).
 
 If you delete the meeting, your delegate is called with the bmltLibInstance(_:BMLTiOSLib,deleteMeetingSuccessful:Bool) method.
 
 Your delegate will be called with the bmltLibInstance(_:BMLTiOSLib,deleteMeetingSuccessful:Bool) method after the deletion.

 If you call the restoreToOriginal() method, any changes that you made to the meeting object will be reverted to the state of the meeting on the server. Nothing will be sent to the server.
 
 You can also revert a meeting to the state it was in before a given change record for that meeting, using the revertMeetingToBeforeThisChange(_:BMLTiOSLibChangeNode) method. Nothing will be sent to the server.
 
 If the change was inappropriate for the meeting, the call will return false. If it was successful, the meeting's state will be reverted to that in the change record, but will not yet be sent to the server. You still need to call saveChanges().
 */
public class BMLTiOSLib : NSObject {
    /* ################################################################## */
    // MARK: Private Properties
    /* ################################################################## */
    /**
     These methods and properties are not meant to be exposed outside the project.
     */
    
    /** This is the delegate that receives state information from this instance. It must obey the BMLTiOSLibDelegate protocol. */
    weak private var _delegate: BMLTiOSLibDelegate! = nil
    /** This is a String, containing the URI for the Root Server this session is connected to. */
    private var _rootServerURI: String = ""
    /** This is an instance of BMLTiOSLibCommunicationHandler that is the actual Root Server session handler. */
    private var _communicationHandler: BMLTiOSLibCommunicationHandler!
    /** This is an instance that we use to manage setting up searches. */
    private var _searchCriteria: BMLTiOSLibSearchCriteria! = nil
    
    /* ################################################################## */
    // MARK: Internal Communications Instance Methods
    /* ################################################################## */
    /**
     If sending messages to meeting contacts is enabled, this function will send a basic email to the contact for this email.
     
     - parameter meetingID: An integer, with the BMLT ID for the meeting.
     - parameter serviceBodyID: An integer, with the BMLT ID for Service body for the meeting.
     - parameter fromAddress: The email to be used as the "from" address. This is required, and should be valid.
     - parameter messageBody: A String containing the body of the message to be sent.
     */
    internal func _sendMessageToMeetingContact(meetingID: Int, serviceBodyID: Int, fromAddress: String, messageBody: String) {
        if self.emailMeetingContactsEnabled {
            self._communicationHandler.sendMessageToMeetingContact(meetingID: meetingID, serviceBodyID: serviceBodyID, fromAddress: fromAddress, messageBody: messageBody)
        } else {
            self.messageSentResponse(false)
        }
    }
    
    /* ################################################################## */
    // MARK: Internal Methods Called By The Communication Handler
    /* ################################################################## */
    /**
     These methods are callbacks from the communication handler. Rather than use a protocol, we have tighter coupling, because this is all
     "between friends." The public interface enforces a protocol.
     
     These methods are not exported outside of the library.
     */
    
    /* ################################################################## */
    /**
     Indicates whether or not the server pointed to via the URI is a valid server (the connection was successful)
     
     This is called during instantiation.
     
     - parameter inServerIsValid: A Bool, true, if the server was successfully connected.
     */
    internal func serverIsValid(_ inServerIsValid: Bool) {
        // We only have a valid search criteria object if we are connected.
        if inServerIsValid {
            self._searchCriteria = BMLTiOSLibSearchCriteria(self)
        } else {
            self._searchCriteria = nil
        }
        
        if nil != self.delegate {
            self.delegate.bmltLibInstance(self, serverIsValid: inServerIsValid)
        }
    }
    
    /* ################################################################## */
    /**
     Indicates whether or not a Semantic Admin login or logout occurred.
     This actually is called when the login state changes (or doesn't change when change is expected).
     
     This is called in response to a login or logout. It is always called, even if the login state did not change.
     
     - parameter inLoginWasSuccessful: A Bool, true, if the session is currently connected.
     */
    internal func loginWasSuccessful(_ inLoginWasSuccessful: Bool) {
        guard let _ = self.delegate?.bmltLibInstance?(self, loginChangedTo: inLoginWasSuccessful) else { return }
    }
    
    /* ################################################################## */
    /**
     Indicates whether or not a Semantic Admin meeting change was successful.
     
     - parameter inChanges: If successful, the meeting changes. If not, nil.
     */
    internal func meetingChangeComplete(_ inChanges: BMLTiOSLibChangedMeeting!) {
        guard let _ = self.delegate?.bmltLibInstance?(self, adminMeetingChangeComplete: inChanges) else { return }
    }
    
    /* ################################################################## */
    /**
     Indicates whether or not a message sent to a meeting contact was successful.
     
     - parameter inWasSuccessful: A Bool, true, if the message send was successful.
     */
    internal func messageSentResponse(_ inWasSuccessful: Bool) {
        guard let _ = self.delegate?.bmltLibInstance?(self, sendMessageSuccessful: inWasSuccessful) else { return }
    }
    
    /* ################################################################## */
    /**
     This is called if the communicator encounters an error.
     
     - parameter inError: The error that occurred.
     */
    internal func errorEncountered(_ inError: Error) {
        if nil != self.delegate {
            self.delegate.bmltLibInstance(self, errorOccurred: inError)
        }
    }
    
    /* ################################################################## */
    /**
     This function checks to see if we believe the user has permission to edit a given meeting.
     If so, we allocate the object as an editable meeting. Otherwise, not.
     
     - parameter inSimpleMeetingDictionary: The meeting object (as a Dictionary<String, String>).
     
     - returns:  an object, either editable, or not.
     */
    internal func generateProperMeetingObject(_ inSimpleMeetingDictionary: [String:String]) -> BMLTiOSLibMeetingNode {
        var ret: BMLTiOSLibMeetingNode! = nil
        
        // If we are logged in, we extract the Service body from the meeting, then we check to see if we are an administrator or authorized editor for that Service body.
        // If so, we wrap the meeting data in an editable object. If not, it gets a standard object (read-only).
        if self.isAdminLoggedIn {
            // Get the Service body ID.
            if let sbID = inSimpleMeetingDictionary["service_body_bigint"] {
                if let sbIDInt: Int = Int(sbID) {
                    // Go through our Service bodies until we come to the one we want.
                    for sb in self.serviceBodies {
                        if sb.id == sbIDInt {
                            // Only admins or editors can change meetings.
                            if sb.iCanEdit {
                                ret = BMLTiOSLibEditableMeetingNode(inSimpleMeetingDictionary, inHandler: self)
                                break
                            }
                        }
                    }
                }
            }
        }
        
        // If we did not make this editable, it's a regular node.
        if nil == ret {
            ret = BMLTiOSLibMeetingNode(inSimpleMeetingDictionary, inHandler: self)
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This is called by the communicator to deliver the meetings result of a meeting search.
     
     - parameter inSearchResultObject: The search result (s a Dictionary<String, String>).
     - parameter newMeeting: If true, this is a new meeting.
     */
    internal func meetingSearchResults(_ inSearchResultObject: [BMLTiOSLibMeetingNode]!, newMeeting: Bool = false) {
        if (nil != inSearchResultObject) && (0 < inSearchResultObject.count) {
            if newMeeting {
                if let meetingObject = inSearchResultObject![0] as? BMLTiOSLibEditableMeetingNode {
                    guard let _ = self.delegate?.bmltLibInstance?(self, newMeetingAdded: meetingObject) else { return }
                }
            } else {
                guard let _ = self.delegate?.bmltLibInstance?(self, meetingSearchResults: inSearchResultObject) else { return }
            }
        } else {
            guard let _ = self.delegate?.bmltLibInstance?(self, meetingSearchResults: []) else { return }
        }
    }
    
    /* ################################################################## */
    /**
     This is called by the communicator to deliver the formats result of a meeting search.
     
     - parameter inSearchResultObject: The search result
     */
    internal func formatSearchResults(_ inSearchResultObject: [BMLTiOSLibFormatNode]!) {
        if (nil != inSearchResultObject) && (0 < inSearchResultObject.count) {
            var formatList: [BMLTiOSLibFormatNode] = []
            
            for format in inSearchResultObject {    // Make sure that we reference objects we already instantiated, as opposed to the new ones.
                formatList.append(self.getFormatByID(format.id))
            }
            
            guard let _ = self.delegate?.bmltLibInstance?(self, formatSearchResults: formatList, isAllUsedFormats: self._communicationHandler._gettingAllUsedFormats) else {
                self._communicationHandler._gettingAllUsedFormats = false
                return
            }
        } else {
            guard let _ = self.delegate?.bmltLibInstance?(self, formatSearchResults: [], isAllUsedFormats: self._communicationHandler._gettingAllUsedFormats) else {
                self._communicationHandler._gettingAllUsedFormats = false
                return
            }
        }
        
        self._communicationHandler._gettingAllUsedFormats = false
    }
    
    /* ################################################################## */
    /**
     This is called by the communicator to deliver the results of a request for changes.
     
     - parameter inSearchResultObject: The search result (s a Dictionary<String, String>).
     - parameter updateMeetingNode: If this is nont nil, then it is a meeting object that needs to be updated.
     - parameter deletedMeetingsOnly: If true, then we are only doing deleted meetings.
     */
    internal func changeRequestResults(_ inSearchResultObject: [BMLTiOSLibChangeNode], updateMeetingNode: BMLTiOSLibMeetingNode!, deletedMeetingsOnly: Bool = false) {
        if nil != updateMeetingNode {
            updateMeetingNode!.changes = inSearchResultObject
            // Special for if this was a newly-created meeting.
            if let editableMeetingNode = updateMeetingNode as? BMLTiOSLibEditableMeetingNode {
                if 1 == inSearchResultObject.count {    // There can only be one...
                    editableMeetingNode.rawMeeting["id_bigint"] = String(inSearchResultObject[0].afterObject.id)    // This is the only place in the entire app where we can change the meeting ID.
                    editableMeetingNode.setChanges()
                    while true {
                        guard let _ = self.delegate?.bmltLibInstance?(self, newMeetingAdded: editableMeetingNode) else { break }
                        return  // We don't call the regular changes thingy in this case.
                    }
                }
            }
        }
        
        if deletedMeetingsOnly {
            guard let _ = self.delegate?.bmltLibInstance?(self, deletedChangeListResults: inSearchResultObject) else { return }
        } else {
            guard let _ = self.delegate?.bmltLibInstance?(self, changeListResults: inSearchResultObject) else { return }
        }
    }
    
    /* ################################################################## */
    /**
     This is called by the communicator to deliver a meeting that was added or restored.
     
     - parameter updateMeetingNode: This is the new meeting that was added or restored.
     */
    internal func restoreRequestResults(_ updateMeetingNode: BMLTiOSLibEditableMeetingNode!) {
        if nil != updateMeetingNode {
            guard let _ = self.delegate?.bmltLibInstance?(self, newMeetingAdded: updateMeetingNode) else { return }
        }
    }
    
    /* ################################################################## */
    /**
     This is called by the communicator to deliver a meeting that was rolled back.
     
     - parameter updateMeetingNode: This is the meeting that was rolled back.
     */
    internal func rollbackRequestResults(_ updateMeetingNode: BMLTiOSLibEditableMeetingNode!) {
        if nil != updateMeetingNode {
            guard let _ = self.delegate?.bmltLibInstance?(self, meetingRolledback: updateMeetingNode) else { return }
        }
    }
    
    /* ################################################################## */
    /**
     This is called by the communicator to deliver a meeting that was added or restored.
     
     - parameter inSuccess: True, if the deletion was successful.
     */
    internal func meetingDeleted(_ inSuccess: Bool) {
        guard let _ = self.delegate?.bmltLibInstance?(self, deleteMeetingSuccessful: inSuccess) else { return }
    }

    /* ################################################################## */
    // MARK: Public Instance Calculated Properties
    /* ################################################################## */
    /**
     - returns:  a reference to the internal SearcCriteria object.
     */
    public var searchCriteria: BMLTiOSLibSearchCriteria! {
        get {
            return self._searchCriteria
        }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal Distance Units.
     */
    public var distanceUnits: BMLTiOSLibDistanceUnits {
        get {
            return self._communicationHandler.distanceUnits
        }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal Distance Units.
     */
    public var distanceUnitsString: String {
        get {
            return self._communicationHandler.distanceUnitsString
        }
    }
    
    /* ############################################################## */
    /**
     These are the available value keys for use when querying meeting data.
     */
    public var availableMeetingValueKeys:[String] {
        get {
            return self._communicationHandler.availableMeetingValueKeys
        }
    }
    
    /* ############################################################## */
    /**
     This is set to true if emails sent to the server are enabled (Goes to meeting contacts).
     */
    public var emailMeetingContactsEnabled: Bool {
        get {
            return self._communicationHandler.emailMeetingContactsEnabled
        }
    }
    
    /* ############################################################## */
    /**
     This is set to true if emails sent to the meeting contacts also send a copy to the Service body Admin for that meeting.
     */
    public var emailServiceBodyAdminsEnabled: Bool {
        get {
            return self._communicationHandler.emailServiceBodyAdminsEnabled
        }
    }
    
    /* ############################################################## */
    /**
     This is number of changes stored per meeting.
     */
    public var changeDepth: Int {
        get {
            return self._communicationHandler.changeDepth
        }
    }
    
    /* ############################################################## */
    /**
     This is the server Google API Key
     */
    public var googleAPIKey: String {
        get {
            return self._communicationHandler.googleAPIKey
        }
    }
    
    /* ################################################################## */
    /**
     This returns the delegate object for this instance.
     The delegate can only be set at instantiation taime, so this is a
     read-only dynamic property.
     
     - returns:  a reference to an object that follows the BMLTiOSLibDelegate protocol.
     */
    public var delegate: BMLTiOSLibDelegate! {
        get {
            return self._delegate
        }
    }
    
    /* ################################################################## */
    /**
     This returns the Root Server URI used by the instance.
     
     - returns:  a String, with the URI.
     */
    public var rootServerURI: String  {
        get {
            return ((self._rootServerURI as NSString).trimmingCharacters(in: ["/"])) as String
        }
    }
    
    /* ################################################################## */
    /**
     This is a simple Boolean test to see if the instance successfully connected.
     
     - returns:  a Bool, true if the instance is successfully connected.
     */
    public var isConnected: Bool  {
        get {
            return self._communicationHandler.isConnected
        }
    }
    
    /* ################################################################## */
    /**
     This returns an error String (if any)
     
     - returns:  an optional String object. This will be a code that can be used to key a localized String.
     */
    public var errorString: String!  {
        get {
            return self._communicationHandler.errorDescription.rawValue
        }
    }
    
    /* ################################################################## */
    /**
     This returns true, if the Semantic Administration interface has an administrator logged in.
     
     - returns:  a Bool, true, if the administrator is logged in.
     */
    public var isAdminLoggedIn: Bool  {
        get {
            return self._communicationHandler.isLoggedInAsAdmin
        }
    }
    
    /* ################################################################## */
    /**
     This returns the Root Server version, as an easily readable String.
     
     - returns:  a String, with the version, in "X.Y.Z" form, where X is the major version, Y is the minor version, and Z is the fix version
     */
    public var versionAsString: String  {
        get {
            return self._communicationHandler.versionString
        }
    }
    
    /* ################################################################## */
    /**
     This returns the Root Server version, as an integer. This allows easy version level checking.
     
     The format is XXXYYYZZZ, with XXX being the major version, YYY being the minor version, and ZZZ being the fix version.
     
     The result has no leading zeroes (It's an Int), so, for example, 2.8.1 is represented as "2008001".
     
     - returns:  an Int, with the version packed into integer form.
     */
    public var versionAsInt: Int  {
        get {
            return self._communicationHandler.serverVersionAsInt
        }
    }
   
    /* ################################################################## */
    /**
     This returns whether or not the Root Server is capable of supporting Semantic Administration.
     
     - returns:  a Bool, true, if the Root Server supports Semantic Administration.
     */
    public var isAdminAvailable: Bool  {
        get {
            return self._communicationHandler.semanticAdminEnabled
        }
    }
    
    /* ################################################################## */
    /**
     This returns the Root Server center coordinates.
     
     - returns:  a CLLocationCoordinate2D object, with the coordinates (default Server coordinates).
     */
    public var defaultLocation: CLLocationCoordinate2D  {
        get {
            return self._communicationHandler.defaultLocation
        }
    }
    
    /* ################################################################## */
    /**
     This returns a flat (non-hierarchical) array of Service Body nodes.
     
     This returns every Service body on the server. Each will be in a node, with links to its parents and children (if any).
     
     - returns:  an Array of BMLTiOSLibHierarchicalServiceBodyNode objects, each of which represents one Service body.
     */
    public var serviceBodies: [BMLTiOSLibHierarchicalServiceBodyNode]  {
        get {
            return self._communicationHandler.allServiceBodies
        }
    }
    
    /* ################################################################## */
    /**
     This returns a flat (non-hierarchical) array of Service Body nodes that can be observed.
     
     This returns every Service body on the server that the current user can observe. Each will be in a node, with links to its parents and children (if any).
     
     - returns:  an Array of BMLTiOSLibHierarchicalServiceBodyNode objects, each of which represents one Service body.
     */
    public var serviceBodiesICanObserve: [BMLTiOSLibHierarchicalServiceBodyNode]  {
        get {
            var ret: [BMLTiOSLibHierarchicalServiceBodyNode] = []
            
            if self.isAdminLoggedIn {   // Have to at least be logged in.
                for sb in self.serviceBodies {
                    if sb.iCanObserve {
                        ret.append(sb)
                    }
                }
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     This returns a flat (non-hierarchical) array of Service Body nodes that can be edited or observed.
     
     This returns every Service body on the server that the current user can observe or edit. Each will be in a node, with links to its parents and children (if any).
     
     - returns:  an Array of BMLTiOSLibHierarchicalServiceBodyNode objects, each of which represents one Service body.
     */
    public var serviceBodiesICanEdit: [BMLTiOSLibHierarchicalServiceBodyNode]  {
        get {
            var ret: [BMLTiOSLibHierarchicalServiceBodyNode] = []
            
            if self.isAdminLoggedIn {   // Have to at least be logged in.
                for sb in self.serviceBodies {
                    if sb.iCanEdit {
                        ret.append(sb)
                    }
                }
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     This returns a flat (non-hierarchical) array of Service Body nodes that can be observed.
     
     This returns every Service body on the server that the current user can observe, edit or administer. Each will be in a node, with links to its parents and children (if any).
     
     - returns:  an Array of BMLTiOSLibHierarchicalServiceBodyNode objects, each of which represents one Service body.
     */
    public var serviceBodiesICanAdminister: [BMLTiOSLibHierarchicalServiceBodyNode]  {
        get {
            var ret: [BMLTiOSLibHierarchicalServiceBodyNode] = []
            
            if self.isAdminLoggedIn {   // Have to at least be logged in.
                for sb in self.serviceBodies {
                    if sb.iCanAdminister {
                        ret.append(sb)
                    }
                }
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     This returns a hierarchical linked list of Service Body nodes.
     
     This returns every Service body on the server, in a doubly linked list.
     
     - returns:  a BMLTiOSLibHierarchicalServiceBodyNode object that is the root of the hierarchy. Look in its "children" property.
     */
    public var hierarchicalServiceBodies: BMLTiOSLibHierarchicalServiceBodyNode  {
        get {
            return self._communicationHandler.hierarchicalServiceBodies
        }
    }
    
    /* ################################################################## */
    /** This contains all of possible meeting formats.
     */
    public var allPossibleFormats: [BMLTiOSLibFormatNode] {
        get {
            return self._communicationHandler.allAvailableFormats
        }
    }
    
    /* ################################################################## */
    /** This contains the response from our get server languages call (nil, by default). */
    public var availableServerLanguages: [BMLTiOSLibServerLang] {
        get {
            return self._communicationHandler._availableServerLanguages
        }
    }
    
    /* ################################################################## */
    // MARK: Public Instance Methods
    /* ################################################################## */
    /**
     This is the default initializer. This is required. You need to supply a valid URI and a valid delegate.
     
     After this is called, the BMLTiOSLib attempts to connect to the Root Server.
     
     IMPORTANT: YOU SHOULD NOT DO ANYTHING MORE WITH THIS BMLTiOSLib INSTANCE UNTIL THE DELEGATE CALLBACK IS INVOKED!
     
     The callback is the bmltLibInstance(_:BMLTiOSLib,serverIsValid:Bool) method in your delegate instance.
     
     You need to wait until this callback is invoked with serverIsValid set to true.
     
     If serverIsValid is false, then this instance of BMLTiOSLib is no longer usable, and should be discarded.
     
     Each instance of BMLTiOSLib has a lifetime associated with its HTTPS connection session.
     
     - parameter inRootServerURI: A String, with the URI to a valid BMLT Root Server
     - parameter inDelegate: A reference to an object that follows the BMLTiOSLibDelegate protocol.
     */
    public init(inRootServerURI: String, inDelegate: BMLTiOSLibDelegate) {
        super.init()
        self._rootServerURI = inRootServerURI
        self._delegate = inDelegate
        self._communicationHandler = BMLTiOSLibCommunicationHandler(self)
    }
    
    /* ########################################################## */
    /**
     Belt and suspenders. Just make sure we remove everything.
     */
    deinit {
        if nil != self.delegate {   // Quickly let the delegate know we're out of action.
            self.delegate.bmltLibInstance(self, serverIsValid: false)
        }
        self._communicationHandler.delegate = nil   // Make sure we don't get any bad callbacks.
        self.clearStorage()
    }
    
    /* ########################################################## */
    /**
     Disconnects the session, and removes all local storage.
     */
    public func clearStorage() {
        self._searchCriteria.clearStorage()
        self._communicationHandler.disconnectSession()
    }
    
    /* ################################################################## */
    /**
     Fetches a Service body node by its ID.
     
     - parameter inID: The ID for the requested Service body.
     */
    public func getServiceBodyByID(_ inID: Int)-> BMLTiOSLibHierarchicalServiceBodyNode! {
        var ret: BMLTiOSLibHierarchicalServiceBodyNode! = nil
        
        for sbNode in self.serviceBodies {
            if sbNode.id == inID {
                ret = sbNode
                break
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     Fetches a format node by its shared ID.
     
     - parameter inID: The ID for the requested format.
     */
    public func getFormatByID(_ inID: Int)-> BMLTiOSLibFormatNode! {
        var ret: BMLTiOSLibFormatNode! = nil
        
        for formatNode in self.allPossibleFormats {
            if formatNode.id == inID {
                ret = formatNode
                break
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     Fetches a format node by its string key.
     
     - parameter inKey: The key for the requested format.
     */
    public func getFormatByKey(_ inKey: String)-> BMLTiOSLibFormatNode! {
        var ret: BMLTiOSLibFormatNode! = nil
        
        for formatNode in self.allPossibleFormats {
            if formatNode.key == inKey {
                ret = formatNode
                break
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    // MARK: Communication Methods
    /* ################################################################## */
    /**
     These methods actually invoke communication with the Root Server.
     
     They should not be invoked until the serverIsValid callback has been returned with a value of True.
     */
    
    /* ################################################################## */
    /**
     Called to get every format actually used by meetings in the database (usually a subset of the entire format list).
     */
    public func getAllUsedFormats() {
        self.searchCriteria.clearAll()
        self._communicationHandler._gettingAllUsedFormats = true
        self.performMeetingSearch(.FormatsOnly)
    }
    
    /* ################################################################## */
    /**
     This performs a meeting search, based on the search criteria that currently exists.
     
     - parameter inSearchResultsType: The type of result[s] you'd like. Defaults to both meetings and formats.
     */
    public func performMeetingSearch(_ inSearchResultsType: BMLTiOSLibSearchCriteria.SearchCriteriaExtent = .BothMeetingsAndFormats) {
        self._communicationHandler.meetingSearch(self.searchCriteria.generateSearchURI(inSearchResultsType))
    }
    
    /* ################################################################## */
    /**
     This performs a meeting search, based on a list of meeting IDs.
     
     The BMLT Root Server has a special case, where a CSV list of integers is interpreted as a list of meeting IDs.
     
     - parameter inMeetingIDArray: An array on Int, with each integer being a BMLT ID of a meeting.
     - parameter searchType: The type of result[s] you'd like. Defaults to both meetings and formats.
     */
    public func getMeetingsObjectsByID(_ inMeetingIDArray: [Int], searchType inSearchResultsType: BMLTiOSLibSearchCriteria.SearchCriteriaExtent = .BothMeetingsAndFormats) {
        self.searchCriteria.clearAll()
        self.searchCriteria.searchString = inMeetingIDArray.map{String($0)}.joined(separator: ",")  // Generates a CSV list of integers.
        self._communicationHandler.meetingSearch(self.searchCriteria.generateSearchURI(inSearchResultsType))
    }
    
    /* ################################################################## */
    // MARK: Changed, Deleted and Rolled-Back Meetings
    /* ################################################################## */
    
    /* ################################################################## */
    /**
     Called to get meeting change records for deleted meetings only from the Root Server.
     
     - parameter fromDate: This is a Date object that contains a date/time that represents the first meeting change instance. It can be nil for no Start Date.
     - parameter toDate: This is a Date object that contains a date/time that represents the last meeting change instance. It can be nil for no End Date.
     - parameter serviceBodyIDs: An Array of Int, with the ID of one or more Service Bodies for which we want to get changes. It can be nil for all meeting changes within the given date range.
     */
    public func getDeletedMeetingChanges(fromDate inFromDate: Date?, toDate inToDate: Date?, serviceBodyIDs inServiceBodyIDs: [Int]?) {
        self._communicationHandler.getDeletedMeetingChanges(inFromDate: inFromDate, inToDate: inToDate, inServiceBodyIDs: inServiceBodyIDs)
    }
    
    /* ################################################################## */
    /**
     Called to get meeting change records for deleted meetings only from the Root Server.
     
     - parameter fromDate: This is a Date object that contains a date/time that represents the first meeting change instance. It can be nil for no Start Date.
     - parameter toDate: This is a Date object that contains a date/time that represents the last meeting change instance. It can be nil for no End Date.
     - parameter serviceBodyID: An Int, with the ID of one Service Body for which we want to get changes. It can be nil for all meeting changes within the given date range.
     */
    public func getDeletedMeetingChanges(fromDate inFromDate: Date?, toDate inToDate: Date?, serviceBodyID inServiceBodyID: Int?) {
        if nil == inServiceBodyID {
            self._communicationHandler.getDeletedMeetingChanges(inFromDate: inFromDate, inToDate: inToDate, inServiceBodyIDs: nil)
        } else {
            self._communicationHandler.getDeletedMeetingChanges(inFromDate: inFromDate, inToDate: inToDate, inServiceBodyIDs: [inServiceBodyID!])
        }
    }
    
    /* ################################################################## */
    /**
     Called to get meeting change records for deleted meetings only from the Root Server for a particular Service body.
     
     - parameter serviceBodyID: An Int, with the ID of one Service Body for which we want to get changes. It can be nil for all meeting changes within the given date range.
     */
    public func getDeletedMeetingChanges(serviceBodyID inServiceBodyID: Int?) {
        self.getDeletedMeetingChanges(fromDate: nil, toDate: nil, serviceBodyID: inServiceBodyID)
    }
    
    /* ################################################################## */
    /**
     Called to get meeting change records for deleted meetings only from the Root Server for a particular Service body.
     
     - parameter serviceBodyIDs: An Array of Int, with the ID of one or more Service Bodies for which we want to get changes. It can be nil for all meeting changes within the given date range.
     */
    public func getDeletedMeetingChanges(serviceBodyIDs inServiceBodyIDs: [Int]?) {
        self.getDeletedMeetingChanges(fromDate: nil, toDate: nil, serviceBodyIDs: inServiceBodyIDs)
    }
    
    /* ################################################################## */
    /**
     Called to get all meeting change records for deleted meetings only from the Root Server.
     */
    public func getDeletedMeetingChanges() {
        self.getDeletedMeetingChanges(fromDate: nil, toDate: nil, serviceBodyID: nil)
    }
    
    /* ################################################################## */
    /**
     Called to get meeting change records from the Root Server.
     
     - parameter fromDate: This is a Date object that contains a date/time that represents the first meeting change instance. It can be nil for no Start Date.
     - parameter toDate: This is a Date object that contains a date/time that represents the last meeting change instance. It can be nil for no End Date.
     - parameter serviceBodyID: An Int, with the ID of one Service Body for which we want to get changes. It can be nil for all meeting changes within the given date range.
     - parameter meetingID: An Int, with the ID of one meeting for which we want to get changes. It can be nil for all meeting changes within the given date range.
     - parameter userID: An Int, with the ID of one Admin User for which we want to get changes. It can be nil for all meeting changes within the given date range. This is only valid for logged-in users.
     */
    public func getAllMeetingChanges(fromDate inFromDate: Date?, toDate inToDate: Date?, serviceBodyID inServiceBodyID: Int?, meetingID inMeetingID: Int?, userID inUserID: Int?) {
        var userID: Int! = inUserID
        if !self.isAdminLoggedIn {  // Only logged-in users can track user IDs.
            userID = nil
        }
        self._communicationHandler.getAllMeetingChanges(inFromDate: inFromDate, inToDate: inToDate, inServiceBodyID: inServiceBodyID, inMeetingID: inMeetingID, inUserID: userID, inMeetingNode: nil)
    }
    
    /* ################################################################## */
    /**
     Called to get meeting change records from the Root Server.
     
     - parameter fromDate: This is a Date object that contains a date/time that represents the first meeting change instance. It can be nil for no Start Date.
     - parameter toDate: This is a Date object that contains a date/time that represents the last meeting change instance. It can be nil for no End Date.
     - parameter meetingID: An Int, with the ID of one meeting for which we want to get changes. It can be nil for all meeting changes within the given date range.
     - parameter serviceBodyID: An Int, with the ID of one Service Body for which we want to get changes. It can be nil for all meeting changes within the given date range.
     */
    public func getAllMeetingChanges(fromDate inFromDate: Date?, toDate inToDate: Date?, serviceBodyID inServiceBodyID: Int?, meetingID inMeetingID: Int?) {
        self.getAllMeetingChanges(fromDate: inFromDate, toDate: inToDate, serviceBodyID: inServiceBodyID, meetingID: inMeetingID, userID: nil)
    }
    
    /* ################################################################## */
    /**
     Called to get meeting change records from a meeting within a date range from the Root Server.
     
     - parameter fromDate: This is a Date object that contains a date/time that represents the first meeting change instance. It can be nil for no Start Date.
     - parameter toDate: This is a Date object that contains a date/time that represents the last meeting change instance. It can be nil for no End Date.
     - parameter meetingID: An Int, with the ID of one meeting for which we want to get changes. It can be nil for all meeting changes within the given date range.
     */
    public func getAllMeetingChanges(fromDate inFromDate: Date?, toDate inToDate: Date?, meetingID inID: Int?) {
        self.getAllMeetingChanges(fromDate: inFromDate, toDate: inToDate, serviceBodyID: nil, meetingID: inID)
    }
    
    /* ################################################################## */
    /**
     Called to get meeting change records from a Service body within a date range from the Root Server.
     
     - parameter fromDate: This is a Date object that contains a date/time that represents the first meeting change instance. It can be nil for no Start Date.
     - parameter toDate: This is a Date object that contains a date/time that represents the last meeting change instance. It can be nil for no End Date.
     - parameter serviceBodyID: An Int, with the ID of one Service Body for which we want to get changes. It can be nil for all meeting changes within the given date range.
     */
    public func getAllMeetingChanges(fromDate inFromDate: Date?, toDate inToDate: Date?, serviceBodyID inServiceBodyID: Int?) {
        self.getAllMeetingChanges(fromDate: inFromDate, toDate: inToDate, serviceBodyID: inServiceBodyID, meetingID: nil)
    }
    
    /* ################################################################## */
    /**
     Called to get all meeting change records within a date range from the Root Server.
     
     - parameter fromDate: This is a Date object that contains a date/time that represents the first meeting change instance. It can be nil for no Start Date.
     - parameter toDate: This is a Date object that contains a date/time that represents the last meeting change instance. It can be nil for no End Date.
     */
    public func getAllMeetingChanges(fromDate inFromDate: Date?, toDate inToDate: Date?) {
        self.getAllMeetingChanges(fromDate: inFromDate, toDate: inToDate, meetingID: nil)
    }
    
    /* ################################################################## */
    /**
     Called to get meeting change records for one single meeting from the Root Server.
     
     - parameter meetingID: An Int, with the ID of one meeting for which we want to get all of the last changes (It fetches all the stored changes, which are limited in scope).
     */
    public func getAllMeetingChanges(meetingID inID: Int) {
        self.getAllMeetingChanges(fromDate: nil, toDate: nil, meetingID: inID)
    }
    
    /* ################################################################## */
    /**
     Called to get meeting change records for one single meeting from the Root Server, with delivery of the changes to that meeting.
     
     - parameter meetingID: An Int, with the ID of one meeting for which we want to get all of the last changes (It fetches all the stored changes, which are limited in scope).
     */
    public func getAllMeetingChanges(meeting inMeetingNode: BMLTiOSLibMeetingNode?) {
        self._communicationHandler.getAllMeetingChanges(inFromDate: nil, inToDate: nil, inServiceBodyID: nil, inMeetingID: nil, inUserID: nil, inMeetingNode: inMeetingNode)
    }
    
    /* ################################################################## */
    /**
     Called to get meeting change records for one single Service body from the Root Server.
     
     - parameter serviceBodyID: An Int, with the ID of one Service Body for which we want to get changes. It can be nil for all meeting changes within the given date range.
     */
    public func getAllMeetingChanges(serviceBodyID inServiceBodyID: Int) {
        self.getAllMeetingChanges(fromDate: nil, toDate: nil, serviceBodyID: inServiceBodyID)
    }
    
    /* ################################################################## */
    // MARK: Public Administration Instance Methods
    /* ################################################################## */
    /**
     Called to log into a server that has semantic admin turned on.
     
     - parameter inLoginID: This is a string, with the login ID.
     - parameter inPassword: This is a string, with the password.
     
     - returns:  a Bool, which is true, if the connection is to a valid server with semantic admin on.
     */
    public func adminLogin(loginID inLoginID:String, password inPassword:String) -> Bool {
        return self._communicationHandler.adminLogin(loginID: inLoginID, password: inPassword)
    }
    
    /* ################################################################## */
    /**
     Called to log out of a server that has semantic admin turned on.
     
     - returns:  a Bool, which is true, if the connection is to a valid server with semantic admin on.
     */
    public func adminLogout() -> Bool {
        return self._communicationHandler.adminLogout()
    }
    
    /* ################################################################## */
    /**
     - returns:  If we are logged in as an admin, this will indicate the level of permission we have with a given Service body.
     */
    public func permissions(forServiceBody inServiceBody:BMLTiOSLibHierarchicalServiceBodyNode) -> BMLTiOSLibPermissions {
        return self._communicationHandler.permissions(forServiceBody: inServiceBody)
    }
    
    /* ################################################################## */
    /**
     This is called to set a meeting change.
     
     - parameter inMeetingObject: an editable meeting object.
     */
    public func saveMeetingChanges(_ inMeetingObject: BMLTiOSLibEditableMeetingNode) {
        self._communicationHandler.saveMeetingChanges(inMeetingObject)
    }
    
    /* ################################################################## */
    /**
     This is called to set a meeting change.
     
     - parameter inMeetingObject: an ID of an editable meeting object.
     
     - returns:  true, if the operation was dispatched successfully.
     */
    public func rollbackMeeting(_ inMeetingID: Int, toBeforeChange inChangeID: Int) -> Bool {
        return self._communicationHandler.rollbackMeeting(inMeetingID, toBeforeChange: inChangeID)
    }
    
    /* ################################################################## */
    /**
     Saves the meeting as a copy (does not save or set changes in current meeting).
     */
    public func saveMeetingAsCopy(_ inMeetingObject: BMLTiOSLibEditableMeetingNode) {
        var copyOfMeetingData = inMeetingObject.rawMeeting
        copyOfMeetingData["id_bigint"] = "0"
        copyOfMeetingData["published"] = "0"
        let copiedMeeting = BMLTiOSLibEditableMeetingNode(copyOfMeetingData, inHandler: self)
        self._communicationHandler.saveMeetingChanges(copiedMeeting)
    }
    
    /* ################################################################## */
    /**
     Called to delete a meeting.
     
     We have to assume the logged-in admin has rights. If they don't, it will be stopped at the server.
     
     - parameter inMeetingID: An Int, with the ID of the meeting to be deleted.
     */
    public func deleteMeeting(_ inMeetingID: Int) {
        self._communicationHandler.deleteMeeting(inMeetingID)
    }
   
    /* ################################################################## */
    /**
     Called to restore a deleted meeting.
     
     This instructs the Root Server to find the last deletion record for the meeting,
     and restore it to the state it was in just prior to deletion.
     
     However, it is more ideal to find the latest deletion record, and restore its "before" instance (See discussion above).
     
     - parameter inMeetingID: An Int, with the ID of the meeting to be restored.
     
     - returns:  true, if the operation was dispatched successfully.
     */
    public func restoreDeletedMeeting(_ inMeetingID: Int) -> Bool {
        return self._communicationHandler.restoreDeletedMeeting(inMeetingID)
    }
}

/* ###################################################################################################################################### */
// MARK: - Search Criteria Class -
/* ###################################################################################################################################### */
/**
 This is a special class that is used to gather and process meeting search criteria.
 
 The way it works, is that it gathers a search state, then creates a URI parameter list to be used by the main communication module.
 It does not do any communication, in itself.
 
 It has been designed so that the search criteria are expressed as properties, instead of functions.
 
 In order to execute searches, the user should access the instance of this class, and use it to set up search criteria. Upon completion of
 this, they should call the main instance's performMeetingSearch(_:) method. The main instance will ask the Search Criteria instance to
 create a URI parameter list that will describe the search.
 */
public class BMLTiOSLibSearchCriteria : NSObject {
    /* ############################################################## */
    // MARK: Public Typealiases
    /* ############################################################## */
    
    /** The idea here is that these are "selectable." They can be assigned a state of "selected," "deselected" or "clear." */
    /** This contains a Service body Dictionary, and is used to make it easy to differentiate the Service bodies from other data types. */
    public typealias SelectableServiceBodyItem = BMLTiOSLibServiceBodyContainer
    public typealias SelectableServiceBodyList = [SelectableServiceBodyItem]
    
    /** The same for formats. */
    public typealias SelectableFormatItem = BMLTiOSLibFormatContainer
    public typealias SelectableFormatList = [SelectableFormatItem]
    
    /** This allows us to differentiate weekday objects. */
    public typealias SelectableWeekdayDictionary = [WeekdayIndex:SelectionState]
    
    /** This is used to specify a field, and a value for that field */
    public typealias SpecificFieldValueTuple = (fieldKey: String, value: String, completeMatch: Bool, caseSensitive: Bool)
    
    /* ############################################################## */
    // MARK: Public Enums
    /* ############################################################## */
    
    /** These are the available selection states for Search Criteria. */
    public enum SelectionState: Int {
        /** This is a "hard NOT". This means that this criteria should state that the associated data item NOT be present. */
        case Deselected = -1
        /** This means "I don't care." It means that the associated item should not be considered in the criteria. */
        case Clear = 0
        /** This is a "hard YES". It means that the associated Criteria item should be present in the Search Criteria. */
        case Selected = 1
    }
    
    /**
     This enum specifies what kind of results we want from the search.
     */
    public enum SearchCriteriaExtent {
        /** Only return Meeting objects. */
        case MeetingsOnly
        /** Only return Format objects (Formats will be only those used in the specific meetings returned in the search). */
        case FormatsOnly
        /** Return both types of objects (The delagate callback will be called for each type). */
        case BothMeetingsAndFormats
    }
    
    /**
     This only applies when we are logged in as an admin. We can search for published, unpublished, or both kinds of meetings.
     Additionally, this only applies to meetings that are under the logged-in admin's control. Meetings outside their control will
     always only show published meetings.
     */
    public enum SearchCriteriaPublishedStatus {
        /** Only show meetings that are marked as "unpublished" (and are also in the control of the logged-in adminstrator). */
        case Unpublished
        /** Only show published meetings. */
        case Published
        /** Show both published and unpublished meetings. */
        case Both
    }
    
    /**
     This is used to index our weekday list.
     */
    public enum WeekdayIndex: Int {
        /** Sunday */
        case Sunday = 1
        /** Monday */
        case Monday
        /** Tuesday */
        case Tuesday
        /** Wednesday */
        case Wednesday
        /** Thursday */
        case Thursday
        /** Friday */
        case Friday
        /** Saturday */
        case Saturday
    }

    /* ############################################################## */
    // MARK: Private Properties
    /* ############################################################## */
    unowned private let _serverComm: BMLTiOSLib
    
    private var _serviceBodies: SelectableServiceBodyList
    private var _formats: SelectableFormatList
    private var _weekdays:SelectableWeekdayDictionary = [.Sunday:.Clear,.Monday:.Clear,.Tuesday:.Clear,.Wednesday:.Clear,.Thursday:.Clear,.Friday:.Clear,.Saturday:.Clear]
    private var _searchString: String = ""
    private var _searchIsALocation: Bool = false
    private var _stringSearchAll: Bool = false
    private var _stringSearchExact: Bool = false
    private var _searchRadius: Float = -10
    private var _searchLocation: CLLocationCoordinate2D! = nil
    private var _publishedStatus: SearchCriteriaPublishedStatus = .Both
    private var _specificFieldValue: SpecificFieldValueTuple! = nil
    private var _startTimeInSeconds: Int! = nil
    private var _endTimeInSeconds: Int! = nil
    private var _durationTimeInSeconds: Int! = nil
    private var _meetingsStartBeforeStartTime: Bool = false
    private var _meetingsAreShorterThanDuration: Bool = false
    
    /* ############################################################## */
    // MARK: Internal Methods
    /* ############################################################## */
    /**
     This takes the current search specifier state, and synthesizes a new URI from it.
     
     - parameter inSearchResultType: This specifies exactly what kind of results we are expecting.
     
     - returns:  a String, with the synthesized search URI.
     */
    internal func generateSearchURI(_ inSearchResultType: SearchCriteriaExtent) -> String {
        // First, generate the basic URI.
        var ret = ""
        
        switch inSearchResultType {
        case .MeetingsOnly:
            break
            
        case .FormatsOnly:
            ret += "&get_formats_only"
            
        case .BothMeetingsAndFormats:
            ret += "&get_used_formats"
        }
        
        // Next, we need to start adding the specific criteria.
        
        // Start with Service bodies
        
        for item in self.serviceBodies {
            if item.selection != .Clear {
                ret += "&services[]="
                if item.selection == .Deselected {
                    ret += "-"
                }
                ret += String(item.item.id)
            }
        }
        
        // Next, we do formats.
        
        for item in self.formats {
            if item.selection != .Clear {
                ret += "&formats[]="
                if item.selection == .Deselected {
                    ret += "-"
                }
                ret += String(item.item.id)
            }
        }
        
        // And then weekdays.
        
        for i in self._weekdays.keys {
            if let weekday = self._weekdays[i] {
                if weekday != .Clear {
                    ret += "&weekdays[]="
                    if weekday == .Deselected {
                        ret += "-"
                    }
                    ret += String(i.rawValue)
                }
            }
        }
        
        // Next, look for a search string
        
        var isSearchString: Bool = false    // If the location is determined by a string geocode, then we use a different radius parameter.
        
        if !self._searchString.isEmpty {
            ret += "&SearchString="
            ret += self._searchString.URLEncodedString()!
            // If this is a location string, then we set the flag, and ignore the other two flags.
            if self._searchIsALocation {
                isSearchString = true
                ret += "&StringSearchIsAnAddress=1"
            } else {
                if self._stringSearchExact {
                    ret += "&SearchStringExact=1"
                }
                if self._stringSearchAll {
                    ret += "&SearchStringAll=1"
                }
            }
        }
        
        // Next, see if a location was specified. This is ignored if a location search string was provided.
        
        if !(!self._searchString.isEmpty && self._searchIsALocation) && (nil != self._searchLocation) {
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 12
            formatter.decimalSeparator = "."
            ret += "&lat_val=" + formatter.string(from: self._searchLocation.latitude as NSNumber)!
            ret += "&long_val=" + formatter.string(from: self._searchLocation.longitude as NSNumber)!
        }
        
        // Next, check the search radius. This is ignored if there is no search center or location string.
        
        if ((!self._searchString.isEmpty && self._searchIsALocation) || (nil != self._searchLocation)) && (0 != self._searchRadius) {
            let radius: Float = self._searchRadius
            
            if isSearchString { // We use this parameter if it's a search string.
                ret += "&SearchStringRadius="
            } else {    // If we are doing a long/lat search, we use the geo_width parameter.
                if NSLocale.current.usesMetricSystem {
                    ret += "&geo_width_km="
                } else {
                    ret += "&geo_width="
                }
            }
            
            if 0 > radius {
                ret += String(format: "-%d", abs(Int(radius)))
            } else {
                ret += String(format: "%.4g", radius)
            }
        }
        
        // Let's see if we have a start time specified.
        
        if nil != self.startTimeInSeconds {
            var minutes: Int = Int(self.startTimeInSeconds!) / 60
            let hours: Int = (minutes / 60)
            minutes -= (hours * 60)
            
            if 0 < hours {
                ret += (self.meetingsStartBeforeStartTime ? "&StartsBeforeH=" : "&StartsAfterH=")
                ret += String(hours)
            }
            
            if 0 < minutes {
                ret += (self.meetingsStartBeforeStartTime ? "&StartsBeforeM=" : "&StartsAfterM=")
                ret += String(minutes)
            }
        }
        
        // Let's see if we have an end time specified.
        
        if nil != self.endTimeInSeconds {
            var minutes: Int = Int(self.endTimeInSeconds!) / 60
            let hours: Int = (minutes / 60)
            minutes -= (hours * 60)
            
            if 0 < hours {
                ret += ("&EndsBeforeH=" + String(hours))
            }
            
            if 0 < minutes {
                ret += ("&EndsBeforeM=" + String(minutes))
            }
        }
        
        // Let's see if we have a duration time specified.
        
        if nil != self.durationTimeInSeconds {
            let hours: Int = Int(self.durationTimeInSeconds! / 3600)
            let minutes: Int = Int(self.durationTimeInSeconds! - (hours * 3600)) / 60
            
            if 0 < hours {
                ret += (self.meetingsAreShorterThanDuration ? "&MaxDurationH=" : "&MinDurationH=")
                ret += String(hours)
            }
            
            if 0 < minutes {
                ret += (self.meetingsAreShorterThanDuration ? "&MaxDurationM=" : "&MinDurationM=")
                ret += String(minutes)
            }
        }
        
        // Now, see if we are asking for a specific value of a field.
        
        if (nil != self._specificFieldValue) && !self._specificFieldValue!.fieldKey.isEmpty {
            ret += "&meeting_key=" + self._specificFieldValue!.fieldKey.URLEncodedString()!
            ret += "&meeting_key_value=" + self._specificFieldValue!.value.URLEncodedString()!
            if self._specificFieldValue!.caseSensitive {
                ret += "&meeting_key_match_case=1"
            }
            
            if self._specificFieldValue!.completeMatch {
                ret += "&meeting_key_contains=0"
            }
        }
        
        // If we are a logged-in admin, then we can pick our published status.
        if self._serverComm.isAdminLoggedIn {
            ret += "&advanced_published=" + ((.Published == self.publishedStatus) ? "1" : ((.Both == self.publishedStatus) ? "0" : "-1"))
        }
        
        // Return the search parameter list.
        return ret
    }
    
    /* ############################################################## */
    // MARK: Public Calculated Properties
    /* ############################################################## */
    /**
     Accessor for our internal Published Status.
     */
    public var publishedStatus: SearchCriteriaPublishedStatus {
        get { return self._publishedStatus }
        set { self._publishedStatus = newValue }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal Service body list.
     */
    public var serviceBodies: SelectableServiceBodyList {
        get { return self._serviceBodies }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal format list.
     */
    public var formats: SelectableFormatList {
        get { return self._formats }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal weekday list.
     */
    public var weekdays: SelectableWeekdayDictionary {
        get { return self._weekdays }
        set { self._weekdays = newValue }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal search radius value.
     */
    public var searchRadius: Float {
        get { return self._searchRadius }
        set { self._searchRadius = newValue }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal Search String.
     */
    public var searchString: String {
        get {
            return self._searchString
        }
        set {
            self._searchString = newValue
        }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal Search String Is a Location selector.
     
     NOTE: If this is specified, and a string is provided in searchString, then searchLocation is ignored.
     */
    public var searchStringIsALocation: Bool {
        get {
            return self._searchIsALocation
        }
        set {
            self._searchIsALocation = newValue
        }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal Search String is Exact selector
     */
    public var stringSearchIsExact: Bool {
        get {
            return self._stringSearchExact
        }
        set {
            self._stringSearchExact = newValue
        }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal Search String Uses all Substrings selector
     */
    public var stringSearchUsesAllStrings: Bool {
        get {
            return self._stringSearchAll
        }
        set {
            self._stringSearchAll = newValue
        }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal center location selector.
     
     NOTE: This is ignored if searchStringIsALocation is true, and we have a search string in searchString.
     */
    public var searchLocation: CLLocationCoordinate2D! {
        get {
            return self._searchLocation
        }
        set {
            self._searchLocation = newValue
        }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal specific field value search criteria.
     
     - returns:  an optional tuple, with the various field criteria, or nil
     */
    public var specificFieldSearch: SpecificFieldValueTuple? {
        get {
            return self._specificFieldValue
        }
        
        set {
            self._specificFieldValue = newValue
        }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal start time (in seconds from midnight -00:00:00) search criteria.
     This is an inclusive time, and includes 24:00:00 (end of day midnight).
     
     - returns:  an optional int, with seconds from Midnight, or nil
     */
    public var startTimeInSeconds: Int? {
        get { return self._startTimeInSeconds }
        set { self._startTimeInSeconds = newValue }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal meeting end time (in seconds from midnight -00:00:00) search criteria.
     This is an inclusive time, and includes 24:00:00 (end of day midnight).
     
     - returns:  an optional int, with seconds from Midnight, or nil
     */
    public var endTimeInSeconds: Int? {
        get { return self._endTimeInSeconds }
        set { self._endTimeInSeconds = newValue }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal duration (in seconds) search criteria.
     
     - returns:  an optional int, with seconds, or nil
     */
    public var durationTimeInSeconds: Int? {
        get { return self._durationTimeInSeconds }
        set { self._durationTimeInSeconds = newValue }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal meetings should begin before (or at) start time flag.
     
     - returns:  a Bool, true if the meeting should start before or on the start time, or false, if the meeting is to start at or after the start time.
     */
    public var meetingsStartBeforeStartTime: Bool {
        get { return self._meetingsStartBeforeStartTime }
        set { self._meetingsStartBeforeStartTime = newValue }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal meetings should be shorter than the duration flag.
     
     - returns:  a Bool, true if the meeting should be shorter than (or equal to) the duration time, or false, if the meeting is equal to, or longer than, the duration.
     */
    public var meetingsAreShorterThanDuration: Bool {
        get { return self._meetingsAreShorterThanDuration }
        set { self._meetingsAreShorterThanDuration = newValue }
    }
    
    /* ############################################################## */
    /**
     An easy way to test or set a minimum starting time for meetings.
     
     - returns:  an optional NSDateComponents. If not nil, will contain the minimum start time for meetings.
     */
    public var meetingsShouldStartAtOrAfter: NSDateComponents? {
        get {
            var ret: NSDateComponents! = nil
            
            if (nil != self.startTimeInSeconds) && !self.meetingsStartBeforeStartTime {
                ret = NSDateComponents()
                
                ret.hour = (self.startTimeInSeconds! / 3600)
                ret.minute = self.startTimeInSeconds! - (ret.hour * 3600)
                ret.second = self.startTimeInSeconds! - ((ret.hour * 3600) + (ret.minute * 60))
            }
            
            return ret
        }
        
        set {
            self.meetingsStartBeforeStartTime = false
            self.startTimeInSeconds = nil
            if nil != newValue {
                let hours = (nil != newValue?.hour) ? newValue!.hour : 0
                let minutes = (nil != newValue?.minute) ? newValue!.minute : 0
                let seconds = (nil != newValue?.second) ? newValue!.second : 0
                self.startTimeInSeconds = (hours * 3600) + (minutes * 60) + seconds
            }
        }
    }
    
    /* ############################################################## */
    /**
     An easy way to test or set a maximum starting time for meetings.
     
     - returns:  an optional NSDateComponents. If not nil, will contain the maximum start time for meetings.
     */
    public var meetingsShouldStartBeforeOrAt: NSDateComponents? {
        get {
            var ret: NSDateComponents! = nil
            
            if (nil != self.startTimeInSeconds) && self.meetingsStartBeforeStartTime {
                ret = NSDateComponents()
                
                ret.hour = (self.startTimeInSeconds! / 3600)
                ret.minute = self.startTimeInSeconds! - (ret.hour * 3600)
                ret.second = self.startTimeInSeconds! - ((ret.hour * 3600) + (ret.minute * 60))
            }
            
            return ret
        }
        
        set {
            self.meetingsStartBeforeStartTime = true
            self.startTimeInSeconds = nil
            if nil != newValue {
                self.startTimeInSeconds = (newValue!.hour * 3600) + (newValue!.minute * 60) + newValue!.second
            }
        }
    }
    
    /* ############################################################## */
    /**
     An easy way to test or set a minimum duration time for meetings.
     
     - returns:  an optional NSDateComponents. If not nil, will contain the minimum duration for meetings.
     */
    public var meetingsAreAtLeast: NSDateComponents? {
        get {
            var ret: NSDateComponents! = nil
            
            if (nil != self.durationTimeInSeconds) && !self.meetingsAreShorterThanDuration {
                ret = NSDateComponents()
                
                ret.hour = (self.durationTimeInSeconds! / 3600)
                ret.minute = self.durationTimeInSeconds! - (ret.hour * 3600)
                ret.second = self.durationTimeInSeconds! - ((ret.hour * 3600) + (ret.minute * 60))
            }
            
            return ret
        }
        
        set {
            self.meetingsAreShorterThanDuration = false
            self.durationTimeInSeconds = nil
            if nil != newValue {
                self.durationTimeInSeconds = (newValue!.hour * 3600) + (newValue!.minute * 60) + newValue!.second
            }
        }
    }
    
    /* ############################################################## */
    /**
     An easy way to test or set a maximum duration time for meetings.
     
     - returns:  an optional NSDateComponents. If not nil, will contain the maximum duration for meetings.
     */
    public var meetingsAreNoLongerThan: NSDateComponents? {
        get {
            var ret: NSDateComponents! = nil
            
            if (nil != self.durationTimeInSeconds) && self.meetingsAreShorterThanDuration {
                ret = NSDateComponents()
                
                ret.hour = (self.durationTimeInSeconds! / 3600)
                ret.minute = self.durationTimeInSeconds! - (ret.hour * 3600)
                ret.second = self.durationTimeInSeconds! - ((ret.hour * 3600) + (ret.minute * 60))
            }
            
            return ret
        }
        
        set {
            self.meetingsAreShorterThanDuration = true
            self.durationTimeInSeconds = nil
            if nil != newValue {
                self.durationTimeInSeconds = (newValue!.hour * 3600) + (newValue!.minute * 60) + newValue!.second
            }
        }
    }
    
    /* ############################################################## */
    /**
     An easy way to test or set a maximum end time for meetings.
     
     - returns:  an optional NSDateComponents. If not nil, will contain the maximum end time for meetings.
     */
    public var meetingsEndOnOrBefore: NSDateComponents? {
        get {
            var ret: NSDateComponents! = nil
            
            if nil != self.endTimeInSeconds {
                ret = NSDateComponents()
                
                ret.hour = (self.endTimeInSeconds! / 3600)
                ret.minute = self.endTimeInSeconds! - (ret.hour * 3600)
                ret.second = self.endTimeInSeconds! - ((ret.hour * 3600) + (ret.minute * 60))
            }
            
            return ret
        }
        
        set {
            self.endTimeInSeconds = nil
            if nil != newValue {
                self.endTimeInSeconds = (newValue!.hour * 3600) + (newValue!.minute * 60) + newValue!.second
            }
        }
    }
    
    /* ############################################################## */
    /**
     - returns:  true, if there is a search criteria set.
     */
    public var isDirty: Bool {
        get {
            var ret: Bool = false
            
            for sb in self._serviceBodies {
                ret = (sb.selection != .Clear) ? true : ret
            }
            
            for fmt in self._formats {
                ret = (fmt.selection != .Clear) ? true : ret
            }
            
            for wd in self._weekdays {
                ret = (wd.value != .Clear) ? true : ret
            }
            
            if !self._searchString.isEmpty {
                ret = true
            }
            
            if nil != self._searchLocation {
                ret = true
            }
            
            if nil != self._startTimeInSeconds {
                ret = true
            }
            
            if nil != self._endTimeInSeconds {
                ret = true
            }
            
            if nil != self._durationTimeInSeconds {
                ret = true
            }
            
            if (nil != self._specificFieldValue) && !self._specificFieldValue!.fieldKey.isEmpty {
                ret = true
            }
            
            // Let's see if we have a start time specified.
            
            if nil != self.startTimeInSeconds {
                ret = true
            }
            
            // Let's see if we have an end time specified.
            
            if nil != self.endTimeInSeconds {
                ret = true
            }
            
            // Let's see if we have a duration time specified.
            
            if nil != self.durationTimeInSeconds {
                ret = true
            }
            
            return ret
        }
    }
    
    /* ############################################################## */
    // MARK * Public Initializer
    /* ############################################################## */
    /**
     Default initializer. We must have at least the server comm.
     
     - parameter inServerComm: This is a reference to the BMLTiOSLib instance that "owns" this.
     */
    public init(_ inServerComm: BMLTiOSLib) {
        self._serverComm = inServerComm
        self._serviceBodies = []
        self._formats = []
        
        for sb in inServerComm.serviceBodies {
            let wrapper: SelectableServiceBodyItem = SelectableServiceBodyItem(item: sb, selection: .Clear, extraData: nil)
            self._serviceBodies.append(wrapper)
        }
        
        for fm in inServerComm.allPossibleFormats {
            let wrapper: SelectableFormatItem = SelectableFormatItem(item: fm, selection: .Clear, extraData: nil)
            self._formats.append(wrapper)
        }
        
        super.init()
    }
    
    /* ############################################################## */
    // MARK: Public Instance Methods
    /* ############################################################## */
    /**
     Make sure we completely deallocate our selectable lists.
     */
    public func clearStorage() {
        self._formats.removeAll()
        self._serviceBodies.removeAll()
        self.clearAll()
    }
    
    /* ############################################################## */
    /**
     This resets all search criteria to default.
     */
    public func clearAll() {
        for i in 0..<self._serviceBodies.count {
            self._serviceBodies[i].selection = .Clear
        }
        
        for i in 0..<self._formats.count {
            self._formats[i].selection = .Clear
        }
        
        for key in self._weekdays.keys {
            self._weekdays[key] = .Clear
        }
        
        self._searchRadius = -10
        self._searchString = ""
        self._searchIsALocation = false
        self._stringSearchAll = false
        self._stringSearchExact = false
        self._searchLocation = nil
    }
    
    /* ############################################################## */
    /**
     This returns the selection object for a given Service body object.
     - parameter inObject: The Service body object we are matching.
     - returns:  the wrapper item for that Service body object.
     */
    public func getServiceBodyElementFromServiceBodyObject(_ inObject: BMLTiOSLibHierarchicalServiceBodyNode) -> SelectableServiceBodyItem! {
        for item in self.serviceBodies {
            if item.item == inObject {
                return item
            }
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     This tells our BMLTiOSLib instance to perform a meeting search, based on our current criteria.
     
     - parameter inSearchResultsType: The type of result[s] you'd like. Defaults to both meetings and formats.
     */
    public func performMeetingSearch(_ inSearchResultsType: BMLTiOSLibSearchCriteria.SearchCriteriaExtent = .BothMeetingsAndFormats) {
        self._serverComm.performMeetingSearch(inSearchResultsType)
    }
}

/* ###################################################################################################################################### */
// MARK: - Meeting Iterator Element Class -
/* ###################################################################################################################################### */
/**
 This is a special "sub-micro class" for iterating through the fields of this meeting.
 */
public class BMLTiOSLibMeetingNodeSimpleDictionaryElement: NSObject {
    /* ################################################################## */
    // MARK: Public Properties
    /* ################################################################## */
    
    /** The Dictionary key */
    public let key: String
    /** The element value */
    public let value: String
    /** The meeting node that "owns" this element. */
    unowned public let handler: BMLTiOSLibMeetingNode
    
    /* ################################################################## */
    // MARK: Public Calculated Properties
    /* ################################################################## */
    /**
        Accessor for the handler's BMLTiOSLib library (The Handler's handler).
     */
    public var library: BMLTiOSLib {
        get{
            return self.handler._handler
        }
    }
    
    /* ################################################################## */
    // MARK * Public Initializer
    /* ################################################################## */
    /**
        Default Initializer
     
        - parameter key: The key for this node.
        - parameter value: The value to assign for the key
        - parameter handler: The BMLTiOSLibMeetingNode object that "owns" this data object.
    */
    public init(key: String, value: String, handler: BMLTiOSLibMeetingNode) {
        self.key = key
        self.value = value
        self.handler = handler
    }
}

/* ###################################################################################################################################### */
// MARK: - Changed Meeting Class -
/* ###################################################################################################################################### */
/**
 This is a special class that represents objects for meeting changes.
 */
public class BMLTiOSLibChangedMeeting: NSObject {
    /* ################################################################## */
    // MARK: Private Properties
    /* ################################################################## */
    /** This is a Dictionary object with the raw JSON response object */
    private let _rawObject: [String:AnyObject?]
    /** This is the "owning" BMLTiOSLib object for this change */
    unowned private let _handler: BMLTiOSLib
    
    /* ################################################################## */
    // MARK: Public Calculated Properties
    /* ################################################################## */
    /**
     - returns:  The changed meeting's BMLT ID.
     */
    public var meetingID: Int {
        get {
            var ret: Int = 0
            
            if let idContainer = self._rawObject["changeMeeting"] as? [String:String] {
                if let id = idContainer["id"] {
                    if let idInt = Int(id) {
                        ret = idInt
                    }
                }
            }
            return ret
        }
    }

    /* ################################################################## */
    /**
     - returns:  All the various field changes associated with this meeting change.
     */
    public var meetingChanges: [String:[String]] {
        get {
            var ret: [String:[String]] = [:]
            
            if let fieldsContainer = self._rawObject["field"] as? [String:AnyObject?] {
                if let key = fieldsContainer["key"] as? String {
                    if let oldValue = self._rawObject["oldValue"] as? String {
                        if let newValue = self._rawObject["newValue"] as? String {
                            ret[key] = [oldValue,newValue]
                        }
                    }
                }
            } else {
                if let fieldsArray = self._rawObject["field"] as? [[String:AnyObject?]] {
                    for field in fieldsArray {
                        if let attributes = field["@attributes"] as? [String:String] {
                            if let key = attributes["key"] {
                                if let oldValue = field["oldValue"] as? String {
                                    if let newValue = field["newValue"] as? String {
                                        ret[key] = [oldValue,newValue]
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A textual description of the change.
     */
    override public var description: String {
        get {
            var ret: String = "Meeting Change for Meeting ID " + String(self.meetingID)
            
            for key in self.meetingChanges.keys {
                ret += "\n"
                ret += key
                ret += " changed from " + (self.meetingChanges[key]?[0])!
                ret += " to " + (self.meetingChanges[key]?[1])!
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    // MARK: Public Initializer
    /* ################################################################## */
    /**
     Default initializer
     
     - parameter inDictionary: This is a Dictionary object with the raw JSON response object.
     - parameter inHandler: This is the "owning" BMLTiOSLib object for this change.
     */
    public init(_ inDictionary: [String:AnyObject?], inHandler: BMLTiOSLib) {
        self._rawObject = inDictionary
        self._handler = inHandler
    }
}

/* ###################################################################################################################################### */
// MARK: - Change Class -
/* ###################################################################################################################################### */
/**
 This is a special class that represents change objects.
 */
public class BMLTiOSLibChangeNode: NSObject {
    /* ################################################################## */
    // MARK: Private Properties
    /* ################################################################## */
    /** This is a Dictionary object with the raw JSON response object */
    private let _rawObject: [String:AnyObject?]
    /** This is the "owning" BMLTiOSLib object for this change */
    unowned private let _handler: BMLTiOSLib
    
    /* ################################################################## */
    // MARK: Public Properties
    /* ################################################################## */
    /** If there was a "before this change" meeting object, it is provided here. */
    public var beforeObject: BMLTiOSLibMeetingNode! = nil
    /** If there was an "after this change" meeting object, it is provided here. */
    public var afterObject: BMLTiOSLibMeetingNode! = nil
    
    /* ################################################################## */
    // MARK: Public Calculated Properties
    /* ################################################################## */
    /**
     - returns:  The date the change was made.
     */
    public var changeDate: Date! {
        get {
            var ret: Date! = nil
            if let epochDateString = self._rawObject["date_int"] {
                if let dateInt = TimeInterval((epochDateString as? String)!) {
                    ret = Date(timeIntervalSince1970: dateInt)
                }
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  The name of the administrator that made the change.
     */
    public var changeMaker: String {
        get {
            var ret: String = ""
            if let userName = self._rawObject["user_name"] as? String {
                ret = userName
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  The ID of the change.
     */
    public var id: Int {
        get {
            var ret: Int = 0
            if let change_id_string = self._rawObject["change_id"] as? String {
                if let change_id = Int(change_id_string) {
                    ret = change_id
                }
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  The Service body to which the changed meeting belongs.
     */
    public var serviceBody: BMLTiOSLibHierarchicalServiceBodyNode! {
        get {
            var ret: BMLTiOSLibHierarchicalServiceBodyNode! = nil
            if let sbString = self._rawObject["service_body_id"] {
                if let sbInt = Int((sbString as? String)!) {
                    ret = self._handler.getServiceBodyByID(sbInt)
                }
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  True, if the meeting currently exists.
     */
    public var meetingCurrentlyExists: Bool {
        get {
            var ret: Bool = false
            if let keyString = self._rawObject["meeting_exists"] as? String {
                ret = "1" == keyString
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  The listed change details.
     */
    public var details: String {
        get {
            var ret: String = ""
            if let keyString = self._rawObject["details"] as? String {
                ret = keyString.replacingOccurrences(of: "&quot;", with: "\"").replacingOccurrences(of: "&amp;", with: "&")
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  The listed change meeting ID.
     */
    public var meeting_id: Int {
        get {
            var ret: Int = 0
            
            if let idString = self._rawObject["meeting_id"] as? String {
                ret = Int(idString)!
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  True, if the meeting was created by this change.
     */
    public var meetingWasCreated: Bool {
        get {
            return nil == self.beforeObject
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  True, if the meeting was deleted by this change.
     */
    public var meetingWasDeleted: Bool {
        get {
            return nil == self.afterObject
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  a Dictionary of changes made, with "before" and "after" values for each changed field.
     
     Each Dictionary entry is described by the field key. The content is a 2-element String Array, with 0 being the "before" value and 1 being the "after" value
     */
    public var meetingWasChanged: [String: [String]]! {
        get {
            var ret: [String: [String]]! = nil
            
            if (nil != self.beforeObject) && (nil != self.afterObject) {
                var keys = self._handler.availableMeetingValueKeys
                keys.append("published")
                
                for key in keys {
                    let beforeValue = self.beforeObject[key]
                    let afterValue = self.afterObject[key]
                    
                    if beforeValue != afterValue {
                        if nil == ret {
                            ret = [:]
                        }
                        ret[key] = [(nil != beforeValue) ? beforeValue! : "", (nil != afterValue) ? afterValue! : ""]
                    }
                }
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     */
    override public var description: String {
        get {
            var ret: String = ""
            
            let dateformatter = DateFormatter()
            
            dateformatter.dateFormat = "h:mm a MMMM d, YYYY"
            
            let changeDate = dateformatter.string(from: self.changeDate)
            
            if self.meetingWasCreated {
                ret += "\(changeDate): \(self.changeMaker) created this meeting."
            } else {
                if self.meetingWasDeleted {
                    ret += "\(changeDate): \(self.changeMaker) deleted this meeting."
                } else {
                    ret += "\(changeDate): \(self.changeMaker) changed this meeting:"
                    if let changes = self.meetingWasChanged {
                        for change in changes {
                            ret += ("\n    " + change.key + " changed from \"" + change.value[0] + "\" to \"" + change.value[1] + "\"")
                        }
                    }
                }
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    // MARK: Public Initializer
    /* ################################################################## */
    /**
     Default initializer
     
     - parameter inDictionary: This is a Dictionary object with the raw JSON response object.
     - parameter inHandler: This is the "owning" BMLTiOSLib object for this change.
     */
    public init(_ inDictionary: [String:AnyObject?], inHandler: BMLTiOSLib) {
        self._rawObject = inDictionary
        self._handler = inHandler
        
        if let beforeAfterJSON = inDictionary["json_data"] as? [String:[String:AnyObject?]] {
            if let beforeObject = beforeAfterJSON["before"] {
                var allStringObject: [String:String] = [:]
                for key in beforeObject.keys {
                    if let strVal = beforeObject[key] as? String {
                        allStringObject[key] = strVal
                    } else {
                        if let arVal = beforeObject[key] as? NSArray {
                            allStringObject[key] = arVal.componentsJoined(by: ",")
                        }
                    }
                }
                
                self.beforeObject = inHandler.generateProperMeetingObject(allStringObject)

            }
            
            if let afterObject = beforeAfterJSON["after"] {
                var allStringObject: [String:String] = [:]
                for key in afterObject.keys {
                    if let strVal = afterObject[key] as? String {
                        allStringObject[key] = strVal
                    } else {
                        if let arVal = afterObject[key] as? NSArray {
                            allStringObject[key] = arVal.componentsJoined(by: ",")
                        }
                    }
                }
                
                self.afterObject = inHandler.generateProperMeetingObject(allStringObject)
            }
        }
        
        super.init()
    }
    
    /* ################################################################## */
    // MARK: Public Methods
    /* ################################################################## */
    /**
     Reverts a meeting to the "before" state of this change, but does not save the changes.
     
     The "before" meeting must also be editable, the user needs to be currently logged in
     with edit privileges on the meeting.
     
     - returns:  True, if the reversion was allowed.
     */
    public func revertMeetingToBeforeThisChange() -> Bool {
        if let beforeObject = self.beforeObject {
            if beforeObject.isEditable {
                return (beforeObject as! BMLTiOSLibEditableMeetingNode).revertMeetingToBeforeThisChange(self)
            }
        }
        
        return false
    }
    
    /* ################################################################## */
    /**
     Reverts a meeting to the "before" state of this change, and saves it on the server.
     
     If this is a deleted meeting, the meeting will be restored, which the server does by finding the last delete change for that meeting, and restores it.
     It is possible that the restored meeting may be different from the one before this change,
     but doing it this way makes sure the last meeting state is preserved.
     
     The "before" meeting must also be editable, the user needs to be currently logged in
     with edit privileges on the meeting.
     
     - returns:  True, if the reversion was allowed.
     */
    public func saveMeetingToBeforeThisChange() -> Bool {
        if let beforeObject = self.beforeObject {
            if beforeObject.isEditable {
                if self.meetingWasDeleted {
                    return self._handler.restoreDeletedMeeting(beforeObject.id)
                } else {
                    return self._handler.rollbackMeeting(beforeObject.id, toBeforeChange: self.id)
                }
            }
        }
        
        return false
    }
}

/* ###################################################################################################################################### */
// MARK: - Meeting Class -
/* ###################################################################################################################################### */
/**
 This is a special "micro class" for accessing the meetings for a Server.
 */
public class BMLTiOSLibMeetingNode: NSObject, Sequence {
    /* ################################################################## */
    // MARK: Private Properties
    /* ################################################################## */
    /**
     This tells us whether or not the device is set for military time.
     */
    private var _using12hClockFormat: Bool {
        get {
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            
            let dateString = formatter.string(from: Date())
            let amRange = dateString.range(of: formatter.amSymbol)
            let pmRange = dateString.range(of: formatter.pmSymbol)
            
            return !(pmRange == nil && amRange == nil)
        }
    }

    /* ################################################################## */
    // MARK: Public Subscript
    /* ################################################################## */
    /**
     This allows us to treat the meeting as if it were a standard Dictionary.
     
     - parameter inStringKey: This is a String key to access the meeting data element.
     */
    public subscript(_ inStringKey: String) -> String! {
        if "formats" == inStringKey {
            return self.formatsAsCSVList    // We make sure we reorder this, so we are consistent.
        } else {
            return self._rawMeeting[inStringKey]
        }
    }

    /* ################################################################## */
    // MARK: Internal Static Class Variables
    /* ################################################################## */
    /**
     This is a default placeholder for new (unnammed) meetings.
     */
    private static let BMLTiOSLib_DefaultMeetingNameString = "BMLTiOSLib-Default-Meeting-Name"
    
    /**
     This is a default placeholder for new meetings.
     */
    private static let BMLTiOSLib_DefaultMeetingStartTime = "22:00:00"
    
    /**
     This is a default placeholder for new meetings.
     */
    private static let BMLTiOSLib_DefaultMeetingDurationTime = "01:00:00"
    
    /**
     This is a default placeholder for new meetings.
     */
    private static let BMLTiOSLib_DefaultMeetingWeekday = "1"

    /* ################################################################## */
    // MARK: Internal Properties
    /* ################################################################## */
    /** This will contain the "raw" meeting data. It isn't meant to be exposed. */
    private var _rawMeeting: [String:String]
    
    /* ################################################################## */
    // MARK: Internal Methods
    /* ################################################################## */
    /**
     This parses the meeting data, and creates a fairly basic, straightforward, US-type address.
     
     - returns:  A String, with a basic address, in US format.
     */
    private var _USAddressParser: String {
        get {
            var ret: String = ""    // We will build this string up from location information.
            
            let name = self.locationName
            let street = self.locationStreetAddress
            let borough = self.locationBorough
            let town = self.locationTown
            let state = self.locationState
            let zip = self.locationZip
            
            if !name.isEmpty {  // We check each field to make sure it isn't empty.
                ret = name
            }
            
            if !street.isEmpty {
                if !ret.isEmpty {
                    ret += ", "
                }
                ret += street
            }
            
            // Boroughs are treated a bit differently, as they are often the primary address for a given city area.
            if !borough.isEmpty {
                if !ret.isEmpty {
                    ret += ", "
                }
                ret += borough
                if !town.isEmpty {
                    ret += " (" + town + ")"
                }
            } else {
                if !town.isEmpty {
                    if !ret.isEmpty {
                        ret += ", "
                    }
                    ret += town
                }
            }
            
            if !state.isEmpty {
                if !ret.isEmpty {
                    ret += ", "
                }
                ret += state
            }
            
            if !zip.isEmpty {
                if !ret.isEmpty {
                    ret += " "
                }
                ret += zip
            }
            
            return ret
        }
    }
    
    /** These are the standard keys that all meeting objects should have available (They may not all be filled, though). */
    internal static let standardKeys: [String] = ["id_bigint", "service_body_bigint", "weekday_tinyint", "start_time", "duration_time", "formats", "longitude", "latitude", "meeting_name", "location_text", "location_info", "location_street", "location_city_subsection", "location_neighborhood", "location_municipality", "location_sub_province", "location_province", "location_postal_code_1", "comments"]
    
    /** This is the library object that "owns" this instance. */
    weak internal var _handler: BMLTiOSLib! = nil
    
    /* ################################################################## */
    // MARK: Public Properties
    /* ################################################################## */
    /** This will contain any changes that are associated with this meeting. */
    public var changes: [BMLTiOSLibChangeNode]! = nil
    
    /* ################################################################## */
    // MARK: Public Calculated Properties
    /* ################################################################## */
    /** This class is not editable. */
    public var isEditable: Bool {
        get {
            return false
        }
    }
    
    /* ################################################################## */
    /**
     Returns a sorted list of the value array keys. It sorts the "default" ones first.
     - returns:  all of the available keys in our dictionary.
     */
    public var keys: [String] {
        get {
            var sortOrder = type(of: self).standardKeys
            
            sortOrder.append("published")
            
            let meetingKeys = self.rawMeeting.keys.sorted()
            
            var key_array:[String] = []
            
            for key in sortOrder {
                if meetingKeys.contains(key) {
                    key_array.append(key)
                }
            }
            
            for key in meetingKeys {
                if !key_array.contains(key) {
                    key_array.append(key)
                }
            }
            
            return key_array
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  Our internal editable instance instead of the read-only one for the superclass.
     */
    public var rawMeeting: [String:String] {
        get { return self._rawMeeting }
        set {
            if self.isEditable {
                self._rawMeeting = newValue
            }
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  An Int, with the meeting BMLT ID.
     */
    public var id: Int {
        get {
            var ret: Int = 0
            
            if let val = Int(self["id_bigint"]) {
                ret = val
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A String, with the meeting NAWS ID.
     */
    public var worldID: String {
        get {
            var ret: String = ""
            
            if let val = self["worldid_mixed"] {
                ret = val
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  An Int, with the meeting's Service body BMLT ID.
     */
    public var serviceBodyId: Int {
        get {
            var ret: Int = 0
            
            if let val = Int(self["service_body_bigint"]) {
                ret = val
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  The meeting's Service body object. nil, if no Service body (should never happen).
     */
    public var serviceBody: BMLTiOSLibHierarchicalServiceBodyNode! {
        get {
            return self._handler.getServiceBodyByID(self.serviceBodyId)
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  an array of format objects.
     */
    public var formats: [BMLTiOSLibFormatNode] {
        get {
            let formatIDArray = self.formatsAsCSVList.components(separatedBy: ",")
            
            var ret: [BMLTiOSLibFormatNode] = []
            
            for formatKey in formatIDArray {
                if let format = self._handler.getFormatByKey(formatKey) {
                    ret.append(format)
                }
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  a CSV string of format codes, sorted alphabetically.
     */
    public var formatsAsCSVList: String {
        get {
            var ret: String = ""
            
            if let list = self._rawMeeting["formats"]?.components(separatedBy: ",").sorted() {
                ret = list.joined(separator: ",")
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A Bool. True, if the meeting is published.
     */
    public var published: Bool {
        get {
            var ret: Bool = false
            if let pub = self["published"] {
                ret = pub == "1"
            }
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A String, with the meeting name.
     */
    public var name: String {
        get {
            var ret: String = ""
            if let name = self["meeting_name"] {
                ret = name
            }
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  An Int, with the weekday (1 = Sunday, 7 = Saturday).
     */
    public var weekdayIndex: Int {
        get {
            var ret: Int = 0
            
            if let weekday = self["weekday_tinyint"] {
                if let val = Int(weekday) {
                    ret = val
                }
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A String, with the start time in military format ("HH:MM").
     */
    public var timeString: String {
        get {
            var ret: String = "00:00"
            
            if let time = self["start_time"] {
                var timeComponents = time.components(separatedBy: ":").map{Int($0)}
                if (23 == timeComponents[0]!) && (54 < timeComponents[1]!) {
                    timeComponents[0] = 24
                    timeComponents[1] = 0
                }
                ret = String(format: "%02d:%02d", timeComponents[0]!, timeComponents[1]!)
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A String, with the duration ("HH:MM").
     */
    public var durationString: String {
        get {
            var ret: String = "00:00"
            
            if let time = self["duration_time"] {
                let timeComponents = time.components(separatedBy: ":").map{Int($0)}
                ret = String(format: "%02d:%02d", timeComponents[0]!, timeComponents[1]!)
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  An Integer, with the duration in minutes.
     */
    public var durationInMinutes: Int {
        get {
            var ret: Int = 0
            
            if let time = self["duration_time"] {
                let timeComponents = time.components(separatedBy: ":").map{Int($0)}
                if let hours = timeComponents[0] {
                    ret = hours * 60
                }
                if let minutes = timeComponents[1] {
                    ret += minutes
                }
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  an optional DateComponents object, with the time of the meeting.
     */
    public var startTime: DateComponents! {
        get {
            var ret: DateComponents! = nil
            if let time = self["start_time"] {
                var timeComponents = time.components(separatedBy: ":").map{Int($0)}
                
                if 1 < timeComponents.count {
                    // Create our answer from the components of the result.
                    ret = DateComponents(calendar: nil, timeZone: nil, era: nil, year: nil, month: nil, day: nil, hour: timeComponents[0]!, minute: timeComponents[1]!, second: 0, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
                }
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  an optional DateComponents object, with the weekday and time of the meeting.
     */
    public var startTimeAndDay: DateComponents! {
        get {
            var ret: DateComponents! = nil
            if let time = self["start_time"] {
                var timeComponents = time.components(separatedBy: ":").map{Int($0)}
                
                if 1 < timeComponents.count {
                    var weekdayIndex = self.weekdayIndex
                    if (23 == timeComponents[0]!) && (54 < timeComponents[1]!) {
                        weekdayIndex += 1
                        if 7 < weekdayIndex {
                            weekdayIndex = 1
                        }
                        timeComponents = [0, 0]
                    }
                    
                    // Create our answer from the components of the result.
                    ret = DateComponents(calendar: nil, timeZone: nil, era: nil, year: nil, month: nil, day: nil, hour: timeComponents[0]!, minute: timeComponents[1]!, second: 0, nanosecond: nil, weekday: weekdayIndex, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
                }
            }
            
            return ret
        }
    }
    /* ################################################################## */
    /**
     - returns:  returns an integer that allows sorting quickly. Weekday is 1,000s, hours are 100s, and minutes are 1s.
     */
    public var timeDayAsInteger: Int {
        get {
            var ret: Int = 0
            if let time = self["start_time"] {
                var timeComponents = time.components(separatedBy: ":").map{Int($0)}
                
                if 1 < timeComponents.count {
                    var weekdayIndex = self.weekdayIndex
                    if (23 == timeComponents[0]!) && (54 < timeComponents[1]!) {
                        weekdayIndex += 1
                        if 7 < weekdayIndex {
                            weekdayIndex = 1
                        }
                        timeComponents = [0, 0]
                    }
                    
                    ret = (weekdayIndex * 10000) + (timeComponents[0]! * 100) + timeComponents[1]!
                }
            }
            
            return ret
        }
    }
    
    
    /* ################################################################## */
    /**
     - returns:  an optional Date object, with the next occurrence of the meeting (from now).
     */
    public var nextStartDate: Date! {
        get {
            var ret: Date! = nil
            let now = Date()
            
            let myCalendar = Calendar.current
            if let meetingEvent = self.startTimeAndDay {
                if let nextMeeting = myCalendar.nextDate(after: now, matching: meetingEvent, matchingPolicy: .nextTimePreservingSmallerComponents) {
                    ret = nextMeeting
                }
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  The location (optional).
     */
    public var locationCoords: CLLocationCoordinate2D! {
        get {
            if let long = CLLocationDegrees(self["longitude"]) {
                if let lat = CLLocationDegrees(self["latitude"]) {
                    return CLLocationCoordinate2D(latitude: lat, longitude: long)
                }
            }
            return nil
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A String, with the location building name.
     */
    public var locationName: String {
        get {
            var ret: String = ""
            if let name = self["location_text"] {
                ret = name
            }
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A String, with the location street address.
     */
    public var locationStreetAddress: String {
        get {
            var ret: String = ""
            if let name = self["location_street"] {
                ret = name
            }
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A String, with the location borough.
     */
    public var locationBorough: String {
        get {
            var ret: String = ""
            if let name = self["location_city_subsection"] {
                ret = name
            }
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A String, with the location neigborhood.
     */
    public var locationNeighborhood: String {
        get {
            var ret: String = ""
            if let name = self["location_neighborhood"] {
                ret = name
            }
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A String, with the location town.
     */
    public var locationTown: String {
        get {
            var ret: String = ""
            if let name = self["location_municipality"] {
                ret = name
            }
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A String, with the location county.
     */
    public var locationCounty: String {
        get {
            var ret: String = ""
            if let name = self["location_sub_province"] {
                ret = name
            }
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A String, with the location state/province.
     */
    public var locationState: String {
        get {
            var ret: String = ""
            if let name = self["location_province"] {
                ret = name
            }
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A String, with the location zip code/postal code.
     */
    public var locationZip: String {
        get {
            var ret: String = ""
            if let name = self["location_postal_code_1"] {
                ret = name
            }
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A String, with the location nation.
     */
    public var locationNation: String {
        get {
            var ret: String = ""
            if let name = self["location_nation"] {
                ret = name
            }
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A String, with additional location info.
     */
    public var locationInfo: String {
        get {
            var ret: String = ""
            if let name = self["location_info"] {
                ret = name
            }
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A String, with the comments.
     */
    public var comments: String {
        get {
            var ret: String = ""
            if let name = self["comments"] {
                ret = name
            }
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     Read-only property that returns the distance (in Miles) from the search center.
     
     - returns: the distance from the search center (may not be applicable, in which case it will be 0).
     */
    public var distanceInMiles: Double {
        get {
            var ret: Double = 0
            
            if let val = Double(self["distance_in_miles"]) {
                ret = val
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     Read-only property that returns the distance (in Kilometers) from the search center.
     
     - returns: the distance from the search center (may not be applicable, in which case it will be 0).
     */
    public var distanceInKm: Double {
        get {
            var ret: Double = 0
            
            if let val = Double(self["distance_in_km"]) {
                ret = val
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     This parses the meeting data, and creates a fairly basic, straightforward address.
     
     The address type is specified by the "BMLTiOSLibAddressParser" info.plist property.
     
     This is a read-only property.
     
     - returns:  A String, with a basic address.
     */
    public var basicAddress: String {
        get {
            // See if we have specified an address format in the info.plist file.
            if let addressParserType = Bundle.main.object(forInfoDictionaryKey: "BMLTiOSLibAddressParser") as? String {
                switch addressParserType {
                default:    // Currently, this is the only one.
                    return self._USAddressParser
                }
            }
            
            return self._USAddressParser    // Default is US format.
        }
    }
    
    /* ################################################################## */
    /**
     This is always false for this class.
     */
    public var isDirty: Bool {get { return false }}
    
    /* ################################################################## */
    /**
     This is a read-only property that overrides the NSObject description.
     It returns a string that aggregates the meeting info into a simple
     US-style meeting description.
     
     For many uses, this may give enough information to display the meeting.
     
     - returns:  A String, with the essential Meeting Info.
     */
    override public var description: String {
        get {
            let dateformatter = DateFormatter()
            
            if self._using12hClockFormat {
                dateformatter.dateFormat = "EEEE, h:mm a"
            } else {
                dateformatter.dateFormat = "EEEE, H:mm"
            }
            
            if let nextStartDate = self.nextStartDate {
                let nextDate = dateformatter.string(from: nextStartDate)
                let formats = self.formatsAsCSVList.isEmpty ? "" : " (" + self.formatsAsCSVList + ")"
                return "\(nextDate)\n\(self.name)\(formats)\n\(self.basicAddress)"
            } else {
                return "\(self.name) (\(self.formatsAsCSVList))\n\(self.basicAddress)"
            }
        }
    }
    
    /* ################################################################## */
    // MARK: Public Methods
    /* ################################################################## */
    /**
     Default initializer. Initiatlize with raw meeting data (a simple Dictionary).
     
     - parameter inRawMeeting: This is a Dictionary that describes the meeting. If empty, then a default meeting will be created.
     - parameter inHandler: This is the BMLTiOSLib object that "owns" this meeting
     */
    public init(_ inRawMeeting: [String:String], inHandler: BMLTiOSLib) {
        var myMeeting = inRawMeeting
        // If we have an empty meeting, we fill it with a default (empty) dataset.
        if 0 == myMeeting.count {
            for key in inHandler.availableMeetingValueKeys {
                var val: String = ""
                // These get a big fat "0".
                if ("id_bigint" == key) || ("published" == key) {
                    val = "0"
                }
                
                // Give it the first Service body we can edit, or 0.
                if "service_body_bigint" == key {
                    var sb_id: Int = 0
                    
                    // If we are in an editable state, and have available Service bodies, we simply assign the first one we can edit.
                    let sbs = inHandler.serviceBodiesICanEdit
                    
                    if 0 < sbs.count {
                        sb_id = sbs[0].id
                    }
                    
                    val = String(sb_id)
                }
                
                // This is a placeholder for localization.
                if "meeting_name" == key {
                    val = type(of: self).BMLTiOSLib_DefaultMeetingNameString
                }
                
                // We use the Root Server default location in the absence of any other location.
                if "longitude" == key {
                    val = String(inHandler.defaultLocation.longitude)
                }
                
                if "latitude" == key {
                    val = String(inHandler.defaultLocation.latitude)
                }
                
                // Use placeholder values.
                if "start_time" == key {
                    val = type(of: self).BMLTiOSLib_DefaultMeetingStartTime
                }
                
                if "duration_time" == key {
                    val = type(of: self).BMLTiOSLib_DefaultMeetingDurationTime
                }
                
                if "weekday_tinyint" == key {
                    val = type(of: self).BMLTiOSLib_DefaultMeetingWeekday
                }
                
                myMeeting[key] = val
            }
        }
        
        self._rawMeeting = myMeeting
        self._handler = inHandler
        super.init()
    }

    /* ################################################################## */
    /**
     Requests all changes for this meeting from the BMLTiOSLib handler.
     */
    public func getChanges() {
        self._handler.getAllMeetingChanges(meeting: self)
    }
    
    /* ################################################################## */
    /**
     If sending messages to meeting contacts is enabled, this function will send a basic email to the contact for this email.
     
     This will result in the delegate callback bmltLibInstance(_:BMLTiOSLib,sendMessageSuccessful: Bool) being invoked.
     
     - parameter fromAddress: The email to be used as the "from" address. This is required, and should be valid.
     - parameter messageBody: A String containing the body of the message to be sent.
     */
    public func sendMessageToMeetingContact(fromAddress: String, messageBody: String) {
        self._handler._sendMessageToMeetingContact(meetingID: self.id, serviceBodyID: self.serviceBodyId, fromAddress: fromAddress, messageBody: messageBody)
    }
    
    /* ################################################################## */
    // MARK: Meeting Start and End Time Test Methods
    /* ################################################################## */
    /**
     Returns true, if the meeting start time is after the given time.
     
     - parameter inTime: The test start time, as time components (hours, minutes, seconds). The day is ignored.
     
     - returns: true, if the meeting starts on or after the given test time.
     */
    public func meetingStartsOnOrAfterThisTime(_ inTime : NSDateComponents) -> Bool {
        if let myStartTime = self.startTimeAndDay {
            if var startHour = myStartTime.hour {
                if let startMinute = myStartTime.minute {
                    if let startSecond = myStartTime.second {
                        // Special case for midnight.
                        if (0 == startHour) && (0 == startMinute) && (0 == startSecond) {
                            startHour = 24
                        }
                        let myStartSeconds = (startHour * 3600) + (startMinute * 60) + startSecond
                        let myTestSeconds = (inTime.hour * 3600) + (inTime.minute * 60) + inTime.second
                        
                        return myStartSeconds >= myTestSeconds
                    }
                }
            }
        }
        
        return false
    }
    
    /* ################################################################## */
    /**
     Returns true, if the meeting start time is before the given time.
     
     - parameter inTime: The test start time, as time components (hours, minutes, seconds). The day is ignored.
     
     - returns: true, if the meeting starts on or before the given test time.
     */
    public func meetingStartsOnOrBeforeThisTime(_ inTime : NSDateComponents) -> Bool {
        if let myStartTime = self.startTimeAndDay {
            if var startHour = myStartTime.hour {
                if let startMinute = myStartTime.minute {
                    if let startSecond = myStartTime.minute {
                        // Special case for midnight.
                        if (0 == startHour) && (0 == startMinute) && (0 == startSecond) {
                            startHour = 24
                        }
                        let myStartSeconds = (startHour * 3600) + (startMinute * 60) + startSecond
                        let myTestSeconds = (inTime.hour * 3600) + (inTime.minute * 60) + inTime.second
                        
                        return myStartSeconds <= myTestSeconds
                    }
                }
            }
        }
        
        return false
    }
    
    /* ################################################################## */
    /**
     Returns true, if the meeting end time is before the given time.
     
     - parameter inTime: The test end time, as time components (hours, minutes, seconds). The day is ignored.
     
     - returns: true, if the meeting ends at or before the given test time.
     */
    public func meetingEndsAtOrBeforeThisTime(_ inTime : NSDateComponents) -> Bool {
        if let myStartTime = self.startTimeAndDay {
            if var startHour = myStartTime.hour {
                if let startMinute = myStartTime.minute {
                    if let startSecond = myStartTime.minute {
                        // Special case for midnight.
                        if (0 == startHour) && (0 == startMinute) && (0 == startSecond) {
                            startHour = 24
                        }
                        let myStartSeconds = (startHour * 3600) + (startMinute * 60) + startSecond + (self.durationInMinutes * 60)
                        let myTestSeconds = (inTime.hour * 3600) + (inTime.minute * 60) + inTime.second
                        
                        return myStartSeconds <= myTestSeconds
                    }
                }
            }
        }
        
        return false
    }
    
    /* ############################################################## */
    // MARK: Sequence Protocol Methods
    /* ############################################################## */
    /**
     Create an iterator for this list.
     
     This iterator follows the order of the array, starting from element 0, and working up to the end.
     
     - returns:  an iterator for the list.
     */
    public func makeIterator() -> AnyIterator<BMLTiOSLibMeetingNodeSimpleDictionaryElement> {
        var nextIndex = 0
        let keys = self.keys
        // Return a "bottom-up" iterator for the list.
        return AnyIterator() {
            if nextIndex == self.keys.count {
                return nil
            }
            
            let key = keys[nextIndex]
            nextIndex += 1
            if let value = self.rawMeeting[key] {
                return BMLTiOSLibMeetingNodeSimpleDictionaryElement(key: key, value: value, handler: self)
            } else {
                return nil
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Editable Meeting Class -
/* ###################################################################################################################################### */
/**
 This is a special "micro class" for editing the meetings for a Server.
 */
public class BMLTiOSLibEditableMeetingNode: BMLTiOSLibMeetingNode {
    /* ################################################################## */
    // MARK: Private Properties
    /* ################################################################## */
    var _originalObject: [String:String] = [:]
    
    /* ################################################################## */
    // MARK: Public Calculated Properties
    /* ################################################################## */
    
    /* ################################################################## */
    /**
     This returns a flat (non-hierarchical) array of Service Body nodes that this meeting can be assinged.
     
     This returns every Service body on the server that the current user can observe or edit.
     Each will be in a node, with links to its parents and children (if any).
     
     - returns:  an Array of BMLTiOSLibHierarchicalServiceBodyNode objects, each of which represents one Service body.
     */
    public var serviceBodiesICanBelongTo: [BMLTiOSLibHierarchicalServiceBodyNode]  {
        get {
            return self._handler.serviceBodiesICanEdit
        }
    }
    
    /* ################################################################## */
    /** This class is editable. */
    override public var isEditable: Bool {
        get {
            return true
        }
    }
    
    /* ################################################################## */
    /**
     This allows us to set a new collection of meeting formats via an array of format objects.
     
     - returns:  an array of format objects.
     */
    override public var formats: [BMLTiOSLibFormatNode] {
        get {
            return super.formats
        }
        
        set {
            var formatList: [String] = []
            for format in newValue {
                if let _ = self._handler.getFormatByID(format.id) {
                    formatList.append(format.key)
                }
            }
            self.formatsAsCSVList = formatList.joined(separator: ",")
        }
    }
    
    /* ################################################################## */
    /**
     This allows us to set a new collection of meeting formats via a CSV string of their codes.
     
     - returns:  a CSV string of format codes, sorted alphabetically.
     */
    override public var formatsAsCSVList: String {
        get {
            return super.formatsAsCSVList
        }
        
        set {
            let list = newValue.components(separatedBy: ",").sorted()
            self.rawMeeting["formats"] = list.joined(separator: ",")
        }
    }
    
    /* ################################################################## */
    /**
     This sets the meeting's "published" status.
     
     - returns:  A Bool. True, if the meeting is published.
     */
    override public var published: Bool {
        get {
            return super.published
        }
        
        set {
            self.rawMeeting["published"] = newValue ? "1" : "0"
        }
    }
    
    /* ################################################################## */
    /**
     This sets the meeting's NAWS (World ID).
     
     - returns:  A String, with the meeting NAWS ID.
     */
    override public var worldID: String {
        get {
            return super.worldID
        }
        
        set {
            self.rawMeeting["worldid_mixed"] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  An Int, with the meeting's Service body BMLT ID.
     */
    override public var serviceBodyId: Int {
        get {
            return super.serviceBodyId
        }
        
        set {
            self.rawMeeting["service_body_bigint"] = String(newValue)
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  The meeting's Service body object. nil, if no Service body (should never happen).
     */
    override public var serviceBody: BMLTiOSLibHierarchicalServiceBodyNode! {
        get {
            return super.serviceBody
        }
        
        set {
            self.serviceBodyId = newValue.id
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A String, with the meeting name.
     */
    override public var name: String {
        get {
            return super.name
        }
        
        set {
            self.rawMeeting["meeting_name"] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     This creates new long/lat values for the given coordinate.
     
     - returns:  The location (optional).
     */
    override public var locationCoords: CLLocationCoordinate2D! {
        get {
            return super.locationCoords
        }
        
        set {
            if nil != newValue {
                self.rawMeeting["longitude"] = String(newValue.longitude as Double)
                self.rawMeeting["latitude"] = String(newValue.latitude as Double)
            } else {
                self.rawMeeting["longitude"] = "0"
                self.rawMeeting["latitude"] = "0"
            }
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A String, with the location building name.
     */
    override public var locationName: String {
        get {
            return super.locationName
        }
        
        set {
            self.rawMeeting["location_text"] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A String, with the location street address.
     */
    override public var locationStreetAddress: String {
        get {
            return super.locationStreetAddress
        }
        
        set {
            self.rawMeeting["location_street"] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A String, with the location neighborhood.
     */
    override public var locationNeighborhood: String {
        get {
            return super.locationNeighborhood
        }
        
        set {
            self.rawMeeting["location_neighborhood"] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A String, with the location borough.
     */
    override public var locationBorough: String {
        get {
            return super.locationBorough
        }
        
        set {
            self.rawMeeting["location_city_subsection"] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A String, with the location town.
     */
    override public var locationTown: String {
        get {
            return super.locationTown
        }
        
        set {
            self.rawMeeting["location_municipality"] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A String, with the location county.
     */
    override public var locationCounty: String {
        get {
            return super.locationCounty
        }
        
        set {
            self.rawMeeting["location_sub_province"] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A String, with the location state/province.
     */
    override public var locationState: String {
        get {
            return super.locationState
        }
        
        set {
            self.rawMeeting["location_province"] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A String, with the location zip code/postal code.
     */
    override public var locationZip: String {
        get {
            return super.locationZip
        }
        
        set {
            self.rawMeeting["location_postal_code_1"] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A String, with the location nation.
     */
    override public var locationNation: String {
        get {
            return super.locationNation
        }
        
        set {
            self.rawMeeting["location_nation"] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A String, with additional location info.
     */
    override public var locationInfo: String {
        get {
            return super.locationInfo
        }
        
        set {
            self.rawMeeting["location_info"] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A String, with the comments.
     */
    override public var comments: String {
        get {
            return super.comments
        }
        
        set {
            self.rawMeeting["comments"] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  An Int, with the weekday (1 = Sunday, 7 = Saturday).
     */
    override public var weekdayIndex: Int {
        get {
            return super.weekdayIndex
        }
        
        set {
            if (0 < newValue) && (8 > newValue) {
                self.rawMeeting["weekday_tinyint"] = String(newValue)
            }
        }
    }
    
    /* ################################################################## */
    /**
     This parses a military time string (either "HH:MM" or "HHMM"), and creates a new
     start time from the string.
     
     - returns:  A String, with the start time in military format ("HH:MM").
     */
    override public var timeString: String {
        get {
            return super.timeString
        }
        
        set {
            var timeComponents = newValue.components(separatedBy: ":").map{Int($0)}
            // See if we need to parse as a simple number.
            if 1 == timeComponents.count {
                if let simpleNumber = Int(timeString) {
                    let hours = simpleNumber / 100
                    let minutes = simpleNumber - hours
                    timeComponents[0] = hours
                    timeComponents[1] = minutes
                }
            }
            
            // This is a special case for midnight. We always represent it as 11:59 PM.
            if ((0 == timeComponents[0]!) || (24 == timeComponents[0]!)) && (0 == timeComponents[1]!) {
                timeComponents[0] = 23
                timeComponents[1] = 59
            }
            
            // Belt and suspenders. This should always pass.
            if 1 < timeComponents.count {
                let val = String(format: "%02d:%02d:00", timeComponents[0]!, timeComponents[1]!)
                self.rawMeeting["start_time"] = val
            }
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  A String, with the duration ("HH:MM").
     */
    override public var durationString: String {
        get {
            return super.durationString
        }
        
        set {
            let timeComponents = newValue.components(separatedBy: ":").map{Int($0)}
            var hours = (nil != timeComponents[0]) ? timeComponents[0]! : 0
            var minutes = (nil != timeComponents[1]) ? timeComponents[1]! : 0
            
            // Just to make sure that we haven't asked for an unreasonable amount of minutes.
            let extraTime = Int(minutes / 60)
            
            if 0 < extraTime {
                hours += extraTime
                minutes -= (extraTime * 60)
            }
            
            self.durationInMinutes = (hours * 60) + minutes
        }
    }
    
    /* ################################################################## */
    /**
     Sets the new duration from an integer, representing the number of minutes.
     
     - returns:  An Integer, with the duration in minutes.
     */
    override public var durationInMinutes: Int {
        get {
            return super.durationInMinutes
        }
        
        set {
            if 1440 > newValue {    // Can't be more than 23:59
                let hours = Int(newValue / 60)
                let minutes = newValue - hours
                self.rawMeeting["duration_time"] = String(format: "%02d:%02d:00", hours, minutes)
            }
        }
    }
    
    /* ################################################################## */
    /**
     This simply sets the time exactly from components.
     
     - returns:  an optional DateComponents object, with the time of the meeting.
     */
    override public var startTime: DateComponents! {
        get {
            return super.startTime
        }
        
        set {
            if let hour = newValue.hour {
                if let minute = newValue.minute {
                    self.timeString = String(format: "%02d:%02d", hour, minute)
                }
            }
        }
    }

    /* ################################################################## */
    /**
     This extracts the weekday and the time of day from the components, and uses these as new values for the meeting.
     
     - returns:  an optional DateComponents object, with the weekday and time of the meeting.
     */
    override public var startTimeAndDay: DateComponents! {
        get {
            return super.startTimeAndDay
        }
        
        set {
            if var weekday = newValue.weekday {
                if var hour = newValue.hour {
                    if var minute = newValue.minute {
                        // This is a special case for midnight. We always represent it as 11:59 PM of the previous day.
                        if ((0 == hour) || (24 == hour)) && (0 == minute) {
                            if (0 == hour) && (0 == minute) {   // In the case of the morning, we really mean last night.
                                weekday -= 1
                                if 0 == weekday {
                                    weekday = 7
                                }
                            }
                            hour = 23
                            minute = 59
                        }
                        
                        self.timeString = String(format: "%02d:%02d", hour, minute)
                        self.weekdayIndex = weekday
                    }
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     This sets a new time and weekday by parsing the Date object provided.
     It extracts the weekday and the time of day, and uses these as new values for the meeting.
     
     - returns:  an optional Date object, with the next occurrence of the meeting (from now).
     */
    override public var nextStartDate: Date! {
        get {
            return super.nextStartDate
        }
        
        set {
            let myCalendar:Calendar = Calendar.current
            let unitFlags: NSCalendar.Unit = [NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.weekday]
            let myComponents = (myCalendar as NSCalendar).components(unitFlags, from: newValue)
            self.startTimeAndDay = myComponents
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  true, if the meeting data has changed from its original instance.
     */
    override public var isDirty: Bool {
        get {
            var ret: Bool = false
            
            // No-brainer
            if self._originalObject.count != self.rawMeeting.count {
                ret = true
            } else {    // Hunt through our keys, looking for differences from the original.
                for key in self._originalObject.keys {
                    if "id_bigint" != key { // Can't change the ID
                        if let origValue = self._originalObject[key] {
                            if let newValue = self.rawMeeting[key] {
                                if "formats" == key {
                                    // We do this, because we may change the order, without actually changing the value.
                                    let origKeys = origValue.components(separatedBy: ",").sorted()
                                    let newKeys = newValue.components(separatedBy: ",").sorted()
                                    ret = newKeys != origKeys
                                } else {
                                    ret = newValue != origValue
                                }
                            } else {
                                ret = false
                            }
                        }
                        
                        if ret {    // We stop if we are dirty.
                            break
                        }
                    }
                }
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    // MARK: Public Initializer
    /* ################################################################## */
    /**
     Default initializer. Initiatlize with raw meeting data (a simple Dictionary).
     
     - parameter inRawMeeting: This is a Dictionary that describes the meeting.
     - parameter inHandler: This is the BMLTiOSLib object that "owns" this meeting
     */
    override public init(_ inRawMeeting: [String:String], inHandler: BMLTiOSLib) {
        super.init(inRawMeeting, inHandler: inHandler)
        self._originalObject = self.rawMeeting
    }
    
    /* ################################################################## */
    // MARK: Internal Methods
    /* ################################################################## */
    /**
     Sets the original object to the current one.
     */
    internal func setChanges() {
        if self.isDirty {
            self._originalObject = self.rawMeeting  // We are no longer "dirty".
        }
    }
    
    /* ################################################################## */
    // MARK: Public Methods
    /* ################################################################## */
    /**
     This allows us to add a single format, via its object reference.
     
     If the format was already there, no change is made, and there is no error.
     
     - parameter inFormatObject: The format object to be added.
     */
    public func addFormat(_ inFormatObject :BMLTiOSLibFormatNode) {
        var found: Bool = false
        for formatObject in self.formats {
            if formatObject == inFormatObject {
                found = true
                break
            }
        }
        
        if !found {
            self.formats.append(inFormatObject)
        }
    }
    
    /* ################################################################## */
    /**
     This allows us to remove a single format, via its object reference.
     
     If the format was not there, no change is made, and there is no error.
     
     - parameter inFormatObject: The format object to be removed.
     */
    public func removeFormat(_ inFormatObject :BMLTiOSLibFormatNode) {
        var index: Int = 0
        for formatObject in self.formats {
            if formatObject == inFormatObject {
                self.formats.remove(at: index)
                break
            }
            index += 1
        }
    }
    
    /* ################################################################## */
    /**
     Removes all changes made to the meeting.
     */
    public func restoreToOriginal() {
        self.rawMeeting = self._originalObject
    }
    
    /* ################################################################## */
    /**
     Reverts a meeting to the "before" state of a given change, but does not save it to the server.
     
     The "before" meeting must also be editable, the user needs to be currently logged in
     with edit privileges on the meeting.
     
     This makes the meeting "dirty."
     
     - returns:  True, if the reversion was allowed.
     */
    public func revertMeetingToBeforeThisChange(_ inChangeObject: BMLTiOSLibChangeNode) -> Bool {
        if let beforeObject = inChangeObject.beforeObject {
            if beforeObject.isEditable {
                self.rawMeeting = beforeObject.rawMeeting
                return true
            }
        }
        
        return false
    }
    
    /* ################################################################## */
    /**
     Reverts a meeting to the "before" state of a given change, and saves it to the server.
     
     The "before" meeting must also be editable, the user needs to be currently logged in
     with edit privileges on the meeting.
     
     - returns:  True, if the reversion was allowed.
     */
    public func saveMeetingToBeforeThisChange(_ inChangeObject: BMLTiOSLibChangeNode) -> Bool {
        if self.revertMeetingToBeforeThisChange(inChangeObject) {
            self.saveChanges()
            return true
        }
        
        return false
    }
    
    /* ################################################################## */
    /**
     Test whether or not a given field has undergone a change.
     
     - parameter inKey: The meeting field key to test.
     
     - returns:  True, if the given field is different from the original one.
     */
    public func valueChanged(_ inKey: String) -> Bool {
        var ret: Bool = false
        
        if let oldVal = self._originalObject[inKey] {
            if let newVal = self.rawMeeting[inKey] {
                ret = oldVal != newVal
            } else {
                ret = true
            }
        } else {
            if let _ = self.rawMeeting[inKey] {
                ret = true
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     Deletes this meeting.
     */
    public func delete() {
        self._handler.deleteMeeting(self.id)
    }
    
    /* ################################################################## */
    /**
     Saves changes made to the meeting.
     */
    public func saveChanges() {
        if self.isDirty {
            self._handler.saveMeetingChanges(self)
            self.setChanges()  // We are no longer "dirty".
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Service Body Container Class -
/* ###################################################################################################################################### */
/**
 This is a special "micro class" for wrapping the Service bodies.
 */
public class BMLTiOSLibServiceBodyContainer {
    /* ################################################################## */
    // MARK: Public Properties
    /* ################################################################## */
    /** This is the actual Service body node. */
    public var item: BMLTiOSLibHierarchicalServiceBodyNode
    /** This is the selection state for this node. */
    public var selection: BMLTiOSLibSearchCriteria.SelectionState
    /** This is any extra data that the user may want to attach to this instance. */
    public var extraData: AnyObject?
    
    /* ################################################################## */
    // MARK: Public Initializer
    /* ################################################################## */
    /**
     Simple direct initializer.
     */
    public init(item: BMLTiOSLibHierarchicalServiceBodyNode, selection: BMLTiOSLibSearchCriteria.SelectionState, extraData: AnyObject?) {
        self.item = item
        self.selection = selection
        self.extraData = extraData
    }
}

/* ###################################################################################################################################### */
// MARK: - Format Container Class -
/* ###################################################################################################################################### */
/**
 This is a special "micro class" for wrapping the formats.
 */
public class BMLTiOSLibFormatContainer {
    /* ################################################################## */
    // MARK: Public Properties
    /* ################################################################## */
    /** This is the actual Format node. */
    public var item: BMLTiOSLibFormatNode
    /** This is the selection state for this node. */
    public var selection: BMLTiOSLibSearchCriteria.SelectionState
    /** This is any extra data that the user may want to attach to this instance. */
    public var extraData: AnyObject?
    
    /* ################################################################## */
    // MARK: Public Initializer
    /* ################################################################## */
    /**
     Simple direct initializer.
     */
    public init(item: BMLTiOSLibFormatNode, selection: BMLTiOSLibSearchCriteria.SelectionState, extraData: AnyObject?) {
        self.item = item
        self.selection = selection
        self.extraData = extraData
    }
}

/* ###################################################################################################################################### */
// MARK: - Format Class -
/* ###################################################################################################################################### */
/**
 This is a special "micro class" for accessing the formats for a Server.
 */
public class BMLTiOSLibFormatNode: NSObject {
    /* ################################################################## */
    // MARK: Private Properties
    /* ################################################################## */
    /** This will contain the "raw" format data. It isn't meant to be exposed. */
    private let _rawFormat: [String:String]

    /* ################################################################## */
    // MARK: Public Properties
    /* ################################################################## */
    /** This is whatever data the user wants to attach to the node. */
    public var extraData: AnyObject?
    
    /* ################################################################## */
    // MARK: Public Calculated Properties
    /* ################################################################## */
    /**
     - returns:  all of the available keys in our dictionary.
     */
    public var keys: [String] {
        get {
            return Array(self._rawFormat.keys)
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  An optional Int, with the format Shared ID.
     */
    public var id: Int! {
        get {
            return Int(self._rawFormat["id"]!)
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  An optional String, with the format key.
     */
    public var key: String! {
        get {
            return self._rawFormat["key_string"]!
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  An optional String, with the format name.
     */
    public var name: String! {
        get {
            return self._rawFormat["name_string"]!
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  An optional String, with the format description.
     */
    override public var description: String {
        get {
            return self._rawFormat["description_string"]!
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  An optional String, with the format language indicator.
     */
    public var lang: String! {
        get {
            return self._rawFormat["lang"]!
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  An optional String, with the format World ID (which may not be available, returning an empty string).
     */
    public var worldID: String! {
        get {
            return self._rawFormat["world_id"]!
        }
    }
    
    /* ################################################################## */
    // MARK: Public Initializer
    /* ################################################################## */
    /**
     Default initializer. Initiatlize with raw format data (a simple Dictionary).
     
     - parameter inRawFormat: This is a Dictionary that describes the format.
     */
    public init(_ inRawFormat: [String:String], inExtraData: AnyObject?) {
        self._rawFormat = inRawFormat
        self.extraData = inExtraData
    }
}

/* ###################################################################################################################################### */
// MARK: - Server Language Class -
/* ###################################################################################################################################### */
/**
 This class will present a functional interface to the server languages.
 */
public class BMLTiOSLibServerLang: NSObject {
    /* ################################################################## */
    // MARK: Private Properties
    /* ################################################################## */
    private let _serverInfoDictionary: [String:String]
    
    /* ################################################################## */
    // MARK: Public Calculated Properties
    /* ################################################################## */
    /**
     This allows the class to be treated like a standard Dictionary.
     
     - returns:  the Server Info element, as a String.
     */
    public subscript(_ inString:String) -> String! {
        get {
            if let value = self._serverInfoDictionary[inString] {
                return value
            }
            
            return nil
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  the language key.
     */
    public var langKey: String {
        get {
            if let keyString = self["key"] {
                return keyString
            }
            
            return ""
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  the language name.
     */
    public var langName: String {
        get {
            if let nameString = self["name"] {
                return nameString
            }
            
            return ""
        }
    }
    
    /* ################################################################## */
    /**
     :returns true, if this is the default Server language.
     */
    public var isDefault: Bool {
        get {
            if let defString = self["default"] {
                return "0" != defString
            }
            
            return false
        }
    }
    
    /* ################################################################## */
    // MARK: Public Initializer
    /* ################################################################## */
    /**
     Simple direct initializer.
     - parameter inLang: This is a Dictionary that contains the info returned from the server.
     */
    public init(_ inLang: [String:String]) {
        self._serverInfoDictionary = inLang
        super.init()
    }
}

/* ###################################################################################################################################### */
// MARK: - Hierarchical Service Body Class -
/* ###################################################################################################################################### */
/**
 This is a special "micro class" for aggregating a hierarchical Service body map.
 
 We create the map when we connect to the Root Server, and the map is a doubly-linked list,
 with each node containing the basic dictionary for a Service body, and references to parents
 and contained ("children") nodes.
 */
public class BMLTiOSLibHierarchicalServiceBodyNode: NSObject {
    /* ################################################################## */
    // MARK: Internal Properties.
    /* ################################################################## */
    /** The BMLTiOSLib instance that "owns" this instance. */
    internal let serverComm: BMLTiOSLib

    /* ################################################################## */
    // MARK: Public Properties.
    /* ################################################################## */
    /** The parent node for this object. Nil if top-level. */
    public var parent: BMLTiOSLibHierarchicalServiceBodyNode! = nil
    /** The Service body information for this node. */
    public var serviceBody: [String:String]! = nil
    /** An array of "child" nodes. May be empty, if we are a "leaf." */
    public var children: [BMLTiOSLibHierarchicalServiceBodyNode] = []
    /** This is whatever data the user wants to attach to the node. */
    public var extraData: AnyObject?
    
    /* ################################################################## */
    // MARK: Public Calculated Properties.
    /* ################################################################## */
    /**
     - returns:  all of the available keys in our dictionary.
     */
    public var keys: [String] {
        get {
            return Array(self.serviceBody.keys)
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  the Service body ID as an Int. If there is no ID, it returns 0 (Should never happen).
     */
    public var id: Int {
        get{
            if let ret1 = self.serviceBody["id"] {
                if let id = Int(ret1) {
                    return id
                }
            }
            
            return 0
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  the Service body name as a String. If there is no name, it returns blank.
     */
    public var name: String {
        get {
            if let name = self.serviceBody["name"] {
                return name
            }
            
            return ""
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  the Service body description as a String. If there is no description, it returns the name.
     */
    override public var description: String {
        get {
            if let description = self.serviceBody["description"] {
                if description.isEmpty {
                    return self.name
                }
                return description
            }
            
            return ""
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  If we are logged in as an admin, and have administrator rights for this Service body, we get a true.
     */
    public var iCanAdminister: Bool {
        get {
            return BMLTiOSLibPermissions.Administrator.rawValue == self.permissions.rawValue
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  If we are logged in as an admin, and have edit rights for this Service body, we get a true.
     */
    public var iCanEdit: Bool {
        get {
            return BMLTiOSLibPermissions.Editor.rawValue <= self.permissions.rawValue
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  If we are logged in as an admin, and have observer rights for this Service body, we get a true.
     */
    public var iCanObserve: Bool {
        get {
            return BMLTiOSLibPermissions.Observer.rawValue <= self.permissions.rawValue
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  If we are logged in as an admin, this will indicate the level of permission we have with this Service body.
     */
    public var permissions: BMLTiOSLibPermissions {
        get {
            return self.serverComm.permissions(forServiceBody: self)
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  true, if we have a parent.
     */
    public var hasParent: Bool {
        get {
            return nil != self.parent
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  true, if we have children.
     */
    public var hasChildren: Bool {
        get {
            return !self.children.isEmpty
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  the total number of children, including children of children, etc.
     */
    public var completeChildCount: Int {
        get {
            var ret : Int = 0
            
            if !self.children.isEmpty {
                for shorty in self.children {
                    ret += (1 + shorty.completeChildCount)
                }
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     - returns:  how many levels down we are. 0 is top-level (no parent).
     */
    public var howDeepInTheRabbitHoleAmI: Int {
        get {
            var ret: Int = 0
            
            var parent = self.parent
            
            while nil != parent {
                parent = parent!.parent
                if nil == parent {
                    break
                }
                ret += 1
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    // MARK: Public Initializers.
    /* ################################################################## */
    /**
     Copy initializer.
     
     - parameter inObject: This references an object we will adopt.
     */
    public init(_ inObject: BMLTiOSLibHierarchicalServiceBodyNode) {
        self.parent = inObject.parent
        self.serviceBody = inObject.serviceBody
        self.children = inObject.children
        self.serverComm = inObject.serverComm
    }
    
    /* ################################################################## */
    /**
     Default initializer. We must have at least the server comm.
     
     - parameter inServerComm: This is a reference to the BMLTiOSLib instance that "owns" this.
     */
    public init(inServerComm: BMLTiOSLib) {
        self.parent = nil
        self.serviceBody = nil
        self.children = []
        self.serverComm = inServerComm
    }
    
    /* ################################################################## */
    /**
     Basic initializer with full data.
     
     - parameter inServerComm: This is a reference to the BMLTiOSLib instance that "owns" this.
     - parameter parent: any parent node in a hierarchy.
     - parameter serviceBody: a Dictionary<String,String>, containing the Service body information.
     - parameter chidren: This is an Array of BMLTiOSLibHierarchicalServiceBodyNode objects, which are the children for this node.
     */
    public init(inServerComm: BMLTiOSLib, parent: BMLTiOSLibHierarchicalServiceBodyNode!, serviceBody: [String:String]!, children: [BMLTiOSLibHierarchicalServiceBodyNode]) {
        self.parent = parent
        self.serviceBody = serviceBody
        self.children = children
        self.serverComm = inServerComm
    }
    
    /* ################################################################## */
    // MARK: Public Instance Methods.
    /* ################################################################## */
    /**
     This checks a given Service Body node, and sees if it is in the hierarchy.
     
     - parameter inSBNode: this is the node to check.
     
     - returns:  true, if the node is somewhere in our woodpile.
     */
    public func isInHierarchy(_ inSBNode: BMLTiOSLibHierarchicalServiceBodyNode) -> Bool {
        return self.isSBIDInHierarchy(inSBNode.id)
    }
    
    /* ################################################################## */
    /**
     This checks a given Service Body node by its ID, and sees if it is in the hierarchy.
     
     - parameter inID: the integer ID of the Service body to check.
     
     - returns:  true, if the ID represents a Service body somewhere in our woodpile.
     */
    public func isSBIDInHierarchy(_ inID: Int) -> Bool {
        var ret: Bool = false
        
        if self.id == inID {
            ret = true
        } else {
            for shorty in self.children {
                if shorty.isSBIDInHierarchy(inID) {
                    ret = true
                    break
                }
            }
        }
        
        return ret
    }
}

/* ###################################################################################################################################### */
// MARK: - Public Enumerations -
/* ######################################################################################################################################
    Most of these string descriptions and domains are designed to be replaced by localized strings, so they are just keys.
 ###################################################################################################################################### */
/**
 These are string representation of various error codes. The string can be used as a key to a localized string table.
 */
public enum BMLTiOSLibCommunicationHandlerBadTestReasons: String {
    /** No errors. */
    case None               =   ""
    /** The URI does not point to a valid Root Server. */
    case BadURI             =   "BMLTiOSLibCommunicationHandlerBadTestReasons-BadURI"
    /** The indicated Root Server is an unsupported version. */
    case WrongVersion       =   "BMLTiOSLibCommunicationHandlerBadTestReasons-WrongVersion"
    /** The Root Server has been too heavily modified to work with this class. */
    case MissingFields      =   "BMLTiOSLibCommunicationHandlerBadTestReasons-MissingFields"
    /** There are no available Service bodies in the Root Server. */
    case NoServiceBodies    =   "BMLTiOSLibCommunicationHandlerBadTestReasons-NoServiceBodies"
    /** There are no available formats in the Root Server. */
    case NoFormats          =   "BMLTiOSLibCommunicationHandlerBadTestReasons-NoFormats"
    /** A communication error occurred. */
    case CommError          =   "BMLTiOSLibCommunicationHandlerBadTestReasons-CommError"
    /** An operation was attempted for which the user is not authorized (or the user is not logged in). */
    case AuthError          =   "BMLTiOSLibCommunicationHandlerBadTestReasons-AuthError"
}

/* ###################################################################### */
/**
 These indicate the domains for BMLT errors (In an NSError object).
 */
public enum BMLTiOSLibErrorDomains: String {
    /** General communication error. */
    case CommunicationError     =   "BMLTiOSLibErrorDomains-Communication-Error"
    /** An action was attempted that the user does not have permission to perform. */
    case PermissionError        =   "BMLTiOSLibErrorDomains-Permission-Error"
    /** There was a problem sending mail to a meeting contact. */
    case MailSendingError       =   "BMLTiOSLibErrorDomains-Mail-Sending-Error"
}

/* ###################################################################### */
/**
 These indicate specific descriptions for errors within the domains (In an NSError object).
 */
public enum BMLTiOSLibErrorDescriptions: String {
    /** There was a general (unspecified) error. */
    case GeneralError           =   "BMLTiOSLibErrorDomains-Communication-Error-General-Error"
    /** The user supplied incorrect login credentials. */
    case IncorrectCredentials   =   "BMLTiOSLibErrorDomains-Permission-Error-Incorrect-Credentials"
    /** There was an unkown error encountered while sending an email to a meeting contact. */
    case SendingUnknownError    =   "BMLTiOSLibErrorDomains-Mail-Sending-Error-Unknown-Error"
    /** The From: address was invalid when sending email to a meeting contact. */
    case MessageInvalidFrom     =   "BMLTiOSLibErrorDomains-Mail-Sending-Error-Invalid-From"
    /** The message failed the SPAM check. */
    case MessageAppearsToBeSpam =   "BMLTiOSLibErrorDomains-Mail-Sending-Error-Message-Appears-To-Be-Spam"
}

/* ###################################################################### */
/**
 These indicate specific codes for errors within the domains (In an NSError object).
 */
public enum BMLTiOSLibErrorCodes: Int {
    /** There is a general error. */
    case GeneralError           =   101000
    /** No data was received. */
    case NoDataReceivedError    =   101010
    /** Data was received, but it is bad data. */
    case BadDataReceivedError   =   101020
    /** The user supplied incorrect login credentials. */
    case IncorrectCredentials   =   201000
    /** There was an unkown error encountered while sending email to a meeting contact. */
    case SendingUnknownError    =   301000
    /** The From: address was invalid when sending email to a meeting contact. */
    case MessageInvalidFrom     =   301020
    /** The message failed the SPAM check. */
    case MessageAppearsToBeSpam =   301030
}

/* ###################################################################### */
/**
 These indicate the distance units for the server.
 */
public enum BMLTiOSLibDistanceUnits: String {
    /** This is a bad value, and should never happen. */
    case Error      = ""
    /** Miles */
    case Miles      = "mi"
    /** Kilometeres */
    case Kilometers = "km"
}

/* ###################################################################### */
/**
 These indicate the level of permissions for a Service body.
 */
public enum BMLTiOSLibPermissions: Int {
    /** The user has no permissions for this Service Bbody. */
    case None           = 0
    /** The user has Observer-only (can see hidden meeting fields) for meetings in this Service body, and nested Service bodies. */
    case Observer       = 1
    /** The user can edit meetings in this Service body, and nested Service bodies (but cannot edit the Service Body or nested Service bodies). */
    case Editor         = 2
    /** The user can administer the Service body, nested Service bodies, and meetings in all Service bodies at or below the level of this Service body. */
    case Administrator  = 3
}
