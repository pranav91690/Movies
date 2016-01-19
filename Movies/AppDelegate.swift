//
//  AppDelegate.swift
//  Movies
//
//  Created by Pranav Achanta on 1/15/16.
//  Copyright © 2016 pranav. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Logic to Create the Tab Controllers
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        // Create the Navigation Controllers and it's associated view controllers
        let nowPlayingNavigationController = storyBoard.instantiateViewControllerWithIdentifier("moviesNavigationController") as! UINavigationController
        // Top View Controller is the first view controller that the navigation controller is hooked into
        let nowPlayingViewController = nowPlayingNavigationController.topViewController as! MoviesViewController
        nowPlayingViewController.endPoint = "now_playing"
        nowPlayingNavigationController.tabBarItem.title = "Now Playing"
//        nowPlayingNavigationController.tabBarItem.image = UIImage(named: "now_playing")

        
        let topRatedNavigationController = storyBoard.instantiateViewControllerWithIdentifier("moviesNavigationController") as! UINavigationController
        // Top View Controller is the first view controller that the navigation controller is hooked into
        let topRatedViewController = topRatedNavigationController.topViewController as! MoviesViewController
        topRatedViewController.endPoint = "top_rated"
        topRatedNavigationController.tabBarItem.title = "Top Rated"
//        topRatedNavigationController.tabBarItem.image = UIImage(named: "top_rated")
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [nowPlayingNavigationController,topRatedNavigationController]
        
        // Why this code??? --> What other properties does this window have???
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

