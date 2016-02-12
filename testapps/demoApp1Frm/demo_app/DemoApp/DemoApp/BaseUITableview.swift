//
//  BaseUITableview.swift
//  DemoApp
//
//  Created by Seals, Morris D on 3/2/15.
//  Copyright (c) 2015 Seals, Morris D. All rights reserved.
//


import UIKit

public class BaseUITableview: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let textCellIdentifier = "CellIdentifier"
    
    var tableDataNSMutableArray: NSMutableArray = []
    
    @IBOutlet weak var tableView: UITableView!
    
    // Child classes will removeAllObjects() here, then populate data in tableDataNSMutableArray
    public func loadData() {
    }
    
    public func registerClassAndSetDelegates() {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: textCellIdentifier)
        tableView.delegate      = self
        tableView.dataSource    = self
    }

    ///////////////// UITableView delegate methods
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDataNSMutableArray.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        let row = indexPath.row
        cell.textLabel?.text = "\(self.tableDataNSMutableArray[indexPath.row])"
        return cell
    }
    
    /*
    // This sample is what should be implemented in the child class.  Leave it in here so we can copy / paste into child class.
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let row = indexPath.row
        
        // Gets selected row as String
        var selectedRowAsString = String( tableDataNSMutableArray[row] as NSString )
        println("Selected:  " + selectedRowAsString)

    }
    */

    ///////////////// UITableView delegate methods
}




    