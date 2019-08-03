//
//  TestTabController.swift
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
class TestTabController: UITabBarController {
    enum TabPositions: Int {
        case DetailedInfoTab = 0
        case SearchTab
        case ChangesTab
        case NewMeetingTab
    }
    
    // When we are logged in, the tab bar is a dark green, and the icons are displayed selected as red.
    static let barTintLoggedIn: UIColor = UIColor(red: 0, green: 0.25, blue: 0.25, alpha: 1)
    static let iconTintLoggedIn: UIColor = UIColor(red: 0.75, green: 0.25, blue: 0, alpha: 1)
    static let unselectedIconTintLoggedIn: UIColor = UIColor(red: 1, green: 0.5, blue: 0.15, alpha: 0.5)

    // Logged out, black and white.
    static let barTintLoggedOut: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    static let iconTintLoggedOut: UIColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    static let unselectedIconTintLoggedOut: UIColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
    
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateLogin()
    }
    
    /* ################################################################## */
    /**
     */
    func getOneMeetingByID(_ inMeetingID: Int) {
        if let controllers = self.viewControllers {
            if let searchController = controllers[TabPositions.SearchTab.rawValue] as? SearchViewController {
                self.selectedIndex = TabPositions.SearchTab.rawValue
                searchController.getOneMeetingByID(inMeetingID)
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func updateLogin() {
        if let controllers = self.viewControllers {
            if let detailController = controllers[TabPositions.DetailedInfoTab.rawValue] as? DetailedInfoController {
                detailController.setupLoginView()
            }
            
            if let searchController = controllers[TabPositions.SearchTab.rawValue] as? SearchViewController {
                searchController.clearSearchCriteria()
                searchController.updateMeetingSearchResults(inMeetings: [])
                searchController.updateFormatSearchResults(inFormats: [])
            }
            
            if let newMeetingController = controllers[TabPositions.NewMeetingTab.rawValue] as? NewMeetingViewController {
                newMeetingController.tabBarItem.isEnabled = BMLTiOSLibTesterAppDelegate.libraryObject.isAdminLoggedIn
            }
            
            self.tabBar.barTintColor = BMLTiOSLibTesterAppDelegate.libraryObject.isAdminLoggedIn ? type(of: self).barTintLoggedIn : type(of: self).barTintLoggedOut
            self.tabBar.tintColor = BMLTiOSLibTesterAppDelegate.libraryObject.isAdminLoggedIn ? type(of: self).iconTintLoggedIn : type(of: self).iconTintLoggedOut
            if #available(iOS 10.0, *) {
                self.tabBar.unselectedItemTintColor = BMLTiOSLibTesterAppDelegate.libraryObject.isAdminLoggedIn ? type(of: self).unselectedIconTintLoggedIn : type(of: self).unselectedIconTintLoggedOut
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func updateUsedFormats(inUsedFormats: [BMLTiOSLibFormatNode], isAllUsedFormats: Bool) {
        if let controllers = self.viewControllers {
            if let detailController = controllers[TabPositions.DetailedInfoTab.rawValue] as? DetailedInfoController {
                detailController.updateUsedFormats(inUsedFormats: inUsedFormats, isAllUsedFormats: isAllUsedFormats)
                self.updateFormatSearchResults(inFormats: inUsedFormats, isAllUsedFormats: false)
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func updateMeetingSearchResults(inMeetings: [BMLTiOSLibMeetingNode]) {
        if let controllers = self.viewControllers {
            if 0 < inMeetings.count {
                self.selectedIndex = TabPositions.SearchTab.rawValue
            }
            if let searchController = controllers[TabPositions.SearchTab.rawValue] as? SearchViewController {
                searchController.updateMeetingSearchResults(inMeetings: inMeetings)
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func updateChangeResults(inChanges: [BMLTiOSLibChangeNode]) {
        if let controllers = self.viewControllers {
            if let changeController = controllers[TabPositions.ChangesTab.rawValue] as? AllChangesListViewController {
                changeController.updateChangeResults(inChanges: inChanges)
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func updateFormatSearchResults(inFormats: [BMLTiOSLibFormatNode], isAllUsedFormats: Bool) {
        if let controllers = self.viewControllers {
            if let searchController = controllers[TabPositions.SearchTab.rawValue] as? SearchViewController {
                searchController.updateFormatSearchResults(inFormats: inFormats)
            }
            if isAllUsedFormats {
                self.updateUsedFormats(inUsedFormats: inFormats, isAllUsedFormats: isAllUsedFormats)
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    public func updateMeetingChanges(adminMeetingChangeComplete: BMLTiOSLibChangedMeeting!) {
        let alertController = UIAlertController(title: "Meeting Change Complete", message: adminMeetingChangeComplete.description, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertAction.Style.cancel, handler: nil)
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
   
    /* ################################################################## */
    /**
     */
    func updateNewMeeting(_ inNewMeeting: BMLTiOSLibEditableMeetingNode) {
        self.navigationController!.popToRootViewController(animated: true)
        self.getOneMeetingByID(inNewMeeting.id)
    }
    
    /* ################################################################## */
    /**
     */
    func updateDeletedMeeting(_ inSuccess: Bool) {
        if let controllers = self.viewControllers {
            if let searchController = controllers[self.selectedIndex] as? SearchViewController {
                searchController.deleteSuccessful(inSuccess)
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func updateMessageSent(_ inWasSuccessful: Bool) {
        if let sendMessageController = self.navigationController?.topViewController as? SendMessageViewController {
            sendMessageController.sendMessageUpdate(wasSuccessful: inWasSuccessful)
        }
    }
}
