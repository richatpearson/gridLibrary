//
//  ProfileUIViewController.swift
//  DemoApp
//
//  Created by Seals, Morris D on 3/6/15.
//  Copyright (c) 2015 Seals, Morris D. All rights reserved.
//

import UIKit
import GRIDMobileSDK

class ProfileUIViewController: BaseUITableview {
    
    // segue_to_profile_uiviewcontroller_id
    //@IBOutlet weak var tableView: UITableView!  // Drag the connection, then comment it out since its in base class
    
    var uiTableViewCellFont = UIFont.boldSystemFontOfSize(12)

    var selectedCelString = "My Profile"
    
    override func loadData() {
        
        println("AccountUIViewController loadData")
        tableDataNSMutableArray.removeAllObjects()

        let accessToken = AuthenticationViewModel.sharedInstance.myPGMAuthResponse?.authContext.accessToken
        tableDataNSMutableArray.addObject( "Access Token:  " + accessToken!)
        
        let refreshToken = AuthenticationViewModel.sharedInstance.myPGMAuthResponse?.authContext.refreshToken
        tableDataNSMutableArray.addObject( "Refresh Token:  " + refreshToken!)

        let tokenExpiresIn = AuthenticationViewModel.sharedInstance.myPGMAuthResponse?.authContext.tokenExpiresIn
        tableDataNSMutableArray.addObject( "Expires In:  " + String(tokenExpiresIn!) )  // NSInteger

        let userIdentityId = AuthenticationViewModel.sharedInstance.myPGMAuthResponse?.authContext.userIdentityId
        tableDataNSMutableArray.addObject( "User Identity ID:  " + userIdentityId!)
        
        let username = AuthenticationViewModel.sharedInstance.myPGMAuthResponse?.authContext.username
        tableDataNSMutableArray.addObject( "User Name:  " + username!)
        
    }
    
    
    // runs once
    override func viewDidLoad() {
        println("AccountUIViewController viewDidLoad")
        super.viewDidLoad()
        self.title = "Profile"
        registerClassAndSetDelegates()
    }
    
    // runs everytime
    override func viewWillAppear(animated: Bool) {
        println("AccountUIViewController viewWillAppear")
        super.viewWillAppear(true)
        
        loadData()
        
        tableView.rowHeight = UITableViewAutomaticDimension

        self.tableView.reloadData()
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        // try http://makeapppie.com/tag/apple-swift/
        
        cell.textLabel?.text = "\(self.tableDataNSMutableArray[indexPath.row])"
        cell.textLabel?.lineBreakMode = .ByWordWrapping;
        cell.textLabel?.numberOfLines = 0;
        cell.textLabel?.font = uiTableViewCellFont
        
        cell.textLabel?.sizeToFit()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let row = indexPath.row
        
        // Gets selected row as String
        var selectedRowAsString = String( tableDataNSMutableArray[row] as NSString )
        println("Selected:  " + selectedRowAsString)
        
    }
    
}











