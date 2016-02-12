//
//  TermsOfUseDetailUIViewController.swift
//  DemoApp
//
//  Created by Seals, Morris D on 2/25/15.
//  Copyright (c) 2015 Seals, Morris D. All rights reserved.
//

import UIKit
import GRIDMobileSDK

public class TermsOfUseDetailUIViewController: UIViewController {
    

    @IBOutlet weak var uiWebView: UIWebView!
    
    public var selectedPGMConsentPolicy: PGMConsentPolicy!

    
    public func setConsentedPGMConsentPolicy( policy: PGMConsentPolicy ) {
        selectedPGMConsentPolicy = policy
    }
    
    
    // runs once
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Terms Of Use Details"
    }
    
    // runs every time
    public override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(true)
        
        println("TermsOfUseDetailUIViewController viewWillAppear with termsOfUseWebsiteString:  " + selectedPGMConsentPolicy.consentPageUrl)
        
        let url = NSURL(string: selectedPGMConsentPolicy.consentPageUrl)

        let request = NSURLRequest(URL: url!)
        
        uiWebView.loadRequest(request)
        
    }
    
    
}















