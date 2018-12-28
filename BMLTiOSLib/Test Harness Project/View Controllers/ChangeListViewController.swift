//
//  ChangeListViewController.swift
//  BMLTiOSLib
//
//  Created by MAGSHARE
//
//  https: //bmlt.magshare.net/bmltioslib/
//
//  Created by MAGSHARE
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

/* ###################################################################################################################################### */
/**
 */
class ChangeListViewController: BaseTestViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    var changesObjects: [BMLTiOSLibChangeNode]! = nil
    
    @IBOutlet weak var displayTableView: UITableView!
    
    /* ################################################################## */
    /**
     */
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.displayTableView.reloadData()
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.changesObjects.count
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ret = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "")
        let beforeMeeting = self.changesObjects[indexPath.row].beforeObject
        let afterMeeting = self.changesObjects[indexPath.row].afterObject
        
        var isEditable: Bool = true
        let isNewMeeting: Bool = (nil == beforeMeeting)
        let isDeletedMeeting: Bool = (nil == afterMeeting)
        
        if (nil == beforeMeeting) || !beforeMeeting!.isEditable {
            isEditable = false
        }
        
        if isEditable && (nil != afterMeeting) && !afterMeeting!.isEditable {
            isEditable = false
        }
        
        var frame: CGRect = CGRect.zero
        
        frame.size.height = self.tableView(tableView, heightForRowAt: indexPath)
        frame.size.width = tableView.bounds.size.width
        
        ret.backgroundColor = UIColor.clear
        
        ret.frame = frame
        
        var textColor: UIColor = isEditable ? UIColor.green : UIColor.white
        
        if isDeletedMeeting {
            textColor = isEditable ? UIColor.orange : UIColor.red
        } else {
            if isNewMeeting {
                textColor = UIColor.yellow
            }
        }
        
        let textView = UITextView(frame: frame)
        textView.backgroundColor = UIColor.clear
        textView.textColor = textColor
        textView.isUserInteractionEnabled = false
        textView.text = self.changesObjects[indexPath.row].description

        ret.addSubview(textView)
        
        return ret
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let beforeMeeting = self.changesObjects[indexPath.row].beforeObject
        let afterMeeting = self.changesObjects[indexPath.row].afterObject
        
        if (nil == beforeMeeting) || !beforeMeeting!.isEditable {
            return nil
        }
        
        if (nil != afterMeeting) && !afterMeeting!.isEditable {
            return nil
        }
        
        return indexPath
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return nil != self.tableView(tableView, willSelectRowAt: indexPath)
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let beforeMeeting = self.changesObjects[indexPath.row].beforeObject
        let afterMeeting = self.changesObjects[indexPath.row].afterObject
        
        if (nil != beforeMeeting) && beforeMeeting!.isEditable {
            var message = "Do you want to revert this meeting to before this change?"
            
            if nil == afterMeeting {
                message = "Do you want to undelete this meeting?"
            }
            
            let alertController = UIAlertController(title: NSLocalizedString("Are You Sure?", comment: ""), message: message, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Go For It!", style: UIAlertAction.Style.cancel, handler: {(_: UIAlertAction) in tableView.deselectRow(at: indexPath, animated: true);self.setMeetingToChange(self.changesObjects[indexPath.row], undelete: nil == afterMeeting)})
            
            alertController.addAction(okAction)
            
            let cancelAction = UIAlertAction(title: "Belay That Order!", style: UIAlertAction.Style.default, handler: {(_: UIAlertAction) in tableView.deselectRow(at: indexPath, animated: true)})
            
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func setMeetingToChange(_ inChange: BMLTiOSLibChangeNode, undelete: Bool) {
        if inChange.saveMeetingToBeforeThisChange() {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
}
