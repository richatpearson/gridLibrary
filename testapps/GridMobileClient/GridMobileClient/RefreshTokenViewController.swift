//
//  RefreshTokenViewController.swift
//  GridMobileClient
//
//  Created by Richard Rosiak on 1/5/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

import UIKit

class RefreshTokenViewController: UIViewController, UITextFieldDelegate {
    
    var authContext: PGMAuthenticatedContext?
    var currentEnvironemt: PGMEnvironment!
    var clientOptions: PGMAuthOptions!
    var contextValidator = PGMAuthContextValidator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ExpirationIntervalInSeconds.delegate = self
        self.validateContextCountTextField.delegate = self
        
        println("Access token sent is: \(authContext?.accessToken)")
        self.CurrentAccessToken.text = authContext?.accessToken
        self.CurrentRefreshToken.text = authContext?.refreshToken
        if (authContext != nil) {
            self.CurrentExpiresIn.text = String(authContext!.tokenExpiresIn)
        }
        
        self.currentEnvironemt = GridClientManager.sharedInstance.currentClient?.environment
        self.clientOptions = GridClientManager.sharedInstance.currentClient?.options
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet var CurrentAccessToken: UILabel!
    @IBOutlet var CurrentRefreshToken: UILabel!
    @IBOutlet var CurrentExpiresIn: UILabel!
    

    @IBOutlet var NewAccessToken: UILabel!
    @IBOutlet var NewRefreshToken: UILabel!
    @IBOutlet var NewExpiresIn: UILabel!
    
    @IBOutlet var ExpirationIntervalInSeconds: UITextField!
    
    @IBOutlet var ErrorMessages: UITextView!
    
    @IBOutlet weak var validateContextCountTextField: UITextField!
    
    @IBOutlet weak var providedAccessTokenTextField: UITextField!
    
    // MARK - UITextField delegate - only allow digits and backspace chars
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
        replacementString string: String) -> Bool {
            
        if (string.utf16Count == 0) {
            return true
        }
            
        if (string.toInt() != nil) {
            return true
        }
        
        return false
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func ModifyExpIntervalTapped(sender: AnyObject) {
        var expIntervalInSeconds: Int! = (self.ExpirationIntervalInSeconds.text.toInt() != nil) ? self.ExpirationIntervalInSeconds.text.toInt() : 0
        println("exp interval is: \(expIntervalInSeconds)")
        
        var authContextForMod = PGMAuthenticatedContext(accessToken: self.CurrentAccessToken.text, refreshToken: self.CurrentRefreshToken.text, andExpirationInterval: UInt(expIntervalInSeconds))
        authContextForMod.userIdentityId = authContext?.userIdentityId
        authContextForMod.username = authContext?.username
        
        var authContextData = NSKeyedArchiver.archivedDataWithRootObject(authContextForMod)
        println("Will modify context's interval to \(UInt(expIntervalInSeconds))")
        
        PGMSecureKeychainStorage.storeKeychainData(authContextData, withIdentifier: self.authContext?.userIdentityId)
    }
    
    @IBAction func ValidateContextTapped(sender: AnyObject) {
        
        self.ErrorMessages.text = ""
        
        self.setContextValidatorInstance()
        
        println("Clicking away...")

        var counter: Int = 0
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        
        while counter < self.validateContextCountTextField.text.toInt()! {

            println("Counter is: \(counter)")
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                println("\(counter): Runnig task to provide current context - on thread \(NSThread.currentThread())")
                self.contextValidator.provideCurrentTokenForAuthContext(self.authContext, environment: self.currentEnvironemt, options: self.clientOptions, onComplete: { (response) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.validateContextOnComplete(response)
                    }
                })
            }
            ++counter
            //NSThread.sleepForTimeInterval(0.002) //NOTE for debugging only
        }
    }
    
    // Morris
    @IBAction func providedAccessTokenTapped(sender: AnyObject) {
        self.ErrorMessages.text = ""
        
        println("providedAccessTokenTapped")
        
        println("providedAccessTokenTapped with provided access token:   " + providedAccessTokenTextField.text)
        
        self.setContextValidatorInstance()
        
        var counter: Int = 0
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        
        while counter < self.validateContextCountTextField.text.toInt()! {
            
            println("Counter is: \(counter)")
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                println("\(counter): Runnig task to provide current context - on thread \(NSThread.currentThread())")
                
                var authContextWithProvidedToken = PGMAuthenticatedContext(accessToken: self.providedAccessTokenTextField.text, refreshToken: self.CurrentRefreshToken.text, andExpirationInterval: 10)
                
                authContextWithProvidedToken.userIdentityId = self.authContext?.userIdentityId
                
                self.contextValidator.provideCurrentTokenForExpiredAuthContext(authContextWithProvidedToken, environment: self.currentEnvironemt, options: self.clientOptions, onComplete: { (response) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.validateContextOnComplete(response)
                    }
                })
                
            }
            ++counter
            //NSThread.sleepForTimeInterval(0.002) //NOTE for debugging only
        }
        
    }
    
    func validateContextOnComplete(response: PGMAuthResponse) {
        if (response.error != nil) {
            //
            println("validateContextOnComplete - Error: \(response.error.description)")
            
            self.ErrorMessages.text = response.error.description
            
            self.NewAccessToken.text = nil
            self.NewRefreshToken.text = nil
            self.NewExpiresIn.text = nil
            self.CurrentAccessToken.text = nil
            self.CurrentRefreshToken.text = nil
            self.CurrentExpiresIn.text = nil
        }
        else {
            println("validateContextOnComplete - Success!!")
            var printInfo = "Reporting access token \(response.authContext.accessToken)\n"
            println(printInfo)
            self.ErrorMessages.text = self.ErrorMessages.text + "\n" + printInfo
            
            self.NewAccessToken.text = response.authContext.accessToken
            self.NewRefreshToken.text = response.authContext.refreshToken
            self.NewExpiresIn.text = String(response.authContext.tokenExpiresIn)
            
            //change current context values in labels:
            if (self.CurrentAccessToken.text != self.NewAccessToken.text) {
                self.CurrentAccessToken.text = self.NewAccessToken.text
                self.CurrentRefreshToken.text = self.NewRefreshToken.text
                self.CurrentExpiresIn.text = self.NewExpiresIn.text
            }
        }
    }
    
    //only one instance of contextValidator
    func setContextValidatorInstance() {
        if (self.contextValidator == nil) {
            println("Will create contextValidator")
            self.contextValidator = PGMAuthContextValidator()
        }
    }
    
    
    

    
    
    
    
}









