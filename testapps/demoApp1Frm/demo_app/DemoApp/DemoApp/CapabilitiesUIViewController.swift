//
//  CapabilitiesUIViewController.swift
//  DemoApp
//
//  Created by Seals, Morris D on 2/25/15.
//  Copyright (c) 2015 Seals, Morris D. All rights reserved.
//

import UIKit


class CapabilitiesUIViewController: BaseUITableview {

    
    override func loadData() {
        tableDataNSMutableArray.removeAllObjects()
        
        tableDataNSMutableArray.addObject("Course Files")
        tableDataNSMutableArray.addObject("Announcements")
        tableDataNSMutableArray.addObject("Homework")
        tableDataNSMutableArray.addObject("Discussions")
        tableDataNSMutableArray.addObject("Activities")
        tableDataNSMutableArray.addObject("Assignments")
        tableDataNSMutableArray.addObject("Notifications")
        tableDataNSMutableArray.addObject("Do Thing H")
        tableDataNSMutableArray.addObject("Do Thing I")
        tableDataNSMutableArray.addObject("Do Thing J")
        tableDataNSMutableArray.addObject("Do Thing K")
        tableDataNSMutableArray.addObject("Do Thing L")
        tableDataNSMutableArray.addObject("Do Thing M")
        tableDataNSMutableArray.addObject("Do Thing N")
        tableDataNSMutableArray.addObject("Do Thing O")
        tableDataNSMutableArray.addObject("Do Thing P")
        tableDataNSMutableArray.addObject("Do Thing Q")
        tableDataNSMutableArray.addObject("Do Thing R")
        tableDataNSMutableArray.addObject("Do Thing S")
        tableDataNSMutableArray.addObject("Do Thing T")
        tableDataNSMutableArray.addObject("Do Thing U")
        tableDataNSMutableArray.addObject("Do Thing V")
        tableDataNSMutableArray.addObject("Do Thing W")
        tableDataNSMutableArray.addObject("Do Thing X")
        tableDataNSMutableArray.addObject("Do Thing Y")
        tableDataNSMutableArray.addObject("Do Thing Z")
    }
    
    // runs once
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        registerClassAndSetDelegates()
    }
    
    // runs every time
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(true)
        
        println("CapabilitiesUIViewController viewWillAppear" )

        self.title = "Capabilities"
        
    }

    
    // UITableView delegate method
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let row = indexPath.row

        // Gets selected row as String
        var selectedRowAsString = String( tableDataNSMutableArray[row] as NSString )
        println("Selected:  " + selectedRowAsString)
        
        //
        if ( selectedRowAsString == "List Courses" ) {
            self.performSegueWithIdentifier( "segue_to_course_list_uiviewcontroller", sender: nil )
        } else {
            println( selectedRowAsString + " not implemented yet" )
        }
    }
    

}
