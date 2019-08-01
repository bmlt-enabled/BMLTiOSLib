//
//  BMLTiOSLibSearchCriteria.swift
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
// MARK: - Search Criteria Class -
/* ###################################################################################################################################### */
/**
 This is a special class that is used to gather and process meeting search criteria.
 
 The way it works, is that it gathers a search state, then creates a URI parameter list to be used by the main communication module.
 It does not do any communication, in itself.
 
 It has been designed so that the search criteria are expressed as properties, instead of functions.
 
 In order to execute searches, the user should access the instance of this class, and use it to set up search criteria. Upon completion of
 this, they should call the main instance's performMeetingSearch(_:) method. The main instance will ask the Search Criteria instance to
 create a URI parameter list that will describe the search.
 */
public class BMLTiOSLibSearchCriteria: NSObject {
    /* ############################################################## */
    // MARK: Public Typealiases
    /* ############################################################## */
    
    /** The idea here is that these are "selectable." They can be assigned a state of "selected," "deselected" or "clear." */
    /** This contains a Service body Dictionary, and is used to make it easy to differentiate the Service bodies from other data types. */
    public typealias SelectableServiceBodyItem = BMLTiOSLibServiceBodyContainer
    /** This is a simple Array of SelectableServiceBodyItem instances. */
    public typealias SelectableServiceBodyList = [SelectableServiceBodyItem]
    
    /** The same for formats. */
    public typealias SelectableFormatItem = BMLTiOSLibFormatContainer
    /** This is a simple Array of SelectableFormatItem instances. */
    public typealias SelectableFormatList = [SelectableFormatItem]
    
    /** This allows us to differentiate weekday objects. */
    public typealias SelectableWeekdayDictionary = [WeekdayIndex: SelectionState]
    
    /** This is used to specify a field, and a value for that field */
    public typealias SpecificFieldValueTuple = (fieldKey: String, value: String, completeMatch: Bool, caseSensitive: Bool)
    
    /* ############################################################## */
    // MARK: Public Enums
    /* ############################################################## */
    /** These are the available selection states for Search Criteria. */
    public enum SelectionState: Int {
        /** This is a "hard NOT". This means that this criteria should state that the associated data item NOT be present. */
        case Deselected = -1
        /** This means "I don't care." It means that the associated item should not be considered in the criteria. */
        case Clear = 0
        /** This is a "hard YES". It means that the associated Criteria item should be present in the Search Criteria. */
        case Selected = 1
    }
    
    /**
     This enum specifies what kind of results we want from the search.
     */
    public enum SearchCriteriaExtent {
        /** Only return Meeting objects. */
        case MeetingsOnly
        /** Only return Format objects (Formats will be only those used in the specific meetings returned in the search). */
        case FormatsOnly
        /** Return both types of objects (The delagate callback will be called for each type). */
        case BothMeetingsAndFormats
    }
    
    /**
     This only applies when we are logged in as an admin. We can search for published, unpublished, or both kinds of meetings.
     Additionally, this only applies to meetings that are under the logged-in admin's control. Meetings outside their control will
     always only show published meetings.
     */
    public enum SearchCriteriaPublishedStatus {
        /** Only show meetings that are marked as "unpublished" (and are also in the control of the logged-in adminstrator). */
        case Unpublished
        /** Only show published meetings. */
        case Published
        /** Show both published and unpublished meetings. */
        case Both
    }
    
    /**
     This is used to index our weekday list.
     */
    public enum WeekdayIndex: Int {
        /** Sunday */
        case Sunday = 1
        /** Monday */
        case Monday
        /** Tuesday */
        case Tuesday
        /** Wednesday */
        case Wednesday
        /** Thursday */
        case Thursday
        /** Friday */
        case Friday
        /** Saturday */
        case Saturday
    }
    
    /* ############################################################## */
    // MARK: Private Properties
    /* ############################################################## */
    /** This is the communication object that "owns" this search criteria. */
    unowned private let _serverComm: BMLTiOSLib
    
    /** These are all various choices we provide for search criteria. */
    private var _serviceBodies: SelectableServiceBodyList
    private var _formats: SelectableFormatList
    private var _weekdays: SelectableWeekdayDictionary = [.Sunday: .Clear, .Monday: .Clear, .Tuesday: .Clear, .Wednesday: .Clear, .Thursday: .Clear, .Friday: .Clear, .Saturday: .Clear]
    private var _searchString: String = ""
    private var _searchIsALocation: Bool = false
    private var _stringSearchAll: Bool = false
    private var _stringSearchExact: Bool = false
    private var _searchRadius: Float = -10
    private var _searchLocation: CLLocationCoordinate2D! = nil
    private var _publishedStatus: SearchCriteriaPublishedStatus = .Both
    private var _specificFieldValue: SpecificFieldValueTuple! = nil
    private var _startTimeInSeconds: Int! = nil
    private var _endTimeInSeconds: Int! = nil
    private var _durationTimeInSeconds: Int! = nil
    private var _meetingsStartBeforeStartTime: Bool = false
    private var _meetingsAreShorterThanDuration: Bool = false
    
    /* ############################################################## */
    // MARK: Internal Methods
    /* ############################################################## */
    /**
     This takes the current search specifier state, and synthesizes a new URI from it.
     
     - parameter inSearchResultType: This specifies exactly what kind of results we are expecting.
     
     - returns: a String, with the synthesized search URI.
     */
    internal func generateSearchURI(_ inSearchResultType: SearchCriteriaExtent) -> String {
        // First, generate the basic URI.
        var ret = ""
        
        switch inSearchResultType {
        case .MeetingsOnly:
            break
            
        case .FormatsOnly:
            ret += "&get_formats_only"
            
        case .BothMeetingsAndFormats:
            ret += "&get_used_formats"
        }
        
        // Next, we need to start adding the specific criteria.
        
        // Start with Service bodies
        
        ret = self.appendServiceBodies(ret)
        
        // Next, we do formats.
        
        ret = self.appendFormats(ret)
        
        // And then weekdays.
        
        ret = self.appendWeekdays(ret)
        
        // Next, look for a search string
        
        ret = self.appendSearchString(ret)
        
        // Let's see if we have a start time specified.
        
        ret = self.appendStartTime(ret)
        
        // Let's see if we have an end time specified.
        
        ret = self.appendEndTime(ret)
        
        // Let's see if we have a duration time specified.
        
        ret = self.appendDurationTime(ret)
        
        // Now, see if we are asking for a specific value of a field.
        
        ret = self.appendFieldValue(ret)
        
        // If we are a logged-in admin, then we can pick our published status.
        if self._serverComm.isAdminLoggedIn {
            ret += "&advanced_published=" + ((.Published == self.publishedStatus) ? "1" : ((.Both == self.publishedStatus) ? "0" : "-1"))
        }
        
        // Return the search parameter list.
        return ret
    }
    
    /* ############################################################## */
    /**
     Append the Service bodies parameter (if any) to the URI.
     
     - parameter retIn: The URI so far.
     
     - returns: The new URI, with (or without) the new parameters.
     */
    internal func appendServiceBodies(_ retIn: String) -> String {
        var ret = retIn
        
        for item in self.serviceBodies where item.selection != .Clear {
            ret += "&services[]="
            if item.selection == .Deselected {
                ret += "-"
            }
            ret += String(item.item.id)
        }
        
        return ret
    }
    
    /* ############################################################## */
    /**
     Append the Formats parameter (if any) to the URI.
     
     - parameter retIn: The URI so far.
     
     - returns: The new URI, with (or without) the new parameters.
     */
    internal func appendFormats(_ retIn: String) -> String {
        var ret = retIn
        
        for item in self.formats where item.selection != .Clear {
            ret += "&formats[]="
            if item.selection == .Deselected {
                ret += "-"
            }
            ret += String(item.item.id)
        }
        
        return ret
    }
    
    /* ############################################################## */
    /**
     Append the Weekdays parameter (if any) to the URI.
     
     - parameter retIn: The URI so far.
     
     - returns: The new URI, with (or without) the new parameters.
     */
    internal func appendWeekdays(_ retIn: String) -> String {
        var ret = retIn
        
        for i in self._weekdays.keys {
            if let weekday = self._weekdays[i] {
                if weekday != .Clear {
                    ret += "&weekdays[]="
                    if weekday == .Deselected {
                        ret += "-"
                    }
                    ret += String(i.rawValue)
                }
            }
        }
        
        return ret
    }
    
    /* ############################################################## */
    /**
     Append the Search String (and other modifiers) parameter (if any) to the URI.
     
     - parameter retIn: The URI so far.
     
     - returns: The new URI, with (or without) the new parameters.
     */
    internal func appendSearchString(_ retIn: String) -> String {
        var ret = retIn
        
        var isSearchString: Bool = false    // If the location is determined by a string geocode, then we use a different radius parameter.
        
        if !self._searchString.isEmpty {
            ret += "&SearchString="
            ret += self._searchString.URLEncodedString()!
            // If this is a location string, then we set the flag, and ignore the other two flags.
            if self._searchIsALocation {
                isSearchString = true
                ret += "&StringSearchIsAnAddress=1"
            } else {
                if self._stringSearchExact {
                    ret += "&SearchStringExact=1"
                }
                if self._stringSearchAll {
                    ret += "&SearchStringAll=1"
                }
            }
        }
        
        // Next, see if a location was specified. This is ignored if a location search string was provided.
        
        if !(!self._searchString.isEmpty && self._searchIsALocation) && (nil != self._searchLocation) {
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 12
            formatter.decimalSeparator = "."
            ret += "&lat_val=" + formatter.string(from: self._searchLocation.latitude as NSNumber)!
            ret += "&long_val=" + formatter.string(from: self._searchLocation.longitude as NSNumber)!
        }
        
        // Next, check the search radius. This is ignored if there is no search center or location string.
        
        if ((!self._searchString.isEmpty && self._searchIsALocation) || (nil != self._searchLocation)) && (0 != self._searchRadius) {
            let radius: Float = self._searchRadius
            
            if isSearchString { // We use this parameter if it's a search string.
                ret += "&SearchStringRadius="
            } else {    // If we are doing a long/lat search, we use the geo_width parameter.
                if NSLocale.current.usesMetricSystem {
                    ret += "&geo_width_km="
                } else {
                    ret += "&geo_width="
                }
            }
            
            if 0 > radius {
                ret += String(format: "-%d", abs(Int(radius)))
            } else {
                ret += String(format: "%.4g", radius)
            }
        }
        
        return ret
    }
    
    /* ############################################################## */
    /**
     Append the Start Time parameter (if any) to the URI.
     
     - parameter retIn: The URI so far.
     
     - returns: The new URI, with (or without) the new parameters.
     */
    internal func appendStartTime(_ retIn: String) -> String {
        var ret = retIn
        
        if nil != self.startTimeInSeconds {
            var minutes: Int = Int(self.startTimeInSeconds!) / 60
            let hours: Int = (minutes / 60)
            minutes -= (hours * 60)
            
            if 0 < hours {
                ret += (self.meetingsStartBeforeStartTime ? "&StartsBeforeH=" : "&StartsAfterH=")
                ret += String(hours)
            }
            
            if 0 < minutes {
                ret += (self.meetingsStartBeforeStartTime ? "&StartsBeforeM=" : "&StartsAfterM=")
                ret += String(minutes)
            }
        }
        
        return ret
    }
    
    /* ############################################################## */
    /**
     Append the End Time parameter (if any) to the URI.
     
     - parameter retIn: The URI so far.
     
     - returns: The new URI, with (or without) the new parameters.
     */
    internal func appendEndTime(_ retIn: String) -> String {
        var ret = retIn
        
        if nil != self.endTimeInSeconds {
            var minutes: Int = Int(self.endTimeInSeconds!) / 60
            let hours: Int = (minutes / 60)
            minutes -= (hours * 60)
            
            if 0 < hours {
                ret += ("&EndsBeforeH=" + String(hours))
            }
            
            if 0 < minutes {
                ret += ("&EndsBeforeM=" + String(minutes))
            }
        }
        
        return ret
    }
    
    /* ############################################################## */
    /**
     Append the Duration Time parameter (if any) to the URI.
     
     - parameter retIn: The URI so far.
     
     - returns: The new URI, with (or without) the new parameters.
     */
    internal func appendDurationTime(_ retIn: String) -> String {
        var ret = retIn
        
        if nil != self.durationTimeInSeconds {
            let hours: Int = Int(self.durationTimeInSeconds! / 3600)
            let minutes: Int = Int(self.durationTimeInSeconds! - (hours * 3600)) / 60
            
            if 0 < hours {
                ret += (self.meetingsAreShorterThanDuration ? "&MaxDurationH=" : "&MinDurationH=")
                ret += String(hours)
            }
            
            if 0 < minutes {
                ret += (self.meetingsAreShorterThanDuration ? "&MaxDurationM=" : "&MinDurationM=")
                ret += String(minutes)
            }
        }
        
        return ret
    }
    
    /* ############################################################## */
    /**
     Append the Value of a selected field parameter (if any) to the URI.
     
     - parameter retIn: The URI so far.
     
     - returns: The new URI, with (or without) the new parameters.
     */
    internal func appendFieldValue(_ retIn: String) -> String {
        var ret = retIn
        
        if (nil != self._specificFieldValue) && !self._specificFieldValue!.fieldKey.isEmpty {
            ret += "&meeting_key=" + self._specificFieldValue!.fieldKey.URLEncodedString()!
            ret += "&meeting_key_value=" + self._specificFieldValue!.value.URLEncodedString()!
            if self._specificFieldValue!.caseSensitive {
                ret += "&meeting_key_match_case=1"
            }
            
            if self._specificFieldValue!.completeMatch {
                ret += "&meeting_key_contains=0"
            }
        }
        
        return ret
    }
    
    /* ############################################################## */
    // MARK: Public Calculated Properties
    /* ############################################################## */
    /**
     Accessor for our internal Published Status.
     
     - returns: whether we want published, unpublished, or both.
     */
    public var publishedStatus: SearchCriteriaPublishedStatus {
        get { return self._publishedStatus }
        set { self._publishedStatus = newValue }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal Service body list.
     
     - returns: the selected/unselected Service bodies, in a linear list.
     */
    public var serviceBodies: SelectableServiceBodyList {
        return self._serviceBodies
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal format list.
     
     - returns: The selected/unselected formats.
     */
    public var formats: SelectableFormatList {
        return self._formats
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal weekday list.
     
     - returns the selected/unselected weekdays.
     */
    public var weekdays: SelectableWeekdayDictionary {
        get { return self._weekdays }
        set { self._weekdays = newValue }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal search radius value.
     
     - returns: the search radius. negative integer values are auto-search thresholds. Positive floating point is dependent upon the measurement units selected by the user.
     */
    public var searchRadius: Float {
        get { return self._searchRadius }
        set { self._searchRadius = newValue }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal Search String.
     
     - returns: the string we are looking for.
     */
    public var searchString: String {
        get { return self._searchString }
        set { self._searchString = newValue }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal Search String Is a Location selector.
     
     NOTE: If this is specified, and a string is provided in searchString, then searchLocation is ignored.
     
     - returns: true, if the string is to be interpreted as a location.
     */
    public var searchStringIsALocation: Bool {
        get { return self._searchIsALocation }
        set { self._searchIsALocation = newValue }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal Search String is Exact selector
     
     - returns: true, if the string should be parsed strictly (no metaphone).
     */
    public var stringSearchIsExact: Bool {
        get { return self._stringSearchExact }
        set { self._stringSearchExact = newValue }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal Search String Uses all Substrings selector
     
     - returns: true, if the match needs to go across all strings.
     */
    public var stringSearchUsesAllStrings: Bool {
        get { return self._stringSearchAll }
        set { self._stringSearchAll = newValue }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal center location selector.
     
     NOTE: This is ignored if searchStringIsALocation is true, and we have a search string in searchString.
     
     - returns: the search center, as a Location manager 2D coordinate.
     */
    public var searchLocation: CLLocationCoordinate2D! {
        get { return self._searchLocation }
        set { self._searchLocation = newValue }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal specific field value search criteria.
     
     - returns: an optional tuple, with the various field criteria, or nil
     */
    public var specificFieldSearch: SpecificFieldValueTuple? {
        get { return self._specificFieldValue }
        set { self._specificFieldValue = newValue }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal start time (in seconds from midnight -00:00:00) search criteria.
     This is an inclusive time, and includes 24:00:00 (end of day midnight).
     
     - returns: an optional int, with seconds from Midnight, or nil
     */
    public var startTimeInSeconds: Int? {
        get { return self._startTimeInSeconds }
        set { self._startTimeInSeconds = newValue }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal meeting end time (in seconds from midnight -00:00:00) search criteria.
     This is an inclusive time, and includes 24:00:00 (end of day midnight).
     
     - returns: an optional int, with seconds from Midnight, or nil
     */
    public var endTimeInSeconds: Int? {
        get { return self._endTimeInSeconds }
        set { self._endTimeInSeconds = newValue }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal duration (in seconds) search criteria.
     
     - returns: an optional int, with seconds, or nil
     */
    public var durationTimeInSeconds: Int? {
        get { return self._durationTimeInSeconds }
        set { self._durationTimeInSeconds = newValue }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal meetings should begin before (or at) start time flag.
     
     - returns: a Bool, true if the meeting should start before or on the start time, or false, if the meeting is to start at or after the start time.
     */
    public var meetingsStartBeforeStartTime: Bool {
        get { return self._meetingsStartBeforeStartTime }
        set { self._meetingsStartBeforeStartTime = newValue }
    }
    
    /* ############################################################## */
    /**
     Accessor for our internal meetings should be shorter than the duration flag.
     
     - returns: a Bool, true if the meeting should be shorter than (or equal to) the duration time, or false, if the meeting is equal to, or longer than, the duration.
     */
    public var meetingsAreShorterThanDuration: Bool {
        get { return self._meetingsAreShorterThanDuration }
        set { self._meetingsAreShorterThanDuration = newValue }
    }
    
    /* ############################################################## */
    /**
     An easy way to test or set a minimum starting time for meetings.
     
     - returns: an optional NSDateComponents. If not nil, will contain the minimum start time for meetings.
     */
    public var meetingsShouldStartAtOrAfter: NSDateComponents? {
        get {
            var ret: NSDateComponents! = nil
            
            if (nil != self.startTimeInSeconds) && !self.meetingsStartBeforeStartTime {
                ret = NSDateComponents()
                
                ret.hour = (self.startTimeInSeconds! / 3600)
                ret.minute = self.startTimeInSeconds! - (ret.hour * 3600)
                ret.second = self.startTimeInSeconds! - ((ret.hour * 3600) + (ret.minute * 60))
            }
            
            return ret
        }
        
        set {
            self.meetingsStartBeforeStartTime = false
            self.startTimeInSeconds = nil
            if nil != newValue {
                let hours = (nil != newValue?.hour) ? newValue!.hour : 0
                let minutes = (nil != newValue?.minute) ? newValue!.minute : 0
                let seconds = (nil != newValue?.second) ? newValue!.second : 0
                self.startTimeInSeconds = (hours * 3600) + (minutes * 60) + seconds
            }
        }
    }
    
    /* ############################################################## */
    /**
     An easy way to test or set a maximum starting time for meetings.
     
     - returns: an optional NSDateComponents. If not nil, will contain the maximum start time for meetings.
     */
    public var meetingsShouldStartBeforeOrAt: NSDateComponents? {
        get {
            var ret: NSDateComponents! = nil
            
            if (nil != self.startTimeInSeconds) && self.meetingsStartBeforeStartTime {
                ret = NSDateComponents()
                
                ret.hour = (self.startTimeInSeconds! / 3600)
                ret.minute = self.startTimeInSeconds! - (ret.hour * 3600)
                ret.second = self.startTimeInSeconds! - ((ret.hour * 3600) + (ret.minute * 60))
            }
            
            return ret
        }
        
        set {
            self.meetingsStartBeforeStartTime = true
            self.startTimeInSeconds = nil
            if nil != newValue {
                self.startTimeInSeconds = (newValue!.hour * 3600) + (newValue!.minute * 60) + newValue!.second
            }
        }
    }
    
    /* ############################################################## */
    /**
     An easy way to test or set a minimum duration time for meetings.
     
     - returns: an optional NSDateComponents. If not nil, will contain the minimum duration for meetings.
     */
    public var meetingsAreAtLeast: NSDateComponents? {
        get {
            var ret: NSDateComponents! = nil
            
            if (nil != self.durationTimeInSeconds) && !self.meetingsAreShorterThanDuration {
                ret = NSDateComponents()
                
                ret.hour = (self.durationTimeInSeconds! / 3600)
                ret.minute = self.durationTimeInSeconds! - (ret.hour * 3600)
                ret.second = self.durationTimeInSeconds! - ((ret.hour * 3600) + (ret.minute * 60))
            }
            
            return ret
        }
        
        set {
            self.meetingsAreShorterThanDuration = false
            self.durationTimeInSeconds = nil
            if nil != newValue {
                self.durationTimeInSeconds = (newValue!.hour * 3600) + (newValue!.minute * 60) + newValue!.second
            }
        }
    }
    
    /* ############################################################## */
    /**
     An easy way to test or set a maximum duration time for meetings.
     
     - returns: an optional NSDateComponents. If not nil, will contain the maximum duration for meetings.
     */
    public var meetingsAreNoLongerThan: NSDateComponents? {
        get {
            var ret: NSDateComponents! = nil
            
            if (nil != self.durationTimeInSeconds) && self.meetingsAreShorterThanDuration {
                ret = NSDateComponents()
                
                ret.hour = (self.durationTimeInSeconds! / 3600)
                ret.minute = self.durationTimeInSeconds! - (ret.hour * 3600)
                ret.second = self.durationTimeInSeconds! - ((ret.hour * 3600) + (ret.minute * 60))
            }
            
            return ret
        }
        
        set {
            self.meetingsAreShorterThanDuration = true
            self.durationTimeInSeconds = nil
            if nil != newValue {
                self.durationTimeInSeconds = (newValue!.hour * 3600) + (newValue!.minute * 60) + newValue!.second
            }
        }
    }
    
    /* ############################################################## */
    /**
     An easy way to test or set a maximum end time for meetings.
     
     - returns: an optional NSDateComponents. If not nil, will contain the maximum end time for meetings.
     */
    public var meetingsEndOnOrBefore: NSDateComponents? {
        get {
            var ret: NSDateComponents! = nil
            
            if nil != self.endTimeInSeconds {
                ret = NSDateComponents()
                
                ret.hour = (self.endTimeInSeconds! / 3600)
                ret.minute = self.endTimeInSeconds! - (ret.hour * 3600)
                ret.second = self.endTimeInSeconds! - ((ret.hour * 3600) + (ret.minute * 60))
            }
            
            return ret
        }
        
        set {
            self.endTimeInSeconds = nil
            if nil != newValue {
                self.endTimeInSeconds = (newValue!.hour * 3600) + (newValue!.minute * 60) + newValue!.second
            }
        }
    }
    
    /* ############################################################## */
    /**
     - returns: true, if there is a search criteria set.
     */
    public var isDirty: Bool {
        var ret: Bool = false
        
        for sb in self._serviceBodies {
            ret = (sb.selection != .Clear) ? true : ret
        }
        
        for fmt in self._formats {
            ret = (fmt.selection != .Clear) ? true : ret
        }
        
        for wd in self._weekdays {
            ret = (wd.value != .Clear) ? true : ret
        }
        
        if !self._searchString.isEmpty {
            ret = true
        }
        
        if nil != self._searchLocation {
            ret = true
        }
        
        if nil != self._startTimeInSeconds {
            ret = true
        }
        
        if nil != self._endTimeInSeconds {
            ret = true
        }
        
        if nil != self._durationTimeInSeconds {
            ret = true
        }
        
        if (nil != self._specificFieldValue) && !self._specificFieldValue!.fieldKey.isEmpty {
            ret = true
        }
        
        // Let's see if we have a start time specified.
        
        if nil != self.startTimeInSeconds {
            ret = true
        }
        
        // Let's see if we have an end time specified.
        
        if nil != self.endTimeInSeconds {
            ret = true
        }
        
        // Let's see if we have a duration time specified.
        
        if nil != self.durationTimeInSeconds {
            ret = true
        }
        
        return ret
    }
    
    /* ############################################################## */
    // MARK: Public Initializer
    /* ############################################################## */
    /**
     Default initializer. We must have at least the server comm.
     
     - parameter inServerComm: This is a reference to the BMLTiOSLib instance that "owns" this.
     */
    public init(_ inServerComm: BMLTiOSLib) {
        self._serverComm = inServerComm
        self._serviceBodies = []
        self._formats = []
        
        for sb in inServerComm.serviceBodies {
            let wrapper: SelectableServiceBodyItem = SelectableServiceBodyItem(item: sb, selection: .Clear, extraData: nil)
            self._serviceBodies.append(wrapper)
        }
        
        for fm in inServerComm.allPossibleFormats {
            let wrapper: SelectableFormatItem = SelectableFormatItem(item: fm, selection: .Clear, extraData: nil)
            self._formats.append(wrapper)
        }
        
        super.init()
    }
    
    /* ############################################################## */
    // MARK: Public Instance Methods
    /* ############################################################## */
    /**
     Make sure we completely deallocate our selectable lists.
     */
    public func clearStorage() {
        self._formats.removeAll()
        self._serviceBodies.removeAll()
        self.clearAll()
    }
    
    /* ############################################################## */
    /**
     This resets all search criteria to default.
     */
    public func clearAll() {
        for i in 0..<self._serviceBodies.count {
            self._serviceBodies[i].selection = .Clear
        }
        
        for i in 0..<self._formats.count {
            self._formats[i].selection = .Clear
        }
        
        for key in self._weekdays.keys {
            self._weekdays[key] = .Clear
        }
        
        self._searchRadius = -10
        self._searchString = ""
        self._searchIsALocation = false
        self._stringSearchAll = false
        self._stringSearchExact = false
        self._searchLocation = nil
    }
    
    /* ############################################################## */
    /**
     This returns the selection object for a given Service body object.
     - parameter inObject: The Service body object we are matching.
     - returns: the wrapper item for that Service body object.
     */
    public func getServiceBodyElementFromServiceBodyObject(_ inObject: BMLTiOSLibHierarchicalServiceBodyNode) -> SelectableServiceBodyItem! {
        for item in self.serviceBodies where item.item == inObject {
            return item
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     This tells our BMLTiOSLib instance to perform a meeting search, based on our current criteria.
     
     - parameter inSearchResultsType: The type of result[s] you'd like. Defaults to both meetings and formats.
     */
    public func performMeetingSearch(_ inSearchResultsType: BMLTiOSLibSearchCriteria.SearchCriteriaExtent = .BothMeetingsAndFormats) {
        self._serverComm.performMeetingSearch(inSearchResultsType)
    }
}
