//
//  CourseListUIViewController.swift
//  DemoApp
//
//  Created by Seals, Morris D on 2/25/15.
//  Copyright (c) 2015 Seals, Morris D. All rights reserved.
//

import UIKit

public class CourseListUIViewController: BaseUITableview {
    
    //@IBOutlet weak var tableView: UITableView!
    
    
    override public func loadData() {
        tableDataNSMutableArray.removeAllObjects()
        
        tableDataNSMutableArray.addObject("Basic Astronomy")
        tableDataNSMutableArray.addObject("Accounting")
        tableDataNSMutableArray.addObject("Statistics")
        tableDataNSMutableArray.addObject("Ancient History")
        tableDataNSMutableArray.addObject("Art History")
        tableDataNSMutableArray.addObject("Business Economics")
    }
    
    
    // runs once
    public override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = "Course List"
        loadData()
        registerClassAndSetDelegates()
    }
    
    // runs everytime
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        println("AccountUIViewController viewWillAppear" )
    }

    
    // UITableView delegate method
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let row = indexPath.row
        
        // Gets selected row as String
        var selectedRowAsString = String( tableDataNSMutableArray[row] as NSString )
        println("Selected:  " + selectedRowAsString)
        
        self.performSegueWithIdentifier( "segue_to_course_list_uiviewcontroller_id", sender: nil )
    }

}











