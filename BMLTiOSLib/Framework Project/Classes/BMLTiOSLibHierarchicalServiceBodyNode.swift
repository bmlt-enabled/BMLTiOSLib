//
//  BMLTiOSLibHierarchicalServiceBodyNode.swift
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
    public var serviceBody: [String: String]! = nil
    /** An array of "child" nodes. May be empty, if we are a "leaf." */
    public var children: [BMLTiOSLibHierarchicalServiceBodyNode] = []
    /** This is whatever data the user wants to attach to the node. */
    public var extraData: AnyObject?
    
    /* ################################################################## */
    // MARK: Public Calculated Properties.
    /* ################################################################## */
    /**
     - returns: all of the available keys in our dictionary.
     */
    public var keys: [String] {
        return Array(self.serviceBody.keys)
    }
    
    /* ################################################################## */
    /**
     - returns: the Service body ID as an Int. If there is no ID, it returns 0 (Should never happen).
     */
    public var id: Int {
        if let ret1 = self.serviceBody["id"] {
            if let id = Int(ret1) {
                return id
            }
        }
        
        return 0
    }
    
    /* ################################################################## */
    /**
     - returns: the Service body name as a String. If there is no name, it returns blank.
     */
    public var name: String {
        if let name = self.serviceBody["name"] {
            return name
        }
        
        return ""
    }
    
    /* ################################################################## */
    /**
     - returns: the Service body description as a String. If there is no description, it returns the name.
     */
    override public var description: String {
        if let description = self.serviceBody["description"] {
            if description.isEmpty {
                return self.name
            }
            return description
        }
        
        return ""
    }
    
    /* ################################################################## */
    /**
     - returns: If we are logged in as an admin, and have administrator rights for this Service body, we get a true.
     */
    public var iCanAdminister: Bool {
        return BMLTiOSLibPermissions.Administrator.rawValue == self.permissions.rawValue
    }
    
    /* ################################################################## */
    /**
     - returns: If we are logged in as an admin, and have edit rights for this Service body, we get a true.
     */
    public var iCanEdit: Bool {
        return BMLTiOSLibPermissions.Editor.rawValue <= self.permissions.rawValue
    }
    
    /* ################################################################## */
    /**
     - returns: If we are logged in as an admin, and have observer rights for this Service body, we get a true.
     */
    public var iCanObserve: Bool {
        return BMLTiOSLibPermissions.Observer.rawValue <= self.permissions.rawValue
    }
    
    /* ################################################################## */
    /**
     - returns: If we are logged in as an admin, this will indicate the level of permission we have with this Service body.
     */
    public var permissions: BMLTiOSLibPermissions {
        return self.serverComm.permissions(forServiceBody: self)
    }
    
    /* ################################################################## */
    /**
     - returns: true, if we have a parent.
     */
    public var hasParent: Bool {
        return nil != self.parent
    }
    
    /* ################################################################## */
    /**
     - returns: true, if we have children.
     */
    public var hasChildren: Bool {
        return !self.children.isEmpty
    }
    
    /* ################################################################## */
    /**
     - returns: the total number of children, including children of children, etc.
     */
    public var completeChildCount: Int {
        var ret: Int = 0
        
        if !self.children.isEmpty {
            for shorty in self.children {
                ret += (1 + shorty.completeChildCount)
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: how many levels down we are. 0 is top-level (no parent).
     */
    public var howDeepInTheRabbitHoleAmI: Int {
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
    public init(inServerComm: BMLTiOSLib, parent: BMLTiOSLibHierarchicalServiceBodyNode!, serviceBody: [String: String]!, children: [BMLTiOSLibHierarchicalServiceBodyNode]) {
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
     
     - returns: true, if the node is somewhere in our woodpile.
     */
    public func isInHierarchy(_ inSBNode: BMLTiOSLibHierarchicalServiceBodyNode) -> Bool {
        return self.isSBIDInHierarchy(inSBNode.id)
    }
    
    /* ################################################################## */
    /**
     This checks a given Service Body node by its ID, and sees if it is in the hierarchy.
     
     - parameter inID: the integer ID of the Service body to check.
     
     - returns: true, if the ID represents a Service body somewhere in our woodpile.
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
