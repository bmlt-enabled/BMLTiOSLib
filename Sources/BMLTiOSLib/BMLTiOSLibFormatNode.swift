//
//  BMLTiOSLibFormatNode.swift
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
    private let _rawFormat: [String: String]
    
    /* ################################################################## */
    // MARK: Public Properties
    /* ################################################################## */
    /** This is whatever data the user wants to attach to the node. */
    public var extraData: AnyObject?
    
    /* ################################################################## */
    // MARK: Public Calculated Properties
    /* ################################################################## */
    /**
     - returns: all of the available keys in our dictionary.
     */
    public var keys: [String] {
        return Array(self._rawFormat.keys)
    }
    
    /* ################################################################## */
    /**
     - returns: An optional Int, with the format Shared ID.
     */
    public var id: Int! {
        return Int(self._rawFormat["id"]!)
    }
    
    /* ################################################################## */
    /**
     - returns: An optional String, with the format key.
     */
    public var key: String! {
        return self._rawFormat["key_string"]!
    }
    
    /* ################################################################## */
    /**
     - returns: An optional String, with the format name.
     */
    public var name: String! {
        return self._rawFormat["name_string"]!
    }
    
    /* ################################################################## */
    /**
     - returns: An optional String, with the format description.
     */
    override public var description: String {
        return self._rawFormat["description_string"]!
    }
    
    /* ################################################################## */
    /**
     - returns: An optional String, with the format language indicator.
     */
    public var lang: String! {
        return self._rawFormat["lang"]!
    }
    
    /* ################################################################## */
    /**
     - returns: An optional String, with the format World ID (which may not be available, returning an empty string).
     */
    public var worldID: String! {
        return self._rawFormat["world_id"]!
    }
    
    /* ################################################################## */
    // MARK: Public Initializer
    /* ################################################################## */
    /**
     Default initializer. Initiatlize with raw format data (a simple Dictionary).
     
     - parameter inRawFormat: This is a Dictionary that describes the format.
     */
    public init(_ inRawFormat: [String: String], inExtraData: AnyObject?) {
        self._rawFormat = inRawFormat
        self.extraData = inExtraData
    }
}
