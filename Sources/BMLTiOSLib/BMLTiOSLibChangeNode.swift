//
//  BMLTiOSLibChangeNode.swift
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
    private let _rawObject: [String: AnyObject?]
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
     - returns: The date the change was made.
     */
    public var changeDate: Date! {
        var ret: Date! = nil
        if let epochDateString = self._rawObject["date_int"] as? String {
            if let dateInt = TimeInterval(epochDateString) {
                ret = Date(timeIntervalSince1970: dateInt)
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: The name of the administrator that made the change.
     */
    public var changeMaker: String {
        var ret: String = ""
        if let userName = self._rawObject["user_name"] as? String {
            ret = userName
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: The ID of the change.
     */
    public var id: Int {
        var ret: Int = 0
        if let change_id_string = self._rawObject["change_id"] as? String {
            if let change_id = Int(change_id_string) {
                ret = change_id
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: The Service body to which the changed meeting belongs.
     */
    public var serviceBody: BMLTiOSLibHierarchicalServiceBodyNode! {
        var ret: BMLTiOSLibHierarchicalServiceBodyNode! = nil
        if let sbString = self._rawObject["service_body_id"] {
            if let sbInt = Int((sbString as? String)!) {
                ret = self._handler.getServiceBodyByID(sbInt)
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: True, if the meeting currently exists.
     */
    public var meetingCurrentlyExists: Bool {
        var ret: Bool = false
        if let keyString = self._rawObject["meeting_exists"] as? String {
            ret = "1" == keyString
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: The listed change details.
     */
    public var details: String {
        var ret: String = ""
        if let keyString = self._rawObject["details"] as? String {
            ret = keyString.replacingOccurrences(of: "&quot;", with: "\"").replacingOccurrences(of: "&amp;", with: "&")
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: The listed change meeting ID.
     */
    public var meeting_id: Int {
        var ret: Int = 0
        
        if let idString = self._rawObject["meeting_id"] as? String {
            ret = Int(idString)!
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: True, if the meeting was created by this change.
     */
    public var meetingWasCreated: Bool {
        return nil == self.beforeObject
    }
    
    /* ################################################################## */
    /**
     - returns: True, if the meeting was deleted by this change.
     */
    public var meetingWasDeleted: Bool {
        return nil == self.afterObject
    }
    
    /* ################################################################## */
    /**
     - returns: a Dictionary of changes made, with "before" and "after" values for each changed field.
     
     Each Dictionary entry is described by the field key. The content is a 2-element String Array, with 0 being the "before" value and 1 being the "after" value
     */
    public var meetingWasChanged: [String: [String]]! {
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
    
    /* ################################################################## */
    /**
     - returns: A String, with the change as a textual description.
     */
    override public var description: String {
        var ret: String = ""
        
        let dateformatter = DateFormatter()
        
        dateformatter.dateFormat = "h:mm a MMMM d, yyyy"
        
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
    
    /* ################################################################## */
    // MARK: Public Initializer
    /* ################################################################## */
    /**
     Default initializer
     
     - parameter inDictionary: This is a Dictionary object with the raw JSON response object.
     - parameter inHandler: This is the "owning" BMLTiOSLib object for this change.
     */
    public init(_ inDictionary: [String: AnyObject?], inHandler: BMLTiOSLib) {
        self._rawObject = inDictionary
        self._handler = inHandler
        
        if let beforeAfterJSON = inDictionary["json_data"] as? [String: [String: AnyObject?]] {
            if let beforeObject = beforeAfterJSON["before"] {
                var allStringObject: [String: String] = [:]
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
                var allStringObject: [String: String] = [:]
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
     
     - returns: True, if the reversion was allowed.
     */
    public func revertMeetingToBeforeThisChange() -> Bool {
        if let beforeObject = self.beforeObject {
            if beforeObject.isEditable {
                return (beforeObject as? BMLTiOSLibEditableMeetingNode)!.revertMeetingToBeforeThisChange(self)
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
     
     - returns: True, if the reversion was allowed.
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
