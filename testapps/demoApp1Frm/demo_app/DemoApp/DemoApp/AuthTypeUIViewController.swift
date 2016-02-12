//
//  AuthTypeUIViewController.swift
//  DemoApp
//
//  Created by Seals, Morris D on 2/24/15.
//  Copyright (c) 2015 Seals, Morris D. All rights reserved.
//


import UIKit

class AuthTypeUIViewController: BaseUITableview {

    override func loadData() {
        tableDataNSMutableArray.removeAllObjects()
        tableDataNSMutableArray.addObject("Log In With Pi")
        tableDataNSMutableArray.addObject("Log In With SMS")
    }
    
    
    // runs once
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        registerClassAndSetDelegates()
    }
    
    // runs everytime
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(true)
        
        println("AuthTypeUIViewController viewWillAppear" )
        
        self.title = "Auth Type"

    }
    
    // UITableView delegate method
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let row = indexPath.row
        
        // Gets selected row as String
        var selectedRowAsString = String( tableDataNSMutableArray[row] as NSString )
        println("Selected:  " + selectedRowAsString)

        if        ( selectedRowAsString == "Log In With Pi" ) {
            self.performSegueWithIdentifier( "segue_to_pi_login_not_consented", sender: nil )
        } else if ( selectedRowAsString == "Log In With SMS" ) {

        }
    }
    

}












