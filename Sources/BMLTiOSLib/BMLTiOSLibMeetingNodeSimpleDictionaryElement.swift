//
//  BMLTiOSLibMeetingNodeSimpleDictionaryElement.swift
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
        return self.handler._handler
    }
    
    /* ################################################################## */
    // MARK: Public Initializer
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
