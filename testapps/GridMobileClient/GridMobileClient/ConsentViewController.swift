//
//  ConsentViewController.swift
//  GridMobileClient
//
//  Created by Joe Miller on 11/10/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

import UIKit

protocol PGMConsentViewControllerDelegate {
    func submitConsentAfterAcceptance(controller: UIViewController)
}

class ConsentViewController: UIViewController, UIWebViewDelegate {
    
    var delegate: PGMConsentViewControllerDelegate? = nil
    @IBOutlet var consentWebView: UIWebView!
    var currentPolicyId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = GridClientManager.sharedInstance.loginView
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        self.consentWebView.scalesPageToFit = true
        self.loadNextConsentPage()
        println("Consent web view should be loaded with url.")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadNextConsentPage() {
        var url = NSURL(string: self.getConsentUrl())
        var urlRequest = NSURLRequest(URL: url!)
        self.consentWebView.loadRequest(urlRequest)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        println("WEB VIEW DID FINISH LOADING")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func acceptConsentPressed(sender: AnyObject) {
        println("accept consent clicked!")
        self.expressConsent()
        self.processCurrentConsents()
    }
    
    @IBAction func declineConsentPressed(sender: AnyObject) {
        println("decline consent clicked!")
        
        self.declinePolicyConsentForPolicyId(self.currentPolicyId!)
        self.processCurrentConsents()
    }
    
    func getConsentUrl() -> String {
        var url = ""
        var consentPolicies = GridClientManager.sharedInstance.consentPolicies!
        policyLoop: for currentPolicy in consentPolicies {
            if (!currentPolicy.isConsented && !currentPolicy.isReviewed) {
                url = currentPolicy.consentPageUrl
                println("Returning url \(currentPolicy.consentPageUrl) for policy id \(currentPolicy.policyId)")
                self.currentPolicyId = currentPolicy.policyId
                break policyLoop
            }
        }
        
        return url
    }
    
    func processCurrentConsents() {
        if (self.areAllPoliciesReviewed()) {
            self.postConsentsToPi()
        } else {
            self.loadNextConsentPage()
        }
    }
    
    func postConsentsToPi() {
        println("Closing view and calling delegate...")
        self.navigationController?.popViewControllerAnimated(false)
        
        self.delegate?.submitConsentAfterAcceptance(self)
    }
    
    func expressConsent() -> Bool {
        if (self.currentPolicyId != nil) {
            self.markPolicyAsConsentedForPolicyId(self.currentPolicyId!)
        }
        return true
    }
    
    func markPolicyAsConsentedForPolicyId(policyId: String) {
        var consentPolicies = GridClientManager.sharedInstance.consentPolicies!
        
        for currentPolicy in consentPolicies {
            if (currentPolicy.policyId == policyId) {
                currentPolicy.isConsented = true
                currentPolicy.isReviewed = true
            }
        }
    }
    
    func areAllPoliciesReviewed () -> Bool {
        var consentPolicies = GridClientManager.sharedInstance.consentPolicies!
        
        for currentPolicy in consentPolicies {
            if (!currentPolicy.isReviewed) {
                return false;
            }
        }
        return true;
    }
    
    func declinePolicyConsentForPolicyId(policyId: String) {
        var consentPolicies = GridClientManager.sharedInstance.consentPolicies!
        
        for currentPolicy in consentPolicies {
            if (currentPolicy.policyId == policyId) {
                currentPolicy.isConsented = false
                currentPolicy.isReviewed = true
            }
        }
    }
}
