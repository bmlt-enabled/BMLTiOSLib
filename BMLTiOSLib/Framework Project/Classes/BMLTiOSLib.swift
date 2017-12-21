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
 */
public class BMLTiOSLib: NSObject {
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
        guard nil != self.delegate?.bmltLibInstance?(self, loginChangedTo: inLoginWasSuccessful) else { return }
    }
    
    /* ################################################################## */
    /**
     Indicates whether or not a Semantic Admin meeting change was successful.
     
     - parameter inChanges: If successful, the meeting changes. If not, nil.
     */
    internal func meetingChangeComplete(_ inChanges: BMLTiOSLibChangedMeeting!) {
        guard nil != self.delegate?.bmltLibInstance?(self, adminMeetingChangeComplete: inChanges) else { return }
    }
    
    /* ################################################################## */
    /**
     Indicates whether or not a message sent to a meeting contact was successful.
     
     - parameter inWasSuccessful: A Bool, true, if the message send was successful.
     */
    internal func messageSentResponse(_ inWasSuccessful: Bool) {
        guard nil != self.delegate?.bmltLibInstance?(self, sendMessageSuccessful: inWasSuccessful) else { return }
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
     
     - returns: an object, either editable, or not.
     */
    internal func generateProperMeetingObject(_ inSimpleMeetingDictionary: [String: String]) -> BMLTiOSLibMeetingNode {
        var ret: BMLTiOSLibMeetingNode! = nil
        
        // If we are logged in, we extract the Service body from the meeting, then we check to see if we are an administrator or authorized editor for that Service body.
        // If so, we wrap the meeting data in an editable object. If not, it gets a standard object (read-only).
        if self.isAdminLoggedIn {
            // Get the Service body ID.
            if let sbID = inSimpleMeetingDictionary["service_body_bigint"] {
                if let sbIDInt: Int = Int(sbID) {
                    // Go through our Service bodies until we come to the one we want.
                    for sb in self.serviceBodies where (sb.id == sbIDInt) && sb.iCanEdit {
                        // Ony authorized users can edit.
                        ret = BMLTiOSLibEditableMeetingNode(inSimpleMeetingDictionary, inHandler: self)
                        break
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
                    guard nil != self.delegate?.bmltLibInstance?(self, newMeetingAdded: meetingObject) else { return }
                }
            } else {
                guard nil != self.delegate?.bmltLibInstance?(self, meetingSearchResults: inSearchResultObject) else { return }
            }
        } else {
            guard nil != self.delegate?.bmltLibInstance?(self, meetingSearchResults: []) else { return }
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
            
            guard nil != self.delegate?.bmltLibInstance?(self, formatSearchResults: formatList, isAllUsedFormats: self._communicationHandler._gettingAllUsedFormats) else {
                self._communicationHandler._gettingAllUsedFormats = false
                return
            }
        } else {
            guard nil != self.delegate?.bmltLibInstance?(self, formatSearchResults: [], isAllUsedFormats: self._communicationHandler._gettingAllUsedFormats) else {
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
                        guard nil != self.delegate?.bmltLibInstance?(self, newMeetingAdded: editableMeetingNode) else { break }
                        return  // We don't call the regular changes thingy in this case.
                    }
                }
            }
        }
        
        if deletedMeetingsOnly {
            guard nil != self.delegate?.bmltLibInstance?(self, deletedChangeListResults: inSearchResultObject) else { return }
        } else {
            guard nil != self.delegate?.bmltLibInstance?(self, changeListResults: inSearchResultObject) else { return }
        }
    }
    
    /* ################################################################## */
    /**
     This is called by the communicator to deliver a meeting that was added or restored.
     
     - parameter updateMeetingNode: This is the new meeting that was added or restored.
     */
    internal func restoreRequestResults(_ updateMeetingNode: BMLTiOSLibEditableMeetingNode!) {
        if nil != updateMeetingNode {
            guard nil != self.delegate?.bmltLibInstance?(self, newMeetingAdded: updateMeetingNode) else { return }
        }
    }
    
    /* ################################################################## */
    /**
     This is called by the communicator to deliver a meeting that was rolled back.
     
     - parameter updateMeetingNode: This is the meeting that was rolled back.
     */
    internal func rollbackRequestResults(_ updateMeetingNode: BMLTiOSLibEditableMeetingNode!) {
        if nil != updateMeetingNode {
            guard nil != self.delegate?.bmltLibInstance?(self, meetingRolledback: updateMeetingNode) else { return }
        }
    }
    
    /* ################################################################## */
    /**
     This is called by the communicator to deliver a meeting that was added or restored.
     
     - parameter inSuccess: True, if the deletion was successful.
     */
    internal func meetingDeleted(_ inSuccess: Bool) {
        guard nil != self.delegate?.bmltLibInstance?(self, deleteMeetingSuccessful: inSuccess) else { return }
    }

    /* ################################################################## */
    // MARK: Public Instance Calculated Properties
    /* ################################################################## */
    /**
     - returns: a reference to the internal SearcCriteria object.
     */
    public var searchCriteria: BMLTiOSLibSearchCriteria! {
        return self._searchCriteria
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal Distance Units.
     */
    public var distanceUnits: BMLTiOSLibDistanceUnits {
        return self._communicationHandler.distanceUnits
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal Distance Units.
     */
    public var distanceUnitsString: String {
        return self._communicationHandler.distanceUnitsString
    }
    
    /* ############################################################## */
    /**
     These are the available value keys for use when querying meeting data.
     */
    public var availableMeetingValueKeys: [String] {
        return self._communicationHandler.availableMeetingValueKeys
    }
    
    /* ############################################################## */
    /**
     This is set to true if emails sent to the server are enabled (Goes to meeting contacts).
     */
    public var emailMeetingContactsEnabled: Bool {
        return self._communicationHandler.emailMeetingContactsEnabled
    }
    
    /* ############################################################## */
    /**
     This is set to true if emails sent to the meeting contacts also send a copy to the Service body Admin for that meeting.
     */
    public var emailServiceBodyAdminsEnabled: Bool {
        return self._communicationHandler.emailServiceBodyAdminsEnabled
    }
    
    /* ############################################################## */
    /**
     This is number of changes stored per meeting.
     */
    public var changeDepth: Int {
        return self._communicationHandler.changeDepth
    }
    
    /* ############################################################## */
    /**
     This is the server Google API Key
     */
    public var googleAPIKey: String {
        return self._communicationHandler.googleAPIKey
    }
    
    /* ################################################################## */
    /**
     This returns the delegate object for this instance.
     The delegate can only be set at instantiation taime, so this is a
     read-only dynamic property.
     
     - returns: a reference to an object that follows the BMLTiOSLibDelegate protocol.
     */
    public var delegate: BMLTiOSLibDelegate! {
        return self._delegate
    }
    
    /* ################################################################## */
    /**
     This returns the Root Server URI used by the instance.
     
     - returns: a String, with the URI.
     */
    public var rootServerURI: String {
        return ((self._rootServerURI as NSString).trimmingCharacters(in: ["/"])) as String
    }
    
    /* ################################################################## */
    /**
     This is a simple Boolean test to see if the instance successfully connected.
     
     - returns: a Bool, true if the instance is successfully connected.
     */
    public var isConnected: Bool {
        return self._communicationHandler.isConnected
    }
    
    /* ################################################################## */
    /**
     This returns an error String (if any)
     
     - returns: an optional String object. This will be a code that can be used to key a localized String.
     */
    public var errorString: String! {
        return self._communicationHandler.errorDescription.rawValue
    }
    
    /* ################################################################## */
    /**
     This returns true, if the Semantic Administration interface has an administrator logged in.
     
     - returns: a Bool, true, if the administrator is logged in.
     */
    public var isAdminLoggedIn: Bool {
        return self._communicationHandler.isLoggedInAsAdmin
    }
    
    /* ################################################################## */
    /**
     This returns the Root Server version, as an easily readable String.
     
     - returns: a String, with the version, in "X.Y.Z" form, where X is the major version, Y is the minor version, and Z is the fix version
     */
    public var versionAsString: String {
        return self._communicationHandler.versionString
    }
    
    /* ################################################################## */
    /**
     This returns the Root Server version, as an integer. This allows easy version level checking.
     
     The format is XXXYYYZZZ, with XXX being the major version, YYY being the minor version, and ZZZ being the fix version.
     
     The result has no leading zeroes (It's an Int), so, for example, 2.8.1 is represented as "2008001".
     
     - returns: an Int, with the version packed into integer form.
     */
    public var versionAsInt: Int {
        return self._communicationHandler.serverVersionAsInt
    }
   
    /* ################################################################## */
    /**
     This returns whether or not the Root Server is capable of supporting Semantic Administration.
     
     - returns: a Bool, true, if the Root Server supports Semantic Administration.
     */
    public var isAdminAvailable: Bool {
        return self._communicationHandler.semanticAdminEnabled
    }
    
    /* ################################################################## */
    /**
     This returns the Root Server center coordinates.
     
     - returns: a CLLocationCoordinate2D object, with the coordinates (default Server coordinates).
     */
    public var defaultLocation: CLLocationCoordinate2D {
        return self._communicationHandler.defaultLocation
    }
    
    /* ################################################################## */
    /**
     This returns a flat (non-hierarchical) array of Service Body nodes.
     
     This returns every Service body on the server. Each will be in a node, with links to its parents and children (if any).
     
     - returns: an Array of BMLTiOSLibHierarchicalServiceBodyNode objects, each of which represents one Service body.
     */
    public var serviceBodies: [BMLTiOSLibHierarchicalServiceBodyNode] {
        return self._communicationHandler.allServiceBodies
    }
    
    /* ################################################################## */
    /**
     This returns a flat (non-hierarchical) array of Service Body nodes that can be observed.
     
     This returns every Service body on the server that the current user can observe. Each will be in a node, with links to its parents and children (if any).
     
     - returns: an Array of BMLTiOSLibHierarchicalServiceBodyNode objects, each of which represents one Service body.
     */
    public var serviceBodiesICanObserve: [BMLTiOSLibHierarchicalServiceBodyNode] {
        var ret: [BMLTiOSLibHierarchicalServiceBodyNode] = []
        
        if self.isAdminLoggedIn {   // Have to at least be logged in.
            for sb in self.serviceBodies where sb.iCanObserve {
                ret.append(sb)
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This returns a flat (non-hierarchical) array of Service Body nodes that can be edited or observed.
     
     This returns every Service body on the server that the current user can observe or edit. Each will be in a node, with links to its parents and children (if any).
     
     - returns: an Array of BMLTiOSLibHierarchicalServiceBodyNode objects, each of which represents one Service body.
     */
    public var serviceBodiesICanEdit: [BMLTiOSLibHierarchicalServiceBodyNode] {
        var ret: [BMLTiOSLibHierarchicalServiceBodyNode] = []
        
        if self.isAdminLoggedIn {   // Have to at least be logged in.
            for sb in self.serviceBodies where sb.iCanEdit {
                ret.append(sb)
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This returns a flat (non-hierarchical) array of Service Body nodes that can be observed.
     
     This returns every Service body on the server that the current user can observe, edit or administer. Each will be in a node, with links to its parents and children (if any).
     
     - returns: an Array of BMLTiOSLibHierarchicalServiceBodyNode objects, each of which represents one Service body.
     */
    public var serviceBodiesICanAdminister: [BMLTiOSLibHierarchicalServiceBodyNode] {
        var ret: [BMLTiOSLibHierarchicalServiceBodyNode] = []
        
        if self.isAdminLoggedIn {   // Have to at least be logged in.
            for sb in self.serviceBodies where sb.iCanAdminister {
                ret.append(sb)
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This returns a hierarchical linked list of Service Body nodes.
     
     This returns every Service body on the server, in a doubly linked list.
     
     - returns: a BMLTiOSLibHierarchicalServiceBodyNode object that is the root of the hierarchy. Look in its "children" property.
     */
    public var hierarchicalServiceBodies: BMLTiOSLibHierarchicalServiceBodyNode {
        return self._communicationHandler.hierarchicalServiceBodies
    }
    
    /* ################################################################## */
    /** This contains all of the possible meeting formats.
     */
    public var allPossibleFormats: [BMLTiOSLibFormatNode] {
        return self._communicationHandler.allAvailableFormats
    }
    
    /* ################################################################## */
    /** This contains the response from our get server languages call (nil, by default). */
    public var availableServerLanguages: [BMLTiOSLibServerLang] {
        return self._communicationHandler._availableServerLanguages
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
        self._searchCriteria?.clearStorage()
        self._communicationHandler.disconnectSession()
    }
    
    /* ################################################################## */
    /**
     Fetches a Service body node by its ID.
     
     - parameter inID: The ID for the requested Service body.
     */
    public func getServiceBodyByID(_ inID: Int) -> BMLTiOSLibHierarchicalServiceBodyNode! {
        var ret: BMLTiOSLibHierarchicalServiceBodyNode! = nil
        
        for sbNode in self.serviceBodies where sbNode.id == inID {
            ret = sbNode
            break
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     Fetches a format node by its shared ID.
     
     - parameter inID: The ID for the requested format.
     
     - returns: an optional format node object.
     */
    public func getFormatByID(_ inID: Int) -> BMLTiOSLibFormatNode! {
        var ret: BMLTiOSLibFormatNode! = nil
        
        for formatNode in self.allPossibleFormats where formatNode.id == inID {
            ret = formatNode
            break
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     Fetches a format node by its string key.
     
     - parameter inKey: The key for the requested format.
     
     - returns: an optional format node object.
     */
    public func getFormatByKey(_ inKey: String) -> BMLTiOSLibFormatNode! {
        var ret: BMLTiOSLibFormatNode! = nil
        
        for formatNode in self.allPossibleFormats where formatNode.key == inKey {
            ret = formatNode
            break
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
        self.searchCriteria.searchString = inMeetingIDArray.map { String($0) }.joined(separator: ",")  // Generates a CSV list of integers.
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
     
     - returns: a Bool, which is true, if the connection is to a valid server with semantic admin on.
     */
    public func adminLogin(loginID inLoginID: String, password inPassword: String) -> Bool {
        return self._communicationHandler.adminLogin(loginID: inLoginID, password: inPassword)
    }
    
    /* ################################################################## */
    /**
     Called to log out of a server that has semantic admin turned on.
     
     - returns: a Bool, which is true, if the connection is to a valid server with semantic admin on.
     */
    public func adminLogout() -> Bool {
        return self._communicationHandler.adminLogout()
    }
    
    /* ################################################################## */
    /**
     - returns: If we are logged in as an admin, this will indicate the level of permission we have with a given Service body.
     */
    public func permissions(forServiceBody inServiceBody: BMLTiOSLibHierarchicalServiceBodyNode) -> BMLTiOSLibPermissions {
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
     
     - returns: true, if the operation was dispatched successfully.
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
     
     - returns: true, if the operation was dispatched successfully.
     */
    public func restoreDeletedMeeting(_ inMeetingID: Int) -> Bool {
        return self._communicationHandler.restoreDeletedMeeting(inMeetingID)
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
