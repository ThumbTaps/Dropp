//
//  AppDelegate.swift
//  Lissic
//
//  Created by Jeffery Jackson Jr. on 4/17/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	enum ShortcutIdentifier: String {
		case search = "com.lissic.app.search"
	}

	var window: UIWindow?
	
	var shortcutItem: UIApplicationShortcutItem?
	
	func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
		
		var succeeded = false
		
		guard let shortcutIdentifier = ShortcutIdentifier(rawValue: shortcutItem.type) else {
			return succeeded
		}
		
		if shortcutIdentifier == .search {
			self.window?.rootViewController?.dismiss(animated: false)
			(self.window?.rootViewController as? NewReleasesViewController)?.showSearch()
			succeeded = true
		}
		
		return succeeded
	}
	
	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		
		completionHandler(self.handleShortcutItem(shortcutItem))
		
	}
	
	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		
		PreferenceManager.shared.load {
			PreferenceManager.shared.updateNewReleases()
		}

		return true
	}
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

		// Override point for customization after application launch.
//		FIRApp.configure()
		
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
			if granted {
				
			}
		}
		//		let content = UNMutableNotificationContent()
		//		content.title = "10 Second Notification Demo"
		//		content.subtitle = "From MakeAppPie.com"
		//		content.body = "Notification after 10 seconds - Your pizza is Ready!!"
		//		content.categoryIdentifier = "message"
		//
		//		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10.0, repeats: false)
		//
		//		let request = UNNotificationRequest(identifier: "10.second.message", content: content, trigger: trigger)
		//
		//		UNUserNotificationCenter.current().add(
		//			request, withCompletionHandler: nil)
		
		application.registerForRemoteNotifications()
		
		var performShortcutDelegate = true
		
		if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
			
			self.shortcutItem = shortcutItem
			
			performShortcutDelegate = false
		}
		
		return performShortcutDelegate
		
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		PreferenceManager.shared.save()
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		
		guard let shortcut = shortcutItem else { return }
		
		_ = self.handleShortcutItem(shortcut)
		
		self.shortcutItem = nil
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		PreferenceManager.shared.save()
	}
	
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		
		let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
		
		print("Device token: \(deviceTokenString)")
	}
	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		
		print("Failed to register for remote notifications.")
	}
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		
		print("Hello there.")
	}
	
}

