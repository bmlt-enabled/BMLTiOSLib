//
//  BMLTiOSLibTesterMarker.swift
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

/**
 This file contains a couple of classes that allow us to establish and manipulate markers in our map.
 */

import MapKit

/** Points to a meeting JSON element. */
typealias BMLTiOSLibTesterMeeting = [String: String]
/** Points to an array of JSON meetings. */
typealias BMLTiOSLibTesterMeetingList = [BMLTiOSLibTesterMeeting]

// MARK: - Classes -
/* ###################################################################################################################################### */
/**
 This handles the marker annotation.
 */
class BMLTiOSLibTesterAnnotation: NSObject, MKAnnotation, NSCoding {
    let sCoordinateObjectKey: String = "BMLTiOSLibTesterAnnotation_Coordinate"
    let sMeetingsObjectKey: String = "BMLTiOSLibTesterAnnotation_Meetings"

    @objc var coordinate: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    var meetings: BMLTiOSLibTesterMeetingList = []
    
    /* ################################################################## */
    /**
     Convenience initializer.
     
     - parameter coordinate: the coordinate for this annotation display.
     */
    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init(coordinate: coordinate, meetings: [])
    }
    
    /* ################################################################## */
    /**
     Default initializer.
     
     - parameter coordinate: the coordinate for this annotation display.
     - parameter meetings: a list of meetings to be assigned to this annotation.
     */
    init(coordinate: CLLocationCoordinate2D, meetings: BMLTiOSLibTesterMeetingList) {
        self.coordinate = coordinate
        self.meetings = meetings
    }
    
    // MARK: - NSCoding Protocol Methods -
    /* ################################################################## */
    /**
     This method will restore the meetings and coordinate objects from the coder passed in.
     
     - parameter aDecoder: The coder that will contain the coordinates.
     */
    @objc required init?(coder aDecoder: NSCoder) {
        self.meetings = (aDecoder.decodeObject(forKey: self.sMeetingsObjectKey) as? BMLTiOSLibTesterMeetingList)!
        if let tempCoordinate = aDecoder.decodeObject(forKey: self.sCoordinateObjectKey) as? [NSNumber] {
            self.coordinate.longitude = tempCoordinate[0].doubleValue
            self.coordinate.latitude = tempCoordinate[1].doubleValue
        }
    }
    
    /* ################################################################## */
    /**
     This method saves the meetings and coordinates as part of the serialization.
     
     - parameter aCoder: The coder that contains the coordinates.
     */
    @objc func encode(with aCoder: NSCoder) {
        let long: NSNumber = NSNumber(value: self.coordinate.longitude as Double)
        let lat: NSNumber = NSNumber(value: self.coordinate.latitude as Double)
        let values: [NSNumber] = [long, lat]
        
        aCoder.encode(values, forKey: self.sCoordinateObjectKey)
        aCoder.encode(self.meetings, forKey: self.sMeetingsObjectKey)
    }
}

/* ###################################################################################################################################### */
/**
 This handles our map marker.
 */
class BMLTiOSLibTesterMarker: MKAnnotationView {
    let sAnnotationObjectKey: String = "BMLTiOSLibTesterMarker_Annotation"
    let sRegularAnnotationOffsetUp: CGFloat     = 24; /**< This is how many display units to shift the annotation view up. */
    let sRegularAnnotationOffsetRight: CGFloat  = 5;  /**< This is how many display units to shift the annotation view right. */

    // MARK: - Properties -
    var currentFrame: Int = 0
    var animationTimer: Timer! = nil
    var animationFrames: [UIImage] = []
    
    // MARK: - Computed Properties -
    /* ################################################################## */
    /**
     We override this, so we can be sure to refresh the need for a draw state when draggable is set (Meaning it's a black marker).
     */
    override var isDraggable: Bool {
        get {
            return super.isDraggable
        }
        
        set {
            // You can only drag if there are no meetings, or just one meeting.
            if 2 > self.meetings.count {
                super.isDraggable = newValue
            } else {
                super.isDraggable = false
            }
            
            if !super.isDraggable {
                self.animationFrames = []
            }
            
            self.setNeedsDisplay()
        }
    }
    
    /* ################################################################## */
    /**
     This gives us a shortcut to the annotation prpoerty.
     */
    var coordinate: CLLocationCoordinate2D {
        return (self.annotation?.coordinate)!
    }
    
    /* ################################################################## */
    /**
     This gives us a shortcut to the annotation prpoerty.
     */
    var meetings: BMLTiOSLibTesterMeetingList {
        return ((self.annotation as? BMLTiOSLibTesterAnnotation)!.meetings)
    }
    
    // MARK: - Instance Methods -
    /* ################################################################## */
    /**
     The default initializer.
     
     - parameter annotation: The annotation that represents this instance.
     - parameter draggable: If true, then this will be draggable (ignored if the annotation has more than one meeting).
     */
    init(annotation: MKAnnotation?, draggable: Bool, reuseID: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseID)
        self.isDraggable = draggable
        self.backgroundColor = UIColor.clear
        self.image = self.selectImage(false)
        self.centerOffset = CGPoint(x: self.sRegularAnnotationOffsetRight, y: -self.sRegularAnnotationOffsetUp)
    }
    
    /* ################################################################## */
    /**
     This selects the appropriate image for our display.
     - parameter inAnimated: If true, then the drag will be animated.
     */
    func selectImage(_ inAnimated: Bool) -> UIImage! {
        var image: UIImage! = nil
        if self.isDraggable && (2 > self.meetings.count) {
            if self.dragState == MKAnnotationView.DragState.dragging {
                if inAnimated {
                    image = self.animationFrames[self.currentFrame]
                } else {
                    image = UIImage(named: "MapMarkerGreen", in: nil, compatibleWith: nil)
                }
            } else {
                image = UIImage(named: "MapMarkerBlack", in: nil, compatibleWith: nil)
            }
        } else {
            if self.isSelected {
                image = UIImage(named: "MapMarkerGreen", in: nil, compatibleWith: nil)
            } else {
                if 1 < self.meetings.count {
                    image = UIImage(named: "MapMarkerRed", in: nil, compatibleWith: nil)
                } else {
                    image = UIImage(named: "MapMarkerBlue", in: nil, compatibleWith: nil)
                }
            }
        }
        
        return image
    }
    
    // MARK: - Base Class Override Methods -
    /* ################################################################## */
    /**
     Draws the image for the marker.
     
     - parameter rect: The rectangle in which this is to be drawn.
     */
    override func draw(_ rect: CGRect) {
        let image = self.selectImage(0 < self.animationFrames.count)
        if nil != image {
            image!.draw(in: rect)
        }
    }
    
    /* ################################################################## */
    /**
     Sets the drag state for this marker.
     
     - parameter newDragState: The new state that should be set after this call.
     - parameter animated: True, if the state change is to be animated (ignored).
     */
    override func setDragState(_ newDragState: MKAnnotationView.DragState, animated: Bool) {
        var subsequentDragState = MKAnnotationView.DragState.none
        switch newDragState {
        case MKAnnotationView.DragState.starting:
            subsequentDragState = MKAnnotationView.DragState.dragging
            self.currentFrame = 0
            self.animationFrames = []
            
        case MKAnnotationView.DragState.dragging:
            if animated && (0 == self.animationFrames.count) {
                // Set up the drag animation.
                // We have 10 frames in the drag animation.
                for c in 1 ..< 11 {
                    // Construct an image name for each frame.
                    var imageName = "Frame"
                    if 10 > c {
                        imageName += "0"
                    }
                    
                    imageName += String(c)
                    
                    if let image = UIImage(named: imageName, in: nil, compatibleWith: nil) {
                        self.animationFrames.append(image)
                    }
                }
            }
            
            _ = self.selectImage(true)
            self.currentFrame += 1
            subsequentDragState = MKAnnotationView.DragState.dragging
            if self.currentFrame == self.animationFrames.count {
                self.currentFrame = 0
            }

        default:
            subsequentDragState = MKAnnotationView.DragState.none
        }
        
        super.dragState = subsequentDragState
        self.setNeedsDisplay()
    }
    
    // MARK: - NSCoding Protocol Methods -
    /* ################################################################## */
    /**
     This class will restore its meeting object from the coder passed in.
     
     - parameter aDecoder: The coder that will contain the meeting.
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.annotation = aDecoder.decodeObject(forKey: self.sAnnotationObjectKey) as? BMLTiOSLibTesterAnnotation
    }
    
    /* ################################################################## */
    /**
     This method saves the meetings and coordinates as part of the serialization.
     
     - parameter aCoder: The coder that contains the coordinates.
     */
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(self.annotation, forKey: self.sAnnotationObjectKey)
        super.encode(with: aCoder)
    }
}
