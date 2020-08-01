//
//  BMLTiOSLibServerLang.swift
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
// MARK: - Server Language Class -
/* ###################################################################################################################################### */
/**
 This class will present a functional interface to the server languages.
 */
public class BMLTiOSLibServerLang: NSObject {
    /* ################################################################## */
    // MARK: Private Properties
    /* ################################################################## */
    private let _serverInfoDictionary: [String: String]
    
    /* ################################################################## */
    // MARK: Public Calculated Properties
    /* ################################################################## */
    /**
     This allows the class to be treated like a standard Dictionary.
     
     - returns: the Server Info element, as a String.
     */
    public subscript(_ inString: String) -> String! {
        if let value = self._serverInfoDictionary[inString] {
            return value
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     - returns: the language key.
     */
    public var langKey: String {
        if let keyString = self["key"] {
            return keyString
        }
        
        return ""
    }
    
    /* ################################################################## */
    /**
     - returns: the language name.
     */
    public var langName: String {
        if let nameString = self["name"] {
            return nameString
        }
        
        return ""
    }
    
    /* ################################################################## */
    /**
     :returns true, if this is the default Server language.
     */
    public var isDefault: Bool {
        if let defString = self["default"] {
            return "0" != defString
        }
        
        return false
    }
    
    /* ################################################################## */
    // MARK: Public Initializer
    /* ################################################################## */
    /**
     Simple direct initializer.
     - parameter inLang: This is a Dictionary that contains the info returned from the server.
     */
    public init(_ inLang: [String: String]) {
        self._serverInfoDictionary = inLang
        super.init()
    }
}
