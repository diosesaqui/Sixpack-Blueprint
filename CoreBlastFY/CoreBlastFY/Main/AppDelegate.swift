//
//  AppDelegate.swift
//  CoreBlast
//
//  Created by Riccardo Washington on 12/8/19.
//  Copyright © 2019 Riccardo Washington. All rights reserved.
//

import UIKit
import BackgroundTasks
import StoreKit
import FirebaseCore
import FirebaseAnalytics
import FacebookCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
//     func scheduleAppRefresh() {
//        let request = BGAppRefreshTaskRequest(identifier: refreshId)
//            request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // Fetch no earlier than 15 minutes from now
//
//            do {
//                try BGTaskScheduler.shared.submit(request)
//            } catch {
//                print("Could not schedule app refresh: \(error)")
//            }
//    }
//
//    // Fetch the latest feed entries from server.
//       func handleAppRefresh(task: BGAppRefreshTask) {
//          scheduleAppRefresh()
//
//        let (shouldDecrement, _) = UserManager.decrementPoint()
//
//        guard notificationsAllowed else {  return }
//
//        if shouldDecrement {
//            sendPointDecrementNotification()
//        }
//      }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize Firebase
        FirebaseApp.configure()
        
        // Initialize Facebook SDK
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        SKPaymentQueue.default().add(StoreObserver.shared)
        
        loadCoreFiles()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return ApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
    
    private func loadCoreFiles() {
        DispatchQueue.global(qos: .userInitiated).sync {
               ProgressionPicController.shared.loadFromFile()
               EntryController.shared.loadFromFile()
               UserAPI.user = UserManager.loadUserFromFile()
            let (shouldDecrement, _) = UserManager.decrementPoint()
            if shouldDecrement {
                sendPointDecrementNotification()
            }
        }
        
        // Prefetch videos in background
        DispatchQueue.global(qos: .background).async {
            VideoManager.shared.prefetchAllVideos()
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Remove the observer.
        SKPaymentQueue.default().remove(StoreObserver.shared)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        UserManager.save()
    }
}

