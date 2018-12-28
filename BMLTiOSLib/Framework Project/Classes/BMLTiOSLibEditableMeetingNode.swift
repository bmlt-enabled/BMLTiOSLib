//
//  BMLTiOSLibEditableMeetingNode.swift
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
// MARK: - Editable Meeting Class -
/* ###################################################################################################################################### */
/**
 This is a special "micro class" for editing the meetings for a Server.
 */
public class BMLTiOSLibEditableMeetingNode: BMLTiOSLibMeetingNode {
    /* ################################################################## */
    // MARK: Private Properties
    /* ################################################################## */
    var _originalObject: [String: String] = [:]
    
    /* ################################################################## */
    // MARK: Public Calculated Properties
    /* ################################################################## */
    
    /* ################################################################## */
    /**
     This returns a flat (non-hierarchical) array of Service Body nodes that this meeting can be assinged.
     
     This returns every Service body on the server that the current user can observe or edit.
     Each will be in a node, with links to its parents and children (if any).
     
     - returns: an Array of BMLTiOSLibHierarchicalServiceBodyNode objects, each of which represents one Service body.
     */
    public var serviceBodiesICanBelongTo: [BMLTiOSLibHierarchicalServiceBodyNode] {
        return self._handler.serviceBodiesICanEdit
    }
    
    /* ################################################################## */
    /** This class is editable. */
    override public var isEditable: Bool {
        return true
    }
    
    /* ################################################################## */
    /**
     This allows us to set a new collection of meeting formats via an array of format objects.
     
     - returns: an array of format objects.
     */
    override public var formats: [BMLTiOSLibFormatNode] {
        get {
            return super.formats
        }
        
        set {
            var formatList: [String] = []
            for format in newValue where nil != self._handler.getFormatByID(format.id) {
                formatList.append(format.key)
            }
            self.formatsAsCSVList = formatList.joined(separator: ",")
        }
    }
    
    /* ################################################################## */
    /**
     This allows us to set a new collection of meeting formats via a CSV string of their codes.
     
     - returns: a CSV string of format codes, sorted alphabetically.
     */
    override public var formatsAsCSVList: String {
        get {
            return super.formatsAsCSVList
        }
        
        set {
            let list = newValue.components(separatedBy: ",").sorted()
            self.rawMeeting["formats"] = list.joined(separator: ",")
        }
    }
    
    /* ################################################################## */
    /**
     This sets the meeting's "published" status.
     
     - returns: A Bool. True, if the meeting is published.
     */
    override public var published: Bool {
        get {
            return super.published
        }
        
        set {
            self.rawMeeting["published"] = newValue ? "1" : "0"
        }
    }
    
    /* ################################################################## */
    /**
     This sets the meeting's NAWS (World ID).
     
     - returns: A String, with the meeting NAWS ID.
     */
    override public var worldID: String {
        get {
            return super.worldID
        }
        
        set {
            self.rawMeeting["worldid_mixed"] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     - returns: An Int, with the meeting's Service body BMLT ID.
     */
    override public var serviceBodyId: Int {
        get {
            return super.serviceBodyId
        }
        
        set {
            self.rawMeeting["service_body_bigint"] = String(newValue)
        }
    }
    
    /* ################################################################## */
    /**
     - returns: The meeting's Service body object. nil, if no Service body (should never happen).
     */
    override public var serviceBody: BMLTiOSLibHierarchicalServiceBodyNode! {
        get {
            return super.serviceBody
        }
        
        set {
            self.serviceBodyId = newValue.id
        }
    }
    
    /* ################################################################## */
    /**
     - returns: A String, with the meeting name.
     */
    override public var name: String {
        get {
            return super.name
        }
        
        set {
            self.rawMeeting["meeting_name"] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     This creates new long/lat values for the given coordinate.
     
     - returns: The location (optional).
     */
    override public var locationCoords: CLLocationCoordinate2D! {
        get {
            return super.locationCoords
        }
        
        set {
            if nil != newValue {
                self.rawMeeting["longitude"] = String(newValue.longitude as Double)
                self.rawMeeting["latitude"] = String(newValue.latitude as Double)
            } else {
                self.rawMeeting["longitude"] = "0"
                self.rawMeeting["latitude"] = "0"
            }
        }
    }
    
    /* ################################################################## */
    /**
     - returns: A String, with the location building name.
     */
    override public var locationName: String {
        get {
            return super.locationName
        }
        
        set {
            self.rawMeeting["location_text"] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     - returns: A String, with the location street address.
     */
    override public var locationStreetAddress: String {
        get {
            return super.locationStreetAddress
        }
        
        set {
            self.rawMeeting["location_street"] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     - returns: A String, with the location neighborhood.
     */
    override public var locationNeighborhood: String {
        get {
            return super.locationNeighborhood
        }
        
        set {
            self.rawMeeting["location_neighborhood"] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     - returns: A String, with the location borough.
     */
    override public var locationBorough: String {
        get {
            return super.locationBorough
        }
        
        set {
            self.rawMeeting["location_city_subsection"] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     - returns: A String, with the location town.
     */
    override public var locationTown: String {
        get {
            return super.locationTown
        }
        
        set {
            self.rawMeeting["location_municipality"] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     - returns: A String, with the location county.
     */
    override public var locationCounty: String {
        get {
            return super.locationCounty
        }
        
        set {
            self.rawMeeting["location_sub_province"] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     - returns: A String, with the location state/province.
     */
    override public var locationState: String {
        get {
            return super.locationState
        }
        
        set {
            self.rawMeeting["location_province"] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     - returns: A String, with the location zip code/postal code.
     */
    override public var locationZip: String {
        get {
            return super.locationZip
        }
        
        set {
            self.rawMeeting["location_postal_code_1"] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     - returns: A String, with the location nation.
     */
    override public var locationNation: String {
        get {
            return super.locationNation
        }
        
        set {
            self.rawMeeting["location_nation"] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     - returns: A String, with additional location info.
     */
    override public var locationInfo: String {
        get {
            return super.locationInfo
        }
        
        set {
            self.rawMeeting["location_info"] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     - returns: A String, with the comments.
     */
    override public var comments: String {
        get {
            return super.comments
        }
        
        set {
            self.rawMeeting["comments"] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     - returns: An Int, with the weekday (1 = Sunday, 7 = Saturday).
     */
    override public var weekdayIndex: Int {
        get {
            return super.weekdayIndex
        }
        
        set {
            if (0 < newValue) && (8 > newValue) {
                self.rawMeeting["weekday_tinyint"] = String(newValue)
            }
        }
    }
    
    /* ################################################################## */
    /**
     This parses a military time string (either "HH:MM" or "HHMM"), and creates a new
     start time from the string.
     
     - returns: A String, with the start time in military format ("HH:MM").
     */
    override public var timeString: String {
        get {
            return super.timeString
        }
        
        set {
            var timeComponents = newValue.components(separatedBy: ":").map { Int($0) }
            // See if we need to parse as a simple number.
            if 1 == timeComponents.count {
                if let simpleNumber = Int(timeString) {
                    let hours = simpleNumber / 100
                    let minutes = simpleNumber - (hours * 100)
                    timeComponents[0] = hours
                    timeComponents[1] = minutes
                }
            }
            
            // This is a special case for midnight. We always represent it as 11:59 PM.
            if ((0 == timeComponents[0]!) || (24 == timeComponents[0]!)) && (0 == timeComponents[1]!) {
                timeComponents[0] = 23
                timeComponents[1] = 59
            }
            
            // Belt and suspenders. This should always pass.
            if 1 < timeComponents.count {
                let val = String(format: "%02d:%02d:00", timeComponents[0]!, timeComponents[1]!)
                self.rawMeeting["start_time"] = val
            }
        }
    }
    
    /* ################################################################## */
    /**
     - returns: A String, with the duration ("HH:MM").
     */
    override public var durationString: String {
        get {
            return super.durationString
        }
        
        set {
            let timeComponents = newValue.components(separatedBy: ":").map { Int($0) }
            var hours = (nil != timeComponents[0]) ? timeComponents[0]! : 0
            var minutes = (nil != timeComponents[1]) ? timeComponents[1]! : 0
            
            // Just to make sure that we haven't asked for an unreasonable amount of minutes.
            let extraTime = Int(minutes / 60)
            
            if 0 < extraTime {
                hours += extraTime
                minutes -= (extraTime * 60)
            }
            
            self.durationInMinutes = (hours * 60) + minutes
        }
    }
    
    /* ################################################################## */
    /**
     Sets the new duration from an integer, representing the number of minutes.
     
     - returns: An Integer, with the duration in minutes.
     */
    override public var durationInMinutes: Int {
        get {
            return super.durationInMinutes
        }
        
        set {
            if 1440 > newValue {    // Can't be more than 23:59
                let hours = Int(newValue / 60)
                let minutes = newValue - (hours * 60)
                self.rawMeeting["duration_time"] = String(format: "%02d:%02d:00", hours, minutes)
            }
        }
    }
    
    /* ################################################################## */
    /**
     This simply sets the time exactly from components.
     
     - returns: an optional DateComponents object, with the time of the meeting.
     */
    override public var startTime: DateComponents! {
        get {
            return super.startTime
        }
        
        set {
            if let hour = newValue.hour {
                if let minute = newValue.minute {
                    self.timeString = String(format: "%02d:%02d", hour, minute)
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     This extracts the weekday and the time of day from the components, and uses these as new values for the meeting.
     
     - returns: an optional DateComponents object, with the weekday and time of the meeting.
     */
    override public var startTimeAndDay: DateComponents! {
        get {
            return super.startTimeAndDay
        }
        
        set {
            if var weekday = newValue.weekday {
                if var hour = newValue.hour {
                    if var minute = newValue.minute {
                        // This is a special case for midnight. We always represent it as 11:59 PM of the previous day.
                        if ((0 == hour) || (24 == hour)) && (0 == minute) {
                            if (0 == hour) && (0 == minute) {   // In the case of the morning, we really mean last night.
                                weekday -= 1
                                if 0 == weekday {
                                    weekday = 7
                                }
                            }
                            hour = 23
                            minute = 59
                        }
                        
                        self.timeString = String(format: "%02d:%02d", hour, minute)
                        self.weekdayIndex = weekday
                    }
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     This sets a new time and weekday by parsing the Date object provided.
     It extracts the weekday and the time of day, and uses these as new values for the meeting.
     
     - returns: an optional Date object, with the next occurrence of the meeting (from now).
     */
    override public var nextStartDate: Date! {
        get {
            return super.nextStartDate
        }
        
        set {
            let myCalendar: Calendar = Calendar.current
            let unitFlags: NSCalendar.Unit = [NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.weekday]
            let myComponents = (myCalendar as NSCalendar).components(unitFlags, from: newValue)
            self.startTimeAndDay = myComponents
        }
    }
    
    /* ################################################################## */
    /**
     - returns: true, if the meeting data has changed from its original instance.
     */
    override public var isDirty: Bool {
        var ret: Bool = false
        
        // No-brainer
        if self._originalObject.count != self.rawMeeting.count {
            ret = true
        } else {    // Hunt through our keys, looking for differences from the original.
            for key in self._originalObject.keys where "id_bigint" != key { // Can't change the ID
                if let origValue = self._originalObject[key] {
                    if let newValue = self.rawMeeting[key] {
                        if "formats" == key {
                            // We do this, because we may change the order, without actually changing the value.
                            let origKeys = origValue.components(separatedBy: ",").sorted()
                            let newKeys = newValue.components(separatedBy: ",").sorted()
                            ret = newKeys != origKeys
                        } else {
                            ret = newValue != origValue
                        }
                    } else {
                        ret = false
                    }
                }
                
                if ret {    // We stop if we are dirty.
                    break
                }
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    // MARK: Public Initializer
    /* ################################################################## */
    /**
     Default initializer. Initiatlize with raw meeting data (a simple Dictionary).
     
     - parameter inRawMeeting: This is a Dictionary that describes the meeting.
     - parameter inHandler: This is the BMLTiOSLib object that "owns" this meeting
     */
    override public init(_ inRawMeeting: [String: String], inHandler: BMLTiOSLib) {
        super.init(inRawMeeting, inHandler: inHandler)
        self._originalObject = self.rawMeeting
    }
    
    /* ################################################################## */
    // MARK: Internal Methods
    /* ################################################################## */
    /**
     Sets the original object to the current one.
     */
    internal func setChanges() {
        if self.isDirty {
            self._originalObject = self.rawMeeting  // We are no longer "dirty".
        }
    }
    
    /* ################################################################## */
    // MARK: Public Methods
    /* ################################################################## */
    /**
     This allows us to add a single format, via its object reference.
     
     If the format was already there, no change is made, and there is no error.
     
     - parameter inFormatObject: The format object to be added.
     */
    public func addFormat(_ inFormatObject: BMLTiOSLibFormatNode) {
        var found: Bool = false
        for formatObject in self.formats where formatObject == inFormatObject {
            found = true
            break
        }
        
        if !found {
            self.formats.append(inFormatObject)
        }
    }
    
    /* ################################################################## */
    /**
     This allows us to remove a single format, via its object reference.
     
     If the format was not there, no change is made, and there is no error.
     
     - parameter inFormatObject: The format object to be removed.
     */
    public func removeFormat(_ inFormatObject: BMLTiOSLibFormatNode) {
        var index: Int = 0
        for formatObject in self.formats {
            if formatObject == inFormatObject {
                self.formats.remove(at: index)
                break
            }
            index += 1
        }
    }
    
    /* ################################################################## */
    /**
     Removes all changes made to the meeting.
     */
    public func restoreToOriginal() {
        self.rawMeeting = self._originalObject
    }
    
    /* ################################################################## */
    /**
     Reverts a meeting to the "before" state of a given change, but does not save it to the server.
     
     The "before" meeting must also be editable, the user needs to be currently logged in
     with edit privileges on the meeting.
     
     This makes the meeting "dirty."
     
     - returns: True, if the reversion was allowed.
     */
    public func revertMeetingToBeforeThisChange(_ inChangeObject: BMLTiOSLibChangeNode) -> Bool {
        if let beforeObject = inChangeObject.beforeObject {
            if beforeObject.isEditable {
                self.rawMeeting = beforeObject.rawMeeting
                return true
            }
        }
        
        return false
    }
    
    /* ################################################################## */
    /**
     Reverts a meeting to the "before" state of a given change, and saves it to the server.
     
     The "before" meeting must also be editable, the user needs to be currently logged in
     with edit privileges on the meeting.
     
     - returns: True, if the reversion was allowed.
     */
    public func saveMeetingToBeforeThisChange(_ inChangeObject: BMLTiOSLibChangeNode) -> Bool {
        if self.revertMeetingToBeforeThisChange(inChangeObject) {
            self.saveChanges()
            return true
        }
        
        return false
    }
    
    /* ################################################################## */
    /**
     Test whether or not a given field has undergone a change.
     
     - parameter inKey: The meeting field key to test.
     
     - returns: True, if the given field is different from the original one.
     */
    public func valueChanged(_ inKey: String) -> Bool {
        var ret: Bool = false
        
        if let oldVal = self._originalObject[inKey] {
            if let newVal = self.rawMeeting[inKey] {
                ret = oldVal != newVal
            } else {
                ret = true
            }
        } else {
            if nil != self.rawMeeting[inKey] {
                ret = true
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     Deletes this meeting.
     */
    public func delete() {
        self._handler.deleteMeeting(self.id)
    }
    
    /* ################################################################## */
    /**
     Saves changes made to the meeting.
     */
    public func saveChanges() {
        if self.isDirty {
            self._handler.saveMeetingChanges(self)
            self.setChanges()  // We are no longer "dirty".
        }
    }
}
