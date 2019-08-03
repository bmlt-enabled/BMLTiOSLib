//
//  BMLTiOSLibCommunicationHandler.swift
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

import Foundation
import CoreLocation

/* ###################################################################################################################################### */
// MARK: - Internal Class -
/* ###################################################################################################################################### */
/**
 This class is the workhorse of the system.
 
 It is instantiated by the BMLTiOSLib class, and handles the actual communications with the Root Server.
 */
class BMLTiOSLibCommunicationHandler: BMLTSession, BMLTCommunicatorDataSinkProtocol {
    /** This is a special typeAlias for when we save a meeting as a new meeting. Making the meeting object editable adds a another modicum of security. */
    typealias NewMeetingRefCon = (meetingObject: BMLTiOSLibEditableMeetingNode, refCon: AnyObject?)
    typealias PermissionsTuple = (id: Int, name: String, permissions: BMLTiOSLibPermissions)

    /** This helps us to parse out the various Service bodies. */
    class ServiceBodyRawDataDictionary {
        let sbData: [String: String]
        
        init(_ inData: [String: String] ) {
            self.sbData = inData
        }
    }
    
    /* ######################################################## */
    // MARK: Enumerations
    /* ######################################################## */
    /**
     These are URL suffixes for calling into the semantic interface. We also use them as enumerations.
     */
    enum BMLTiOSLibCommunicationHandlerSuffixes: String {
        case ServerTest                 =   "/client_interface/json/?switcher=GetServerInfo"
        case GetFormats                 =   "/client_interface/json/?switcher=GetFormats"
        case GetServiceBodies           =   "/client_interface/json/?switcher=GetServiceBodies"
        case MeetingSearch              =   "/client_interface/json/?switcher=GetSearchResults"
        case GetLangs                   =   "/client_interface/json/GetLangs.php"
        case GetChanges                 =   "/client_interface/json/?switcher=GetChanges"
        case GetDeletedMeetings         =   "/client_interface/json/?switcher=GetChanges&ignoredFlagDeleted"    // The extra parameter is ignored by the server, but is used to key the handler.
        case AdminLogin                 =   "/local_server/server_admin/json.php?admin_action=login"
        case AdminLogout                =   "/local_server/server_admin/json.php?admin_action=logout"
        case AdminPermissions           =   "/local_server/server_admin/json.php?admin_action=get_permissions"
        case AdminSaveMeetingChanges    =   "/local_server/server_admin/json.php?admin_action=modify_meeting"
        case AdminCreateMeeting         =   "/local_server/server_admin/json.php?admin_action=add_meeting"
        case AdminGetChanges            =   "/local_server/server_admin/json.php?admin_action=get_changes"
        case AdminRestoreDeletedMtg     =   "/local_server/server_admin/json.php?admin_action=restore_deleted_meeting"
        case AdminDeleteMtg             =   "/local_server/server_admin/json.php?admin_action=delete_meeting"
        case AdminRollbackMtg           =   "/local_server/server_admin/json.php?admin_action=rollback_meeting_to_before_change"
        case GetRestoredMeetingInfo     =   "/client_interface/json/?switcher=GetSearchResults&SearchString="
        case GetRollbackMeetingInfo     =   "/client_interface/json/?switcher=GetSearchResults&ignoredFlagRollback&SearchString="    // The extra parameter is ignored by the server, but is used to key the handler.
        case SendMessageToContact       =   "/client_interface/contact.php?"
    }
    
    /* ######################################################## */
    // MARK: Constant Instance Properties
    /* ######################################################## */
    /** This is the minimum server version we'll support. Format is XYYYZZZ, with X = Main version (No leading zeroes), YYY = Feature Version (with leading zeroes), and ZZZ = Fix Version (with leading zeroes). */
    let s_minServerVersion: Int                     =   2008012 ///< 2.8.12
    
    /* ######################################################## */
    // MARK: Variable Instance Properties
    /* ######################################################## */
    /** This is a semaphore that is set to let the class know that it needs to call a different callback for new and restored meetings. */
    var _newMeetingCall: Bool = false
    /** This contains all the permissions in a simple string Dictionary. */
    var _permissions: [PermissionsTuple]             =   []
    /** This contains all the various available Service bodies as a simple array of string dictionaries in a flat format. */
    var _availableServiceBodies: [[String: String]]   =   []
    /** This is the communication manager that we are using to connect to the server. */
    var _activeCommunicator: BMLTCommunicator!      =   nil
    /** This contains all the various available formats. */
    var _availableFormats: [[String: String]]         =   []
    /** This stores instances of our available formats. These are the "root" objects that are referenced everywhere else. */
    var _allformatsStored: [BMLTiOSLibFormatNode]   =   []
    /** This is a semaphore that is set while the "all used formats" call is going. */
    var _gettingAllUsedFormats: Bool                =   false
    /** This contains the available Server languages (not just the keys). */
    var _availableServerLanguages: [BMLTiOSLibServerLang] = []
    
    /** This is the BMLTiOSLib instance that "owns" this connection. */
    weak var delegate: BMLTiOSLib!                  =   nil
    /** This contains the localization key for why the URL is wrong. It should be nil if everything is OK. */
    var errorDescription: BMLTiOSLibCommunicationHandlerBadTestReasons! =   nil
    /** This contains all the various available Service bodies, as a flat array of "smart" nodes. */
    var allServiceBodies: [BMLTiOSLibHierarchicalServiceBodyNode] = []
    /** This contains all the various available Service bodies, but arranged in a hierarchy. */
    var hierarchicalServiceBodies: BMLTiOSLibHierarchicalServiceBodyNode! = nil
    /** These are the public formats. */
    var formats: [BMLTiOSLibFormatNode]             =   []
    /** This is set to true if the admin login happened, and we are logged into an admin session. */
    var adminLoggedIn: Bool                         =   false
    /** This is the basic server info for our server. */
    var serverInfo: BMLTiOSLibServerInfo?
    
    /* ######################################################## */
    // MARK: Calculated Properties
    /* ######################################################## */
    /** This is a calculated property that returns a boolean to tell whether or not the server is valid and connected. */
    var isConnected: Bool { return 0 < self.serverVersionAsInt }
    /** This is a calculated property that returns a boolean to tell whether or not we are logged into an admin session. */
    var isLoggedInAsAdmin: Bool { return self.adminLoggedIn && self.isConnected }
    /** This returns our server-available formats. */
    var allAvailableFormats: [BMLTiOSLibFormatNode] { return self._allformatsStored }

    /** This will hold the server version (as an integer). */
    var serverVersionAsInt: Int { return self.serverInfo!.versionInt }
    /** This contains the default location information for the server. */
    var defaultLocation: CLLocationCoordinate2D { return self.serverInfo!.centerLocation }
    /** This is set to true if the server allows semantic administration. */
    var semanticAdminEnabled: Bool { return self.serverInfo!.semanticAdmin }
    /** These are the available value keys for use when querying meeting data. */
    var availableMeetingValueKeys: [String] { return self.serverInfo!.available_keys }
    /** This is a list of the language keys for this server. */
    var availableLangKeys: [String] { return self.serverInfo!.langs }
    /** This is our default language key. */
    var defaulLangKey: String { return self.serverInfo!.nativeLang }
    /** This is set to true if emails sent to the server are enabled (Goes to meeting contacts). */
    var emailMeetingContactsEnabled: Bool { return self.serverInfo!.emailEnabled }
    /** This is set to true if emails sent to the meeting contacts also send a copy to the Service body Admin for that meeting. */
    var emailServiceBodyAdminsEnabled: Bool { return self.serverInfo!.emailIncludesServiceBodies }
    /** This is number of changes stored per meeting. */
    var changeDepth: Int { return self.serverInfo!.changesPerMeeting }
    /** This is the server Google API Key */
    var googleAPIKey: String { return self.serverInfo!.google_api_key }
    /** This is the version number as a string. */
    var versionString: String { return self.serverInfo!.version }
    /** This is what our server distance units are. This will be either "mi" (miles) or "km" (kilometers). */
    var distanceUnitsString: String { return self.serverInfo!.distanceUnits.rawValue }
    /** This is what our server distance units are. This will be either "mi" (miles) or "km" (kilometers). */
    var distanceUnits: BMLTiOSLibDistanceUnits { return self.serverInfo!.distanceUnits }

    /* ################################################################################################################################## */
    // MARK: Initializer and Deinitializer
    /* ################################################################################################################################## */
    /**
     */
    init(_ inDelegate: BMLTiOSLib) {
        super.init()
        self.delegate = inDelegate
        self.testServerURI()
    }
    
    /* ########################################################## */
    /**
     Belt and suspenders. Just make sure we remove everything.
     */
    deinit {
        self.delegate = nil   // Make sure we don't send any bad callbacks.
        self.clearStorage()
    }
    
    /* ################################################################################################################################## */
    // MARK: Utility Methods
    /* ################################################################################################################################## */
    /**
     Belt and suspenders. Just make sure we remove everything.
     */
    func clearStorage() {
        self.serverInfo = nil
        self.allServiceBodies.removeAll()
        self._availableFormats.removeAll()
        self._availableServiceBodies.removeAll()
        self._permissions.removeAll()
        self.formats.removeAll()
        self._activeCommunicator = nil
        self.deleteNodes(self.hierarchicalServiceBodies)
        self.hierarchicalServiceBodies = nil
    }
    
    /* ########################################################## */
    /**
     This funtion deletes the node hierarchy passed in. It recurseively walks the hierarchy.
     
     - parameter inNode: This is the root node of the hierarchy we are to delete.
     */
    func deleteNodes(_ inNode: BMLTiOSLibHierarchicalServiceBodyNode) {
        if 0 < inNode.children.count {
            for child in inNode.children {
                self.deleteNodes(child)
            }
            inNode.children.removeAll()
        }
        
        inNode.serviceBody = nil
        inNode.parent = nil
    }
    
    /* ################################################################## */
    /**
     - returns:  If we are logged in as an admin, this will indicate the level of permission we have with a given Service body.
     */
    func permissions(forServiceBody inServiceBody: BMLTiOSLibHierarchicalServiceBodyNode) -> BMLTiOSLibPermissions {
        if self.isLoggedInAsAdmin {
            for sbp in self._permissions where sbp.id == inServiceBody.id {
                return sbp.permissions
            }
        }
        
        return .None
    }
    
    /* ################################################################## */
    /**
     This cleans everything up if we have a problem.
     */
    func cleanupOnAisleSeven() {
        // If we got here, we gots problems.
        self._availableServiceBodies.removeAll()
        self._availableFormats.removeAll()
        self.allServiceBodies.removeAll()
        self._permissions.removeAll()
        self._activeCommunicator = nil
        self.formats.removeAll()
        self.hierarchicalServiceBodies = nil
        self.adminLoggedIn = false
        self.serverInfo = nil
        
        self.delegate.serverIsValid(false)
    }
    
    /* ################################################################## */
    /**
     This recursive method is called after the formats query finishes, so it will not be established unless the entire connection has been validated.
     
     - parameter inParentObject: This is for recursion. If supplied (not-nil), then it is the parent node to be populated.
     
     - returns:  a new node with a Service body. This node may have other nodes in it.
     */
    func populateHierarchicalServiceBodies(inParentObject: BMLTiOSLibHierarchicalServiceBodyNode?) -> BMLTiOSLibHierarchicalServiceBodyNode {
        var parentID: Int = 0
        var parentObject: BMLTiOSLibHierarchicalServiceBodyNode! = inParentObject
        
        // If no parent, we create an empty parent.
        if nil == parentObject {
            parentObject = BMLTiOSLibHierarchicalServiceBodyNode(inServerComm: self.delegate)
        }
        
        // If we have a parent, we indicate that here.
        if let parentObject_sb = parentObject.serviceBody {
            if let pid_string = parentObject_sb["id"] {
                if let pID = Int(pid_string) {
                    parentID = Int(pID)
                    self.allServiceBodies.append(parentObject)
                }
            }
        }
        
        // Go through the flat Service body list.
        for var sb in self._availableServiceBodies {
            if let pid_string = sb["parent_id"] {
                if let pID = Int(pid_string) {
                    // If we find a Service body that belongs inside this parent, we create a node for it, then populate that node.
                    if pID == parentID {
                        // Create a node for the child.
                        let shorty = BMLTiOSLibHierarchicalServiceBodyNode(inServerComm: self.delegate, parent: parentObject, serviceBody: sb, children: [])
                        // Populate that node with any children.
                        let shortyMcFee = self.populateHierarchicalServiceBodies(inParentObject: shorty)
                        parentObject.children.append(shortyMcFee)
                    }
                }
            }
        }
        
        return parentObject
    }
    
    /* ################################################################## */
    // MARK: Error Eater
    /* ################################################################## */
    /**
     This handles communication errors.
     
     - parameter inOffendingCall: This is the call that was being responded to.
     - parameter inBadData: This is the data that was not what it should have been.
     */
    func handleCommunicationError(_ inOffendingCall: BMLTiOSLibCommunicationHandlerSuffixes, inBadData: AnyObject?) {
        let error = NSError(domain: BMLTiOSLibErrorDomains.CommunicationError.rawValue, code: BMLTiOSLibErrorCodes.BadDataReceivedError.rawValue, userInfo: nil)
        self.delegate.errorEncountered(error)
    }
    
    /* ################################################################################################################################## */
    // MARK: Communication Trigger Methods
    /* ################################################################################################################################## */

    /* ################################################################## */
    /**
     Called when we want to validate the server credentials.
     
     The server must be SSL, with a valid published CA value.
     */
    func testServerURI() {
        if nil == self._activeCommunicator {
            self.errorDescription = .BadURI
            let refCon = BMLTiOSLibCommunicationHandlerSuffixes.ServerTest.rawValue
            let cleanedURI = self.delegate.rootServerURI.cleanURI(sslRequired: true) + refCon
            self.suppressErrors = true
            self._activeCommunicator = BMLTCommunicator(cleanedURI, dataSource: self, delegate: self, refCon: refCon as AnyObject?)
        }
    }
    
    /* ################################################################## */
    /**
     This is called to request the available Service bodies from the server.
     */
    func getServiceBodiesFromServer() {
        if nil == self._activeCommunicator {
            let refCon = BMLTiOSLibCommunicationHandlerSuffixes.GetServiceBodies.rawValue
            let cleanedURI = self.delegate.rootServerURI.cleanURI(sslRequired: true) + refCon
            self.suppressErrors = false
            self._activeCommunicator = BMLTCommunicator(cleanedURI, dataSource: self, delegate: self, refCon: refCon as AnyObject?)
        }
    }
    
    /* ################################################################## */
    /**
     This is called to request the available formats from the server.
     */
    func getFormatsFromServer() {
        if nil == self._activeCommunicator {
            let refCon = BMLTiOSLibCommunicationHandlerSuffixes.GetFormats.rawValue
            let cleanedURI = self.delegate.rootServerURI.cleanURI(sslRequired: true) + refCon
            self.suppressErrors = false
            self._activeCommunicator = BMLTCommunicator(cleanedURI, dataSource: self, delegate: self, refCon: refCon as AnyObject?)
        }
    }
    
    /* ################################################################## */
    /**
     This is called to request the available languages (localizations) from the server.
     */
    func getLanguagesFromServer() {
        if nil == self._activeCommunicator {
            let refCon = BMLTiOSLibCommunicationHandlerSuffixes.GetLangs.rawValue
            let cleanedURI = self.delegate.rootServerURI.cleanURI(sslRequired: true) + refCon
            self.suppressErrors = false
            self._activeCommunicator = BMLTCommunicator(cleanedURI, dataSource: self, delegate: self, refCon: refCon as AnyObject?)
        }
    }
    
    /* ################################################################## */
    /**
     This is called to request the available permissions from the server.
     
     - returns:  a Bool, which is true, if the connection is to a valid server with semantic admin on, and we are logged in.
     */
    func getPermissionsFromServer() -> Bool {
        if nil == self._activeCommunicator {
            self._permissions = []
            // We have to be logged in.
            if self.isLoggedInAsAdmin {
                let refCon = BMLTiOSLibCommunicationHandlerSuffixes.AdminPermissions.rawValue
                let cleanedURI = self.delegate.rootServerURI.cleanURI(sslRequired: true) + refCon
                self.suppressErrors = false
                self._activeCommunicator = BMLTCommunicator(cleanedURI, dataSource: self, delegate: self, refCon: refCon as AnyObject?)
                
                return true
            }
        }
        
        return false
    }
    
    /* ################################################################## */
    /**
     This is called to set a meeting change.
     
     If the meeting ID is set to zero, then a new meeting is created.
     
     - parameter inMeetingObject: an editable meeting object.
     */
    func saveMeetingChanges(_ inMeetingObject: BMLTiOSLibEditableMeetingNode) {
        if self.isLoggedInAsAdmin {
            var refCon: AnyObject? = (0 < inMeetingObject.id ? BMLTiOSLibCommunicationHandlerSuffixes.AdminSaveMeetingChanges.rawValue: BMLTiOSLibCommunicationHandlerSuffixes.AdminCreateMeeting.rawValue) as AnyObject?
            var cleanedURI: String = self.delegate.rootServerURI.cleanURI(sslRequired: true) + (refCon as? String)!
            self.suppressErrors = false
            cleanedURI += "&meeting_id=" + String(inMeetingObject.id)
            let keys = inMeetingObject.rawMeeting.keys
            for key in keys {
                if (0 == inMeetingObject.id) || inMeetingObject.valueChanged(key) {
                    if let newValue = inMeetingObject.rawMeeting[key] {
                        cleanedURI += "&meeting_field[]=" + key.URLEncodedString()! + "," + newValue.URLEncodedString()!
                    }
                }
            }
            
            if 0 == inMeetingObject.id {
                refCon = NewMeetingRefCon(meetingObject: (inMeetingObject as BMLTiOSLibEditableMeetingNode), refCon: refCon) as AnyObject?
            }
            
            self._activeCommunicator = BMLTCommunicator(cleanedURI, dataSource: self, delegate: self, refCon: refCon)
        }
    }
    
    /* ################################################################## */
    /**
     This begins a meeting search.
     
     - parameter inURISuffix: This is the suffix that is appened to the fundamental URI.
     */
    func meetingSearch(_ inURISuffix: String ) {
        if nil == self._activeCommunicator {
            let refCon = BMLTiOSLibCommunicationHandlerSuffixes.MeetingSearch.rawValue
            let cleanedURI = self.delegate.rootServerURI.cleanURI(sslRequired: true) + refCon + inURISuffix
            self.suppressErrors = false
            self._activeCommunicator = BMLTCommunicator(cleanedURI, dataSource: self, delegate: self, refCon: refCon as AnyObject?)
        }
    }
    
    /* ################################################################## */
    /**
     Called to get meeting change records from the Root Server.
     
     - parameter inFromDate: This is a Date object that contains a date/time that represents the first meeting change instance. It can be nil for no Start Date.
     - parameter inToDate: This is a Date object that contains a date/time that represents the last meeting change instance. It can be nil for no End Date.
     - parameter inMeetingID: An Int, with the ID of one meeting for which we want to get changes. It can be nil for all meeting changes within the given date range.
     - parameter inServiceBodyID: An Int, with the ID of one Service Body for which we want to get changes. It can be nil for all meeting changes within the given date range.
     - parameter inUserID: An Int, with the ID of one Admin User for which we want to get changes. It can be nil for all meeting changes within the given date range. This is only valid for logged-in users.
     - parameter inMeetingNode: If this is provided, then the changes will be sent directly to the meeting node, instead of the handler.
     */
    func getAllMeetingChanges(inFromDate: Date?, inToDate: Date?, inServiceBodyID: Int?, inMeetingID: Int?, inUserID: Int?, inMeetingNode: BMLTiOSLibMeetingNode?) {
        if var uri = self.delegate.rootServerURI.cleanURI(sslRequired: true) {
            uri += BMLTiOSLibCommunicationHandlerSuffixes.GetChanges.rawValue
            if self.isLoggedInAsAdmin {  // Only logged-in users can track user IDs.
                if (nil != inUserID) && (0 < inUserID!) {
                    uri += ("&user_id=" + String(inUserID!))
                }
            }
            
            // If they provide a meeting node, then we use that ID.
            if nil != inMeetingNode {
                uri += ("&meeting_id=" + String(inMeetingNode!.id))
            } else {
                if (nil != inMeetingID) && (0 < inMeetingID!) {
                    uri += ("&meeting_id=" + String(inMeetingID!))
                }
                
                if (nil != inServiceBodyID) && (0 < inServiceBodyID!) {
                    uri += ("&service_body_id=" + String(inServiceBodyID!))
                }
            }
            
            let dateformatter = DateFormatter()
            
            dateformatter.dateFormat = "yyyy-MM-dd"
            
            if nil != inFromDate {
                let dateString = dateformatter.string(from: inFromDate!)
                uri += "&start_date=" + dateString
            }
            
            if nil != inToDate {
                let dateString = dateformatter.string(from: inToDate!)
                uri += "&end_date=" + dateString
            }
            
            // Special case if they sent in a meeting node object.
            let refCon: AnyObject? = (nil != inMeetingNode) ? (inMeetingNode as AnyObject?): (BMLTiOSLibCommunicationHandlerSuffixes.GetChanges.rawValue as AnyObject?)
            self._activeCommunicator = BMLTCommunicator(uri, dataSource: self, delegate: self, refCon: refCon)
        }
    }
    
    /* ################################################################## */
    /**
     Called to get meeting change records from the Root Server.
     
     - parameter inFromDate: This is a Date object that contains a date/time that represents the first meeting change instance. It can be nil for no Start Date.
     - parameter inToDate: This is a Date object that contains a date/time that represents the last meeting change instance. It can be nil for no End Date.
     - parameter inServiceBodyIDs: An Array of Int, with the ID of one or more Service Bodies for which we want to get changes. It can be nil for all meeting changes within the given date range.
     */
    func getDeletedMeetingChanges(inFromDate: Date?, inToDate: Date?, inServiceBodyIDs: [Int]?) {
        if var uri = self.delegate.rootServerURI.cleanURI(sslRequired: true) {
            uri += BMLTiOSLibCommunicationHandlerSuffixes.GetChanges.rawValue
            
            if (nil != inServiceBodyIDs) && (0 < (inServiceBodyIDs?.count)!) {
                if (1 == inServiceBodyIDs!.count) && (0 < (inServiceBodyIDs?[0])!) {
                    uri += ("&service_body_id=" + String((inServiceBodyIDs?[0])!))
                } else {
                    for serviceBodyID in inServiceBodyIDs! {
                        uri += ("&service_body_id[]=" + String(serviceBodyID))
                    }
                }
            }
           
            let dateformatter = DateFormatter()
            
            dateformatter.dateFormat = "yyyy-MM-dd"
            
            if nil != inFromDate {
                let dateString = dateformatter.string(from: inFromDate!)
                uri += "&start_date=" + dateString
            }
            
            if nil != inToDate {
                let dateString = dateformatter.string(from: inToDate!)
                uri += "&end_date=" + dateString
            }
            
            let refCon: AnyObject? = (BMLTiOSLibCommunicationHandlerSuffixes.GetDeletedMeetings.rawValue as AnyObject?)
            self._activeCommunicator = BMLTCommunicator(uri, dataSource: self, delegate: self, refCon: refCon)
        }
    }
    
    /* ################################################################## */
    /**
     Called to restore a deleted meeting.
     
     We have to assume the logged-in admin has rights. If they don't, it will be stopped at the server.
     
     - parameter inMeetingID: An Int, with the ID of the meeting to be restored.
     
     - returns:  true, if the operation went successfully.
     */
    func restoreDeletedMeeting(_ inMeetingID: Int) -> Bool {
        if var uri = self.delegate.rootServerURI.cleanURI(sslRequired: true) {
            uri += BMLTiOSLibCommunicationHandlerSuffixes.AdminRestoreDeletedMtg.rawValue
            
            if 0 < inMeetingID {
                uri += ("&meeting_id=" + String(inMeetingID))
                let refCon: AnyObject? = (BMLTiOSLibCommunicationHandlerSuffixes.AdminRestoreDeletedMtg.rawValue as AnyObject?)
                self._activeCommunicator = BMLTCommunicator(uri, dataSource: self, delegate: self, refCon: refCon)
                
                return true
            }
        }
        
        return false
    }
    
    /* ################################################################## */
    /**
     Called to delete a meeting.
     
     We have to assume the logged-in admin has rights. If they don't, it will be stopped at the server.
     
     - parameter inMeetingID: An Int, with the ID of the meeting to be deleted.
     */
    func deleteMeeting(_ inMeetingID: Int) {
        if var uri = self.delegate.rootServerURI.cleanURI(sslRequired: true) {
            uri += BMLTiOSLibCommunicationHandlerSuffixes.AdminDeleteMtg.rawValue
            
            if 0 < inMeetingID {
                uri += ("&meeting_id=" + String(inMeetingID))
                let refCon: AnyObject? = (BMLTiOSLibCommunicationHandlerSuffixes.AdminDeleteMtg.rawValue as AnyObject?)
                self._activeCommunicator = BMLTCommunicator(uri, dataSource: self, delegate: self, refCon: refCon)
            }
        }
    }
    
    /* ################################################################## */
    /**
     Called to rollback a meeting to before a change.
     
     We have to assume the logged-in admin has rights. If they don't, it will be stopped at the server.
     
     - parameter inMeetingID: An Int, with the ID of the meeting to be rolled back.
     - parameter inChangeID: An Int, with the ID of the change.
     
     - returns:  true, if the operation was dispatched successfully.
     */
    func rollbackMeeting(_ inMeetingID: Int, toBeforeChange inChangeID: Int) -> Bool {
        if var uri = self.delegate.rootServerURI.cleanURI(sslRequired: true) {
            uri += BMLTiOSLibCommunicationHandlerSuffixes.AdminRollbackMtg.rawValue
            
            if 0 < inMeetingID {
                uri += ("&meeting_id=" + String(inMeetingID))
                uri += ("&change_id=" + String(inChangeID))
                let refCon: AnyObject? = (BMLTiOSLibCommunicationHandlerSuffixes.AdminRollbackMtg.rawValue as AnyObject?)
                self._activeCommunicator = BMLTCommunicator(uri, dataSource: self, delegate: self, refCon: refCon)
                return true
            }
        }
        
        return false
    }
    
    /* ################################################################## */
    /**
     Called to log into a server that has semantic admin turned on.
     
     - parameter inLoginID: This is a string, with the login ID.
     - parameter inPassword: This is a string, with the password.
     
     - returns:  a Bool, which is true, if the connection is to a valid server with semantic admin on.
     */
    func adminLogin(loginID inLoginID: String, password inPassword: String) -> Bool {
        if nil == self._activeCommunicator {
            self._permissions = []
            if self.isConnected && self.semanticAdminEnabled {
                if !self.adminLoggedIn {
                    let refCon = BMLTiOSLibCommunicationHandlerSuffixes.AdminLogin.rawValue
                    
                    var cleanedURI = self.delegate.rootServerURI.cleanURI(sslRequired: true) + refCon
                    
                    cleanedURI += ("&c_comdef_admin_login=" + inLoginID.URLEncodedString()!)
                    cleanedURI += ("&c_comdef_admin_password=" + inPassword.URLEncodedString()!)
                    
                    self.suppressErrors = false
                    self._activeCommunicator = BMLTCommunicator(cleanedURI, dataSource: self, delegate: self, refCon: refCon as AnyObject?)
                } else {
                    self.delegate.loginWasSuccessful(self.adminLoggedIn)
                }
                
                return true
            }
        }
        
        return false
    }
    
    /* ################################################################## */
    /**
     Called to log out of a logged-in server that has semantic admin turned on.
     
     - returns:  a Bool, which is true, if the connection is to a valid server with semantic admin on.
     */
    func adminLogout() -> Bool {
        if nil == self._activeCommunicator {
            if self.isConnected && self.semanticAdminEnabled {
                if self.adminLoggedIn {
                    let refCon = BMLTiOSLibCommunicationHandlerSuffixes.AdminLogout.rawValue
                    let cleanedURI = self.delegate.rootServerURI.cleanURI(sslRequired: true) + refCon
                    
                    self.suppressErrors = false
                    self._activeCommunicator = BMLTCommunicator(cleanedURI, dataSource: self, delegate: self, refCon: refCon as AnyObject?)
                } else {
                    self.delegate.loginWasSuccessful(self.adminLoggedIn)
                }
                
                return true
            }
        }
        
        self._activeCommunicator = nil
        
        return false
    }
    
    /* ################################################################## */
    /**
     If sending messages to meeting contacts is enabled, this function will send a basic email to the contact for this email.
     
     - parameter meetingID: An integer, with the BMLT ID for the meeting.
     - parameter serviceBodyID: An integer, with the BMLT ID for Service body for the meeting.
     - parameter fromAddress: The email to be used as the "from" address. This is required, and should be valid.
     - parameter messageBody: A String containing the body of the message to be sent.
     */
    func sendMessageToMeetingContact(meetingID: Int, serviceBodyID: Int, fromAddress: String, messageBody: String) {
        if self.delegate.emailMeetingContactsEnabled {
            let refCon = BMLTiOSLibCommunicationHandlerSuffixes.SendMessageToContact.rawValue
            if let fromAddr = fromAddress.URLEncodedString() {
                if let message = messageBody.URLEncodedString() {
                    let uriString = "meeting_id=" + String(meetingID) + "&service_body_id=" + String(serviceBodyID) + "&from_address=\(fromAddr)&message=\(message)"
                    let cleanedURI = self.delegate.rootServerURI.cleanURI(sslRequired: true) + refCon + uriString
                    self.suppressErrors = false
                    self._activeCommunicator = BMLTCommunicator(cleanedURI, dataSource: self, delegate: self, refCon: refCon as AnyObject?)
                    return
                }
            }
        }
        
        self.delegate.messageSentResponse(false)
    }

    /* ################################################################################################################################## */
    // MARK: Data Response Handlers
    /* ################################################################################################################################## */
    /**
     Called when we want to validate the server credentials.
     
     - parameter inResponseData: The parsed JSON object. This is a server info object.
     */
    func handleServerTest(_ inResponseData: BMLTiOSLibServerInfo) {
        self._availableServiceBodies.removeAll()
        self._availableFormats.removeAll()
        self.allServiceBodies.removeAll()
        self._permissions.removeAll()
        self.formats.removeAll()
        self.hierarchicalServiceBodies = nil
        self.adminLoggedIn = false
        self.serverInfo = nil
        
        self.errorDescription = .WrongVersion
        if self.s_minServerVersion <= inResponseData.versionInt {
            self.errorDescription = .MissingFields
            var hasAllKeys: Bool = true
            for key in BMLTiOSLibMeetingNode.standardKeys {
                if !inResponseData.available_keys.contains(key) {
                    hasAllKeys = false
                    break
                }
            }
            
            if hasAllKeys {
                self.errorDescription = .None
                self.serverInfo = inResponseData
                self.getServiceBodiesFromServer()
                return
            }
        }
        
        // If we got here, we gots problems.
        self.cleanupOnAisleSeven()
    }
    
    /* ################################################################## */
    /**
     Called when we want to parse the returned Service body data.
     
     - parameter inResponseData: The parsed JSON object. This is an array of simple Dictionaries of [String: String]
     */
    func handleServiceBodies(_ inResponseData: [[String: String]]) {
        self._availableServiceBodies = inResponseData
        
        if 0 < self._availableServiceBodies.count {
            self.hierarchicalServiceBodies = self.populateHierarchicalServiceBodies(inParentObject: nil)
            self.errorDescription = .NoFormats
            self.getFormatsFromServer()
        } else {
            // If we got here, we gots problems.
            self.cleanupOnAisleSeven()
        }
    }
    
    /* ################################################################## */
    /**
     Called when we want to parse the returned format data.
     
     - parameter inResponseData: The parsed JSON object. This is a Dictionary of an array of format objects, keyed by the "formats" key.
     */
    func handleFormats(_ inResponseData: [String: [BMLTiOSLibFormatNode]]) {
        if let formatsArray = inResponseData["formats"] {
            self._allformatsStored = formatsArray
            
            if 0 < self._allformatsStored.count {
                self.getLanguagesFromServer()
                return
            }
        }
        
        // If we got here, we gots problems.
        self.cleanupOnAisleSeven()
    }
    
    /* ################################################################## */
    /**
     Called when we want to parse the returned language data.
     
     This method converts all the various data items (not that many) to Strings.
     
     - parameter inResponseData: The parsed JSON object. This is an array of Server language objects.
     */
    func handleLangs(_ inResponseData: [BMLTiOSLibServerLang]) {
        if 0 < inResponseData.count {
            self.self._availableServerLanguages = inResponseData
            if 0 < self._availableServerLanguages.count {
                self.delegate.serverIsValid(true)
                return
            }
        } else {
            // If we got here, we gots problems.
            self.cleanupOnAisleSeven()
        }
    }
    
    /* ################################################################## */
    /**
     Called when we want to parse the returned data from a meeting search.
     
     - parameter inResponseData: The parsed JSON object. This is an array of meeting objects and/or format objects, keyed by either "meetings" or "formats".
     */
    func handleMeetingSearchResponse(_ inResponseData: [String: AnyObject?]) {
        let formatArray = inResponseData["formats"]
        let meetingArray = inResponseData["meetings"]
        if self._newMeetingCall {
            self._newMeetingCall = false
            self.delegate.meetingSearchResults(meetingArray as? [BMLTiOSLibMeetingNode], newMeeting: true)
        } else {
            self.delegate.formatSearchResults(formatArray as? [BMLTiOSLibFormatNode])
            self.delegate.meetingSearchResults(meetingArray as? [BMLTiOSLibMeetingNode])
        }
    }
    
    /* ################################################################## */
    /**
     Called when we want to parse the return from a login attempt.
     
     - parameter inResponseData: The parsed String response object.
     */
    func handleLoginResponse(_ inResponseData: String) {
        self.adminLoggedIn = false
        if "OK" == inResponseData {
            self.adminLoggedIn = true
            if !self.getPermissionsFromServer() {
                self.errorDescription = BMLTiOSLibCommunicationHandlerBadTestReasons.CommError
            } else {
                return
            }
        } else {
            if "NOT AUTHORIZED" == inResponseData {
                self.errorDescription = BMLTiOSLibCommunicationHandlerBadTestReasons.AuthError
                let domain = BMLTiOSLibErrorDomains.PermissionError.rawValue
                let code = BMLTiOSLibErrorCodes.IncorrectCredentials.rawValue
                let error = NSError(domain: domain, code: code, userInfo: nil)
                self.delegate.errorEncountered(error)
            }
        }
        
        self.delegate.loginWasSuccessful(self.adminLoggedIn)
    }
    
    /* ################################################################## */
    /**
     Called when we want to parse the returned permission data.
     
     - parameter inResponseData: The parsed JSON object. This is an array of Permissions tuples.
     */
    func handlePermissionResponse(_ inResponseData: AnyObject?) {
        var inData: [PermissionsTuple] = []
        
        if let permission = inResponseData as? PermissionsTuple {
            inData = [permission]
        } else {
            if let permissions = inResponseData as? [PermissionsTuple] {
                inData = permissions
            }
        }
        self._permissions = inData
        if 0 < self._permissions.count {
            self.adminLoggedIn = true
            self.delegate.loginWasSuccessful(self.adminLoggedIn)
        } else {
            self.handleLogoutResponse()
        }
    }
    
    /* ################################################################## */
    /**
     Called when we want to parse the return from a logout attempt.
     */
    func handleLogoutResponse() {
        self.adminLoggedIn = false
        self._permissions = []
        // We use the same callback for both login and logout.
        self.delegate.loginWasSuccessful(self.adminLoggedIn)
    }
    
    /* ################################################################## */
    /**
     Called when we want to parse the return from a meeting edit save attempt.
     */
    func handleMeetingEditSaveResponse(_ inResponseData: [String: AnyObject?]) {
        if nil != inResponseData["changeMeeting"] as? [String: String] {
            if nil != inResponseData["field"] {
                let newObject = BMLTiOSLibChangedMeeting(inResponseData, inHandler: self.delegate)
                self.delegate.meetingChangeComplete(newObject)
                return
            }
        }
        self.delegate.meetingChangeComplete(nil)
    }
    
    /* ################################################################## */
    /**
     Called when we want to parse the return from a get changes request.
     
     - parameter inResponseData: the change object.
     - parameter inMeetingNode: If this is provided, then the changes will be sent directly to the meeting node, instead of the handler.
     - parameter inDeletedMeetingsOnly: If this is true, then only deleted meeting changes will be returned.
     */
    func handleGetChangesResponse(_ inResponseData: [BMLTiOSLibChangeNode], inMeetingNode: BMLTiOSLibMeetingNode?, inDeletedMeetingsOnly: Bool) {
        var changes: [BMLTiOSLibChangeNode] = []
        for changeInstance in inResponseData {
            // In the case of deleted meetings, we only want the very latest change. This is the one that resulted in the lat deletion.
            if inDeletedMeetingsOnly && (nil == changeInstance.afterObject) && !changeInstance.meetingCurrentlyExists {
                for i in 0..<changes.count where changeInstance.meeting_id == changes[i].meeting_id {
                    changes.remove(at: i)   // Remove the old change.
                    break
                }
            } else {
                if (inDeletedMeetingsOnly && (nil != changeInstance.afterObject)) || (inDeletedMeetingsOnly && changeInstance.meetingCurrentlyExists) {
                    continue
                }
            }
            
            // Append the latest change record if we aren't looking for deleted meetings or are logged in as an admin.
            if !inDeletedMeetingsOnly || !self.delegate.isAdminLoggedIn {
                changes.append(changeInstance)
            } else {
                // If we are logged in as an admin, we are only allowed to see deleted meetings that we can edit.
                if self.delegate.isAdminLoggedIn && inDeletedMeetingsOnly {
                    // We leave out clearly bad meetings.
                    if let beforeObject = changeInstance.beforeObject as? BMLTiOSLibEditableMeetingNode {
                        if !beforeObject.name.isEmpty && (0 < beforeObject.id) && (0 < beforeObject.weekdayIndex) && (8 > beforeObject.weekdayIndex) {
                            changes.append(changeInstance)
                        }
                    }
                }
            }
        }
        
        // Make sure we have the results sorted by date; with most recent at the top.
        changes.sort(by: { (a: BMLTiOSLibChangeNode, b: BMLTiOSLibChangeNode) -> Bool in
            if let aDate = a.changeDate {
                if let bDate = b.changeDate {
                    return ComparisonResult.orderedDescending == aDate.compare(bDate)
                }
            }
            
            return true
        })
        
        self.delegate.changeRequestResults(changes, updateMeetingNode: inMeetingNode, deletedMeetingsOnly: inDeletedMeetingsOnly)
    }
    
    /* ################################################################## */
    /**
     Called when we want to parse the return from a restore deleted meeting request.
     
     - parameter inResponseData: The JSON data object.
     */
    func handleRestoreMeetingResponse(_ inResponseData: [String: AnyObject?]) {
        if let id = inResponseData["meeting_id"] as? String {
            if nil == self._activeCommunicator {
                let refCon = BMLTiOSLibCommunicationHandlerSuffixes.GetRestoredMeetingInfo.rawValue
                let cleanedURI = self.delegate.rootServerURI.cleanURI(sslRequired: true) + refCon + id
                self.suppressErrors = false
                self._activeCommunicator = BMLTCommunicator(cleanedURI, dataSource: self, delegate: self, refCon: refCon as AnyObject?)
            }
        }
    }
    
    /* ################################################################## */
    /**
     Called when we want to parse the return from a get meeting details request after a restore.
     
     - parameter inResponseData: The JSON data object.
     */
    func handleRestoreMeetingInfoResponse(_ inResponseData: [String: [BMLTiOSLibEditableMeetingNode]]) {
        if let mtg = inResponseData["meetings"]?[0] {
            self.delegate.restoreRequestResults(mtg)
        }
    }
    
    /* ################################################################## */
    /**
     Called when we want to parse the return from a get meeting details request after a rollback.
     
     - parameter inResponseData: The JSON data object.
     */
    func handleRollbackMeetingInfoResponse(_ inResponseData: [String: [BMLTiOSLibEditableMeetingNode]]) {
        if let mtg = inResponseData["meetings"]?[0] {
            self.delegate.rollbackRequestResults(mtg)
        }
    }
    
    /* ################################################################## */
    /**
     Called when we want to parse the return from a meeting deletion.
     
     - parameter inResponseData: The JSON data object.
     */
    func handleDeletedMeetingResponse(_ inResponseData: [String: AnyObject?]) {
        // Simply let the delegate know that we did, in fact, delete the meeting (or didn't).
        if let id = inResponseData["meeting_id"] as? String {
            self.delegate.meetingDeleted("0" != id)
        }
    }
    
    /* ################################################################## */
    /**
     Called when we want to parse the return from a restore deleted meeting request.
     
     - parameter inResponseData: The JSON data object.
     */
    func handleRollbackMeetingResponse(_ inResponseData: [String: AnyObject?]) {
        if let id = inResponseData["meeting_id"] as? String {
            if nil == self._activeCommunicator {
                let refCon = BMLTiOSLibCommunicationHandlerSuffixes.GetRollbackMeetingInfo.rawValue
                let cleanedURI = self.delegate.rootServerURI.cleanURI(sslRequired: true) + refCon + id
                self.suppressErrors = false
                self._activeCommunicator = BMLTCommunicator(cleanedURI, dataSource: self, delegate: self, refCon: refCon as AnyObject?)
            }
        }
    }
    
    /* ################################################################## */
    /**
     Called when we want to parse the return from a get changes request.
     
     - parameter inResponseData: The JSON data object.
     */
    func handleNewMeetingResponse(_ inResponseData: [String: AnyObject?]) {
        if let newMeetingIndicatorObject = inResponseData["newMeeting"] as? [String: AnyObject?] {
            // We get the new meeting ID, then do a simple ID search for that meeting.
            if let id = newMeetingIndicatorObject["id"] as? String {
                self._newMeetingCall = true
                if nil == self._activeCommunicator {
                    self.delegate.searchCriteria.clearAll()
                    self.delegate.searchCriteria.searchString = id
                    self.delegate.performMeetingSearch(.MeetingsOnly)
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     Called when we want to parse the return from a send message to contact operation.
     
     - parameter inResponseData: The JSON data object.
     */
    func handleSentMessageResponse(_ inResponseData: AnyObject?) {
        var success = false
        var error: NSError! = nil
        
        if let stringVal = inResponseData as? NSString {
            success = "1" == stringVal
            
            if !success {
                var code: Int = 0
                
                switch stringVal {
                case "-2":
                    code = BMLTiOSLibErrorCodes.MessageAppearsToBeSpam.rawValue

                case "-3":
                    code = BMLTiOSLibErrorCodes.MessageAppearsToBeSpam.rawValue
                    
                default:
                    code = BMLTiOSLibErrorCodes.SendingUnknownError.rawValue
                }
                
                error = NSError(domain: BMLTiOSLibErrorDomains.MailSendingError.rawValue, code: code, userInfo: nil)
            }
        } else {
            error = NSError(domain: BMLTiOSLibErrorDomains.MailSendingError.rawValue, code: BMLTiOSLibErrorCodes.SendingUnknownError.rawValue, userInfo: nil)
        }
        
        if nil != error {
            self.delegate.errorEncountered(error as Error)
        }
        
        self.delegate.messageSentResponse(success)
   }
    
    /* ################################################################################################################################## */
    // MARK: Generic Incoming Data Parser
    /* ################################################################################################################################## */
    /**
     This will parse the response data as JSON data, and create generic Dictionariy objects, Smart objects or Array objects.
     
     This is the heart of the data interpreter. It will create "smart" objects that will be used in subsequent operations.
     It will also correct for some inconsistencies in the data response from the server.
     
     - parameter inResponseData: The JSON data object. If nil, the call failed to produce. Check the handler's error data member.
     - parameter error: Any errors that occurred
     - parameter refCon: The data/object passed in via the 'refCon' parameter in the initializer.
     
     - returns:  An object, parsed from the data. This is returned as a generic AnyObject optional, but it will actually be an array or dictionary or smart object. It may be an Error object.
     */
    func parseJSONData(_ inResponseData: Any?, error inError: Error?, refCon inRefCon: Any?) -> AnyObject? {
        var ret: AnyObject?
        
        if nil == inError {
            // See if the response data is a Dictionary
            if inResponseData is NSDictionary {
                if ret is BMLTiOSLibMeetingNode {
                    ret = ["meetings": [ret]] as AnyObject?
                } else {
                    if ret is BMLTiOSLibFormatNode {
                        ret = ["formats": [ret]] as AnyObject?
                    } else {
                        ret = self.parseJSONDictionaryHandler(inResponseData, error: inError, refCon: inRefCon)
                    }
                }
            } else {
                ret = self.parseJSONOtherHandler(inResponseData, error: inError, refCon: inRefCon)
            }
        } else {
            ret = inError as AnyObject?
        }
    
        return ret
    }
    
    /* ################################################################## */
    /**
     This parses an uncategorized JSON object.
     Parsing is recursive, so we dole out parsing to the main handlers.
     
     - parameter inResponseData: The JSON data object. If nil, the call failed to produce. Check the handler's error data member.
     - parameter error: Any errors that occurred
     - parameter refCon: The data/object passed in via the 'refCon' parameter in the initializer.
     
     - returns:  An object, parsed from the data. This is returned as a generic AnyObject optional, but it will actually be an array or dictionary or smart object. It may be an Error object.
     */
    func parseJSONOtherHandler(_ inResponseData: Any?, error inError: Error?, refCon inRefCon: Any?) -> AnyObject? {
        var ret: AnyObject?
        
        // Arrays are a bit simpler.
        if inResponseData is NSArray {
            ret = self.parseJSONArray((inResponseData as? NSArray)!) as AnyObject?
            
            // See if this was a "meetings only" or "formats only" object, in which case, we create a labeled container.
            if ret is [BMLTiOSLibMeetingNode] {
                ret = ["meetings": ret] as AnyObject?
            } else {
                if ret is [BMLTiOSLibFormatNode] {
                    ret = ["formats": ret] as AnyObject?
                }
            }
        } else {    // Look for simple string responses. A couple of them are errors.
            if inResponseData is NSString {
                ret = (inResponseData as? NSString) as AnyObject?
                
                if "ERROR" == (ret as? String) {
                    ret = NSError(domain: BMLTiOSLibErrorDomains.CommunicationError.rawValue, code: BMLTiOSLibErrorCodes.GeneralError.rawValue, userInfo: nil) as AnyObject?
                } else {
                    if "NOT AUTHORIZED" == (ret as? String) {
                        ret = NSError(domain: BMLTiOSLibErrorDomains.PermissionError.rawValue, code: BMLTiOSLibErrorCodes.IncorrectCredentials.rawValue, userInfo: nil) as AnyObject?
                    }
                }
            } else {
                // We handle numbers as numbers.
                if inResponseData is NSNumber {
                    ret = self.parseJSONNumber((inResponseData as? NSNumber)!) as AnyObject?
                } else {
                    if let dataObj = inResponseData as? Data {
                        if 0 < dataObj.count {
                            ret = String(data: dataObj, encoding: .utf8) as AnyObject?
                        } else {
                            ret = NSError(domain: BMLTiOSLibErrorDomains.CommunicationError.rawValue, code: BMLTiOSLibErrorCodes.NoDataReceivedError.rawValue, userInfo: nil) as AnyObject?
                        }
                    } else {
                        ret = NSError(domain: BMLTiOSLibErrorDomains.CommunicationError.rawValue, code: BMLTiOSLibErrorCodes.NoDataReceivedError.rawValue, userInfo: nil) as AnyObject?
                    }
                }
            }
        }

        return ret
    }

    /* ################################################################## */
    /**
     This parses a Dictionary JSON object.
     Parsing is recursive, so we dole out parsing to the main handlers.
     
     - parameter inResponseData: The JSON data object. If nil, the call failed to produce. Check the handler's error data member.
     - parameter error: Any errors that occurred
     - parameter refCon: The data/object passed in via the 'refCon' parameter in the initializer.
     
     - returns:  An object, parsed from the data. This is returned as a generic AnyObject optional, but it will actually be an array or dictionary or smart object. It may be an Error object.
     */
    func parseJSONDictionaryHandler(_ inResponseData: Any?, error inError: Error?, refCon inRefCon: Any?) -> AnyObject? {
        var ret: AnyObject? = self.parseJSONDictionary((inResponseData as? NSDictionary)!)
        // This does the opposite of above. It removes a redundant layer.
        if ret is [String: [BMLTiOSLibServerLang]] {
            if let retTmp = ret as? [String: [BMLTiOSLibServerLang]] {
                ret = retTmp["languages"] as AnyObject?
            }
        } else {
            // This also does the opposite, and creates an array of BMLTiOSLibPermissions objects.
            
            // The strange dance below is because singular permissions come across as simple Dictionaries,
            // not as Arrays of Dictionaries, so we need to create artificial 1-element Arrays.
            var sb_perms_container_final: [String: [[String: String]]] = [:]
            
            if let sb_perms_container = ret as? [String: [[String: String]]] {
                sb_perms_container_final = sb_perms_container
            } else {    // Create an artificial Array.
                if let sb_perms_container = ret as? [String: [String: String]] {
                    if let sb_perms = sb_perms_container["service_body"] {
                        sb_perms_container_final = ["service_body": [sb_perms]]
                    }
                }
            }
            
            if let sb_perms = sb_perms_container_final["service_body"] {
                var permArray: [PermissionsTuple] = []
                for perm in sb_perms {
                    if let id = Int(perm["id"]!) {
                        if let name = perm["name"] {
                            if let permissions = Int(perm["permissions"]!) {
                                if let permissionsObject = BMLTiOSLibPermissions(rawValue: permissions) {
                                    let tupleoGold: PermissionsTuple = (id: id, name: name, permissions: permissionsObject)
                                    permArray.append(tupleoGold)
                                }
                            }
                        }
                    }
                }
                ret = permArray as AnyObject?
            }
        }
        
        return ret
    }

    /* ################################################################## */
    /**
     This parses a section of data that is an NSArray, and returns a new Swift Array (or single object in one instance).
     
     - parameter inResponseData: The JSON data object as an NSArray.
     
     - returns:  an AnyObject optional that will usually be a Swift Array. However, it could be a single instance of BMLTiOSLibServerInfo.
     */
    func parseJSONArray(_ inResponseData: NSArray) -> AnyObject? {
        var ret: [AnyObject?] = []
        
        for object in inResponseData {  // Get each object in the array.
            if object is NSDictionary { // If it's a Dictionary, we call our general Dictionary parser.
                ret.append(self.parseJSONDictionary((object as? NSDictionary)!) as AnyObject?)
            } else {    // If it isn't a Dictionary, we try other interpreters.
                if object is NSArray {  // If it's an Array, we recursively call the Array parser.
                    ret.append(self.parseJSONArray((object as? NSArray)!) as AnyObject?)
                } else {
                    if object is NSString { // If it's a String, we simply create a copy and slap that in.
                        ret.append(object as AnyObject?)
                    } else {
                        if object is NSNumber { // If it's a number, we create the appropriate type of number object for it.
                            ret.append(self.parseJSONNumber((object as? NSNumber)!) as AnyObject?)
                        }
                    }
                }
            }
        }
        
        // If we only have one item, and it's a Server Info object, we strip away the Array wrapper.
        if (1 == ret.count) && (ret is [BMLTiOSLibServerInfo]) {
            return ret[0] as AnyObject?
        }
        
        // If this was an array of Service Body Dictionaries, we create a very simple 1-deep Array of Dictionaries.
        // The main reason we do this is to make the format as simple and predictable as possible. We will be creating a hierarchy based on these, so we want them simple.
        if ret is [ServiceBodyRawDataDictionary] {
            var retTemp: [[String: String]] = []
            
            for sb in (ret as? [ServiceBodyRawDataDictionary])! {
                retTemp.append(sb.sbData)
            }
            
            return retTemp as AnyObject?
        }
        
        // Return what's left over.
        return ret as AnyObject?
    }
    
    /* ################################################################## */
    /**
     This parses a number, and turns it into a String.
     
     - parameter inResponseData: The JSON data object as an NSNumber.
     
     - returns:  The number as a String.
     */
    func parseJSONNumber(_ inResponseData: NSNumber) -> String {
        var ret: String = "0"
        
        let floatValue = inResponseData.floatValue
        let intValue = inResponseData.intValue
        
        if 0.0 == floatValue - Float(intValue) {
            ret = String(Int(floatValue))
        } else {
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 12
            ret = formatter.string(from: inResponseData)!
        }
        
        return ret as String
    }

    /* ################################################################## */
    /**
     This parses a Dictionary.
     
     In several cases, the Dictionary will represent a "smart" object, and this function will endeavor to return that object.
     
     It will call specialized parsers for these objects.
     
     - parameter inResponseData: The JSON data object as an NSDictionary.
     
     - returns:  The result of the parse. This may be a "smart object" that represents the Dictionary.
     */
    func parseJSONDictionary(_ inResponseData: NSDictionary) -> AnyObject? {
        var ret: AnyObject?
        
        if let keys = inResponseData.allKeys as? [NSString] {
            // First, look for format and meeting lists (both).
            // If so, we call our array parser on each of them.
            if (2 == keys.count) && keys.contains("meetings") && keys.contains("formats") {
                ret = self.parseMeetingsAndFormatsJSONObject(inResponseData: inResponseData) as AnyObject?
            // See if we only have a single set of meetings (no formats).
            } else if (1 == keys.count) && keys.contains("meetings") {
                ret = self.parseMeetingsAloneJSONObject(inResponseData: inResponseData) as AnyObject?
            // Is this a json_data section of a change response?
            } else if (2 >= keys.count) && (keys.contains("before") || keys.contains("after")) {
                ret = self.parseChangeJSONObject(inResponseData: inResponseData) as AnyObject?
            // See if we only have a formats response.
            } else if (1 == keys.count) && keys.contains("formats") {
                ret = self.parseFormatsJSONObject(inResponseData: inResponseData) as AnyObject?
            // Is this a meeting change object?
            } else if keys.contains("json_data") {
                ret = self.parseJSONChangeObject(inResponseData) as AnyObject?
            // Is this a meeting?
            } else if keys.contains("service_body_bigint") && keys.contains("id_bigint") && keys.contains("published") && keys.contains("longitude") && keys.contains("latitude") && keys.contains("formats") {
                ret = self.parseJSONMeeting(inResponseData)
            // Is this a format?
            } else if keys.contains("key_string") && keys.contains("name_string") && keys.contains("description_string") && keys.contains("lang") && keys.contains("id") {
                ret = self.parseJSONFormat(inResponseData) as AnyObject?
            // Is this a server info object?
            } else if keys.contains("available_keys") && keys.contains("centerLatitude") && keys.contains("centerLongitude") && keys.contains("centerZoom") && keys.contains("changesPerMeeting") && keys.contains("version") && keys.contains("versionInt") {
                ret = self.parseJSONServerInfo(inResponseData) as AnyObject?
            // Is this a Service body?
            } else if keys.contains("parent_id") && keys.contains("description") && keys.contains("name") {
                ret = self.parseJSONServiceBody(inResponseData) as AnyObject?
            // Is this a language object?
            } else if (keys.contains("name") && keys.contains("key")) && ((2 == keys.count) || ((3 == keys.count) && keys.contains("default"))) {
                ret = self.parseJSONServerLang(inResponseData) as AnyObject?
            // Otherwise, we treat it as a generic Dictionary.
            } else {
                ret = self.parseGenericJSONObject(keys: keys, inResponseData: inResponseData) as AnyObject?
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This is a specialized parser for meeting/format search results.
     
     - parameter inResponseData: The JSON data object as an NSDictionary.
     
     - returns:  The result of the parse.
     */
    func parseMeetingsAndFormatsJSONObject(inResponseData: NSDictionary) -> [String: [AnyObject?]] {
        var retTemp: [String: [AnyObject?]] = [:]
        retTemp["meetings"] = (self.parseJSONArray((inResponseData.object(forKey: "meetings") as? NSArray)!) as? [AnyObject?]?)!
        retTemp["formats"] = (self.parseJSONArray((inResponseData.object(forKey: "formats") as? NSArray)!) as? [AnyObject?]?)!
        return retTemp
    }
    
    /* ################################################################## */
    /**
     This is a specialized parser for meeting search results without accompanying formats.
     
     - parameter inResponseData: The JSON data object as an NSDictionary.
     
     - returns:  The result of the parse.
     */
    func parseMeetingsAloneJSONObject(inResponseData: NSDictionary) -> [String: [AnyObject?]] {
        var retTemp: [String: [AnyObject?]] = [:]
        retTemp["meetings"] = (self.parseJSONArray((inResponseData.object(forKey: "meetings") as? NSArray)!) as? [AnyObject?]?)!
        return retTemp
    }

    /* ################################################################## */
    /**
     This is a specialized parser for change responses.
     
     - parameter inResponseData: The JSON data object as an NSDictionary.
     
     - returns:  The result of the parse.
     */
    func parseChangeJSONObject(inResponseData: NSDictionary) -> [String: [String: String]] {
        var retTemp: [String: [String: String]] = [:]
        
        // The reason for this odd little dance, is because the meeting Dictionary in a change object is slightly different from that in the regular response (oops).
        // The smart parser will account for this, so we smart parse, then extract the raw data.
        if let beforeObject = inResponseData.object(forKey: "before") as? NSDictionary {
            retTemp["before"] = self.parseJSONMeeting(beforeObject)?.rawMeeting
        }
        
        if let afterObject = inResponseData.object(forKey: "after") as? NSDictionary {
            retTemp["after"] = self.parseJSONMeeting(afterObject)?.rawMeeting
        }

        return retTemp
    }

    /* ################################################################## */
    /**
     This is a specialized parser for format responses.
     
     - parameter inResponseData: The JSON data object as an NSDictionary.
     
     - returns:  The result of the parse.
     */
    func parseFormatsJSONObject(inResponseData: NSDictionary) -> [String: [AnyObject?]] {
        var retTemp: [String: [AnyObject?]] = [:]
        
        if let formats = inResponseData.object(forKey: "formats") as? NSArray {
            retTemp["formats"] = self.parseJSONArray(formats) as? [AnyObject?]
        }
        
        return retTemp
    }

    /* ################################################################## */
    /**
     This is a specialized parser for "generic" objects.
     
     - parameter inResponseData: The JSON data object as an NSDictionary.
     
     - returns:  The result of the parse.
     */
    func parseGenericJSONObject(keys: [NSString], inResponseData: NSDictionary) -> [String: Any?] {
        var retDict: [String: Any?] = [:]
        for key in keys {
            let stringKey = key as String
            if let value = inResponseData.object(forKey: key) {
                if value is NSDictionary {
                    retDict[stringKey] = self.parseJSONDictionary((value as? NSDictionary)!) as AnyObject?
                } else if value is NSArray {
                    retDict[stringKey] = self.parseJSONArray((value as? NSArray)!) as AnyObject?
                } else if value is NSString {
                    retDict[stringKey] = value as AnyObject?
                } else if value is NSNumber {
                    retDict[stringKey] = self.parseJSONNumber((value as? NSNumber)!)
                }
            }
        }
        return retDict
    }
    
    /* ################################################################## */
    /**
     This parses the JSON Dictionary into a Service body smart object.
     
     - parameter inResponseData: The JSON data object as an NSDictionary.
     
     - returns:  The result of the parse. This will be a "smart object" that represents the Dictionary.
     */
    func parseJSONServiceBody(_ inResponseData: NSDictionary) -> ServiceBodyRawDataDictionary? {
        var infoDictionary: [String: String] = [:]
        
        if let keys = inResponseData.allKeys as? [NSString] {
            for key in keys {
                if let value = inResponseData.object(forKey: key) as? String {
                    infoDictionary[key as String] = value
                }
            }
        }
        
        let ret = ServiceBodyRawDataDictionary(infoDictionary)
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This parses the JSON Dictionary into a Server language smart object.
     
     - parameter inResponseData: The JSON data object as an NSDictionary.
     
     - returns:  The result of the parse. This will be a "smart object" that represents the Dictionary.
     */
    func parseJSONServerLang(_ inResponseData: NSDictionary) -> BMLTiOSLibServerLang? {
        var infoDictionary: [String: String] = [:]
        
        if let value = inResponseData.object(forKey: "key") as? NSString {
            infoDictionary["key"] = String(value)
        }
        
        if let value = inResponseData.object(forKey: "name") as? NSString {
            infoDictionary["name"] = String(value)
        }
        
        // This is a "belt and suspenders" thing.
        if self.serverInfo?.nativeLang == infoDictionary["key"] {
            infoDictionary["default"] = "1"
        } else {
            infoDictionary["default"] = "0"
        }
        
        let ret = BMLTiOSLibServerLang(infoDictionary)
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This parses the JSON Dictionary into a Server Info smart object.
     
     - parameter inResponseData: The JSON data object as an NSDictionary.
     
     - returns:  The result of the parse. This will be a "smart object" that represents the Dictionary.
     */
    func parseJSONServerInfo(_ inResponseData: NSDictionary) -> BMLTiOSLibServerInfo? {
        var infoDictionary: [String: String] = [:]
        
        if let keys = inResponseData.allKeys as? [NSString] {
            for key in keys {
                infoDictionary[key as String] = (inResponseData.object(forKey: key) as? NSString)! as String
            }
        }
        
        let ret = BMLTiOSLibServerInfo(infoDictionary)
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This parses the JSON Dictionary into a Meeting Change smart object.
     
     - parameter inResponseData: The JSON data object as an NSDictionary.
     
     - returns:  The result of the parse. This will be a "smart object" that represents the Dictionary.
    */
    func parseJSONChangeObject(_ inResponseData: NSDictionary) -> BMLTiOSLibChangeNode? {
        var infoDictionary: [String: AnyObject?] = [:]
        
        if let keys = inResponseData.allKeys as? [NSString] {
            for key in keys {
                let keyString = String(key)
                if var value = inResponseData.object(forKey: key) {
                    if value is NSDictionary {
                        value = self.parseJSONDictionary((value as? NSDictionary)!)!
                    } else if value is NSArray {
                        value = self.parseJSONArray((value as? NSArray)!)!
                    } else if value is NSNumber {
                        value = self.parseJSONNumber((value as? NSNumber)!) as Any
                    }
                    
                    infoDictionary[keyString] = value as AnyObject
                }
            }
        }
        
        let ret = BMLTiOSLibChangeNode(infoDictionary, inHandler: self.delegate)
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This parses the JSON Dictionary into a Meeting smart object.
     
     - parameter inResponseData: The JSON data object as an NSDictionary.
     
     - returns:  The result of the parse. This will be a "smart object" that represents the Dictionary.
     */
    func parseJSONMeeting(_ inResponseData: NSDictionary) -> BMLTiOSLibMeetingNode? {
        var meetingDictionary: [String: String] = [:]
        
        if let keys = inResponseData.allKeys as? [NSString] {
            for key in keys {
                if "formats" == key {
                    if let array = inResponseData.object(forKey: key) as? NSArray {
                        var formatString = ""
                        
                        for format in array {
                            if !formatString.isEmpty {
                                formatString += ","
                            }
                            formatString += (format as? String)!
                        }
                        meetingDictionary[key as String] = formatString
                    } else {
                        if let formatString = inResponseData.object(forKey: key) as? NSString {
                            meetingDictionary[key as String] = formatString as String
                        }
                    }
                } else {
                    if let objectValue = inResponseData.object(forKey: key) as? NSString {
                        meetingDictionary[key as String] = objectValue as String
                    }
                }
            }
        }
        
        let ret = self.delegate.generateProperMeetingObject(meetingDictionary)
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This parses the JSON Dictionary into a format smart object.
     
     - parameter inResponseData: The JSON data object as an NSDictionary.
     
     - returns:  The result of the parse. This will be a "smart object" that represents the Dictionary.
     */
    func parseJSONFormat(_ inResponseData: NSDictionary) -> BMLTiOSLibFormatNode? {
        var formatDictionary: [String: String] = [:]
        
        if let keys = inResponseData.allKeys as? [NSString] {
            for key in keys {
                if let objectValue = inResponseData.object(forKey: key) as? NSString {
                    formatDictionary[key as String] = objectValue as String
                }
            }
        }
        
        let ret = BMLTiOSLibFormatNode(formatDictionary, inExtraData: nil)
        
        return ret
    }
    
    /* ################################################################################################################################## */
    // MARK: BMLTCommunicatorDataSinkProtocol Methods and Properties
    /* ################################################################################################################################## */
    /**
     The response callback. This acts as a dispatcher, calling the appropriate handler.
     
     - parameter inHandler: The handler for this call.
     - parameter inResponseData: The JSON data object. If nil, the call failed to produce. Check the handler's error data member.
     - parameter inError: Any errors that occurred
     - parameter inRefCon: The data/object passed in via the 'refCon' parameter in the initializer.
     */
    func responseData(_ inHandler: BMLTCommunicator?, inResponseData: Any, inError: Error?, inRefCon: AnyObject?) {
        DispatchQueue.main.async {
            #if DEBUG
                print("Handler: \(String(describing: inHandler)).")
                print("ResponseData: \(inResponseData).")
                print("Error: \(String(describing: inError)).")
                print("RefCon: \(String(describing: inRefCon)).")
            #endif
            if (nil != inError) || ("ERROR" == (inResponseData as? String)) {
                if "ERROR" == (inResponseData as? String) {
                    let newError: NSError = NSError(domain: BMLTiOSLibErrorDomains.CommunicationError.rawValue, code: BMLTiOSLibErrorCodes.GeneralError.rawValue, userInfo: ["localizedDescription": BMLTiOSLibErrorDescriptions.GeneralError.rawValue])
                    self.delegate.errorEncountered(newError)
                } else {
                    self.delegate.errorEncountered(inError! as NSError)
                }
            } else {
                let parsedObject = self.parseJSONData(inResponseData, error: inError, refCon: nil)
                #if DEBUG
                    print("Parsed Object: \(String(describing: parsedObject)).")
                #endif

                // Check to see if we encountered an error.
                if parsedObject is NSError {
                    self.delegate.errorEncountered((parsedObject as? NSError)!)
                } else if nil != inRefCon as? NewMeetingRefCon {
                    self._activeCommunicator = nil // OK. We're done.
                    self.handleNewMeetingResponse((parsedObject as? [String: AnyObject?])!)
                } else if let meetingNode = inRefCon as? BMLTiOSLibMeetingNode {   // This is a special case for when we get changes and directly associate them with a meeting.
                    if nil != parsedObject {
                        self.handleGetChangesResponse((parsedObject as? [BMLTiOSLibChangeNode])!, inMeetingNode: meetingNode, inDeletedMeetingsOnly: false)
                    } else {
                        self.handleGetChangesResponse([], inMeetingNode: meetingNode, inDeletedMeetingsOnly: false)
                    }
                    self._activeCommunicator = nil // OK. We're done.
                } else {
                    if let callType = inRefCon as? String { // We send a key in as a string.
                        // Special handler for deleted meetings.
                        if BMLTiOSLibCommunicationHandlerSuffixes.GetDeletedMeetings.rawValue == callType {
                            if nil != parsedObject {
                                self.handleGetChangesResponse((parsedObject as? [BMLTiOSLibChangeNode])!, inMeetingNode: nil, inDeletedMeetingsOnly: true)
                            } else {
                                self.handleGetChangesResponse([], inMeetingNode: nil, inDeletedMeetingsOnly: true)
                            }
                            self._activeCommunicator = nil // OK. We're done.
                        } else {
                            self._activeCommunicator = nil // OK. We're done.
                            
                            self.handleCallType(callType, parsedObject: parsedObject, inResponseData: inResponseData)
                        }
                    }
                }
            }
        }
    }

    /* ################################################################## */
    /**
     The response callback (second part to reduce CC). This acts as a dispatcher, calling the appropriate handler.
     
     - parameter inHandler: The handler for this call.
     - parameter parsedObject: The partly-parsed response.
     - parameter inResponseData: The JSON data object. If nil, the call failed to produce. Check the handler's error data member.
     */
    func handleCallType(_ callType: String, parsedObject: AnyObject?, inResponseData: Any) {
        switch callType {  // See what this call wanted us to do.
        case BMLTiOSLibCommunicationHandlerSuffixes.ServerTest.rawValue:
            if let testResponse = parsedObject as? BMLTiOSLibServerInfo {
                self.handleServerTest(testResponse)
            } else {
                self.handleCommunicationError(BMLTiOSLibCommunicationHandlerSuffixes.ServerTest, inBadData: inResponseData as AnyObject?)
            }
            
        case BMLTiOSLibCommunicationHandlerSuffixes.GetServiceBodies.rawValue:
            if let serviceBodies = parsedObject as? [[String: String]] {
                self.handleServiceBodies(serviceBodies)
            } else {
                self.handleCommunicationError(BMLTiOSLibCommunicationHandlerSuffixes.GetServiceBodies, inBadData: inResponseData as AnyObject?)
            }
            
        case BMLTiOSLibCommunicationHandlerSuffixes.GetFormats.rawValue:
            if let formats = parsedObject as? [String: [BMLTiOSLibFormatNode]] {
                self.handleFormats(formats)
            } else {
                self.handleCommunicationError(BMLTiOSLibCommunicationHandlerSuffixes.GetFormats, inBadData: inResponseData as AnyObject?)
            }
            
        case BMLTiOSLibCommunicationHandlerSuffixes.GetLangs.rawValue:
            if let langs = parsedObject as? [BMLTiOSLibServerLang] {
                self.handleLangs(langs)
            } else {
                self.handleCommunicationError(BMLTiOSLibCommunicationHandlerSuffixes.GetLangs, inBadData: inResponseData as AnyObject?)
            }
            
        case BMLTiOSLibCommunicationHandlerSuffixes.MeetingSearch.rawValue:
            if let meetings = parsedObject as? [String: AnyObject?] {
                self.handleMeetingSearchResponse(meetings)
            } else {
                if nil == parsedObject {
                    self.handleMeetingSearchResponse([:])
                } else {
                    self.handleCommunicationError(BMLTiOSLibCommunicationHandlerSuffixes.MeetingSearch, inBadData: inResponseData as AnyObject?)
                }
            }
            
        default:
            self.handleCallTypePartDeux(callType, parsedObject: parsedObject, inResponseData: inResponseData)
        }
    }

    /* ################################################################## */
    /**
     The response callback (third part to reduce CC). This acts as a dispatcher, calling the appropriate handler.
     
     - parameter inHandler: The handler for this call.
     - parameter parsedObject: The partly-parsed response.
     - parameter inResponseData: The JSON data object. If nil, the call failed to produce. Check the handler's error data member.
     */
    func handleCallTypePartDeux(_ callType: String, parsedObject: AnyObject?, inResponseData: Any) {
        switch callType {  // See what this call wanted us to do.
        case BMLTiOSLibCommunicationHandlerSuffixes.GetChanges.rawValue:
            if let changeArray = parsedObject as? [BMLTiOSLibChangeNode] {
                self.handleGetChangesResponse(changeArray, inMeetingNode: nil, inDeletedMeetingsOnly: false)
            } else {
                self.handleCommunicationError(BMLTiOSLibCommunicationHandlerSuffixes.GetChanges, inBadData: inResponseData as AnyObject?)
            }
            
        case BMLTiOSLibCommunicationHandlerSuffixes.SendMessageToContact.rawValue:
            self.handleSentMessageResponse(parsedObject)
            
        case BMLTiOSLibCommunicationHandlerSuffixes.AdminLogin.rawValue:
            self.handleLoginResponse((parsedObject as? String)!)
            
        case BMLTiOSLibCommunicationHandlerSuffixes.AdminPermissions.rawValue:
            self.handlePermissionResponse(parsedObject)
            
        case BMLTiOSLibCommunicationHandlerSuffixes.AdminLogout.rawValue:
            self.handleLogoutResponse()
            
        default:
            self.handleCallTypePartTwee(callType, parsedObject: parsedObject, inResponseData: inResponseData)
        }
    }

    /* ################################################################## */
    /**
     The response callback (fourth part to reduce CC). This acts as a dispatcher, calling the appropriate handler.
     
     - parameter inHandler: The handler for this call.
     - parameter parsedObject: The partly-parsed response.
     - parameter inResponseData: The JSON data object. If nil, the call failed to produce. Check the handler's error data member.
     */
    func handleCallTypePartTwee(_ callType: String, parsedObject: AnyObject?, inResponseData: Any) {
        switch callType {  // See what this call wanted us to do.
        case BMLTiOSLibCommunicationHandlerSuffixes.AdminSaveMeetingChanges.rawValue:
            if let savedChanges = parsedObject as? [String: AnyObject?] {
                self.handleMeetingEditSaveResponse(savedChanges)
            } else {
                self.handleCommunicationError(BMLTiOSLibCommunicationHandlerSuffixes.AdminSaveMeetingChanges, inBadData: inResponseData as AnyObject?)
            }
            
        case BMLTiOSLibCommunicationHandlerSuffixes.AdminRestoreDeletedMtg.rawValue:
            if let savedChanges = parsedObject as? [String: AnyObject?] {
                self.handleRestoreMeetingResponse(savedChanges)
            } else {
                self.handleCommunicationError(BMLTiOSLibCommunicationHandlerSuffixes.AdminRestoreDeletedMtg, inBadData: inResponseData as AnyObject?)
            }
            
        default:
            self.handleCallTypeLastPartISwear(callType, parsedObject: parsedObject, inResponseData: inResponseData)
        }
    }

    /* ################################################################## */
    /**
     The response callback (fifth part to reduce CC). This acts as a dispatcher, calling the appropriate handler.
     
     - parameter inHandler: The handler for this call.
     - parameter parsedObject: The partly-parsed response.
     - parameter inResponseData: The JSON data object. If nil, the call failed to produce. Check the handler's error data member.
     */
    func handleCallTypeLastPartISwear(_ callType: String, parsedObject: AnyObject?, inResponseData: Any) {
        switch callType {  // See what this call wanted us to do.
        case BMLTiOSLibCommunicationHandlerSuffixes.GetRestoredMeetingInfo.rawValue:
            if let meetingNodes = parsedObject as? [String: [BMLTiOSLibEditableMeetingNode]] {
                self.handleRestoreMeetingInfoResponse(meetingNodes)
            } else {
                self.handleCommunicationError(BMLTiOSLibCommunicationHandlerSuffixes.GetRestoredMeetingInfo, inBadData: inResponseData as AnyObject?)
            }
            
        case BMLTiOSLibCommunicationHandlerSuffixes.GetRollbackMeetingInfo.rawValue:
            if let meetingNodes = parsedObject as? [String: [BMLTiOSLibEditableMeetingNode]] {
                self.handleRollbackMeetingInfoResponse(meetingNodes)
            } else {
                self.handleCommunicationError(BMLTiOSLibCommunicationHandlerSuffixes.GetRollbackMeetingInfo, inBadData: inResponseData as AnyObject?)
            }
            
        case BMLTiOSLibCommunicationHandlerSuffixes.AdminDeleteMtg.rawValue:
            if let savedChanges = parsedObject as? [String: AnyObject?] {
                self.handleDeletedMeetingResponse(savedChanges)
            } else {
                self.handleCommunicationError(BMLTiOSLibCommunicationHandlerSuffixes.AdminDeleteMtg, inBadData: inResponseData as AnyObject?)
            }
            
        case BMLTiOSLibCommunicationHandlerSuffixes.AdminRollbackMtg.rawValue:
            if let savedChanges = parsedObject as? [String: AnyObject?] {
                self.handleRollbackMeetingResponse(savedChanges)
            } else {
                self.handleCommunicationError(BMLTiOSLibCommunicationHandlerSuffixes.AdminRollbackMtg, inBadData: inResponseData as AnyObject?)
            }
            
        default:
            self.errorDescription = .CommError
        }
    }
}
