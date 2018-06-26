//
//  AppDelegate.swift
//  Clear
//
//  Created by Danko, Radoslav on 16/04/2018.
//  Copyright © 2018 Danko, Radoslav. All rights reserved.
//

import UIKit
import WDePOS

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    public var currentUser:WDMerchantUser?
    
    var selectedPrinter: WDTerminal? {
        get {
            if let data = UserDefaults.standard.object(forKey: "selectedPrinter"){
                return NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? WDTerminal
            }
            return nil
        }
        set {
            UserDefaults.standard.setValue(NSKeyedArchiver.archivedData(withRootObject: newValue as Any), forKey: "selectedPrinter")
            
        }
    }
    
    var selectedTerminal: WDTerminal? {
        get {
            if let data = UserDefaults.standard.object(forKey: "selectedTerminal"){
                return NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? WDTerminal
            }
            return nil
        }
        set {
            UserDefaults.standard.setValue(NSKeyedArchiver.archivedData(withRootObject: newValue as Any), forKey: "selectedTerminal")
            
        }
    }
    
    var selectedCashRegister: WDCashRegister? {
        get {
            if let data = UserDefaults.standard.object(forKey: "selectedCashRegister"){
                return NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? WDCashRegister
            }
            return nil
        }
        set {
            UserDefaults.standard.setValue(NSKeyedArchiver.archivedData(withRootObject: newValue as Any), forKey: "selectedCashRegister")
            
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        changeAppearance()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func changeAppearance(){
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.darkGray]
        navigationBarAppearace.tintColor = UIColor.init(red: 0, green: 0.2, blue: 0.6, alpha: 1)
    }

}

