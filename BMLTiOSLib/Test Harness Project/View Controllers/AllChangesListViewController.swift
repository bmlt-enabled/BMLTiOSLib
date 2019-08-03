//
//  AllChangesListViewController.swift
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

import UIKit
import BMLTiOSLib

/* ###################################################################################################################################### */
/**
 */
class AllChangesListViewController: BaseTestViewController {
    let checkboxRowHeight: CGFloat = 30

    var changesObjects: [BMLTiOSLibChangeNode]! = nil
    var allCheckboxes: [BMLTiOSLibCheckbox] = []
    var checboxBeingHit: BMLTiOSLibCheckbox! = nil

    @IBOutlet weak var selectionCriteriaContainerView: UIView!
    @IBOutlet weak var fromDatePicker: UIDatePicker!
    @IBOutlet weak var toDatePicker: UIDatePicker!
    @IBOutlet weak var serviceBodyScroller: UIScrollView!
    @IBOutlet weak var getChangesButton: UIBarButtonItem!
    @IBOutlet weak var onlyDeletedSwitch: UISwitch!

    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        var scrollerBounds = self.serviceBodyScroller.bounds
        scrollerBounds.size.height = 0
        
        let containerView = UIView(frame: scrollerBounds)
        
        self.populateServiceBodyContainer(inServiceBody: BMLTiOSLibTesterAppDelegate.libraryObject.hierarchicalServiceBodies, inContainerView: containerView)
        
        self.serviceBodyScroller.addSubview(containerView)
        
        self.serviceBodyScroller.contentSize = containerView.frame.size
        
        self.fromDatePicker.setValue(UIColor.white, forKey: "textColor")
        self.toDatePicker.setValue(UIColor.white, forKey: "textColor")
        self.getChangesButton.isEnabled = true
    }
    
    /* ################################################################## */
    /**
     */
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let newController = segue.destination as? ChangeListViewController {
            newController.changesObjects = self.changesObjects
        }
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func getChangesButtonHit(_ sender: UIBarButtonItem) {
        self.getChangesButton.isEnabled = false
        let date = Date()
        let thisYear = NSCalendar.current.component(Calendar.Component.year, from: date)
        let thisMonth = NSCalendar.current.component(Calendar.Component.month, from: date)
        let thisDay = NSCalendar.current.component(Calendar.Component.day, from: date)
        let fromYear = NSCalendar.current.component(Calendar.Component.year, from: self.fromDatePicker.date)
        let fromMonth = NSCalendar.current.component(Calendar.Component.month, from: self.fromDatePicker.date)
        let fromDay = NSCalendar.current.component(Calendar.Component.day, from: self.fromDatePicker.date)
        let toYear = NSCalendar.current.component(Calendar.Component.year, from: self.toDatePicker.date)
        let toMonth = NSCalendar.current.component(Calendar.Component.month, from: self.toDatePicker.date)
        let toDay = NSCalendar.current.component(Calendar.Component.day, from: self.toDatePicker.date)
        
        var fromDate: Date! = nil
        var toDate: Date! = nil
        var serviceBodyID: Int! = nil
        
        if ((toYear <= thisYear) && (toMonth <= thisMonth) && (toDay <= thisDay))
            && ((toYear < thisYear) || (toMonth < thisMonth) || (toDay < thisDay)) {
            toDate = self.toDatePicker.date
        }
        
        if ((fromYear <= thisYear) && (fromMonth <= thisMonth) && (fromDay <= thisDay))
            && ((fromYear <= toYear) || (fromMonth <= toYear) || (fromDay <= toYear))
            && ((fromYear < thisYear) || (fromMonth < thisMonth) || (fromDay < thisDay)) {
            fromDate = self.fromDatePicker.date
        }
        
        for checkbox in self.allCheckboxes where checkbox.selectionState != .Clear {
            if let sb1 = checkbox.extraData as? BMLTiOSLibServiceBodyContainer {
                serviceBodyID = sb1.item.id
            }
        }
        
        if self.onlyDeletedSwitch.isOn {
            BMLTiOSLibTesterAppDelegate.libraryObject.getDeletedMeetingChanges(fromDate: fromDate, toDate: toDate, serviceBodyID: serviceBodyID)
        } else {
            BMLTiOSLibTesterAppDelegate.libraryObject.getAllMeetingChanges(fromDate: fromDate, toDate: toDate, serviceBodyID: serviceBodyID)
        }
    }
    
    /* ################################################################## */
    /**
     */
    @objc func serviceBodyCheckboxChanged(_ inServiceBodyCheckboxObject: BMLTiOSLibCheckbox) {
        let originalValue: BMLTiOSLibCheckbox! = self.checboxBeingHit
        
        if nil == self.checboxBeingHit {
            self.checboxBeingHit = inServiceBodyCheckboxObject
        }
        
        for checkbox in self.allCheckboxes {
            if (checkbox.selectionState != .Clear) && (checkbox != self.checboxBeingHit) {
                checkbox.selectionState = .Clear
            }
        }
        
        self.checboxBeingHit = originalValue
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
                newCheckboxObject.binaryState = true
                inServiceBody.extraData = newCheckboxObject as AnyObject?
                
                self.allCheckboxes.append(newCheckboxObject)
                
                newCheckboxObject.addTarget(self, action: #selector(serviceBodyCheckboxChanged(_:)), for: UIControl.Event.valueChanged)
                
                bounds.size.height = self.checkboxRowHeight
                bounds.size.width = ((inContainerView.bounds.width) - (bounds.size.height + 4))
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
        
        bounds.origin.y = (inContainerView.frame.size.height)
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
    func updateChangeResults(inChanges: [BMLTiOSLibChangeNode]) {
        if nil != self.getChangesButton {
            self.getChangesButton.isEnabled = true
        }
        
        self.changesObjects = inChanges
        
        if 0 < inChanges.count {
            self.performSegue(withIdentifier: "show-changes", sender: self)
        }
    }
}
