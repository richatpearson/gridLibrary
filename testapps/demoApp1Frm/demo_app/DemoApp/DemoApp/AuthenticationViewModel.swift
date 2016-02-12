//
//  AuthenticationViewModel.swift
//  DemoApp
//
//  Created by Seals, Morris D on 3/13/15.
//  Copyright (c) 2015 Seals, Morris D. All rights reserved.
//

// This class operates as a Singleton.


import Foundation
import GRIDMobileSDK


public class AuthenticationViewModel {
    
    // These are 2 public, critical objects that will be referenced from other classes
    public var myPGMClient: PGMClient!
    public var myPGMAuthResponse: PGMAuthResponse?
    
    // This is for the app Settings
    var myNSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    var escrowTicket: String!
    
    // We are passing in this viewcontroller because we need stuff from it like username password
    var myPiLoginUIViewController: PiLoginUIViewController
    
    // This is the array of unmodified consent policies
    public var originalConsentPoliciesArray:            Array<PGMConsentPolicy>!
    
    // This is the array of consented policies as a NSMutableArray
    public var consentedConsentPoliciesNSMutableArray:  NSMutableArray = []
    
    // This is the array of consented policies as a NArray
    public var consentedConsentPoliciesArray:           Array<PGMConsentPolicy>! // we will populate this with consentedConsentPoliciesNSMutableArray
    
    // This is the NSMutableArray of consent URL's
    public var consentURLsNSMutableArray:               NSMutableArray = []
    
    
    // Singleton.  This will allow us to access the variables easily from anywhere in the app.
    class var sharedInstance: AuthenticationViewModel {
        struct Static {
            static var token: dispatch_once_t = 0
            static var instance: AuthenticationViewModel!
        }
        dispatch_once(&Static.token) {
            Static.instance = AuthenticationViewModel()
        }
        return Static.instance
    }
    
    
    init() {
        println("AuthenticationViewModel.init()")
        myPiLoginUIViewController = PiLoginUIViewController()
    }
    
    
    public func setupData() {
        println("AuthenticationViewModel.setupData()")
        initializeNSUserDefaults()
        initializePGMClient()
    }
    
    public func initializeNSUserDefaults() {
        
        // This sets the NSUserDefaults / Settings Bundle and synchronize them.
        
        // Brand name
        if var brand_name:  NSString = myNSUserDefaults.stringForKey("app_brand_name") {
            println("AuthenticationViewModel.initializeNSUserDefaults() got brand_name " + brand_name)
        } else {
            println("AuthenticationViewModel.initializeNSUserDefaults() got nothing for brand_name, setting it")
            myNSUserDefaults.setValue("Branded App",     forKeyPath: "app_brand_name")
        }
        
        // Environment
        if var env_type:  NSString   = myNSUserDefaults.stringForKey("environment_type") {
            println("AuthenticationViewModel.initializeNSUserDefaults() got environment " + env_type)
        } else {
            println("AuthenticationViewModel.initializeNSUserDefaults() got nothing for env_type, setting it")
            myNSUserDefaults.setValue("Staging",            forKeyPath: "environment_type")
        }
        
        // Brand Image
        if var image_1:  NSString  = myNSUserDefaults.stringForKey("brand_image_one_url") {
            println("AuthenticationViewModel.initializeNSUserDefaults() got image " + image_1)
        } else {
            println("AuthenticationViewModel.initializeNSUserDefaults() got nothing for image_1, setting it")
            // brain image
            myNSUserDefaults.setValue("http://s3.amazonaws.com/percolate-media-image-assets/24378678_520",   forKeyPath: "brand_image_one_url")
        }
        
        myNSUserDefaults.synchronize()
    }
    
    
    // Mobile Platform Client
    func initializePGMClient() {
        
        var environmentTypeString = "Staging"
        
        // Get the environmentType stored in Settings bundle / NSUserDefaults.
        if var environmentTypeFromDefaults:  String = myNSUserDefaults.stringForKey("environment_type") {
            println("environment_type " + environmentTypeFromDefaults)
            environmentTypeString = environmentTypeFromDefaults
        } else {
            println("ERROR 523")
        }
        
        println( "AuthenticationViewModel.initializePGMClient() got environment_type " + environmentTypeString)
        
        var mobilePlatformOptions = PGMAuthOptions( clientId:           "wkLZmUJAsTSMbVEI9Po6hNwgJJBGsgi5",
            andClientSecret:    "SAftAexlgpeSTZ7n",
            andRedirectUrl:     "http://int-piapi.stg-openclass.com/pi_group12client" )
        
        if        ( environmentTypeString == "Mock" )       {
            // Mock not implemented yet
            myPGMClient = PGMClient( environmentType: .StagingEnv, andOptions: mobilePlatformOptions )
        } else if ( environmentTypeString == "Staging" )    {
            myPGMClient = PGMClient( environmentType: .StagingEnv, andOptions: mobilePlatformOptions )
        } else if ( environmentTypeString == "Production" ) {
            myPGMClient = PGMClient( environmentType: .ProductionEnv, andOptions: mobilePlatformOptions )
        } else {
            myPGMClient = PGMClient( environmentType: .StagingEnv, andOptions: mobilePlatformOptions )
            println( "Error 1023" ) // We should have got one of the 3 environments.  It's unlikely this will happen.
        }
        
    }
    
    
    
    // Both of the following 2 asyncronous calls (performSignInWith and performConsentPolicySubmissionWith) will complete with the 3rd function:  signInComplete.
    
    // Here we are attempting to sign in.  If it works, we will execute:  self.signInComplete(authResponse)
    func performSignInWith(username: String, password: String, currentPiLoginUIViewController: PiLoginUIViewController) {
        
        // keeping a handle on the uiviewcontroller that sent this because we will need it later
        myPiLoginUIViewController = currentPiLoginUIViewController
        
        NSOperationQueue().addOperationWithBlock({
            self.myPGMClient!.authenticator.authenticateWithUserName(username, andPassword: password, onComplete: { (authResponse: PGMAuthResponse!) -> Void in
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.signInComplete(authResponse)
                })
            })
        })
    }
    
    // Here, we are consenting to all the policies.  If it works, we will execute:  self.signInComplete(authResponse)
    func performConsentPolicySubmissionWith(username: String, password:String ) {
        
        NSOperationQueue().addOperationWithBlock({
            self.myPGMClient!.authenticator.submitUserConsentPolicies(self.consentedConsentPoliciesArray, withUsername: username, password: password, escrowTicket: self.escrowTicket, onComplete: { (authResponse: PGMAuthResponse!) -> Void in
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.signInComplete(authResponse)
                })
            })
        })
    }
    
    func signInComplete(response: PGMAuthResponse) {
        
        println("AuthenticationViewModel.signInComplete() starting")
        
        if (response.error != nil) {
            
            if (response.error.code == 2 || response.error.code == 3) {
                
                // consent(s) required
                
                println("AuthenticationViewModel.signInComplete() consent(s) required starting..................................")
                
                // unconsented policies
                originalConsentPoliciesArray = response.consentPolicies as Array<PGMConsentPolicy>
                
                escrowTicket = response.escrowTicket
                
                // Clear out the consentedConsentPoliciesNSMutableArray
                consentedConsentPoliciesNSMutableArray.removeAllObjects()
                
                var i = 0
                for element in originalConsentPoliciesArray {
                    
                    ++i
                    
                    println(" ")
                    println("-----------------------------------------------------------------------------------")
                    println("Original originalConsentPoliciesArray")
                    println(    "element.policyId:        " + element.policyId )
                    println(    "element.consentPageUrl:  " + element.consentPageUrl )
                    
                    if ( element.isConsented == true ) {
                        println(    "element.isConsented:      true")
                    } else {
                        println(    "element.isConsented:      false")
                    }
                    
                    if ( element.isReviewed == true ) {
                        println(    "element.isReviewed:       true")
                    } else {
                        println(    "element.isReviewed:       false")
                    }
                    println("-----------------------------------------------------------------------------------")
                    println(" ")
                    
                    // As we iterate throught the consent policies, we are setting the isConsented and isReviewed to true.
                    // Then the user will:  Accept All.
                    var consentedPGMConsentPolicy = PGMConsentPolicy(policyId: element.policyId, consentUrl: element.consentPageUrl, isConsented: true, isReviewed: true)
                    
                    println(" ")
                    println("-----------------------------------------------------------------------------------")
                    println("Consented consentedPGMConsentPolicy")
                    println(    "consentedPGMConsentPolicy.policyId:        " + consentedPGMConsentPolicy.policyId )
                    println(    "consentedPGMConsentPolicy.consentPageUrl:  " + consentedPGMConsentPolicy.consentPageUrl )
                    
                    if ( consentedPGMConsentPolicy.isConsented == true ) {
                        println(    "consentedPGMConsentPolicy.isConsented:      true")
                    } else {
                        println(    "consentedPGMConsentPolicy.isConsented:      false")
                    }
                    
                    if ( consentedPGMConsentPolicy.isReviewed == true ) {
                        println(    "consentedPGMConsentPolicy.isReviewed:       true")
                    } else {
                        println(    "consentedPGMConsentPolicy.isReviewed:       false")
                    }
                    println("-----------------------------------------------------------------------------------")
                    println(" ")
                    
                    consentedConsentPoliciesNSMutableArray.addObject(consentedPGMConsentPolicy)
                    
                }
                
                println("AuthenticationViewModel.signInComplete() consent(s) required completed..................................")
                
                // This will be the Array of reviewed and consented policies.
                // We can reference it in both formats.  One format as NSMutableArray (consentedConsentPoliciesNSMutableArray) will be used by the UITableView,
                // and one format as Array will be used for the POST (consentedConsentPoliciesArray).
                //
                consentedConsentPoliciesArray =  consentedConsentPoliciesNSMutableArray as AnyObject as [PGMConsentPolicy]
                
                myPiLoginUIViewController.performSignInSuccessButNotYetConsented()
                
                
            } else if (response.error.code == 9) {
                // Ooops, we hit the end point too many times and hit handleMaxNumberConsentRefusals.  Fix it on server.
                println("AuthenticationViewModel.signInComplete() handleMaxNumberConsentRefusals")
                myPiLoginUIViewController.performSignInFailure(response.error.description)
            } else {
                println("AuthenticationViewModel.signInComplete() .performSignInFailure we don't know exactly why, but it did not get success()")
                myPiLoginUIViewController.performSignInFailure(response.error.description)
            }
        } else {
            // we got success
            println("AuthenticationViewModel.signInComplete() we got success!")
            
            // Set this so we can reference it globally later.
            myPGMAuthResponse = response
            
            myPiLoginUIViewController.performSignInSuccess()
            
        }
    }
    
    public func logout() {
        println("AuthenticationViewModel.logout")
        var signOutAuthResponse: PGMAuthResponse?
        signOutAuthResponse = AuthenticationViewModel.sharedInstance.myPGMClient!.authenticator.logoutUserWithAuthenticatedContext(myPGMAuthResponse?.authContext)
    }
    
}


