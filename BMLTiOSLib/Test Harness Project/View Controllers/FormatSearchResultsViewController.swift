//
//  FormatSearchResultsViewController.swift
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
class FormatSearchResultsViewController: BaseTestViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var _tableView: UITableView!
    var formatSearchResults: [BMLTiOSLibFormatNode]! = nil
    
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.formatSearchResults.count
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let ret: CGFloat = 124
        
        return ret
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ret = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "")
        
        var frame: CGRect = CGRect.zero
        
        frame.size.height = self.tableView(tableView, heightForRowAt: indexPath)
        frame.size.width = tableView.bounds.size.width
        
        ret.backgroundColor = UIColor.clear
        
        ret.frame = frame
        
        let containerView = UIView(frame: frame)
        containerView.backgroundColor = UIColor.clear
        
        var topLabelFrame = frame
        topLabelFrame.size.height = 31
        let topLabel = UILabel(frame: topLabelFrame)
        topLabel.font = UIFont.boldSystemFont(ofSize: 17)
        topLabel.backgroundColor = UIColor.clear
        topLabel.textColor = UIColor.white
        topLabel.textAlignment = NSTextAlignment.center
        topLabel.text = self.formatSearchResults[indexPath.row].key + " (" + String(self.formatSearchResults[indexPath.row].id) + ")"
        
        containerView.addSubview(topLabel)
        
        var shortTextFieldFrame = frame
        shortTextFieldFrame.origin.y = topLabelFrame.size.height
        shortTextFieldFrame.size.height = topLabelFrame.size.height
        let shortTextField = UITextView(frame: shortTextFieldFrame)
        
        shortTextField.backgroundColor = UIColor.clear
        shortTextField.textColor = UIColor.white
        shortTextField.font = UIFont.italicSystemFont(ofSize: 14)
        shortTextField.text = self.formatSearchResults[indexPath.row].name
        shortTextField.showsVerticalScrollIndicator = true
        shortTextField.showsHorizontalScrollIndicator = false
        shortTextField.isEditable = false
        
        containerView.addSubview(shortTextField)
        
        var descriptionTextFieldFrame = frame
        descriptionTextFieldFrame.origin.y = topLabelFrame.size.height + shortTextFieldFrame.size.height
        descriptionTextFieldFrame.size.height = topLabelFrame.size.height * 2
        let descriptionTextField = UITextView(frame: descriptionTextFieldFrame)
        
        descriptionTextField.backgroundColor = UIColor.clear
        descriptionTextField.textColor = UIColor.white
        descriptionTextField.font = UIFont.italicSystemFont(ofSize: 14)
        descriptionTextField.text = self.formatSearchResults[indexPath.row].description
        descriptionTextField.showsVerticalScrollIndicator = true
        descriptionTextField.showsHorizontalScrollIndicator = false
        descriptionTextField.isEditable = false

        containerView.addSubview(descriptionTextField)
        
        ret.addSubview(containerView)
        
        return ret
    }
}
