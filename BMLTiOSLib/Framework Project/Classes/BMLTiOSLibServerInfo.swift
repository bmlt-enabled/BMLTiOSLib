//
//  BMLTiOSLibServerInfo.swift
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
import CoreLocation

/* ###################################################################################################################################### */
// MARK: - Internal Server Info Class -
/* ###################################################################################################################################### */
/**
 This class will present a functional interface to the server info.
 */
internal class BMLTiOSLibServerInfo {
    let _serverInfoDictionary: [String: String]
    
    /* ################################################################## */
    // MARK: Calculated Properties
    /* ################################################################## */
    /**
     This allows the instance to be treated like a standard Dictionary.
     
     - parameter inString: This is the Dictionary key.
     */
    subscript(_ inString: String) -> String? {
        if let value = self._serverInfoDictionary[inString] {
            return value
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     - returns:  an Array of String, with each element being an info element key.
     */
    var available_keys: [String] {
        if let keyString = self["available_keys"] {
            return keyString.components(separatedBy: ",")
        }
        
        return []
    }
    
    /* ################################################################## */
    /**
     - returns:  The Server's central location, as a MapKit CLLocationCorrdinate2D object.
     */
    var centerLocation: CLLocationCoordinate2D {
        if let lat = self["centerLatitude"] {
            if let lng = self["centerLongitude"] {
                let latFloat: Float = Float(lat)!
                let lngFloat: Float = Float(lng)!
                return CLLocationCoordinate2DMake(CLLocationDegrees(latFloat), CLLocationDegrees(lngFloat))
            }
        }
        
        return CLLocationCoordinate2D()
    }
    
    /* ################################################################## */
    /**
     - returns:  The Server default zoom level.
     */
    var centerZoom: Float {
        if let zoom = self["centerZoom"] {
            return Float(zoom)!
        }
        
        return 0
    }
    
    /* ################################################################## */
    /**
     - returns:  The number of changes per meeting.
     */
    var changesPerMeeting: Int {
        if let value = self["changesPerMeeting"] {
            return Int(value)!
        }
        
        return 0
    }
    
    /* ################################################################## */
    /**
     - returns:  The Server character set.
     */
    var charSet: String {
        if let value = self["charSet"] {
            return value
        }
        
        return ""
    }
    
    /* ################################################################## */
    /**
     - returns:  An Integer, with the duration in minutes.
     */
    var defaultDurationInMinutes: Int {
        var ret: Int = 0
        
        let timeComponents = self["defaultDuration"]?.components(separatedBy: ": ").map { Int($0) }
        if let hours = timeComponents![0] {
            ret = hours * 60
        }
        if let minutes = timeComponents![0] {
            ret += minutes
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns:  The distance measurement units, as an enum
     */
    var distanceUnits: BMLTiOSLibDistanceUnits {
        if let value = self["distanceUnits"] {
            if let ret = BMLTiOSLibDistanceUnits(rawValue: value) {
                return ret
            }
        }
        
        return .Error
    }
    
    /* ################################################################## */
    /**
     - returns:  The distance measurement units, as a String
     */
    var distanceUnitsString: String {
        if let value = self["distanceUnitsString"] {
            return value
        }
        
        return ""
    }
    
    /* ################################################################## */
    /**
     - returns:  True, if emailing meeting contacts is enabled.
     */
    var emailEnabled: Bool {
        if let value = self["emailEnabled"] {
            return "0" != value
        }
        
        return false
    }
    
    /* ################################################################## */
    /**
     - returns:  True, if also sending to Service Body Admins is enabled.
     */
    var emailIncludesServiceBodies: Bool {
        if let value = self["emailIncludesServiceBodies"] {
            return "0" != value
        }
        
        return false
    }
    
    /* ################################################################## */
    /**
     - returns:  The Root Server Google API key.
     */
    var google_api_key: String {
        if let value = self["google_api_key"] {
            return value
        }
        
        return ""
    }
    
    /* ################################################################## */
    /**
     - returns:  an Array of String, with each element being a language key.
     */
    var langs: [String] {
        if let keyString = self["langs"] {
            return keyString.components(separatedBy: ",")
        }
        
        return []
    }
    
    /* ################################################################## */
    /**
     - returns:  a String, with the key for the Server default language.
     */
    var nativeLang: String {
        if let value = self["nativeLang"] {
            return value
        }
        
        return ""
    }
    
    /* ################################################################## */
    /**
     - returns:  any Region bias.
     */
    var regionBias: String {
        if let value = self["regionBias"] {
            return value
        }
        
        return ""
    }
    
    /* ################################################################## */
    /**
     - returns:  True, if Semantic Administration has been enabled for this server.
     */
    var semanticAdmin: Bool {
        if let value = self["semanticAdmin"] {
            return "0" != value
        }
        
        return false
    }
    
    /* ################################################################## */
    /**
     - returns:  The server version, as a String ("X.Y.Z").
     */
    var version: String {
        if let value = self["version"] {
            return value
        }
        
        return ""
    }
    
    /* ################################################################## */
    /**
     - returns:  The server version, as an Int (XYYYZZZ).
     */
    var versionInt: Int {
        if let value = self["versionInt"] {
            let ret = Int(value)
            return ret!
        }
        
        return 0
    }
    
    /* ################################################################## */
    /**
     : returns the basic description of this object.
     */
    var description: String {
        return self._serverInfoDictionary.description
    }
    
    /* ################################################################## */
    // MARK: Initializer
    /* ################################################################## */
    /**
     Default initializer. Initiatlize with raw format data (a simple Dictionary).
     
     - parameter inServerInfo: This is a Dictionary that contains the info returned from the server.
     */
    init(_ inServerInfo: [String: String]) {
        self._serverInfoDictionary = inServerInfo
    }
}
