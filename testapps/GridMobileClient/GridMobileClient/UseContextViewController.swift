//
//  UseContextViewController.swift
//  GridMobileClient
//
//  Created by Richard Rosiak on 3/19/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

import UIKit

class UseContextViewController: UIViewController {
    
    var authContext: PGMAuthenticatedContext?
    var client: PGMClient!
    var currentToken: String = ""
    var coreNetworkRequester: PGMCoreNetworkRequester!

    override func viewDidLoad() {
        super.viewDidLoad()

        println("In UserContext VC - access token sent is: \(authContext?.accessToken)")
        accessToken.text = authContext?.accessToken
        
        self.client = GridClientManager.sharedInstance.currentClient
        self.coreNetworkRequester = PGMCoreNetworkRequester()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet var accessToken: UILabel!
    @IBOutlet var userConsents: UITextView!

    @IBAction func showUserConsentsTapped(sender: AnyObject) {
        
        self.obtainCurrentTokenAndConsents(self.authContext!)
    }
    
    func obtainCurrentTokenAndConsents(authContext: PGMAuthenticatedContext) {
        
        self.client!.authenticator.obtainCurrentTokenForAuthContext(authContext, onComplete: { (authResponse: PGMAuthResponse!) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.obtainCurrentTokenForContextComplete(authResponse)
            })
        })
    }
    
    func obtainCurrentTokenForContextComplete(authResponse: PGMAuthResponse) {
        
        println("Get current token complete...")
        if (authResponse.error != nil) {
            println("...and we got an error: \(authResponse.error.description)")
            
            userConsents.text = authResponse.error.description
        } else {
            println("...and we got success!! Current token is \(authResponse.authContext.accessToken)")
            self.authContext = authResponse.authContext //resetting context var in view to the newest one
            self.currentToken = authResponse.authContext.accessToken
            accessToken.text = authResponse.authContext.accessToken
            
            self.obtainUserConsents(self.currentToken)
        }
    }
    
    func obtainUserConsents(token: String) {
        
        var request = self.createUserConsentUrlRequest(token)
        
        self.coreNetworkRequester.performNetworkCallWithRequest(request, andCompletionHandler: { (returnedData: NSData!, error: NSError!) -> Void in
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.executeConsentRequestComplete(returnedData, error: error)
                })
        })
    }
    
    func executeConsentRequestComplete(data: NSData, error: NSError!) {
        println("Get user consents complete...")
        if (error != nil) {
            println("...and we got an error: \(error.description)")
            userConsents.text = error.description
        }
        else {
            println("...and we got success!!")
            var jsonError: NSError?
            let jsonResponse = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as NSDictionary
            
            if (jsonError != nil) {
                println("Error getting JSON from NSData obj")
                userConsents.text = jsonError?.description
            }
            else {
                println("The consent data is: \n \(jsonResponse.description)")
                userConsents.text = jsonResponse.description
            }
        }
    }
    
    func createUserConsentUrlRequest(token: String) -> NSURLRequest {
        var urlObj: NSURL = NSURL(string: self.client.environment.PGMAuthBase + "identities/" +
            self.authContext!.userIdentityId + "/userconsents")!
        
        println("Consent url is: \(urlObj)")
        
        var urlRequest = NSMutableURLRequest(URL: urlObj)
        urlRequest.HTTPMethod = "GET"
        urlRequest.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        
        return urlRequest
    }
    
    @IBAction func showUserConsentsExpTokenTapped(sender: AnyObject) {
        
        self.obtainConsentsForExpiredToken(self.authContext!)
    }
    
    func obtainConsentsForExpiredToken(authContext: PGMAuthenticatedContext) {
        
        self.client!.authenticator.obtainCurrentTokenForExpiredAuthContext(authContext, onComplete: { (authResponse: PGMAuthResponse!) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.obtainCurrentTokenForContextComplete(authResponse)
            })
        })
    }
    
}
