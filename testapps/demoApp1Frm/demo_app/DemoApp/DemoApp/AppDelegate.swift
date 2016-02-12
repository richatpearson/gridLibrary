//
//  AppDelegate.swift
//  DemoApp
//
//  Created by Seals, Morris D on 2/24/15.
//  Copyright (c) 2015 Seals, Morris D. All rights reserved.
//

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        println("AppDelegate didFinishLaunchingWithOptions")
                
        AuthenticationViewModel.sharedInstance.setupData()
        println("AppDelegate AuthenticationViewModel.sharedInstance.setupData() done")


        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        println("AppDelegate applicationWillResignActive")

    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        println("AppDelegate applicationDidEnterBackground")
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        println("AppDelegate applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        println("AppDelegate applicationDidBecomeActive")
        
        // We have to get a new handle on the ViewModel in case something changed in the NSUserDefaults, and we came back in the app.
        AuthenticationViewModel.sharedInstance.setupData()

    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        println("AppDelegate applicationWillTerminate")
    }

    
}



