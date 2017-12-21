//
//  BMLTiOSLibChangedMeeting.swift
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
    private let _rawObject: [String: AnyObject?]
    /** This is the "owning" BMLTiOSLib object for this change */
    unowned private let _handler: BMLTiOSLib
    
    /* ################################################################## */
    // MARK: Public Calculated Properties
    /* ################################################################## */
    /**
     - returns: The changed meeting's BMLT ID.
     */
    public var meetingID: Int {
        var ret: Int = 0
        
        if let idContainer = self._rawObject["changeMeeting"] as? [String: String] {
            if let id = idContainer["id"], let idInt = Int(id) {
                ret = idInt
            }
        }
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: All the various field changes associated with this meeting change.
     */
    public var meetingChanges: [String: [String]] {
        var ret: [String: [String]] = [:]
        
        if let fieldsContainer = self._rawObject["field"] as? [String: AnyObject?] {
            if let key = fieldsContainer["key"] as? String {
                if let oldValue = self._rawObject["oldValue"] as? String {
                    if let newValue = self._rawObject["newValue"] as? String {
                        ret[key] = [oldValue, newValue]
                    }
                }
            }
        } else {
            if let fieldsArray = self._rawObject["field"] as? [[String: AnyObject?]] {
                for field in fieldsArray {
                    if let attributes = field["@attributes"] as? [String: String] {
                        if let key = attributes["key"] {
                            if let oldValue = field["oldValue"] as? String {
                                if let newValue = field["newValue"] as? String {
                                    ret[key] = [oldValue, newValue]
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: A textual description of the change.
     */
    override public var description: String {
        var ret: String = "Meeting Change for Meeting ID " + String(self.meetingID)
        
        for key in self.meetingChanges.keys {
            ret += "\n"
            ret += key
            ret += " changed from " + (self.meetingChanges[key]?[0])!
            ret += " to " + (self.meetingChanges[key]?[1])!
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
    }
}
