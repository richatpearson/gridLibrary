//
//  AccountUIViewController.swift
//  DemoApp
//
//  Created by Seals, Morris D on 3/3/15.
//  Copyright (c) 2015 Seals, Morris D. All rights reserved.
//

import UIKit
import GRIDMobileSDK

class AccountUIViewController: BaseUITableview {
    
    //@IBOutlet weak var tableView: UITableView!  // Drag the connection, then comment it out since its in base class

    var selectedCelString = "My Profile"
    
    
    override func loadData() {
        println("AccountUIViewController loadData")
        tableDataNSMutableArray.removeAllObjects()
        
        tableDataNSMutableArray.addObject("My Profile")
        tableDataNSMutableArray.addObject("My Courses")
        tableDataNSMutableArray.addObject("Grade Book")
        tableDataNSMutableArray.addObject("Logout")

    }
    
    
    // runs once
    override func viewDidLoad() {
        println("AccountUIViewController viewDidLoad")
        super.viewDidLoad()
        self.title = "My Account"
        loadData()
        registerClassAndSetDelegates()
    }
    
    // runs everytime
    override func viewWillAppear(animated: Bool) {
        println("AccountUIViewController viewWillAppear")
        super.viewWillAppear(true)
    }
    
    
    // UITableView delegate method
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let row = indexPath.row
        
        // Gets selected row as String
        var selectedRowAsString = String( tableDataNSMutableArray[row] as NSString )
        println("Selected:  " + selectedRowAsString)
        
        if        ( selectedRowAsString == "My Profile" ) {
            self.performSegueWithIdentifier( "segue_to_profile_uiviewcontroller_id", sender: nil )
        } else if ( selectedRowAsString == "My Courses" ) {
            println("AccountUIViewController selected My Courses")
            self.performSegueWithIdentifier( "segue_to_course_list_uiviewcontroller_id", sender: nil )
        } else if ( selectedRowAsString == "My Notes" ) {
            //self.performSegueWithIdentifier( "segue_xxx", sender: nil )
        } else if ( selectedRowAsString == "Logout" ) {
            AuthenticationViewModel.sharedInstance.logout()
            // get us directly to the root uiviewcontroller.
            self.navigationController?.popToRootViewControllerAnimated(true)
        } else {
            println( selectedRowAsString + " not implemented yet.")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "segue_to_course_list_uiviewcontroller_id" {
            let destinationVC = segue.destinationViewController as CourseListUIViewController
        }
        
    }

    
}




