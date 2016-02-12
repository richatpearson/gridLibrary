//
//  ViewController.swift
//  GridMobileClient
//
//  Created by Joe Miller on 11/4/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, PGMConsentViewControllerDelegate, UIAlertViewDelegate {

    @IBOutlet weak var environmentControl: UISegmentedControl!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginResponseView: UIView!
    @IBOutlet weak var tokenTextView: UITextView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet var keychainTextView: UITextView!
    @IBOutlet var readFromKeychainButton: UIButton!
    @IBOutlet var ValidateAuthContextButton: UIButton!
    @IBOutlet var useContextButton: UIButton!
    
    var client: PGMClient?
    var authResponse: PGMAuthResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setClient()
        
        initializeLoginResponseView()
        
        usernameField.delegate = self
        passwordField.delegate = self
        GridClientManager.sharedInstance.loginView = self //needed so we can assign delegate to it during consent flow
        self.useContextButton.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initializeLoginResponseView() {
        loginResponseView.hidden = true
        tokenTextView.text = ""
        messageTextView.text = ""
        keychainTextView.text = ""
        //readFromKeychainButton.hidden = true
    }
    
    // MARK: Actions
    
    @IBAction func viewTapped(sender: AnyObject) {
        self.view.endEditing(true);
    }
    
    @IBAction func environmentControlValueChanged(sender: AnyObject) {
        setClient()
        initializeLoginResponseView()
    }
    
    @IBAction func signInTapped(sender: AnyObject) {
        self.view.endEditing(true)
        performSignInWith(usernameField.text, password: passwordField.text)
        
    }
    
    @IBAction func signOutTapped(sender: AnyObject) {
        self.view.endEditing(true)
        performSignOut()
    }
    
    func performSignOut() {
        println("Sign Out was tapped.");
        if ( authResponse?.authContext == nil ) {
            println("There is nothing to signout.  You will need to first Sign In, then Sign Out.");
        } else {
            println("We were Signed In.  Now we will attempt to Sign Out.");
            var signOutAuthResponse: PGMAuthResponse?
            signOutAuthResponse = self.client!.authenticator.logoutUserWithAuthenticatedContext(authResponse!.authContext)
            authResponse?.authContext = nil
            clearScreenAfterLogout()
            
            self.useContextButton.hidden = true
        }
    }

    func clearScreenAfterLogout() {
        usernameField.text    = ""
        passwordField.text    = ""
        tokenTextView.text    = "No context at this time because the user logged out.  You will need to Sign In."
        messageTextView.text  = "No message at this time because the user logged out.  You will need to Sign In."
    }

    @IBAction func readContextFromKeychain(sender: AnyObject) {
        retrieveKeychainData()
        println("messageTextView is \(messageTextView.text)")
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == usernameField) {
            usernameField.resignFirstResponder()
            passwordField.becomeFirstResponder()
        } else if (textField == passwordField) {
            passwordField.resignFirstResponder()
            performSignInWith(usernameField.text, password: passwordField.text)
        }
        return true
    }
    
    // MARK: Login Methods
    
    func performSignInWith(username: String, password: String) {
        NSOperationQueue().addOperationWithBlock({
            self.client!.authenticator.authenticateWithUserName(username, andPassword: password, onComplete: { (authResponse: PGMAuthResponse!) -> Void in
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.signInComplete(authResponse)
                })
            })
        })
    }
    
    func signInComplete(response: PGMAuthResponse) {
        println("In signIn complete...")
        if (response.error != nil) {
            println("In signIn complete - error \(response.error.description)")
            if (response.error.code == 2 || response.error.code == 3) { //consent(s) required or consents have been refused
                GridClientManager.sharedInstance.consentPolicies = response.consentPolicies as Array<PGMConsentPolicy>
                println("consentPolicies array has \(GridClientManager.sharedInstance.consentPolicies?.count) elements")
                println("Escrow ticket issued by Pi is \(response.escrowTicket)")
                GridClientManager.sharedInstance.escrowTicket = response.escrowTicket;
                handleConsentFlow()
            }
            if (response.error.code == 9) {
                handleMaxNumberConsentRefusals()
            }
            tokenTextView.text = ""
            keychainTextView.text = ""
            messageTextView.text = response.error.description
            readFromKeychainButton.hidden = true
            ValidateAuthContextButton.hidden = true
        } else {
            tokenTextView.text = "\(response.authContext.accessToken)\n\(response.authContext.refreshToken)\n\(response.authContext.tokenExpiresIn)\n\(response.authContext.userIdentityId)\n\(response.authContext.username)"
            messageTextView.text = ""
            keychainTextView.text = ""
            readFromKeychainButton.hidden = false
            ValidateAuthContextButton.hidden = false
            println("tokenTextView is \(tokenTextView.text)")
            self.useContextButton.hidden = false
        }
        
        authResponse = response
        loginResponseView.hidden = false
    }

    func setClient() {
        switch environmentControl.selectedSegmentIndex {
        case 0:
            client = GridClientManager.sharedInstance.clientFor(PGMEnvironmentType.StagingEnv)
        case 1:
            client = GridClientManager.sharedInstance.clientFor(PGMEnvironmentType.ProductionEnv)
        default:
            client = GridClientManager.sharedInstance.clientFor(PGMEnvironmentType.SimulatedEnv)
        }
    }
    
    func retrieveKeychainData() {
        if (authResponse!.authContext != nil) {
            var storedData = PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(authResponse!.authContext.userIdentityId)
            println("Got keychain data - will unarchive...")
            var retrievedContext = NSKeyedUnarchiver.unarchiveObjectWithData(storedData) as PGMAuthenticatedContext
            
            //keychainTextView.text = "\(retrievedContext.accessToken)\n\(retrievedContext.refreshToken)\n\(retrievedContext.tokenExpiresIn)\n\(retrievedContext.username)\n\(retrievedContext.userIdentityId)"
            
            messageTextView.hidden = false
            messageTextView.text = "Context from keychain:\n\(retrievedContext.accessToken)\n\(retrievedContext.refreshToken)\n\(retrievedContext.tokenExpiresIn)\n\(retrievedContext.username)\n\(retrievedContext.userIdentityId)"
            
            
        }
        else {
            println("No auth response available - can't get keychain data.")
        }
    }
    
    func handleConsentFlow() {
        println("User needs to express consent to policies")
        
        var consentMsg = "User is missing consent. Please submit consent forms."
        
        let alert = UIAlertView()
        alert.title = "Consent Error"
        alert.message = consentMsg
        alert.addButtonWithTitle("OK")
        alert.show()
        
        self.performSegueWithIdentifier("ContinueToConsentSegue", sender: self)
        
    }
    
    func handleMaxNumberConsentRefusals() {
        var consentMsg = "User has reached the max number of consent refusals. Please contact System Administrator."
        
        let alert = UIAlertView()
        alert.title = "Consent Error"
        alert.message = consentMsg
        alert.addButtonWithTitle("OK")
        alert.show()
    }
    
    func submitConsentAfterAcceptance(controller: UIViewController) {
        //controller.navigationController?.popViewControllerAnimated(true)
        messageTextView.text = ""
        
        var consentPolicies = GridClientManager.sharedInstance.consentPolicies!
        
        for currentPolicy in consentPolicies {
            println("Policy id \(currentPolicy.policyId) and it's been reviewed \(currentPolicy.isReviewed) and consent is \(currentPolicy.isConsented)")
        }
        println("Submitting consent policies to Pi for username \(usernameField.text)...")
        self.perforConsentPolicySubmissionWith(self.usernameField.text, password: self.passwordField.text,
            consentPolicies: consentPolicies, escrowTicket: GridClientManager.sharedInstance.escrowTicket)
    }
    
    func perforConsentPolicySubmissionWith(username: String, password: String, consentPolicies: Array<PGMConsentPolicy>, escrowTicket: String) {
        NSOperationQueue().addOperationWithBlock({
            self.client!.authenticator.submitUserConsentPolicies(consentPolicies, withUsername: username, password: password, escrowTicket: escrowTicket, onComplete: { (authResponse: PGMAuthResponse!) -> Void in
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.signInComplete(authResponse)
                })
            })
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("in prepare for segue...")
        if (segue.identifier == "RefreshToken") {
            println("Will send data to refresh token VC...")
            
            var refreshTokenVC = segue.destinationViewController as RefreshTokenViewController
            refreshTokenVC.authContext = self.authResponse?.authContext
        }
        else if (segue.identifier == "UseContext") {
            println("Will send auth context to use context VC...")
            
            var useContextVC = segue.destinationViewController as UseContextViewController
            useContextVC.authContext = self.authResponse?.authContext
        }
    }
    
    @IBAction func validateContextTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("RefreshToken", sender: self)
    }
    
    @IBAction func forgotUsernameTapped(sender: AnyObject) {
        
        let alert = UIAlertView()
        alert.title = "Forgot Username?"
        alert.message = "Enter e-mail"
        alert.addButtonWithTitle("Cancel")
        alert.addButtonWithTitle("Submit")
        alert.delegate = self
        alert.show()
        
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        var buttonTitle = alertView.buttonTitleAtIndex(buttonIndex)
        
        if (buttonTitle == "Submit") {
            println("Clicked on Submit!")
            var emailAddress = alertView.textFieldAtIndex(0)?.text
            if (emailAddress == nil || emailAddress == "") {
                println("Must enter e-mail address!")
                
                messageTextView.text = "You must enter a valid primary e-mail address for the user."
                loginResponseView.hidden = false
                readFromKeychainButton.hidden = true
                ValidateAuthContextButton.hidden = true

            }
            else {
                println("Will call library...")
                
                self.performForgotUsernameWith(emailAddress!)
            }
        }
    }
    
    func performForgotUsernameWith(email: String) {
        self.client!.authenticator.forgotUsernameForEmail(email, onComplete: { (authResponse: PGMAuthResponse!) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.forgotUsernameComplete(authResponse)
            })
        })
    }
    
    func forgotUsernameComplete(response: PGMAuthResponse) {
        println("forgot username complete...")
        if (response.error != nil) {
            println("...and we got an error: \(response.error.description)")
            messageTextView.text = response.error.description
            loginResponseView.hidden = false
            readFromKeychainButton.hidden = true
            ValidateAuthContextButton.hidden = true
        } else {
            println("...and we got success!!")
            
            let alert = UIAlertView()
            alert.title = "Forgot Username?"
            alert.message = "An e-mail with the username has been sent to user's primary e-mail address."
            alert.addButtonWithTitle("OK")
            alert.show()
            
            messageTextView.text = ""
            loginResponseView.hidden = true
        }
    }
    
    @IBAction func forgotPasswordTapped(sender: AnyObject) {
        println("forgotPassword has been tapped")
        
        self.performForgotPasswordWith(self.usernameField.text)
    }
    
    func performForgotPasswordWith(username: String) {
        self.client!.authenticator.forgotPasswordForUsername(username, onComplete: { (authResponse: PGMAuthResponse!) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.forgotPasswordComplete(authResponse)
            })
        })
    }
    
    func forgotPasswordComplete(response: PGMAuthResponse) {
        println("forgot password completion...")
        if (response.error != nil) {
            println("...and we got an error: \(response.error.description)")
            messageTextView.text = response.error.description
            loginResponseView.hidden = false
            readFromKeychainButton.hidden = true
            ValidateAuthContextButton.hidden = true
        } else {
            println("...and we got success!!")
            
            let alert = UIAlertView()
            alert.title = "Forgot Password"
            alert.message = "An e-mail with a link to reset password has been sent to user's primary e-mail address."
            alert.addButtonWithTitle("OK")
            alert.show()
            
            messageTextView.text = ""
            loginResponseView.hidden = true
        }
    }
    
    @IBAction func useContextTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("UseContext", sender: self)
    }
    
}
