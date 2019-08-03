//
//  DetailedInfoController.swift
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
import MapKit
import BMLTiOSLib

/* ###################################################################################################################################### */
/**
 */
class DetailedInfoController: BaseTestViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, UITextFieldDelegate {
    static let sMapSizeInDegrees: CLLocationDegrees         =   0.75
    
    enum TableRows: Int {
        case FormatRow = 0, LoginRow, LocationRow
    }
    
    let sButtonCollapsed: CGFloat = 30
    let sButtonOpen: CGFloat = 200
    let sLoginRowHeight: CGFloat = 164
    let sLoginRowHeightCollapsed: CGFloat = 30

    var mapMarkerAnnotation: BMLTiOSLibTesterAnnotation!    =   nil
    
    @IBOutlet var _formatCellView: UIView!
    @IBOutlet var _formatLabel: UILabel!
    @IBOutlet var _formatTextView: UITextView!
    @IBOutlet var _formatButton: UIButton!
    @IBOutlet var _formatActivity: UIActivityIndicatorView!
    @IBOutlet var _loginCellView: UIView!
    @IBOutlet weak var loginIDLabel: UILabel!
    @IBOutlet weak var loginIDTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var resultsTextView: UITextView!
    var loginButtonLoggedIn: UIButton! = nil

    @IBOutlet var _mapView: MKMapView!
    
    /* ################################################################## */
    /**
     */
    func createDisplayText() {
        if BMLTiOSLibTesterAppDelegate.libraryObject.isAdminLoggedIn {
            var displayText: String = "We are logged into the Root Server as an administrator.\nWe have the indicated permissions for the following Service bodies:\n\n"
            
            for sb in BMLTiOSLibTesterAppDelegate.libraryObject.serviceBodies where .None != sb.permissions {
                displayText += "    " + sb.name + " (\(sb.permissions))\n"
            }
            
            self.resultsTextView.text = displayText
        }
    }
    
    /* ################################################################## */
    /**
     */
    func setupLoginView() {
        if let tableView = self.view as? UITableView {
            tableView.reloadData()
        }
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func fetchAllUsedFormats(_ sender: UIButton) {
        if nil != BMLTiOSLibTesterAppDelegate.libraryObject {
            self._formatButton.isHidden = true
            self._formatLabel.isHidden = true
            self._formatTextView.isHidden = true
            self._formatActivity.isHidden = false
            BMLTiOSLibTesterAppDelegate.libraryObject.getAllUsedFormats()
        }
    }
    
    /* ################################################################## */
    /**
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
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
        var ret: CGFloat = tableView.rowHeight
        switch indexPath.row {
        case TableRows.FormatRow.rawValue:
            if nil != _formatTextView {
                if self._formatTextView.isHidden {
                    ret = self.sButtonCollapsed
                } else {
                    ret = self.sButtonOpen
                }
            }
            
        case TableRows.LoginRow.rawValue:
            ret = BMLTiOSLibTesterAppDelegate.libraryObject.isAdminAvailable ? (BMLTiOSLibTesterAppDelegate.libraryObject.isAdminLoggedIn ? self.sLoginRowHeightCollapsed : self.sLoginRowHeight) : 0
            
        case TableRows.LocationRow.rawValue:
            ret = tableView.bounds.size.width
            
        default:
            break
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var reuseID: String = ""
        var ret: UITableViewCell! = nil

        switch indexPath.row {
        case TableRows.FormatRow.rawValue:
            reuseID = "DetailFormatCell"
        
        case TableRows.LoginRow.rawValue:
            reuseID = ""
            
        case TableRows.LocationRow.rawValue:
            reuseID = "DetailLocationMapCell"
            
        default:
            break
        }
        
        if nil == ret {
            if !reuseID.isEmpty {
                ret = tableView.dequeueReusableCell(withIdentifier: reuseID)
            }
            
            if nil == ret {
                ret = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: reuseID)
                if nil != ret {
                    ret.backgroundColor = UIColor.clear
                    
                    switch indexPath.row {
                    case TableRows.FormatRow.rawValue:
                        ret = self.handleFormatRow(tableView, indexPath: indexPath, ret: ret, reuseID: reuseID)

                    case TableRows.LoginRow.rawValue:
                        ret = self.handleLoginRow(tableView, indexPath: indexPath, ret: ret)

                    case TableRows.LocationRow.rawValue:
                        ret = self.handleLocationRow(tableView, indexPath: indexPath, ret: ret, reuseID: reuseID)
                        
                    default:
                        break
                    }
                }
            }
        }
    
        return ret
    }
    
    /* ################################################################## */
    /**
     */
    func handleFormatRow(_ tableView: UITableView, indexPath: IndexPath, ret: UITableViewCell, reuseID: String) -> UITableViewCell {
        if nil == self._formatCellView {
            _ = UINib(nibName: reuseID, bundle: nil).instantiate(withOwner: self, options: nil)[0]
        }
        
        if nil != self._formatCellView {
            var bounds: CGRect = tableView.bounds
            bounds.size.height = self.tableView(tableView, heightForRowAt: indexPath)
            self._formatCellView.bounds = bounds
            self._formatCellView.frame = bounds
            ret.frame = bounds
            ret.bounds = bounds
            ret.addSubview(self._formatCellView)
        }

        return ret
    }
    
    /* ################################################################## */
    /**
     */
    func handleLoginRow(_ tableView: UITableView, indexPath: IndexPath, ret: UITableViewCell) -> UITableViewCell {
        var bounds: CGRect = tableView.bounds
        bounds.size.height = self.tableView(tableView, heightForRowAt: indexPath)
        ret.frame = bounds
        ret.bounds = bounds
        ret.backgroundColor = UIColor.clear
        
        if BMLTiOSLibTesterAppDelegate.libraryObject.isAdminAvailable {
            if !BMLTiOSLibTesterAppDelegate.libraryObject.isAdminLoggedIn {
                if nil != self.loginButtonLoggedIn {
                    self.loginButtonLoggedIn.removeFromSuperview()
                    self.loginButtonLoggedIn = nil
                }
                
                if nil == self._loginCellView {
                    _ = UINib(nibName: "DetailLoginTableCellView", bundle: nil).instantiate(withOwner: self, options: nil)[0]
                }
                
                if nil != self._loginCellView {
                    self._loginCellView.bounds = bounds
                    self._loginCellView.frame = bounds
                    ret.addSubview(self._loginCellView)
                }
            } else {
                if nil != self._loginCellView {
                    self.loginIDLabel.removeFromSuperview()
                    self.loginIDLabel = nil
                    self.loginIDTextField.removeFromSuperview()
                    self.loginIDTextField = nil
                    self.passwordLabel.removeFromSuperview()
                    self.passwordLabel = nil
                    self.passwordTextField.removeFromSuperview()
                    self.passwordTextField = nil
                    self.loginButton.removeFromSuperview()
                    self.loginButton = nil
                    self._loginCellView.removeFromSuperview()
                    self._loginCellView = nil
                }
                
                if nil == self.loginButtonLoggedIn {
                    self.loginButtonLoggedIn = UIButton(frame: bounds)
                    if nil != self.loginButtonLoggedIn {
                        self.loginButtonLoggedIn.setTitle("LOG OUT", for: UIControl.State.normal)
                        self.loginButtonLoggedIn.setTitleColor(self.view.tintColor, for: UIControl.State.normal)
                        self.loginButtonLoggedIn.addTarget(self, action: #selector(DetailedInfoController.loginButtonHit(_:)), for: UIControl.Event.touchUpInside)
                        ret.addSubview(self.loginButtonLoggedIn)
                    }
                }
            }
        }
        
        return ret
    }

    /* ################################################################## */
    /**
     */
    func handleLocationRow(_ tableView: UITableView, indexPath: IndexPath, ret: UITableViewCell, reuseID: String) -> UITableViewCell {
        if nil == self._mapView {
            _ = UINib(nibName: reuseID, bundle: nil).instantiate(withOwner: self, options: nil)[0]
        }
        
        if nil != self._mapView {
            var bounds: CGRect = tableView.bounds
            bounds.size.height = self.tableView(tableView, heightForRowAt: indexPath)
            self._mapView.bounds = bounds
            self._mapView.frame = bounds
            ret.frame = bounds
            ret.bounds = bounds
            
            if nil != BMLTiOSLibTesterAppDelegate.libraryObject {
                let mapLocation = BMLTiOSLibTesterAppDelegate.libraryObject.defaultLocation
                let span = MKCoordinateSpan(latitudeDelta: type(of: self).sMapSizeInDegrees, longitudeDelta: 0)
                let newRegion: MKCoordinateRegion = MKCoordinateRegion(center: mapLocation, span: span)
                self._mapView.setRegion(newRegion, animated: false)
                self.mapMarkerAnnotation = BMLTiOSLibTesterAnnotation(coordinate: mapLocation)
                self._mapView.addAnnotation(self.mapMarkerAnnotation)
            }
            
            ret.addSubview(self._mapView)
        }
        
        return ret
    }

    /* ################################################################## */
    /**
     */
    func updateUsedFormats(inUsedFormats: [BMLTiOSLibFormatNode], isAllUsedFormats: Bool) {
        self._formatButton.isHidden = true
        self._formatLabel.isHidden = false
        self._formatTextView.isHidden = false
        self._formatActivity.isHidden = true
        var text: String = ""
        for format in inUsedFormats.sorted(by: { $0.key < $1.key }) {
            text += format.key
            text += " (" + String(format.id) + ") "
            text += format.name + "\n"
        }
        self._formatTextView.text = text
        (self.view as? UITableView)?.reloadData()
    }
    
    /* ################################################################## */
    /**
     Called when text is entered into a Text Entry.
     
     - parameter inSender: The Text Entry Field that caused this to be called.
     */
    @IBAction func textEntered(_ inSender: UITextField) {
        self.loginButton.isEnabled = false
        
        if (nil != self.loginIDTextField) && (nil != self.passwordTextField) {
            if !BMLTiOSLibTesterAppDelegate.libraryObject.isAdminLoggedIn {
                if let liText = self.loginIDTextField.text {
                    if let pwText = self.passwordTextField.text {
                        if !liText.isEmpty && !pwText.isEmpty {
                            self.loginButton.isEnabled = true
                        }
                    }
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func loginButtonHit(_ sender: AnyObject) {
        if BMLTiOSLibTesterAppDelegate.libraryObject.isAdminLoggedIn {
            if !BMLTiOSLibTesterAppDelegate.libraryObject.adminLogout() {
                print("*** ERROR! The logout failed immediately!")
            }
        } else {
            if let liText = self.loginIDTextField.text {
                if let pwText = self.passwordTextField.text {
                    if !liText.isEmpty && !pwText.isEmpty {
                        if !BMLTiOSLibTesterAppDelegate.libraryObject.adminLogin(loginID: liText, password: pwText) {
                            print("*** ERROR! The login failed immediately!")
                        }
                    }
                }
            }
        }
        self.setupLoginView()
    }
    
    // MARK: - UITextFieldDelegate Handlers -
    
    /* ################################################################## */
    /**
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == self.passwordTextField {
            self.loginButtonHit(self.loginButton)
        }
        return true
    }
    
    // MARK: - MKMapViewDelegate Methods -
    /* ################################################################## */
    /**
     */
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: BMLTiOSLibTesterAnnotation.self) {
            let reuseID = ""
            let myAnnotation = annotation as? BMLTiOSLibTesterAnnotation
            return BMLTiOSLibTesterMarker(annotation: myAnnotation, draggable: true, reuseID: reuseID)
        }
        
        return nil
    }
}
