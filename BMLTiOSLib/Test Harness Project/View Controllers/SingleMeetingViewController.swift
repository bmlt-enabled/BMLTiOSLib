//
//  SingleMeetingViewController.swift
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
import MapKit
import BMLTiOSLib

// Cribbed from here: http://stackoverflow.com/a/37494260/879365

extension UIViewController {
    var backViewController: UIViewController? {
        if let stack = self.navigationController?.viewControllers {
            for i in (1..<stack.count).reversed() where stack[i] == self {
                return stack[i-1]
            }
        }
        return nil
    }
}

/* ###################################################################################################################################### */
/**
 */
public class BMLTiOSLibEditorView: UITextView {
    var meetingObject: BMLTiOSLibMeetingNode!
    var key: String = ""
}

/* ###################################################################################################################################### */
/**
 */
public class SingleMeetingViewController: BaseTestViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, MKMapViewDelegate {
    static let sMapSizeInDegrees: CLLocationDegrees         =   0.15

    var meetingObject: BMLTiOSLibMeetingNode! = nil
    
    let deletePrompt   = "Delete"
    let publishPrompt   = "Publish"
    let unpublishPrompt   = "Unpublish"
    
    var publishedTextField: BMLTiOSLibEditorView!    = nil
    var mapMarkerAnnotation: BMLTiOSLibTesterAnnotation!    =   nil
    
    @IBOutlet weak var displayTableView: UITableView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var publishButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var getChangesButton: UIBarButtonItem!
    @IBOutlet weak var messageButton: UIBarButtonItem!
    @IBOutlet weak var _mapView: MKMapView!
    
    /* ################################################################## */
    /**
     */
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.displayTableView.reloadData()
        self.enableDisableMessage()
    }
    
    /* ################################################################## */
    /**
     */
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpPublishButton()
        self.displayTableView.reloadData()
    }
    
    /* ################################################################## */
    /**
     */
    func enableDisableMessage() {
        if nil != self.messageButton {
            self.messageButton.isEnabled = false
            if (nil != self.meetingObject) && BMLTiOSLibTesterAppDelegate.libraryObject.emailMeetingContactsEnabled {
                self.messageButton.isEnabled = true
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func enableDisableSave() {
        if (nil != self.meetingObject) && self.meetingObject.isEditable {
            if nil != self.deleteButton {
                self.deleteButton.title = self.deletePrompt
            }
            self.saveButton.isEnabled = self.meetingObject.isDirty
            self.displayTableView.backgroundColor = (self.meetingObject.isEditable && !self.meetingObject.published) ? UIColor(red: 0.75, green: 0.25, blue: 0, alpha: 0.5) : UIColor.clear
        }
    }
    
    /* ################################################################## */
    /**
     */
    func setUpPublishButton() {
        if nil != self.meetingObject {
            if self.meetingObject.isEditable {
                self.publishButton.isEnabled = true
                self.publishButton.title = self.meetingObject.published ? self.unpublishPrompt : self.publishPrompt
                enableDisableSave()
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func resetAndClose(_ inAction: UIAlertAction) {
        if nil != self.meetingObject {
            (self.meetingObject as? BMLTiOSLibEditableMeetingNode)?.restoreToOriginal()
        }
        self.navigationController!.popViewController(animated: true)
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func publishButtonHit(_ sender: UIBarButtonItem) {
        if (nil != self.meetingObject) && self.meetingObject.isEditable {
            (self.meetingObject as? BMLTiOSLibEditableMeetingNode)?.published = !self.meetingObject.published
            
            if nil != self.publishedTextField {
                self.publishedTextField.text = (self.meetingObject.published ? "1" : "0")
            }
            
            self.setUpPublishButton()
        }
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func getChangesButtonHit(_ sender: UIBarButtonItem) {
        sender.isEnabled = false
        self.meetingObject.getChanges()
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func deleteButtonHit(_ sender: UIBarButtonItem) {
        sender.isEnabled = false

        let alertController = UIAlertController(title: NSLocalizedString("Are You Sure?", comment: ""), message: "Do you want to delete this meeting?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Nuke From Orbit", style: UIAlertAction.Style.cancel, handler: { (_) in (self.meetingObject as? BMLTiOSLibEditableMeetingNode)?.delete() })
        
        alertController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Belay That Order!", style: UIAlertAction.Style.default, handler: nil)
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    /* ################################################################## */
    /**
     */
    func displayChanges() {
        self.getChangesButton.isEnabled = true
        self.performSegue(withIdentifier: "ViewMeetingChangeList", sender: nil)
    }
    
    /* ################################################################## */
    /**
     */
    func deleteSuccessful(_ inSuccess: Bool) {
        if inSuccess {
            if let parent = self.backViewController as? MeetingSearchResultsViewController {
                for i in 0..<parent.meetingSearchResults.count {
                    let meetingObject = parent.meetingSearchResults[i]
                    if meetingObject.id == self.meetingObject.id {
                        parent.meetingSearchResults.remove(at: i)
                        break
                    }
                }
            }
            self.navigationController!.popViewController(animated: true)
        } else {
            self.deleteButton.isEnabled = true
        }
    }
    
    /* ################################################################## */
    /**
     */
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let newController = segue.destination as? SendMessageViewController {
            newController.meetingObject = self.meetingObject
        }
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func cancelButtonHit(_ sender: UIBarButtonItem) {
        if self.meetingObject.isDirty {
            let alertController = UIAlertController(title: NSLocalizedString("Are You Sure?", comment: ""), message: "Do you want to lose the changes you made to this meeting?", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Nuke From Orbit", style: UIAlertAction.Style.cancel, handler: self.resetAndClose)
            
            alertController.addAction(okAction)
            
            let cancelAction = UIAlertAction(title: "Belay That Order!", style: UIAlertAction.Style.default, handler: nil)
            
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.navigationController!.popViewController(animated: true)
        }
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func saveButtonHit(_ sender: UIBarButtonItem) {
        (self.meetingObject as? BMLTiOSLibEditableMeetingNode)?.saveChanges()
        self.navigationController!.popViewController(animated: true)
    }
    
    /* ################################################################## */
    /**
     */
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var ret: Int = 0
        
        if (nil != self.meetingObject) && (1 < self.meetingObject.keys.count) {
            ret = self.meetingObject.keys.count
            if 0 < self.meetingObject.id {  // In the case of a new meeting, we won't display the ID.
                ret += 1
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     */
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let myKeys = self.meetingObject.keys
        var row = indexPath.row
        
        if 0 == self.meetingObject.id {
            row += 1
        }
        
        if row == myKeys.count {
            return tableView.bounds.size.width + 31
        } else {
            var myKeys = self.meetingObject.keys
            let id = myKeys[row]
            let value = self.meetingObject[id].trimmingCharacters(in: CharacterSet(charactersIn: " \n\t"))
            if self.meetingObject.isEditable || !value.isEmpty {
                return tableView.rowHeight
            } else {
                return 0
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var row = indexPath.row
        
        if 0 == self.meetingObject.id {
            row += 1
        }
        
        var myKeys = self.meetingObject.keys
        
        var id: String = ""
        var value = ""
        
        if row == myKeys.count {
            id = "Display Map"
        } else {
            id = myKeys[row]
            value = self.meetingObject[id].trimmingCharacters(in: CharacterSet(charactersIn: " \n\t"))
        }
       
        let ret = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: id)
        
        var frame: CGRect = CGRect.zero
        
        frame.size.height = self.tableView(tableView, heightForRowAt: indexPath)
        frame.size.width = tableView.bounds.size.width
        
        ret.backgroundColor = UIColor.clear
        
        ret.frame = frame
        
        if 0 < frame.size.height {
            ret.backgroundColor = (("id_bigint" != id) && self.meetingObject.isEditable) ? UIColor(red: 0, green: 1, blue: 0.5, alpha: 0.19) : UIColor.clear
            
            let containerView = UIView(frame: frame)
            containerView.backgroundColor = UIColor.clear
            
            var labelFrame = frame
            labelFrame.size.height = 31
            let label = UILabel(frame: labelFrame)

            label.backgroundColor = UIColor.clear
            label.textColor = UIColor.white
            label.font = UIFont.boldSystemFont(ofSize: 17)
            label.textAlignment = NSTextAlignment.center
            label.text = id
            
            containerView.addSubview(label)
            
            var editFrame = frame
            editFrame.size.height -= labelFrame.size.height
            editFrame.origin.y = labelFrame.size.height

            if ("Display Map" != id) && (self.meetingObject.isEditable || !value.isEmpty) {
                if !(("id_bigint" == id) && ("0" == value)) {
                    let editableTextItem = BMLTiOSLibEditorView(frame: editFrame)
                    editableTextItem.meetingObject = self.meetingObject
                    editableTextItem.key = id

                    editableTextItem.showsHorizontalScrollIndicator = false
                    editableTextItem.showsVerticalScrollIndicator = true
                    editableTextItem.font = UIFont.italicSystemFont(ofSize: 14)
                    editableTextItem.isEditable = ("id_bigint" != id) && self.meetingObject.isEditable
                    editableTextItem.backgroundColor = editableTextItem.isEditable ? UIColor.white : UIColor.clear
                    editableTextItem.textColor = editableTextItem.isEditable ? UIColor.black : UIColor.white
                    editableTextItem.text = value
                    editableTextItem.delegate = self
                    
                    if "published" == id {
                        self.publishedTextField = editableTextItem
                    }
                    
                    containerView.addSubview(editableTextItem)
                }
            } else {
                frame.origin.y += 31
                frame.size.height -= 31
                
                let mapContainer = UIView(frame: frame)
                frame.origin.y = 0
                
                if nil == self._mapView {
                    _ = UINib(nibName: "SingleMeetingMapDisplayCellView", bundle: nil).instantiate(withOwner: self, options: nil)[0]
                    
                    if nil != self._mapView {
                        self._mapView.frame = frame
                        
                        if let mapLocation = self.meetingObject.locationCoords {
                            let span = MKCoordinateSpan(latitudeDelta: type(of: self).sMapSizeInDegrees, longitudeDelta: 0)
                            let newRegion: MKCoordinateRegion = MKCoordinateRegion(center: mapLocation, span: span)
                            self._mapView.setRegion(newRegion, animated: false)
                            self.mapMarkerAnnotation = BMLTiOSLibTesterAnnotation(coordinate: mapLocation)
                            self._mapView.addAnnotation(self.mapMarkerAnnotation)
                        }
                    }
                }
                
                if nil != self._mapView {
                    mapContainer.addSubview(self._mapView)
                    containerView.addSubview(mapContainer)
                }
            }
            
            ret.addSubview(containerView)
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     */
    public func textViewDidChange(_ textView: UITextView) {
        if let editField = textView as? BMLTiOSLibEditorView {
            if let meetingObject = editField.meetingObject as? BMLTiOSLibEditableMeetingNode {
                meetingObject.rawMeeting[editField.key] = editField.text
                self.setUpPublishButton()
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    // MARK: - MKMapViewDelegate Methods -
    /* ################################################################## */
    /**
     */
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: BMLTiOSLibTesterAnnotation.self) {
            let reuseID = ""
            let myAnnotation = annotation as? BMLTiOSLibTesterAnnotation
            return BMLTiOSLibTesterMarker(annotation: myAnnotation, draggable: self.meetingObject.isEditable, reuseID: reuseID)
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
                (self.meetingObject as? BMLTiOSLibEditableMeetingNode)?.locationCoords = mapLocation
                self.enableDisableSave()
            }
        }
    }
}
