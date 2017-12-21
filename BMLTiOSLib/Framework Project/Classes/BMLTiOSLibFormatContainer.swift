//
//  BMLTiOSLibFormatContainer.swift
//  BMLTiOSLib
//
//  Created by MAGSHARE
//
//  https: //bmlt.magshare.net/bmltioslib/
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
