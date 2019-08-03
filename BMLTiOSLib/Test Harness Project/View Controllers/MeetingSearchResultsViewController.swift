//
//  MeetingSearchResultsViewController.swift
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
class MeetingSearchResultsViewController: BaseTestViewController, UITableViewDelegate, UITableViewDataSource {
    let sMeetingCellHeight: CGFloat     = 93
    
    @IBOutlet weak var _tableView: UITableView!
    var meetingSearchResults: [BMLTiOSLibMeetingNode]! = nil
    
    /* ################################################################## */
    /**
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self._tableView.reloadData()
    }
   
    /* ################################################################## */
    /**
     */
    override func viewWillAppear(_ animated: Bool) {
        for row in 0..<self._tableView.numberOfRows(inSection: 0) {
            let indexPath = IndexPath(row: row, section: 0)
            self._tableView.deselectRow(at: indexPath, animated: true)
        }
        self._tableView.reloadData()
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meetingSearchResults.count
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.sMeetingCellHeight
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let meeting = self.meetingSearchResults[indexPath.row]
        let reuseID: String = String(meeting.id)

        let ret = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: reuseID)
        if let cell = UINib(nibName: "MeetingSearchResultsTableCell", bundle: nil).instantiate(withOwner: self, options: nil)[0] as? MeetingSearchResultsTableCellView {
            cell.meetingDescriptionTextView.text = meeting.description
            var bounds: CGRect = CGRect.zero
            bounds.size.height = self.tableView(tableView, heightForRowAt: indexPath)
            bounds.size.width = tableView.bounds.size.width
            ret.backgroundColor = meeting.isEditable ? (meeting.published ? UIColor(red: 0, green: 1, blue: 0.5, alpha: 0.19) : UIColor(red: 0.75, green: 0.25, blue: 0, alpha: 0.5)) : UIColor.clear
            ret.bounds = bounds
            cell.frame = bounds
            ret.addSubview(cell)
        }

        return ret
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let meeting = self.meetingSearchResults[indexPath.row]
        self.performSegue(withIdentifier: "ShowSingleMeetingSegue", sender: meeting)
    }
    
    /* ################################################################## */
    /**
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: nil)
        if let meeting = sender as? BMLTiOSLibMeetingNode {
            if let newScreen = segue.destination as? SingleMeetingViewController {
                newScreen.meetingObject = meeting
            }
        }
    }
}

/* ###################################################################################################################################### */
/**
 */
class MeetingSearchResultsTableCellView: UIView {
    @IBOutlet weak var meetingDescriptionTextView: UITextView!
}
