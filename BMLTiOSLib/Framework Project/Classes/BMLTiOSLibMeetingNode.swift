//
//  BMLTiOSLibMeetingNode.swift
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
// MARK: - String Extension for Uppercasing -
/* ###################################################################################################################################### */
/**
 This extension lets us uppercase only the first letter of the string (used for weekdays).
 From here: https://stackoverflow.com/a/28288340/879365
 */
extension String {
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
}

/* ###################################################################################################################################### */
// MARK: - Meeting Class -
/* ###################################################################################################################################### */
/**
 This is a special "micro class" for accessing the meetings for a Server.
 */
public class BMLTiOSLibMeetingNode: NSObject, Sequence {
    /* ################################################################## */
    // MARK: Private Properties
    /* ################################################################## */
    /**
     This tells us whether or not the device is set for military time.
     */
    private var _using12hClockFormat: Bool {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        let dateString = formatter.string(from: Date())
        let amRange = dateString.range(of: formatter.amSymbol)
        let pmRange = dateString.range(of: formatter.pmSymbol)
        
        return !(pmRange == nil && amRange == nil)
    }
    
    /* ################################################################## */
    // MARK: Public Subscript
    /* ################################################################## */
    /**
     This allows us to treat the meeting as if it were a standard Dictionary.
     
     - parameter inStringKey: This is a String key to access the meeting data element.
     */
    public subscript(_ inStringKey: String) -> String! {
        if "formats" == inStringKey {
            return self.formatsAsCSVList    // We make sure we reorder this, so we are consistent.
        } else {
            return self._rawMeeting[inStringKey]
        }
    }
    
    /* ################################################################## */
    // MARK: Internal Static Class Variables
    /* ################################################################## */
    /**
     This is a default placeholder for new (unnammed) meetings.
     */
    private static let BMLTiOSLib_DefaultMeetingNameString = "BMLTiOSLib-Default-Meeting-Name"
    
    /**
     This is a default placeholder for new meetings.
     */
    private static let BMLTiOSLib_DefaultMeetingStartTime = "22:00:00"
    
    /**
     This is a default placeholder for new meetings.
     */
    private static let BMLTiOSLib_DefaultMeetingDurationTime = "01:00:00"
    
    /**
     This is a default placeholder for new meetings.
     */
    private static let BMLTiOSLib_DefaultMeetingWeekday = "1"
    
    /* ################################################################## */
    // MARK: Internal Properties
    /* ################################################################## */
    /** This will contain the "raw" meeting data. It isn't meant to be exposed. */
    private var _rawMeeting: [String: String]
    
    /* ################################################################## */
    // MARK: Internal Methods
    /* ################################################################## */
    /**
     This parses the meeting data, and creates a fairly basic, straightforward, US-type address.
     
     - returns: A String, with a basic address, in US format.
     */
    private var _USAddressParser: String {
        var ret: String = ""    // We will build this string up from location information.
        
        let name = self.locationName
        let street = self.locationStreetAddress
        let borough = self.locationBorough
        let town = self.locationTown
        let state = self.locationState
        let zip = self.locationZip
        
        if !name.isEmpty {  // We check each field to make sure it isn't empty.
            ret = name
        }
        
        if !street.isEmpty {
            if !ret.isEmpty {
                ret += ", "
            }
            ret += street
        }
        
        // Boroughs are treated a bit differently, as they are often the primary address for a given city area.
        if !borough.isEmpty {
            if !ret.isEmpty {
                ret += ", "
            }
            ret += borough
            if !town.isEmpty {
                ret += " (" + town + ")"
            }
        } else {
            if !town.isEmpty {
                if !ret.isEmpty {
                    ret += ", "
                }
                ret += town
            }
        }
        
        if !state.isEmpty {
            if !ret.isEmpty {
                ret += ", "
            }
            ret += state
        }
        
        if !zip.isEmpty {
            if !ret.isEmpty {
                ret += " "
            }
            ret += zip
        }
        
        return ret
    }
    
    /** These are the standard keys that all meeting objects should have available (They may not all be filled, though). */
    internal static let standardKeys = ["id_bigint", "service_body_bigint", "weekday_tinyint", "start_time", "duration_time", "formats", "longitude", "latitude", "meeting_name", "location_text", "location_info", "location_street", "location_city_subsection", "location_neighborhood", "location_municipality", "location_sub_province", "location_province", "location_postal_code_1", "comments"]
    
    /** This is the library object that "owns" this instance. */
    weak internal var _handler: BMLTiOSLib! = nil
    
    /* ################################################################## */
    // MARK: Public Properties
    /* ################################################################## */
    /** This will contain any changes that are associated with this meeting. */
    public var changes: [BMLTiOSLibChangeNode]! = nil
    
    /* ################################################################## */
    // MARK: Public Calculated Properties
    /* ################################################################## */
    /** This class is not editable. */
    public var isEditable: Bool {
        return false
    }
    
    /* ################################################################## */
    /**
     Returns a sorted list of the value array keys. It sorts the "default" ones first.
     - returns: all of the available keys in our dictionary.
     */
    public var keys: [String] {
        var sortOrder = type(of: self).standardKeys
        
        sortOrder.append("published")
        
        let meetingKeys = self.rawMeeting.keys.sorted()
        
        var key_array: [String] = []
        
        for key in sortOrder {
            if meetingKeys.contains(key) {
                key_array.append(key)
            }
        }
        
        for key in meetingKeys {
            if !key_array.contains(key) {
                key_array.append(key)
            }
        }
        
        return key_array
    }
    
    /* ################################################################## */
    /**
     - returns: Our internal editable instance instead of the read-only one for the superclass.
     */
    public var rawMeeting: [String: String] {
        get { return self._rawMeeting }
        set {
            if self.isEditable {
                self._rawMeeting = newValue
            }
        }
    }
    
    /* ################################################################## */
    /**
     - returns: An Int, with the meeting BMLT ID.
     */
    public var id: Int {
        var ret: Int = 0
        
        if let val = Int(self["id_bigint"]) {
            ret = val
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: A String, with the meeting NAWS ID.
     */
    public var worldID: String {
        var ret: String = ""
        
        if let val = self["worldid_mixed"] {
            ret = val
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: An Int, with the meeting's Service body BMLT ID.
     */
    public var serviceBodyId: Int {
        var ret: Int = 0
        
        if let val = Int(self["service_body_bigint"]) {
            ret = val
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: The meeting's Service body object. nil, if no Service body (should never happen).
     */
    public var serviceBody: BMLTiOSLibHierarchicalServiceBodyNode! {
        return self._handler.getServiceBodyByID(self.serviceBodyId)
    }
    
    /* ################################################################## */
    /**
     - returns: an array of format objects.
     */
    public var formats: [BMLTiOSLibFormatNode] {
        let formatIDArray = self.formatsAsCSVList.components(separatedBy: ",")
        
        var ret: [BMLTiOSLibFormatNode] = []
        
        for formatKey in formatIDArray {
            if let format = self._handler.getFormatByKey(formatKey) {
                ret.append(format)
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: a CSV string of format codes, sorted alphabetically.
     */
    public var formatsAsCSVList: String {
        var ret: String = ""
        
        if let list = self._rawMeeting["formats"]?.components(separatedBy: ",").sorted() {
            ret = list.joined(separator: ",")
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: A Bool. True, if the meeting is published.
     */
    public var published: Bool {
        var ret: Bool = false
        if let pub = self["published"] {
            ret = pub == "1"
        }
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: A String, with the meeting name.
     */
    public var name: String {
        var ret: String = ""
        if let name = self["meeting_name"] {
            ret = name
        }
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: An Int, with the weekday (1 = Sunday, 7 = Saturday).
     */
    public var weekdayIndex: Int {
        var ret: Int = 0
        
        if let weekday = self["weekday_tinyint"] {
            if let val = Int(weekday) {
                ret = val
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: A String, with the start time in military format ("HH:MM").
     */
    public var timeString: String {
        var ret: String = "00:00"
        
        if let time = self["start_time"] {
            var timeComponents = time.components(separatedBy: ":").map { Int($0) }
            if (23 == timeComponents[0]!) && (54 < timeComponents[1]!) {
                timeComponents[0] = 24
                timeComponents[1] = 0
            }
            ret = String(format: "%02d:%02d", timeComponents[0]!, timeComponents[1]!)
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: A String, with the duration ("HH:MM").
     */
    public var durationString: String {
        var ret: String = "00:00"
        
        if let time = self["duration_time"] {
            let timeComponents = time.components(separatedBy: ":").map { Int($0) }
            ret = String(format: "%02d:%02d", timeComponents[0]!, timeComponents[1]!)
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: An Integer, with the duration in minutes.
     */
    public var durationInMinutes: Int {
        var ret: Int = 0
        
        if let time = self["duration_time"] {
            let timeComponents = time.components(separatedBy: ":").map { Int($0) }
            if let hours = timeComponents[0] {
                ret = hours * 60
            }
            if let minutes = timeComponents[1] {
                ret += minutes
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: an optional DateComponents object, with the time of the meeting.
     */
    public var startTime: DateComponents! {
        var ret: DateComponents! = nil
        if let time = self["start_time"] {
            var timeComponents = time.components(separatedBy: ":").map { Int($0) }
            
            if 1 < timeComponents.count {
                // Create our answer from the components of the result.
                ret = DateComponents(calendar: nil, timeZone: nil, era: nil, year: nil, month: nil, day: nil, hour: timeComponents[0]!, minute: timeComponents[1]!, second: 0, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: an optional DateComponents object, with the weekday and time of the meeting.
     */
    public var startTimeAndDay: DateComponents! {
        var ret: DateComponents! = nil
        if let time = self["start_time"] {
            var timeComponents = time.components(separatedBy: ":").map { Int($0) }
            
            if 1 < timeComponents.count {
                var weekdayIndex = self.weekdayIndex
                if (23 == timeComponents[0]!) && (54 < timeComponents[1]!) {
                    weekdayIndex += 1
                    if 7 < weekdayIndex {
                        weekdayIndex = 1
                    }
                    timeComponents = [0, 0]
                }
                
                // Create our answer from the components of the result.
                ret = DateComponents(calendar: nil, timeZone: nil, era: nil, year: nil, month: nil, day: nil, hour: timeComponents[0]!, minute: timeComponents[1]!, second: 0, nanosecond: nil, weekday: weekdayIndex, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: returns an integer that allows sorting quickly. Weekday is 1,000s, hours are 100s, and minutes are 1s.
     NOTE: This value reflects the localized start day of the week (the others do not). This is because the reason for this value is for sorting.
     That means that if the week starts on Monday, then the weekday index will be 1 if the meeting is on Monday, and 7 if on Sunday.
     */
    public var timeDayAsInteger: Int {
        var ret: Int = 0
        if let time = self["start_time"] {
            var timeComponents = time.components(separatedBy: ":").map { Int($0) }
            
            if 1 < timeComponents.count {
                var weekdayIndex = self.weekdayIndex - Calendar.current.firstWeekday
                
                if 0 > weekdayIndex {
                    weekdayIndex += 7
                }
                
                if (23 == timeComponents[0]!) && (54 < timeComponents[1]!) {
                    weekdayIndex += 1
                    if 7 < weekdayIndex {
                        weekdayIndex = 1
                    }
                    timeComponents = [0, 0]
                }
                
                ret = (weekdayIndex * 10000) + (timeComponents[0]! * 100) + timeComponents[1]!
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: an optional Date object, with the next occurrence of the meeting (from now).
     */
    public var nextStartDate: Date! {
        var ret: Date! = nil
        let now = Date()
        
        let myCalendar = Calendar.current
        if let meetingEvent = self.startTimeAndDay {
            if let nextMeeting = myCalendar.nextDate(after: now, matching: meetingEvent, matchingPolicy: .nextTimePreservingSmallerComponents) {
                ret = nextMeeting
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: The location (optional).
     */
    public var locationCoords: CLLocationCoordinate2D! {
        if let long = CLLocationDegrees(self["longitude"]) {
            if let lat = CLLocationDegrees(self["latitude"]) {
                return CLLocationCoordinate2D(latitude: lat, longitude: long)
            }
        }
        return nil
    }
    
    /* ################################################################## */
    /**
     - returns: A String, with the location building name.
     */
    public var locationName: String {
        var ret: String = ""
        if let name = self["location_text"] {
            ret = name
        }
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: A String, with the location street address.
     */
    public var locationStreetAddress: String {
        var ret: String = ""
        if let name = self["location_street"] {
            ret = name
        }
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: A String, with the location borough.
     */
    public var locationBorough: String {
        var ret: String = ""
        if let name = self["location_city_subsection"] {
            ret = name
        }
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: A String, with the location neigborhood.
     */
    public var locationNeighborhood: String {
        var ret: String = ""
        if let name = self["location_neighborhood"] {
            ret = name
        }
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: A String, with the location town.
     */
    public var locationTown: String {
        var ret: String = ""
        if let name = self["location_municipality"] {
            ret = name
        }
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: A String, with the location county.
     */
    public var locationCounty: String {
        var ret: String = ""
        if let name = self["location_sub_province"] {
            ret = name
        }
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: A String, with the location state/province.
     */
    public var locationState: String {
        var ret: String = ""
        if let name = self["location_province"] {
            ret = name
        }
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: A String, with the location zip code/postal code.
     */
    public var locationZip: String {
        var ret: String = ""
        if let name = self["location_postal_code_1"] {
            ret = name
        }
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: A String, with the location nation.
     */
    public var locationNation: String {
        var ret: String = ""
        if let name = self["location_nation"] {
            ret = name
        }
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: A String, with additional location info.
     */
    public var locationInfo: String {
        var ret: String = ""
        if let name = self["location_info"] {
            ret = name
        }
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: A String, with the comments.
     */
    public var comments: String {
        var ret: String = ""
        if let name = self["comments"] {
            ret = name
        }
        return ret
    }
    
    /* ################################################################## */
    /**
     Read-only property that returns the distance (in Miles) from the search center.
     
     - returns: the distance from the search center (may not be applicable, in which case it will be 0).
     */
    public var distanceInMiles: Double {
        var ret: Double = 0
        
        if let val = Double(self["distance_in_miles"]) {
            ret = val
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     Read-only property that returns the distance (in Kilometers) from the search center.
     
     - returns: the distance from the search center (may not be applicable, in which case it will be 0).
     */
    public var distanceInKm: Double {
        var ret: Double = 0
        
        if let val = Double(self["distance_in_km"]) {
            ret = val
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This parses the meeting data, and creates a fairly basic, straightforward address.
     
     The address type is specified by the "BMLTiOSLibAddressParser" info.plist property.
     
     This is a read-only property.
     
     - returns: A String, with a basic address.
     */
    public var basicAddress: String {
        // See if we have specified an address format in the info.plist file.
        if let addressParserType = Bundle.main.object(forInfoDictionaryKey: "BMLTiOSLibAddressParser") as? String {
            switch addressParserType {
            default:    // Currently, this is the only one.
                return self._USAddressParser
            }
        }
        
        return self._USAddressParser    // Default is US format.
    }
    
    /* ################################################################## */
    /**
     This is always false for this class.
     */
    public var isDirty: Bool { return false }
    
    /* ################################################################## */
    /**
     This is a read-only property that overrides the NSObject description.
     It returns a string that aggregates the meeting info into a simple
     US-style meeting description.
     
     For many uses, this may give enough information to display the meeting.
     
     - returns: A String, with the essential Meeting Info.
     */
    override public var description: String {
        let dateformatter = DateFormatter()

        if self._using12hClockFormat {
            dateformatter.dateFormat = "EEEE, h:mm a"
        } else {
            dateformatter.dateFormat = "EEEE, H:mm"
        }
        
        if let nextStartDate = self.nextStartDate {
            let nextDate = dateformatter.string(from: nextStartDate).firstUppercased
            let formats = self.formatsAsCSVList.isEmpty ? "" : " (" + self.formatsAsCSVList + ")"
            return "\(nextDate)\n\(self.name)\(formats)\n\(self.basicAddress)"
        } else {
            return "\(self.name) (\(self.formatsAsCSVList))\n\(self.basicAddress)"
        }
    }
    
    /* ################################################################## */
    // MARK: Public Methods
    /* ################################################################## */
    /**
     Default initializer. Initiatlize with raw meeting data (a simple Dictionary).
     
     - parameter inRawMeeting: This is a Dictionary that describes the meeting. If empty, then a default meeting will be created.
     - parameter inHandler: This is the BMLTiOSLib object that "owns" this meeting
     */
    public init(_ inRawMeeting: [String: String], inHandler: BMLTiOSLib) {
        var myMeeting = inRawMeeting
        // If we have an empty meeting, we fill it with a default (empty) dataset.
        if 0 == myMeeting.count {
            for key in inHandler.availableMeetingValueKeys {
                var val: String = ""
                // These get a big fat "0".
                if ("id_bigint" == key) || ("published" == key) {
                    val = "0"
                }
                
                // Give it the first Service body we can edit, or 0.
                if "service_body_bigint" == key {
                    var sb_id: Int = 0
                    
                    // If we are in an editable state, and have available Service bodies, we simply assign the first one we can edit.
                    let sbs = inHandler.serviceBodiesICanEdit
                    
                    if 0 < sbs.count {
                        sb_id = sbs[0].id
                    }
                    
                    val = String(sb_id)
                }
                
                // This is a placeholder for localization.
                if "meeting_name" == key {
                    val = type(of: self).BMLTiOSLib_DefaultMeetingNameString
                }
                
                // We use the Root Server default location in the absence of any other location.
                if "longitude" == key {
                    val = String(inHandler.defaultLocation.longitude)
                }
                
                if "latitude" == key {
                    val = String(inHandler.defaultLocation.latitude)
                }
                
                // Use placeholder values.
                if "start_time" == key {
                    val = type(of: self).BMLTiOSLib_DefaultMeetingStartTime
                }
                
                if "duration_time" == key {
                    val = type(of: self).BMLTiOSLib_DefaultMeetingDurationTime
                }
                
                if "weekday_tinyint" == key {
                    val = type(of: self).BMLTiOSLib_DefaultMeetingWeekday
                }
                
                myMeeting[key] = val
            }
        }
        
        self._rawMeeting = myMeeting
        self._handler = inHandler
        super.init()
    }
    
    /* ################################################################## */
    /**
     Requests all changes for this meeting from the BMLTiOSLib handler.
     */
    public func getChanges() {
        self._handler.getAllMeetingChanges(meeting: self)
    }
    
    /* ################################################################## */
    /**
     If sending messages to meeting contacts is enabled, this function will send a basic email to the contact for this email.
     
     This will result in the delegate callback bmltLibInstance(_:BMLTiOSLib,sendMessageSuccessful: Bool) being invoked.
     
     - parameter fromAddress: The email to be used as the "from" address. This is required, and should be valid.
     - parameter messageBody: A String containing the body of the message to be sent.
     */
    public func sendMessageToMeetingContact(fromAddress: String, messageBody: String) {
        self._handler._sendMessageToMeetingContact(meetingID: self.id, serviceBodyID: self.serviceBodyId, fromAddress: fromAddress, messageBody: messageBody)
    }
    
    /* ################################################################## */
    // MARK: Meeting Start and End Time Test Methods
    /* ################################################################## */
    /**
     Returns true, if the meeting start time is after the given time.
     
     - parameter inTime: The test start time, as time components (hours, minutes, seconds). The day is ignored.
     
     - returns: true, if the meeting starts on or after the given test time.
     */
    public func meetingStartsOnOrAfterThisTime(_ inTime: NSDateComponents) -> Bool {
        if let myStartTime = self.startTimeAndDay {
            if var startHour = myStartTime.hour {
                if let startMinute = myStartTime.minute {
                    if let startSecond = myStartTime.second {
                        // Special case for midnight.
                        if (0 == startHour) && (0 == startMinute) && (0 == startSecond) {
                            startHour = 24
                        }
                        let myStartSeconds = (startHour * 3600) + (startMinute * 60) + startSecond
                        let myTestSeconds = (inTime.hour * 3600) + (inTime.minute * 60) + inTime.second
                        
                        return myStartSeconds >= myTestSeconds
                    }
                }
            }
        }
        
        return false
    }
    
    /* ################################################################## */
    /**
     Returns true, if the meeting start time is before the given time.
     
     - parameter inTime: The test start time, as time components (hours, minutes, seconds). The day is ignored.
     
     - returns: true, if the meeting starts on or before the given test time.
     */
    public func meetingStartsOnOrBeforeThisTime(_ inTime: NSDateComponents) -> Bool {
        if let myStartTime = self.startTimeAndDay {
            if var startHour = myStartTime.hour {
                if let startMinute = myStartTime.minute {
                    if let startSecond = myStartTime.minute {
                        // Special case for midnight.
                        if (0 == startHour) && (0 == startMinute) && (0 == startSecond) {
                            startHour = 24
                        }
                        let myStartSeconds = (startHour * 3600) + (startMinute * 60) + startSecond
                        let myTestSeconds = (inTime.hour * 3600) + (inTime.minute * 60) + inTime.second
                        
                        return myStartSeconds <= myTestSeconds
                    }
                }
            }
        }
        
        return false
    }
    
    /* ################################################################## */
    /**
     Returns true, if the meeting end time is before the given time.
     
     - parameter inTime: The test end time, as time components (hours, minutes, seconds). The day is ignored.
     
     - returns: true, if the meeting ends at or before the given test time.
     */
    public func meetingEndsAtOrBeforeThisTime(_ inTime: NSDateComponents) -> Bool {
        if let myStartTime = self.startTimeAndDay {
            if var startHour = myStartTime.hour {
                if let startMinute = myStartTime.minute {
                    if let startSecond = myStartTime.minute {
                        // Special case for midnight.
                        if (0 == startHour) && (0 == startMinute) && (0 == startSecond) {
                            startHour = 24
                        }
                        let myStartSeconds = (startHour * 3600) + (startMinute * 60) + startSecond + (self.durationInMinutes * 60)
                        let myTestSeconds = (inTime.hour * 3600) + (inTime.minute * 60) + inTime.second
                        
                        return myStartSeconds <= myTestSeconds
                    }
                }
            }
        }
        
        return false
    }
    
    /* ############################################################## */
    // MARK: Sequence Protocol Methods
    /* ############################################################## */
    /**
     Create an iterator for this list.
     
     This iterator follows the order of the array, starting from element 0, and working up to the end.
     
     - returns: an iterator for the list.
     */
    public func makeIterator() -> AnyIterator<BMLTiOSLibMeetingNodeSimpleDictionaryElement> {
        var nextIndex = 0
        let keys = self.keys
        // Return a "bottom-up" iterator for the list.
        return AnyIterator {
            if nextIndex == self.keys.count {
                return nil
            }
            
            let key = keys[nextIndex]
            nextIndex += 1
            if let value = self.rawMeeting[key] {
                return BMLTiOSLibMeetingNodeSimpleDictionaryElement(key: key, value: value, handler: self)
            } else {
                return nil
            }
        }
    }
}
