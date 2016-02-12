//
//  PiLoginUIViewController.swift
//  DemoApp
//
//  Created by Seals, Morris D on 3/13/15.
//  Copyright (c) 2015 Seals, Morris D. All rights reserved.
//

import Foundation
import UIKit

class PiLoginUIViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var loginUITextField: UITextField!
    
    @IBOutlet weak var passwordUITextField: UITextField!
    
    @IBOutlet weak var errorMessageUITextField: UITextView!
    
    @IBOutlet weak var showPasswordUISwitch: UISwitch!
    
    
    // runs once
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Sign In"
        loginUITextField.delegate = self
        passwordUITextField.delegate = self
        showPasswordUISwitch.addTarget(self, action: Selector("switchChangedValue:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    // runs every time
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        println("PiLoginNotConsentedUIViewController viewWillAppear" )
        errorMessageUITextField.text = ""
        
        // We would take this out in production
        loginUITextField.text       = "group12user"
        passwordUITextField.text    = "P@ssword1"
        
        // We would take this out in production
        //loginUITextField.text       = "mobilenotconsented"
        //passwordUITextField.text    = "P@ssword1"
        
        switchChangedValue(showPasswordUISwitch)
    }
    
    func switchChangedValue(mySwitch: UISwitch) {
        if mySwitch.on {
            passwordUITextField.secureTextEntry = false
        } else {
            passwordUITextField.secureTextEntry = true
        }
    }
    
    @IBAction func signInButtonPushed(sender: AnyObject) {
        println("Sign In Button Pushed")
        AuthenticationViewModel.sharedInstance.performSignInWith(self.loginUITextField.text, password: self.passwordUITextField.text, currentPiLoginUIViewController: self)
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        println("PiLoginNotConsentedUIViewController.textFieldShouldReturn")
        self.view.endEditing(true);
        textField.resignFirstResponder()
        return false;
    }
    
    
    /////// Segues
    
    func performSignInSuccess() {
        println("PiLoginNotConsentedUIViewController.performSignInSuccess" )
        self.performSegueWithIdentifier( "segue_to_account_uiviewcontroller_id", sender: self )
    }
    
    func performSignInSuccessButNotYetConsented() {
        println("PiLoginNotConsentedUIViewController.performSignInSuccessButNotYetConsented()" )
        self.performSegueWithIdentifier( "segue_to_terms_of_use_id", sender: self )
    }
    
    func performSignInFailure( failureDescription: String ) {
        println("PiLoginNotConsentedUIViewController.performSignInFailure()" )
        self.errorMessageUITextField.text = failureDescription
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segue_to_terms_of_use_id" {
            println("PiLoginNotConsentedUIViewController.prepareForSegue segue_to_terms_of_use_id")
            let destinationVC = segue.destinationViewController as TermsOfUseUIViewController
            destinationVC.setLoginCredentials( self.loginUITextField.text, password: self.passwordUITextField.text )
        }
    }
    
}


