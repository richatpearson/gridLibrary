//
//  ViewController.swift
//  MPClientSwiftFrm
//
//  Created by Richard Rosiak on 2/6/15.
//  Copyright (c) 2015 Richard Rosiak. All rights reserved.
//

import UIKit
import GRIDMobileSDK

class ViewController: UIViewController {
    
    var client: PGMClient!
    
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var messages: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var options = PGMAuthOptions(clientId: "wkLZmUJAsTSMbVEI9Po6hNwgJJBGsgi5",
            andClientSecret: "SAftAexlgpeSTZ7n", andRedirectUrl: "http://int-piapi.stg-openclass.com/pi_group12client")
        
        self.client = PGMClient(environmentType: .StagingEnv, andOptions: options)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signInTapped(sender: AnyObject) {
        self.performSignInWith(self.username.text, password: self.password.text)
    }
    

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
        self.messages.text = ""
        
        println("In signIn complete...")
        if (response.error != nil) {
            println("In signIn complete - error \(response.error.description)")
            
            self.messages.text = response.error.description
            
        } else {
            println("Login on complete - success!!")
            println("The access token is: \(response.authContext.accessToken)")
            self.messages.text = "\(response.authContext.accessToken)\n\(response.authContext.refreshToken)\n\(response.authContext.tokenExpiresIn)\n\(response.authContext.userIdentityId)\n\(response.authContext.username)"
        }
    }
}

