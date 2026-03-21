//
//  SceneDelegate.swift
//  CoreBlast
//
//  Created by Riccardo Washington on 12/8/19.
//  Copyright © 2019 Riccardo Washington. All rights reserved.
//

import UIKit
import StoreKit

let PauseWorkoutNotification = NSNotification.Name("PauseWorkoutNotification")
let FetchingExercisesFailedNotification = Notification.Name("FetchingExercisesFailed")
let FetchingExercisesSucceededNotification = Notification.Name("FetchingExercisesSucceededNotification")

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
            -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let notificationId = response.notification.request.identifier
        
        // Track notification interaction
        AnalyticsManager.shared.trackNotificationInteraction(
            notificationId: notificationId, 
            action: "tapped"
        )
        
        // Handle different notification types
        if notificationId.contains("daily_workout") {
            // Navigate to workout selection or home
            if let homeVC = window?.rootViewController as? HomeViewController {
                homeVC.selectedIndex = 0 // Navigate to home tab
            }
        } else if notificationId.contains("progress_photo") {
            // Navigate to progression tab
            if let homeVC = window?.rootViewController as? HomeViewController {
                homeVC.selectedIndex = 2 // Navigate to progression tab
            }
        }
        
        completionHandler()
    }
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        UNUserNotificationCenter.current().delegate = self
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        // Track app launches
        trackAppLaunch()
        
        // Track app launch in Firebase Analytics
        AnalyticsManager.shared.trackAppLaunch()
        
        // Initialize StoreKit payment observer for legacy support
        SKPaymentQueue.default().add(StoreObserver.shared)
        
        OnboardingViewController.completion = {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                // Track onboarding completion
                AnalyticsManager.shared.trackOnboardingCompleted()
                
                // add animation
                let homeVC = HomeViewController()
                homeVC.modalPresentationStyle = .fullScreen
                self.window!.rootViewController = homeVC
                self.window!.makeKeyAndVisible()
            }
        }
        
        // MARK: TO DP clean up
        
        let exerciseFetcher = SceneExerciseFetcher()
        exerciseFetcher.fetchExercises() { (success) in
            DispatchQueue.main.async {
                #if DEBUG
                OnboardingManager.debugOnboardingState()
                #endif
                
                if !OnboardingManager.hasCompletedOnboarding {
                    // Use enhanced onboarding with animations and haptics
                    let onboardingView = HostingViewController(view: OnboardingViewEnhanced())
                    self.window!.rootViewController = onboardingView
                    self.window!.makeKeyAndVisible()
                    
                    print("📱 Showing enhanced onboarding - Fresh install: \(OnboardingManager.isFreshInstall)")
                    
                } else {
                    // Check if we need to show subscription on 2nd or 3rd app launch
                    let shouldShowSubscription = self.shouldShowSubscriptionPage()
                    
                    if shouldShowSubscription {
                        // Show subscription page
                        let subscriptionView = HostingViewController(view: SubscriptionView() { success in
                            if success {
                                // Mark as subscribed and proceed to home
                                UserDefaults.standard.set(true, forKey: "hasSubscribed")
                                DispatchQueue.main.async {
                                    self.window!.rootViewController = HomeViewController()
                                    self.window!.makeKeyAndVisible()
                                }
                            } else {
                                // If they decline, still go to home
                                DispatchQueue.main.async {
                                    self.window!.rootViewController = HomeViewController()
                                    self.window!.makeKeyAndVisible()
                                }
                            }
                        })
                        self.window!.rootViewController = subscriptionView
                        self.window!.makeKeyAndVisible()
                        
                        print("💳 Showing subscription page on app launch #\(self.getAppLaunchCount())")
                    } else {
                        DispatchQueue.global(qos: .userInitiated).sync {
                            UserAPI.user = UserManager.loadUserFromFile()
                            if UserAPI.user != nil {
                                DispatchQueue.main.async {
                                    self.window!.rootViewController = HomeViewController()
                                    self.window!.makeKeyAndVisible()
                                }
                            }
                        }
                        
                        print("🏠 Showing main app - Onboarding version: \(OnboardingManager.completedVersion ?? "unknown")")
                    }
                }
//                else {
//                    let subscriptionView = HostingViewController(view: SubscriptionView() { success in
//                        if success {
//                            OnboardingViewController.completion?()
//                            UserDefaults.standard.set(true, forKey: onboardingKey)
//                        }
//                    })
//                    self.window!.rootViewController = subscriptionView
//                    self.window!.makeKeyAndVisible()
//                    
//                }
            }
        }
        
    }
    
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: PauseWorkoutNotification, object: self)
        }
        
        // Check streak status when app becomes active
        if UserAPI.user != nil {
            UserManager.checkStreakStatus()
        }
        
        // Check for inactive users before updating last open time
        OptimizedNotificationManager.shared.checkForInactiveUser()
        
        // Track last app open time for welcome back notifications
        UserDefaults.standard.set(Date(), forKey: "lastAppOpenTime")
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: PauseWorkoutNotification, object: self)
        }
        
        UserManager.save()
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        UserManager.save()
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Remove payment observer
        SKPaymentQueue.default().remove(StoreObserver.shared)
    }
    
    // MARK: - App Launch Tracking
    
    private func trackAppLaunch() {
        let launchCount = UserDefaults.standard.integer(forKey: "appLaunchCount")
        UserDefaults.standard.set(launchCount + 1, forKey: "appLaunchCount")
        UserDefaults.standard.synchronize()
    }
    
    private func getAppLaunchCount() -> Int {
        return UserDefaults.standard.integer(forKey: "appLaunchCount")
    }
    
    private func shouldShowSubscriptionPage() -> Bool {
        let launchCount = getAppLaunchCount()
        let hasSubscribed = UserDefaults.standard.bool(forKey: "hasSubscribed")
        let isPremium = StoreManager.shared.isPremium
        
        // Show subscription on 2nd or 3rd launch if not subscribed
        return (launchCount == 2 || launchCount == 3) && !hasSubscribed && !isPremium
    }
}

