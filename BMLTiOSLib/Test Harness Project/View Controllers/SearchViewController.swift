//
//  SearchViewController.swift
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

import UIKit
import BMLTiOSLib
import MapKit

/* ###################################################################################################################################### */
/**
 */
class SearchViewController: BaseTestViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MKMapViewDelegate {
    static let sMapSizeInDegrees: CLLocationDegrees         =   0.75

    enum TableRows: Int {
        case ClearButtonRow = 0, StartEndTimeRow, DurationTimeRow, SearchStringRow, LocationRadiusRow, MapRow, WeekdayRow, ServiceBodyRow, FormatRow
    }
    
    enum SearchType {
        case MeetingsOnly, MeetingsAndFormats, FormatsOnly
    }
    
    let weekdayRowHeight: CGFloat = 250
    let startEndRowHeight: CGFloat = 246
    let durationTimeRowHeight: CGFloat = 116
    let checkboxRowHeight: CGFloat = 30
    let clearButtonRowHeight: CGFloat = 30
    let searchTypeRowHeight: CGFloat = 34
    let searchStringRowHeight: CGFloat = 176
    let mapRowExtraHeight: CGFloat = 57
    let locationRadiusRowHeight: CGFloat = 114
    let searchTypeControlHeight: CGFloat = 24
    let searchButtonRowHeight: CGFloat = 30
    let searchTypeMeetingsOnlyTitle = "Meetings Only"
    let searchTypeFormatsOnlyTitle = "Formats Only"
    
    @IBOutlet var _tableView: UITableView!
    
    @IBOutlet weak var sundayButton: BMLTiOSLibCheckbox!
    @IBOutlet weak var mondayButton: BMLTiOSLibCheckbox!
    @IBOutlet weak var tuesdayButton: BMLTiOSLibCheckbox!
    @IBOutlet weak var wednesdayButton: BMLTiOSLibCheckbox!
    @IBOutlet weak var thursdayButton: BMLTiOSLibCheckbox!
    @IBOutlet weak var fridayButton: BMLTiOSLibCheckbox!
    @IBOutlet weak var saturdayButton: BMLTiOSLibCheckbox!
    
    @IBOutlet weak var _toolbar: UIToolbar!
    @IBOutlet weak var _viewFormatsButton: UIBarButtonItem!
    @IBOutlet weak var _viewMeetingsButton: UIBarButtonItem!
    @IBOutlet weak var _searchButton: UIBarButtonItem!
    
    @IBOutlet var _weekdayListCellView: UIView!
    
    @IBOutlet var _serviceBodyListCellView: UIView!
    @IBOutlet weak var _serviceBodyLabel: UILabel!
    @IBOutlet weak var _serviceBodyCheckboxContainerView: UIView!
    
    @IBOutlet var _formatListCellView: UIView!
    @IBOutlet weak var _formatLabel: UILabel!
    @IBOutlet weak var _formatCheckboxContainerView: UIView!
    
    @IBOutlet var _searchSegmentedControl: UISegmentedControl!
    
    @IBOutlet var _stringSearchCellView: UIView!
    @IBOutlet weak var _stringSearchTextEntry: UITextField!
    @IBOutlet weak var _stringIsALocationSwitch: UISwitch!
    @IBOutlet weak var _allStringsMustMatchSwitch: UISwitch!
    @IBOutlet weak var _exactMatchSwitch: UISwitch!
    
    @IBOutlet var _locationRadiusCellView: UIView!
    @IBOutlet weak var _autoRadiusSwitch: UISwitch!
    @IBOutlet weak var _radiusTextEntry: UITextField!
    @IBOutlet weak var _radiusLabel: UILabel!
    
    @IBOutlet var _mapView: MKMapView!
    
    @IBOutlet var _startEndTimeContainerView: UIView!
    @IBOutlet weak var _startTimeSwitch: UISwitch!
    @IBOutlet weak var _endTimeSwitch: UISwitch!
    @IBOutlet weak var _startsAfterSegmentedControlView: UISegmentedControl!
    @IBOutlet weak var _startsAfterDatePicker: UIDatePicker!
    @IBOutlet weak var _endsBeforeDatePicker: UIDatePicker!
    
    @IBOutlet var _durationSelectionContainer: UIView!
    @IBOutlet weak var _durationTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var _durationTimePicker: UIDatePicker!
    @IBOutlet weak var _durationSwitch: UISwitch!
    
    var allCheckboxes: [BMLTiOSLibCheckbox] = []
    var serviceBodyMap: [BMLTiOSLibCheckbox: BMLTiOSLibSearchCriteria.SelectableServiceBodyItem] = [:]
    var formatMap: [BMLTiOSLibCheckbox: BMLTiOSLibSearchCriteria.SelectableFormatItem] = [:]
    var searchType: SearchType = .MeetingsAndFormats
    var meetingSearchResults: [BMLTiOSLibMeetingNode]! = nil
    var formatSearchResults: [BMLTiOSLibFormatNode]! = nil
    var mapMarkerAnnotation: BMLTiOSLibTesterAnnotation!    =   nil
    var _useLocationSwitch: UISwitch!
    var _useLocationLabel: UILabel!
    var _clearButton: UIButton!
    
    /* ################################################################## */
    /**
     */
    var startTimeAsSeconds: Int? {
        if self._startTimeSwitch.isOn {
            let date = self._startsAfterDatePicker.date
            let hour = NSCalendar.current.component(Calendar.Component.hour, from: date)
            let minute = NSCalendar.current.component(Calendar.Component.minute, from: date)
            let ret = Int((hour * 3600) + (minute * 60))
            return ret
        } else {
            return nil
        }
    }
    
    /* ################################################################## */
    /**
     */
    var endTimeAsSeconds: Int? {
        if self._endTimeSwitch.isOn {
            let date = self._endsBeforeDatePicker.date
            let hour = NSCalendar.current.component(Calendar.Component.hour, from: date)
            let minute = NSCalendar.current.component(Calendar.Component.minute, from: date)
            let ret = Int((hour * 3600) + (minute * 60))
            return ret
        } else {
            return nil
        }
    }
    
    /* ################################################################## */
    /**
     */
    var durationTimeAsSeconds: Int? {
        if self._durationSwitch.isOn {
            let date = self._durationTimePicker.date
            let hour = NSCalendar.current.component(Calendar.Component.hour, from: date)
            let minute = NSCalendar.current.component(Calendar.Component.minute, from: date)
            let ret = Int((hour * 3600) + (minute * 60))
            return ret
        } else {
            return nil
        }
    }
    
    /* ################################################################## */
    /**
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self._searchButton.isEnabled = true
        self._viewMeetingsButton.isEnabled = (nil != self.meetingSearchResults) && (0 < self.meetingSearchResults.count)
        self._viewFormatsButton.isEnabled = (nil != self.formatSearchResults) && (0 < self.formatSearchResults.count)
        self._tableView.reloadData()
        self.determineStringItemsEnabling()
   }
    
    /* ################################################################## */
    /**
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self._tableView.reloadData()
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func durationSwitchChanged(_ sender: UISwitch) {
        self._durationTypeSegmentedControl.isEnabled = sender.isOn
        self._durationTimePicker.isEnabled = sender.isOn
        BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.meetingsAreShorterThanDuration = (1 == self._durationTypeSegmentedControl.selectedSegmentIndex)
        BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.durationTimeInSeconds = self.durationTimeAsSeconds
        self.determineStringItemsEnabling()
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func durationTypeChanged(_ sender: UISegmentedControl) {
        BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.durationTimeInSeconds = self.durationTimeAsSeconds
        BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.meetingsAreShorterThanDuration = (1 == sender.selectedSegmentIndex)
        self.determineStringItemsEnabling()
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func durationTimeChanged(_ sender: UIDatePicker) {
        BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.durationTimeInSeconds = self.durationTimeAsSeconds
        self.determineStringItemsEnabling()
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func startTimeSwitchChanged(_ sender: UISwitch) {
        self._startsAfterSegmentedControlView.isEnabled = sender.isOn
        self._startsAfterDatePicker.isEnabled = sender.isOn
        BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.startTimeInSeconds = self.startTimeAsSeconds
        BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.meetingsStartBeforeStartTime = (0 == self._startsAfterSegmentedControlView.selectedSegmentIndex)
        self.determineStringItemsEnabling()
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func endTimeSwitchChanged(_ sender: UISwitch) {
        self._endsBeforeDatePicker.isEnabled = sender.isOn
        BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.endTimeInSeconds = self.endTimeAsSeconds
        self.determineStringItemsEnabling()
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func startTimeSegmentedControlChanged(_ sender: UISegmentedControl) {
        BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.startTimeInSeconds = self.startTimeAsSeconds
        BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.meetingsStartBeforeStartTime = (0 == self._startsAfterSegmentedControlView.selectedSegmentIndex)
        self.determineStringItemsEnabling()
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func startsAfterDatePickerChanged(_ sender: UIDatePicker) {
        BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.startTimeInSeconds = self.startTimeAsSeconds
        self.determineStringItemsEnabling()
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func endsBeforeDatePickerChanged(_ sender: UIDatePicker) {
        BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.endTimeInSeconds = self.endTimeAsSeconds
        self.determineStringItemsEnabling()
    }

    /* ################################################################## */
    /**
     */
    @IBAction func searchTextChanged(_ sender: UITextField) {
        self.determineStringItemsEnabling()
    }
    
    /* ################################################################## */
    /**
     */
    func setWeekdayButtons() {
        self.sundayButton.selectionState = BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.weekdays[.Sunday]!
        self.sundayButton.extraData = 1 as AnyObject
        self.mondayButton.selectionState = BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.weekdays[.Monday]!
        self.mondayButton.extraData = 2 as AnyObject
        self.tuesdayButton.selectionState = BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.weekdays[.Tuesday]!
        self.tuesdayButton.extraData = 3 as AnyObject
        self.wednesdayButton.selectionState = BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.weekdays[.Wednesday]!
        self.wednesdayButton.extraData = 4 as AnyObject
        self.thursdayButton.selectionState = BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.weekdays[.Thursday]!
        self.thursdayButton.extraData = 5 as AnyObject
        self.fridayButton.selectionState = BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.weekdays[.Friday]!
        self.fridayButton.extraData = 6 as AnyObject
        self.saturdayButton.selectionState = BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.weekdays[.Saturday]!
        self.saturdayButton.extraData = 7 as AnyObject
    }
    
    /* ################################################################## */
    /**
     */
    func changeServiceBodySelection(_ inServiceBodySelectionObject: inout BMLTiOSLibSearchCriteria.SelectableServiceBodyItem, to newState: BMLTiOSLibSearchCriteria.SelectionState) {
        
        inServiceBodySelectionObject.selection = newState
        if let checkbox = inServiceBodySelectionObject.item.extraData as? BMLTiOSLibCheckbox {
            if checkbox.selectionState != newState {
                checkbox.selectionState = newState
            }
            for child in (inServiceBodySelectionObject.item.children) {
                if let childCheckbox = child.extraData as? BMLTiOSLibCheckbox {
                    if var childObject = childCheckbox.extraData as? BMLTiOSLibSearchCriteria.SelectableServiceBodyItem {
                        self.changeServiceBodySelection(&childObject, to: newState)
                    }
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func changeFormatSelection(_ inFormatSelectionObject: inout BMLTiOSLibSearchCriteria.SelectableFormatItem, to newState: BMLTiOSLibSearchCriteria.SelectionState) {
        
        inFormatSelectionObject.selection = newState
        
        for checkbox in self.formatMap.keys {
            if (self.formatMap[checkbox]!.item == inFormatSelectionObject.item) && (checkbox.selectionState != newState) {
                checkbox.selectionState = newState
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    @objc func formatCheckboxChanged(_ inFormatCheckboxObject: BMLTiOSLibCheckbox) {
        if var format = self.formatMap[inFormatCheckboxObject] {
            self.changeFormatSelection(&format, to: inFormatCheckboxObject.selectionState)
        }
        self.determineStringItemsEnabling()
    }
    
    /* ################################################################## */
    /**
     */
    @objc func serviceBodyCheckboxChanged(_ inServiceBodyCheckboxObject: BMLTiOSLibCheckbox) {
        let sb1 = (inServiceBodyCheckboxObject as BMLTiOSLibCheckbox).extraData
        
        if var sb = sb1 as? BMLTiOSLibSearchCriteria.SelectableServiceBodyItem {
            self.changeServiceBodySelection(&sb, to: inServiceBodyCheckboxObject.selectionState)
        }
        
        self.determineStringItemsEnabling()
    }
    
    /* ################################################################## */
    /**
     */
    @objc func weekdayCheckboxChanged(_ inCheckbox: BMLTiOSLibCheckbox) {
        if let weekdayIndex = inCheckbox.extraData as? Int {
            if (0 < weekdayIndex) && (8 > weekdayIndex) {
                if let weekday = BMLTiOSLibSearchCriteria.WeekdayIndex(rawValue: weekdayIndex) {
                    BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.weekdays[weekday] = inCheckbox.selectionState
                }
            }
        }
        self.determineStringItemsEnabling()
    }
    
    /* ################################################################## */
    /**
     */
    func determineStringItemsEnabling() {
        if nil != self._stringSearchTextEntry {
            if (self._stringSearchTextEntry.text?.isEmpty)! {
                self._stringIsALocationSwitch.isEnabled = false
                self._allStringsMustMatchSwitch.isEnabled = false
                self._exactMatchSwitch.isEnabled = false
                self._stringIsALocationSwitch.isOn = false
                self._allStringsMustMatchSwitch.isOn = false
                self._exactMatchSwitch.isOn = false
            } else {
                self._stringIsALocationSwitch.isEnabled = true
                self._allStringsMustMatchSwitch.isEnabled = true
                self._exactMatchSwitch.isEnabled = true
            }
            
            self.determineRadiusEnabling()
            
            if nil != self._clearButton {
                var enabled: Bool = !self._stringSearchTextEntry.text!.isEmpty
                
                for cb in self.allCheckboxes where cb._selectionState != .Clear {
                    enabled = true
                    break
                }
                
                if nil != self.mapMarkerAnnotation {
                    enabled = true
                }
                
                if BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.isDirty {
                    enabled = true
                }
                
                self._clearButton.isEnabled = enabled
            }
        }
    }

    /* ################################################################## */
    /**
     */
    func determineRadiusEnabling() {
        if nil != self._useLocationSwitch {
            let enabled = self._stringIsALocationSwitch.isOn || self._useLocationSwitch.isOn
            let wasEnabled = self._autoRadiusSwitch.isEnabled
            
            if enabled {
                self._autoRadiusSwitch.isEnabled = true
                self._radiusTextEntry.isEnabled = true
                self._radiusTextEntry.backgroundColor = UIColor.white
                self._radiusTextEntry.textColor = UIColor.black
            } else {
                self._autoRadiusSwitch.isEnabled = false
                self._radiusTextEntry.isEnabled = false
                self._radiusTextEntry.backgroundColor = UIColor.lightGray
                self._radiusTextEntry.textColor = UIColor.darkGray
            }
            
            if enabled != wasEnabled {
                self._autoRadiusSwitch.isOn = true
                self._radiusLabel.text = "Meetings"
                self._radiusTextEntry.placeholder = "Enter a Number of"
                self._radiusTextEntry.keyboardType = .numberPad
                self._radiusTextEntry.text = (enabled ? "10" : "")
            }
            
            if self._stringIsALocationSwitch.isOn {
                self._useLocationSwitch.isOn = false
                self._useLocationSwitch.isEnabled = false
            } else {
                self._useLocationSwitch.isEnabled = true
            }
            
            if self._useLocationSwitch.isOn && (nil == self.mapMarkerAnnotation) {
                self.mapMarkerAnnotation = BMLTiOSLibTesterAnnotation(coordinate: self._mapView.centerCoordinate)
                self._mapView.addAnnotation(self.mapMarkerAnnotation)
                self._mapView.isZoomEnabled = true
                self._mapView.isRotateEnabled = true
                self._mapView.isScrollEnabled = true
                BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.searchLocation = self._mapView.centerCoordinate
            } else {
                if nil != self.mapMarkerAnnotation {
                    self._mapView.removeAnnotation(self.mapMarkerAnnotation)
                }
                self.mapMarkerAnnotation = nil
                self._mapView.isZoomEnabled = false
                self._mapView.isRotateEnabled = false
                self._mapView.isScrollEnabled = false
                BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.searchLocation = nil
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func tappedInBackground(_ sender: UITapGestureRecognizer) {
        if nil != self._radiusTextEntry {
            self._radiusTextEntry.resignFirstResponder()
        }
        
        if nil != self._stringSearchTextEntry {
            self._stringSearchTextEntry.resignFirstResponder()
        }
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func radiusSwitchChanged(_ sender: UISwitch) {
        var labelString: String = ""
        var promptString: String = ""
        
        if sender.isOn {
            labelString = "Meetings"
            promptString = "Enter a Number of"
            self._radiusTextEntry.keyboardType = .numberPad
            self._radiusTextEntry.text = "10"
        } else {
            labelString = ((BMLTiOSLibTesterAppDelegate.libraryObject.distanceUnitsString == "km") ? "Kilometers" : (BMLTiOSLibTesterAppDelegate.libraryObject.distanceUnitsString == "mi") ? "Miles" : "ERROR!")
            promptString = "Search Radius in"
            self._radiusTextEntry.keyboardType = .decimalPad
            self._radiusTextEntry.text = ""
        }
        
        self._radiusLabel.text = labelString
        self._radiusTextEntry.placeholder = promptString
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func searchStringLocationSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            self._allStringsMustMatchSwitch.isOn = false
            self._allStringsMustMatchSwitch.isEnabled = false
            self._exactMatchSwitch.isOn = false
            self._exactMatchSwitch.isEnabled = false
        } else {
            self._allStringsMustMatchSwitch.isEnabled = true
            self._exactMatchSwitch.isEnabled = true
        }
        
        self.determineRadiusEnabling()
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func searchTypeSegmentedControlChanged(_ inSegmentedControl: UISegmentedControl) {
        switch inSegmentedControl.selectedSegmentIndex {
        case 1:
            self.searchType = .MeetingsAndFormats
            
        case 2:
            self.searchType = .MeetingsOnly
            
        default:
            self.searchType = .FormatsOnly
        }
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func _searchHit(_ sender: AnyObject) {
        var searchResultsType: BMLTiOSLibSearchCriteria.SearchCriteriaExtent = .BothMeetingsAndFormats
        self._searchButton.isEnabled = false
        self._viewFormatsButton.isEnabled = false
        self._viewMeetingsButton.isEnabled = false
        self.meetingSearchResults = nil
        self.formatSearchResults = nil
        
        switch self.searchType {
        case .FormatsOnly:
            searchResultsType = .FormatsOnly
            
        case .MeetingsOnly:
            searchResultsType = .MeetingsOnly
            
        default:
            break
        }
        
        if (nil != self._stringIsALocationSwitch) && (nil != self._stringSearchTextEntry) {
            BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.searchString = self._stringSearchTextEntry.text!
            if self._stringIsALocationSwitch.isOn {
                BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.searchStringIsALocation = true
            } else {
                BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.stringSearchIsExact = self._exactMatchSwitch.isOn
                BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.stringSearchUsesAllStrings = self._allStringsMustMatchSwitch.isOn
            }
        }
        
        if (nil != self._autoRadiusSwitch) && (nil != self._radiusTextEntry) {
            if self._autoRadiusSwitch.isEnabled && !(self._radiusTextEntry.text?.isEmpty)! && (0 != Float(self._radiusTextEntry.text!)) {
                var radius = abs(Float(self._radiusTextEntry.text!)!)
                
                if self._autoRadiusSwitch.isOn {
                    radius = -trunc(radius)
                }
                
                BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.searchRadius = radius
            }
        }
        
        BMLTiOSLibTesterAppDelegate.libraryObject.performMeetingSearch(searchResultsType)
    }
    
    /* ################################################################## */
    /**
     */
    @objc func useLocationSwitchChanged(_ : UISwitch) {
        self.determineStringItemsEnabling()
        self.determineRadiusEnabling()
    }
    
    /* ################################################################## */
    /**
     */
    @objc func clearButtonHit(_ : UIButton) {
        self.clearSearchCriteria()
    }
    
    /* ################################################################## */
    /**
     */
    func getOneMeetingByID(_ inMeetingID: Int) {
        self._searchButton.isEnabled = false
        self._viewFormatsButton.isEnabled = false
        self._viewMeetingsButton.isEnabled = false
        self.meetingSearchResults = nil
        self.formatSearchResults = nil
        self.clearSearchCriteria()
        BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.searchString = String(inMeetingID)
        BMLTiOSLibTesterAppDelegate.libraryObject.performMeetingSearch(.MeetingsOnly)
    }
    
    /* ################################################################## */
    /**
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.destination is MeetingSearchResultsViewController {
            (segue.destination as? MeetingSearchResultsViewController)?.meetingSearchResults = self.meetingSearchResults
        } else {
            if segue.destination is FormatSearchResultsViewController {
                (segue.destination as? FormatSearchResultsViewController)?.formatSearchResults = self.formatSearchResults
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func populateServiceBodyContainer(inServiceBody: BMLTiOSLibHierarchicalServiceBodyNode, inContainerView: UIView) {
        var bounds = CGRect.zero
        
        if nil != inServiceBody.serviceBody {
            bounds = CGRect.zero
        
            bounds.size.width = self.checkboxRowHeight
            bounds.size.height = self.checkboxRowHeight
            
            let newCheckboxObject = BMLTiOSLibCheckbox(frame: bounds)
            if let sbElement = BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.getServiceBodyElementFromServiceBodyObject(inServiceBody) {
                newCheckboxObject.extraData = sbElement as AnyObject?
                inServiceBody.extraData = newCheckboxObject as AnyObject?
                
                self.allCheckboxes.append(newCheckboxObject)
                
                newCheckboxObject.addTarget(self, action: #selector(serviceBodyCheckboxChanged(_:)), for: UIControl.Event.valueChanged)
                
                bounds.size.height = self.checkboxRowHeight
                bounds.size.width = (inContainerView.bounds.width - (bounds.size.height + 4))
                bounds.origin.x += (bounds.size.height + 4)
                
                let newLabelObject = UILabel(frame: bounds)
                newLabelObject.text = inServiceBody.name
                newLabelObject.backgroundColor = UIColor.clear
                newLabelObject.textColor = UIColor.white
                newLabelObject.font = (0 < inServiceBody.children.count) ? UIFont.boldSystemFont(ofSize: 15) : UIFont.italicSystemFont(ofSize: 14)
                
                inContainerView.frame.size.height += checkboxRowHeight
                
                inContainerView.addSubview(newCheckboxObject)
                inContainerView.addSubview(newLabelObject)
            }
        }
        
        bounds.origin.y = inContainerView.frame.size.height
        bounds.origin.x = checkboxRowHeight / 2
        bounds.size.width = inContainerView.bounds.size.width - bounds.origin.x
        
        for child in inServiceBody.children {
            bounds.size.height = 0
            
            let newContainer = UIView(frame: bounds)
            
            self.populateServiceBodyContainer(inServiceBody: child, inContainerView: newContainer)
            
            inContainerView.frame.size.height += newContainer.frame.size.height
            inContainerView.addSubview(newContainer)
            
            bounds.origin.y += newContainer.frame.size.height
        }
    }
    
    /* ################################################################## */
    /**
     */
    func populateFormatContainer(inContainerView: UIView) {
        var bounds = CGRect.zero
        
        if let searchCriteria = BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria {
            for format in searchCriteria.formats {
                bounds.size.width = self.checkboxRowHeight
                bounds.size.height = self.checkboxRowHeight
                bounds.origin.x = self.checkboxRowHeight / 2
                
                let newCheckboxObject = BMLTiOSLibCheckbox(frame: bounds)
                self.formatMap[newCheckboxObject] = format
                newCheckboxObject.addTarget(self, action: #selector(formatCheckboxChanged(_:)), for: UIControl.Event.valueChanged)
                self.allCheckboxes.append(newCheckboxObject)
                
                bounds.size.height = self.checkboxRowHeight
                bounds.size.width = (inContainerView.bounds.width - (bounds.origin.x + self.checkboxRowHeight + 4))
                bounds.origin.x += (self.checkboxRowHeight + 4)
                
                let newLabelObject = UILabel(frame: bounds)
                newLabelObject.text = (format.item.key)! + " (" + (format.item.name)! + ")"
                newLabelObject.backgroundColor = UIColor.clear
                newLabelObject.textColor = UIColor.white
                newLabelObject.font = UIFont.italicSystemFont(ofSize: 14)
                
                inContainerView.frame.size.height += checkboxRowHeight
                
                inContainerView.addSubview(newCheckboxObject)
                inContainerView.addSubview(newLabelObject)
                bounds.origin.y += self.checkboxRowHeight
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func clearSearchCriteria() {
        for checkbox in self.allCheckboxes {
            checkbox.selectionState = .Clear
            checkbox.sendActions(for: UIControl.Event.touchUpInside)
        }
        
        if nil != self._mapView {
            if nil != self.mapMarkerAnnotation {
                self._mapView.removeAnnotation(self.mapMarkerAnnotation)
                self.mapMarkerAnnotation = nil
            }
            
            let mapLocation = BMLTiOSLibTesterAppDelegate.libraryObject.defaultLocation
            let span = MKCoordinateSpan(latitudeDelta: type(of: self).sMapSizeInDegrees, longitudeDelta: 0)
            let newRegion: MKCoordinateRegion = MKCoordinateRegion(center: mapLocation, span: span)
            self._mapView.setRegion(newRegion, animated: false)
        }
        
        if nil != self._stringSearchTextEntry {
            self._stringSearchTextEntry.text = ""
            self.determineStringItemsEnabling()
        }
        
        if nil != self._durationSelectionContainer {
            self._durationSwitch.isOn = false
            self.durationSwitchChanged(self._durationSwitch)
        }

        if nil != self._startEndTimeContainerView {
            self._startTimeSwitch.isOn = false
            self.startTimeSwitchChanged(self._startTimeSwitch)
            self._endTimeSwitch.isOn = false
            self.endTimeSwitchChanged(self._endTimeSwitch)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func updateMeetingSearchResults(inMeetings: [BMLTiOSLibMeetingNode]) {
        self.meetingSearchResults = inMeetings
        self.view.setNeedsLayout()
    }
    
    /* ################################################################## */
    /**
     */
    func updateFormatSearchResults(inFormats: [BMLTiOSLibFormatNode]) {
        self.formatSearchResults = inFormats
        self.view.setNeedsLayout()
    }
    
    /* ################################################################## */
    /**
     */
    func updateChangeResults(inChanges: [BMLTiOSLibChangeNode]) {
        if let displayedSingleMeeting = self.navigationController?.topViewController as? SingleMeetingViewController {
            displayedSingleMeeting.displayChanges()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func deleteSuccessful(_ inSuccessful: Bool) {
        if let displayedSingleMeeting = self.navigationController?.topViewController as? SingleMeetingViewController {
            displayedSingleMeeting.deleteSuccessful(inSuccessful)
        }
    }

    // MARK: - UITableViewDataSource Delegate Handlers -
    
    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Got this tip from here: http://natecook.com/blog/2014/10/loopy-random-enum-ideas/
        var max: Int = 0
        while nil != TableRows(rawValue: max) { max += 1 }
        
        return max
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var ret: CGFloat = 0
        
        switch indexPath.row {
        case TableRows.ClearButtonRow.rawValue:
            ret = self.clearButtonRowHeight
            
        case TableRows.StartEndTimeRow.rawValue:
            ret = self.startEndRowHeight
            
        case TableRows.DurationTimeRow.rawValue:
            ret = self.durationTimeRowHeight
            
        case TableRows.SearchStringRow.rawValue:
            ret = self.searchStringRowHeight
            
        case TableRows.LocationRadiusRow.rawValue:
            ret = self.locationRadiusRowHeight
            
        case TableRows.MapRow.rawValue:
            ret = tableView.bounds.size.width + self.mapRowExtraHeight
            
        case TableRows.WeekdayRow.rawValue:
            ret = self.weekdayRowHeight
            
        case TableRows.ServiceBodyRow.rawValue:
            ret = (CGFloat(BMLTiOSLibTesterAppDelegate.libraryObject.serviceBodies.count) * (self.checkboxRowHeight + 1))
            
        case TableRows.FormatRow.rawValue:
            let formats = BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.formats
            
            ret = (CGFloat(formats.count) * (self.checkboxRowHeight + 1))
            
        default:
            break
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var ret: UITableViewCell! = nil
        let reuseIDs = [TableRows.ClearButtonRow.rawValue: "ClearButtonRow",
                        TableRows.StartEndTimeRow.rawValue: "SearchByStartTimeAndEndTimeCellView",
                        TableRows.DurationTimeRow.rawValue: "SearchMeetingDurationCellView",
                        TableRows.SearchStringRow.rawValue: "SearchStringCell",
                        TableRows.LocationRadiusRow.rawValue: "SearchRadiusCell",
                        TableRows.MapRow.rawValue: "SearchViewControllerMapView",
                        TableRows.WeekdayRow.rawValue: "SearchWeekdaysCell",
                        TableRows.ServiceBodyRow.rawValue: "SearchServiceBodyCell",
                        TableRows.FormatRow.rawValue: "SearchFormatCell"]
        
        if let reuseID = reuseIDs[indexPath.row] {
            ret = tableView.dequeueReusableCell(withIdentifier: reuseIDs[indexPath.row]!)
            
            if nil == ret {
                ret = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: reuseID)
                
                ret.backgroundColor = UIColor.clear
                
                switch indexPath.row {
                case TableRows.ClearButtonRow.rawValue:
                    ret = self.handleClearButtonRow(tableView, indexPath: indexPath, ret: ret, reuseID: reuseID)

                case TableRows.StartEndTimeRow.rawValue:
                    ret = self.handleStartTimeRow(tableView, indexPath: indexPath, ret: ret, reuseID: reuseID)

                case TableRows.DurationTimeRow.rawValue:
                    ret = self.handleDurationRow(tableView, indexPath: indexPath, ret: ret, reuseID: reuseID)

                case TableRows.SearchStringRow.rawValue:
                    ret = self.handleSearchStringRow(tableView, indexPath: indexPath, ret: ret, reuseID: reuseID)

                case TableRows.LocationRadiusRow.rawValue:
                    ret = self.handleLocationRow(tableView, indexPath: indexPath, ret: ret, reuseID: reuseID)
                    
                case TableRows.MapRow.rawValue:
                    ret = self.handleMapRow(tableView, indexPath: indexPath, ret: ret, reuseID: reuseID)

                case TableRows.WeekdayRow.rawValue:
                    ret = self.handleWeekdayRow(tableView, indexPath: indexPath, ret: ret, reuseID: reuseID)

                case TableRows.ServiceBodyRow.rawValue:
                    ret = self.handleServiceBodyRow(tableView, indexPath: indexPath, ret: ret, reuseID: reuseID)

                case TableRows.FormatRow.rawValue:
                    ret = self.handleFormatRow(tableView, indexPath: indexPath, ret: ret, reuseID: reuseID)
                    
                default:
                    break
                }
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     */
    func handleClearButtonRow(_ tableView: UITableView, indexPath: IndexPath, ret: UITableViewCell, reuseID: String) -> UITableViewCell {
        var bounds: CGRect = CGRect.zero
        bounds.size.height = self.tableView(tableView, heightForRowAt: indexPath)
        bounds.size.width = tableView.bounds.size.width
        ret.bounds = bounds
        if nil == self._clearButton {
            self._clearButton = UIButton(frame: bounds)
            self._clearButton.setTitle("Clear Search Criteria", for: UIControl.State.normal)
            self._clearButton.setTitleColor(UIColor(red: 0.5, green: 0.6, blue: 1, alpha: 1), for: UIControl.State.normal)
            self._clearButton.setTitleColor(UIColor.lightGray, for: UIControl.State.disabled)
            self._clearButton.addTarget(self, action: #selector(SearchViewController.clearButtonHit(_:)), for: UIControl.Event.touchUpInside)
            self._clearButton.isEnabled = false
            ret.addSubview(self._clearButton)
        }
        
        return ret
    }

    /* ################################################################## */
    /**
     */
    func handleStartTimeRow(_ tableView: UITableView, indexPath: IndexPath, ret: UITableViewCell, reuseID: String) -> UITableViewCell {
        if nil == self._startEndTimeContainerView {
            _ = UINib(nibName: reuseID, bundle: nil).instantiate(withOwner: self, options: nil)[0]
        }
        
        if nil != self._startEndTimeContainerView {
            var bounds: CGRect = CGRect.zero
            bounds.size.height = self.tableView(tableView, heightForRowAt: indexPath)
            bounds.size.width = tableView.bounds.size.width
            self._startsAfterDatePicker.setValue(UIColor.white, forKey: "textColor")
            self._endsBeforeDatePicker.setValue(UIColor.white, forKey: "textColor")
            self._startsAfterSegmentedControlView.isEnabled = false
            self._startsAfterDatePicker.isEnabled = false
            self._endsBeforeDatePicker.isEnabled = false
            ret.bounds = bounds
            self._startEndTimeContainerView.frame = bounds
            ret.addSubview(self._startEndTimeContainerView)
        }
        
        return ret
    }

    /* ################################################################## */
    /**
     */
    func handleDurationRow(_ tableView: UITableView, indexPath: IndexPath, ret: UITableViewCell, reuseID: String) -> UITableViewCell {
        if nil == self._durationSelectionContainer {
            _ = UINib(nibName: reuseID, bundle: nil).instantiate(withOwner: self, options: nil)[0]
        }
        
        if nil != self._durationSelectionContainer {
            var bounds: CGRect = CGRect.zero
            bounds.size.height = self.tableView(tableView, heightForRowAt: indexPath)
            bounds.size.width = tableView.bounds.size.width
            self._durationTimePicker.setValue(UIColor.white, forKey: "textColor")
            self._durationTypeSegmentedControl.isEnabled = false
            self._durationTimePicker.isEnabled = false
            ret.bounds = bounds
            self._durationTimePicker.frame = bounds
            ret.addSubview(self._durationSelectionContainer)
        }
        
        return ret
    }

    /* ################################################################## */
    /**
     */
    func handleSearchStringRow(_ tableView: UITableView, indexPath: IndexPath, ret: UITableViewCell, reuseID: String) -> UITableViewCell {
        if nil == self._stringSearchCellView {
            _ = UINib(nibName: reuseID, bundle: nil).instantiate(withOwner: self, options: nil)[0]
        }
        
        if nil != self._stringSearchCellView {
            var bounds: CGRect = CGRect.zero
            bounds.size.height = self.tableView(tableView, heightForRowAt: indexPath)
            bounds.size.width = tableView.bounds.size.width
            ret.bounds = bounds
            self._stringSearchCellView.frame = bounds
            ret.addSubview(self._stringSearchCellView)
        }
        
        return ret
    }

    /* ################################################################## */
    /**
     */
    func handleLocationRow(_ tableView: UITableView, indexPath: IndexPath, ret: UITableViewCell, reuseID: String) -> UITableViewCell {
        if nil == self._locationRadiusCellView {
            _ = UINib(nibName: reuseID, bundle: nil).instantiate(withOwner: self, options: nil)[0]
        }
        
        if nil != self._locationRadiusCellView {
            var bounds: CGRect = CGRect.zero
            bounds.size.height = self.tableView(tableView, heightForRowAt: indexPath)
            bounds.size.width = tableView.bounds.size.width
            ret.bounds = bounds
            self._locationRadiusCellView.frame = bounds
            ret.addSubview(self._locationRadiusCellView)
        }
        
        return ret
    }

    /* ################################################################## */
    /**
     */
    func handleMapRow(_ tableView: UITableView, indexPath: IndexPath, ret: UITableViewCell, reuseID: String) -> UITableViewCell {
        var bounds: CGRect = CGRect.zero
        bounds.size.height = self.tableView(tableView, heightForRowAt: indexPath)
        bounds.size.width = tableView.bounds.size.width
        ret.bounds = bounds
        
        let mapContainer = UIView(frame: bounds)
        
        if nil == self._mapView {
            _ = UINib(nibName: reuseID, bundle: nil).instantiate(withOwner: self, options: nil)[0]
            
            if nil != self._mapView {
                bounds.size.height -= self.mapRowExtraHeight
                bounds.origin.y = self.mapRowExtraHeight
                
                self._mapView.frame = bounds
                
                bounds.size.height = 31
                bounds.origin.y = 8
                bounds.origin.x = 8
                
                self._useLocationSwitch = UISwitch(frame: bounds)
                self._useLocationSwitch.isOn = false
                self._useLocationSwitch.addTarget(self, action: #selector(SearchViewController.useLocationSwitchChanged(_:)), for: UIControl.Event.valueChanged)
                mapContainer.addSubview(self._useLocationSwitch)
                
                bounds.origin.y = 8
                bounds.origin.x = 61
                bounds.size.height = 31
                bounds.size.width = tableView.bounds.size.width - bounds.origin.x
                self._useLocationLabel = UILabel(frame: bounds)
                self._useLocationLabel.backgroundColor = UIColor.clear
                self._useLocationLabel.textColor = UIColor.white
                self._useLocationLabel.font = UIFont.boldSystemFont(ofSize: 17)
                self._useLocationLabel.text = "Use Map Location:"
                mapContainer.addSubview(self._useLocationLabel)
                
                let mapLocation = BMLTiOSLibTesterAppDelegate.libraryObject.defaultLocation
                let span = MKCoordinateSpan(latitudeDelta: type(of: self).sMapSizeInDegrees, longitudeDelta: 0)
                let newRegion: MKCoordinateRegion = MKCoordinateRegion(center: mapLocation, span: span)
                self._mapView.setRegion(newRegion, animated: false)
            }
        }
        
        if nil != self._mapView {
            mapContainer.addSubview(self._mapView)
            ret.addSubview(mapContainer)
        }
        
        return ret
    }

    /* ################################################################## */
    /**
     */
    func handleWeekdayRow(_ tableView: UITableView, indexPath: IndexPath, ret: UITableViewCell, reuseID: String) -> UITableViewCell {
        if nil == self._weekdayListCellView {
            _ = UINib(nibName: reuseID, bundle: nil).instantiate(withOwner: self, options: nil)[0]
            
            self.allCheckboxes.append(self.sundayButton)
            self.allCheckboxes.append(self.mondayButton)
            self.allCheckboxes.append(self.tuesdayButton)
            self.allCheckboxes.append(self.wednesdayButton)
            self.allCheckboxes.append(self.thursdayButton)
            self.allCheckboxes.append(self.fridayButton)
            self.allCheckboxes.append(self.saturdayButton)
            
            self.sundayButton.addTarget(self, action: #selector(weekdayCheckboxChanged(_:)), for: UIControl.Event.valueChanged)
            self.mondayButton.addTarget(self, action: #selector(weekdayCheckboxChanged(_:)), for: UIControl.Event.valueChanged)
            self.tuesdayButton.addTarget(self, action: #selector(weekdayCheckboxChanged(_:)), for: UIControl.Event.valueChanged)
            self.wednesdayButton.addTarget(self, action: #selector(weekdayCheckboxChanged(_:)), for: UIControl.Event.valueChanged)
            self.thursdayButton.addTarget(self, action: #selector(weekdayCheckboxChanged(_:)), for: UIControl.Event.valueChanged)
            self.fridayButton.addTarget(self, action: #selector(weekdayCheckboxChanged(_:)), for: UIControl.Event.valueChanged)
            self.saturdayButton.addTarget(self, action: #selector(weekdayCheckboxChanged(_:)), for: UIControl.Event.valueChanged)
            
            self.setWeekdayButtons()
        }
        
        if nil != self._weekdayListCellView {
            var bounds: CGRect = CGRect.zero
            bounds.size.height = self.tableView(tableView, heightForRowAt: indexPath)
            bounds.size.width = tableView.bounds.size.width
            ret.bounds = bounds
            self._weekdayListCellView.frame = bounds
            ret.addSubview(self._weekdayListCellView)
        }
        
        return ret
    }

    /* ################################################################## */
    /**
     */
    func handleServiceBodyRow(_ tableView: UITableView, indexPath: IndexPath, ret: UITableViewCell, reuseID: String) -> UITableViewCell {
        if nil == self._serviceBodyListCellView {
            _ = UINib(nibName: reuseID, bundle: nil).instantiate(withOwner: self, options: nil)[0]
            self._serviceBodyListCellView.frame.size.height = self._serviceBodyLabel.frame.size.height
            self._serviceBodyListCellView.frame.size.width = self.view.bounds.size.width
            self._serviceBodyCheckboxContainerView.frame.size.width = self.view.bounds.size.width
            self._serviceBodyCheckboxContainerView.frame.size.height = 0
            self.populateServiceBodyContainer(inServiceBody: BMLTiOSLibTesterAppDelegate.libraryObject.hierarchicalServiceBodies, inContainerView: self._serviceBodyCheckboxContainerView)
            self._serviceBodyListCellView.frame.size.height += self._serviceBodyCheckboxContainerView.frame.size.height
        }
        
        if nil != self._serviceBodyListCellView {
            var bounds: CGRect = CGRect.zero
            bounds.size.height = self.tableView(tableView, heightForRowAt: indexPath)
            bounds.size.width = tableView.bounds.size.width
            ret.bounds = bounds
            self._serviceBodyListCellView.frame = bounds
            ret.addSubview(self._serviceBodyListCellView)
        }
        
        return ret
    }

    /* ################################################################## */
    /**
     */
    func handleFormatRow(_ tableView: UITableView, indexPath: IndexPath, ret: UITableViewCell, reuseID: String) -> UITableViewCell {
        if nil == self._formatListCellView {
            _ = UINib(nibName: reuseID, bundle: nil).instantiate(withOwner: self, options: nil)[0]
            self._formatListCellView.frame.size.height = self._formatLabel.frame.size.height
            self._formatListCellView.frame.size.width = self.view.bounds.size.width
            self._formatCheckboxContainerView.frame.size.width = self.view.bounds.size.width
            self._formatCheckboxContainerView.frame.size.height = 0
            self.populateFormatContainer(inContainerView: self._formatCheckboxContainerView)
            self._formatCheckboxContainerView.frame.size.height += self._formatCheckboxContainerView.frame.size.height
        }
        
        if nil != self._formatListCellView {
            var bounds: CGRect = CGRect.zero
            bounds.size.height = self.tableView(tableView, heightForRowAt: indexPath)
            bounds.size.width = tableView.bounds.size.width
            ret.bounds = bounds
            self._formatListCellView.frame = bounds
            ret.addSubview(self._formatListCellView)
        }
        
        return ret
    }

    // MARK: - UITextFieldDelegate Handlers -
    
    /* ################################################################## */
    /**
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.determineStringItemsEnabling()
        return true
    }
    
    // MARK: - MKMapViewDelegate Methods -
    /* ################################################################## */
    /**
     */
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: BMLTiOSLibTesterAnnotation.self) && self._useLocationSwitch.isOn {
            let reuseID = ""
            let myAnnotation = annotation as? BMLTiOSLibTesterAnnotation
            return BMLTiOSLibTesterMarker(annotation: myAnnotation, draggable: true, reuseID: reuseID)
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     */
    public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        if (MKAnnotationView.DragState.none == newState) && (MKAnnotationView.DragState.dragging == oldState) {
            if let mapLocation = view.annotation?.coordinate {
                let span = self._mapView.region.span
                let newRegion: MKCoordinateRegion = MKCoordinateRegion(center: mapLocation, span: span)
                self._mapView.setRegion(newRegion, animated: true)
                BMLTiOSLibTesterAppDelegate.libraryObject.searchCriteria.searchLocation = mapLocation
            }
        }
    }
}
