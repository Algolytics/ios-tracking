//
//  AppDelegate.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 06/02/2020.
//  Copyright (c) 2020 Mateusz Mirkowski. All rights reserved.
//

import UIKit
import AlgolyticsSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        AlgolyticsSDK.shared.dataToSend
        AlgolyticsSDK.shared.initWith(url: "https://demo.scoring.one/api/scenario/code/remote/score?name=iOSTracking&key=da1ae9dc-6909-4c6a-8f7f-3fa059a7aa83",                                  apiKey: "api-key",
                                      apiPoolingTime: 5000,
                                      components: [
                                        .battery(poolingTime: 2000),
                                        .accelerometer(poolingTime: 5000),
                                        .calendar(poolingTime: 5000),
                                        .connectivity(poolingTime: 5000),
                                        .contact(poolingTime: 5000),
                                        .location(poolingTime: 5000),
                                        .photo(poolingTime: 5000),
                                        .wifi(poolingTime: 5000)
        ])

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

