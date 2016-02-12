//
//  TermsOfUseUIViewController.swift
//  DemoApp
//
//  Created by Seals, Morris D on 2/25/15.
//  Copyright (c) 2015 Seals, Morris D. All rights reserved.
//


import UIKit
import GRIDMobileSDK


public class TermsOfUseUIViewController: BaseUITableview {
    
    // this is the consent policy we will select in the UITableView and use in the segue.
    public var selectedPGMConsentPolicy: PGMConsentPolicy!
    
    // username and password that will be stored for the segue
    public var selectedUsername = "none"
    public var selectedPassword = "none"


    // The incoming segue has to give us the username and password so we can post to PI.
    public func setLoginCredentials( username: String, password: String ) {
        selectedUsername = username
        selectedPassword = password
    }
    
    
    // populate tableview data
    override public func loadData() {
        tableDataNSMutableArray.removeAllObjects()
        tableDataNSMutableArray.addObjectsFromArray(AuthenticationViewModel.sharedInstance.consentedConsentPoliciesNSMutableArray)
    }

    
    // runs once
    override public func viewDidLoad() {
        
        super.viewDidLoad()
        
        var environmentTypeString = "Staging"
        // Get the environmentType stored in Settings bundle / NSUserDefaults.
        if var environmentTypeFromDefaults:  String = AuthenticationViewModel.sharedInstance.myNSUserDefaults.stringForKey("environment_type") {
            println("environment_type " + environmentTypeFromDefaults)
            environmentTypeString = environmentTypeFromDefaults
        } else {
            println("ERROR 967")
        }

        if ( AuthenticationViewModel.sharedInstance.myNSUserDefaults.stringForKey("environment_type") == "Mock" )       {
            // not implemented yet
            // fake data
            // loadMockData()
        }
    }
    
    // runs everytime
    override public func viewWillAppear(animated: Bool) {

        super.viewWillAppear(true)
        
        println("TermsOfUseUIViewController viewWillAppear" )

        self.title = "Terms Of Use"
        
        loadData()
        
        registerClassAndSetDelegates()

    }

    // UITableView delegate method
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell                        = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        let row                         = indexPath.row
        let rowPlusOne                  = row + 1
        cell.textLabel?.text            = "Terms Of Use " + "\(rowPlusOne)"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let row                         = indexPath.row
        
        selectedPGMConsentPolicy        = tableDataNSMutableArray[row] as PGMConsentPolicy
        
        self.performSegueWithIdentifier( "segue_to_terms_of_use_detail_uiviewcontroller", sender: nil )
    }

    
    @IBAction func acceptAllButtonClicked(sender: AnyObject) {
        // We accepted all the policies
        AuthenticationViewModel.sharedInstance.performConsentPolicySubmissionWith( selectedUsername, password: selectedPassword )
    }

    @IBAction func noThanksButtonClicked(sender: AnyObject) {
        println("TermsOf Use noThanksButtonClicked." )
        
        // get us directly to the root uiviewcontroller.
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segue_to_terms_of_use_detail_uiviewcontroller" {
            var myTermsOfUseDetailUIViewController: TermsOfUseDetailUIViewController = segue.destinationViewController as TermsOfUseDetailUIViewController
            myTermsOfUseDetailUIViewController.setConsentedPGMConsentPolicy(selectedPGMConsentPolicy)
        }
    }

}















