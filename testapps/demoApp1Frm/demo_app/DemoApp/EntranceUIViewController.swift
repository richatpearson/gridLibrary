//
//  EntranceUIViewController.swift
//  DemoApp
//
//  Created by Seals, Morris D on 2/24/15.
//  Copyright (c) 2015 Seals, Morris D. All rights reserved.
//


import UIKit

public class EntranceUIViewController: UIViewController {

    @IBOutlet weak var brandedUIImageView: UIImageView!

    @IBOutlet weak var clickHereToEnterButton: UIButton!

    
    // runs once
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // runs every time
    public override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(true)
        
        println("EntranceUIViewController viewWillAppear" )
        
        // AuthenticationViewModel.sharedInstance.
        // Get the brand name stored in Settings bundle / UserDefaults.  11 Characters max
        if var brandNameFromDefaults:  NSString = AuthenticationViewModel.sharedInstance.myNSUserDefaults.stringForKey("app_brand_name") {

            println("got brand_name " + brandNameFromDefaults)
            self.title = brandNameFromDefaults
        } else {
            self.title = "Branded App"
            println("ERROR 400")
        }

        setBrandNameTextInButton()
        
        setImageViewImage()
        
    }

    func setBrandNameTextInButton() {
        if var brandNameFromDefaults:  NSString = AuthenticationViewModel.sharedInstance.myNSUserDefaults.stringForKey("app_brand_name") {
            println("got brand_name " + brandNameFromDefaults)
            clickHereToEnterButton.setTitle("Click Here To Enter " + brandNameFromDefaults, forState: UIControlState.Normal)
        } else {
            println("ERROR 100")
        }
    }

    func setImageViewImage() {
        
        if var brandImageFromDefaults:  NSString = AuthenticationViewModel.sharedInstance.myNSUserDefaults.stringForKey("brand_image_one_url") {
            println("got branded image " + brandImageFromDefaults)
            if let url = NSURL(string: brandImageFromDefaults) {
                if let data = NSData(contentsOfURL: url){
                    brandedUIImageView.contentMode = UIViewContentMode.ScaleAspectFit
                    brandedUIImageView.image = UIImage(data: data)
                }
            } else {
                println("ERROR 200")
            }
        } else {
            println("ERROR 300")
        }
        
    }

    @IBAction func clickHereToEnterButtonClicked(sender: AnyObject) {
        println("Click here pushed.")
        self.performSegueWithIdentifier( "segue_to_auth_type", sender: nil )
    }
    
    
}









