//
//  ViewController.swift
//  CoreBlast
//
//  Created by Riccardo Washington on 12/8/19.
//  Copyright © 2019 Riccardo Washington. All rights reserved.
//

import UIKit
import StoreKit
import MessageUI
import SwiftUI
import Combine

class HomeViewController: UITabBarController, MFMailComposeViewControllerDelegate {
    
    private var cancellables = Set<AnyCancellable>()
    private var premiumButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        UserAPI.user = UserManager.loadUserFromFile()
        registerForOptimizedNotifications()
        StoreManager.shared.delegate = self
        StoreObserver.shared.delegate = self
        setupPremiumButton()
        observeSubscriptionStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Review prompt moved to post-workout completion to ensure user has experienced the app
        // requestReview() is now called from WorkoutViewController after workout completion
    }
    
    private func setupPremiumButton() {
        // Create premium button
        let button = UIButton(type: .system)
        button.setTitle("🔥 Go Premium", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        button.backgroundColor = UIColor.systemYellow
        button.layer.cornerRadius = 20
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.addTarget(self, action: #selector(premiumButtonTapped), for: .touchUpInside)
        
        // Add shadow
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.2
        
        // Add to view
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        // Position at top right
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Store reference
        premiumButton = button
        
        // Initially hide if already subscribed
        button.isHidden = StoreManager.shared.isPremium
    }
    
    private func observeSubscriptionStatus() {
        StoreManager.shared.$isPremium
            .sink { [weak self] isPremium in
                // Hide premium button if user is already subscribed
                self?.premiumButton?.isHidden = isPremium
            }
            .store(in: &cancellables)
    }
    
    @objc private func premiumButtonTapped() {
        // Track analytics
        AnalyticsManager.shared.trackSubscriptionViewShown(trigger: "home_premium_button")
        
        // Present subscription view
        let subscriptionView = SubscriptionView { [weak self] success in
            if success {
                // Subscription successful
                self?.dismiss(animated: true)
            } else {
                // User cancelled
                self?.dismiss(animated: true)
            }
        }
        
        let hostingController = UIHostingController(rootView: subscriptionView)
        hostingController.modalPresentationStyle = .fullScreen
        present(hostingController, animated: true)
    }
    
    func requestReview() {
        if UserAPI.user.totalPoints > 0, UserAPI.user.requestReview {
            let alert = UIAlertController(title: "Are you enjoying the app?", message: nil, preferredStyle: .alert)
                   
                   alert.addAction(UIAlertAction(title: "Leave a 5 star review", style: .default, handler: { [weak self] _ in
                       if let scene = self?.view.window?.windowScene {
                           AppStore.requestReview(in: scene)
                           UserAPI.user.requestReviewCount += 1
                           UserAPI.user.lastReviewRequestDate = Date()
                           UserManager.save()
                       } else {
                           print("Failed to get window scene for review request")
                       }
                   }))
                   
                   alert.addAction(UIAlertAction(title: "Leave feedback", style: .destructive, handler: { _ in
                       self.sendEmail()
                       UserAPI.user.requestReviewCount += 3
                       UserAPI.user.lastReviewRequestDate = Date()
                       UserManager.save()
                   }))
                   
                   self.present(alert, animated: true)
        }

    }
    
    func sendEmail() {
           if MFMailComposeViewController.canSendMail() {
               let mail = MFMailComposeViewController()
               mail.mailComposeDelegate = self
               mail.setToRecipients(["foreveryoungco@icloud.com"])
               mail.setSubject("CoreBlast Feedback")
               
               present(mail, animated: true)
           } else {
               // show failure alert
               let alert = UIAlertController(title: "Email Not Sent", message: "Your device could not send e-mail. Please check e-mail configuration and try again.", preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "OK", style: .default))
               present(alert, animated: true)
           }
       }

       // MFMailComposeViewControllerDelegate

       func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
           controller.dismiss(animated: true)
       }
    
    
    private func setupPreworkoutVC() {
        let workoutViewController = PreWorkoutViewController()
        self.workoutNavController = UINavigationController(rootViewController: workoutViewController)
        self.workoutNavController.navigationBar.barStyle = .black
        self.workoutNavController.navigationBar.tintColor = .white
        self.workoutNavController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.workoutNavController.navigationBar.prefersLargeTitles = true
        self.workoutNavController.tabBarItem = UITabBarItem(title: "Workout", image: #imageLiteral(resourceName: "muscleflex"), selectedImage: nil)
    }
    
    private func setupExerciseVC() {
        let exerciseVC = ExerciseViewController()
        self.exercisesNavVC = UINavigationController(rootViewController: exerciseVC)
        self.exercisesNavVC.navigationBar.barStyle = .black
        self.exercisesNavVC.navigationBar.tintColor = .white
        self.exercisesNavVC.tabBarItem = UITabBarItem(title: "Exercises", image: #imageLiteral(resourceName: "exercises"), selectedImage: nil)
        self.exercisesNavVC.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    private var progressionNavController: UINavigationController!
    private var workoutNavController: UINavigationController!
    private var journalNavViewController: UINavigationController!
    private var nutritionVC: MealPlansViewController!
    private var exercisesNavVC: UINavigationController!
    private var settingsNavController: UINavigationController!
    private var dashboardNavController: UINavigationController!
    private var browseNavController: UINavigationController!
    
    
    private func setup() {
        setupTabBar()
        
        let layout = SnappingLayout()
        layout.scrollDirection = .horizontal
        
        let progressionViewController = ProgressionCollectionViewController(collectionViewLayout: layout)
        progressionNavController = UINavigationController(rootViewController: progressionViewController)
        progressionNavController.tabBarItem = UITabBarItem(title: "Progression", image:UIImage(systemName: "camera.fill"), selectedImage: nil)
        progressionNavController.navigationBar.prefersLargeTitles = true
        progressionNavController.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        
//        nutritionVC = MealPlansViewController()
//        nutritionVC.tabBarItem = UITabBarItem(title: "Meal Plans", image: UIImage(systemName: "fork.knife"), selectedImage: nil)
        
        
        
//        let journalViewController = JournalViewController()
//        journalNavViewController = UINavigationController(rootViewController: journalViewController)
//        journalNavViewController.navigationBar.barStyle = .black
//        journalNavViewController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.makeTitleFont(size: 22)]
//        let journalImage = UIImage(systemName: "list.dash")
//        journalNavViewController.tabBarItem = UITabBarItem(title: "Journal", image: journalImage, selectedImage: nil)
                
        
        let dashboardViewController = DashboardViewController()
        dashboardNavController = UINavigationController(rootViewController: dashboardViewController)
        dashboardNavController.tabBarItem = UITabBarItem(title: "Stats", image: UIImage(systemName: "chart.bar.fill"), selectedImage: nil)
        dashboardNavController.navigationBar.prefersLargeTitles = true
        dashboardNavController.navigationBar.barStyle = .black
        dashboardNavController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        
//        let browseViewController = BrowseViewController()
//        browseViewController.navigationItem.title = "Browse"
//        browseNavController = UINavigationController(rootViewController: browseViewController)
//        browseNavController.tabBarItem = UITabBarItem(title: "Browse", image: UIImage(systemName: "square.grid.2x2.fill"), selectedImage: nil)
//        browseNavController.navigationBar.prefersLargeTitles = true
//        browseNavController.navigationBar.barStyle = .black
//        browseNavController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        let settingsViewController = SettingsViewController()
        settingsNavController = UINavigationController(rootViewController: settingsViewController)
        settingsNavController.tabBarItem = UITabBarItem(title: "More", image: UIImage(systemName: "gear" ), selectedImage: nil)
        settingsNavController.navigationBar.prefersLargeTitles = true
        settingsNavController.navigationBar.barStyle = .black
        settingsNavController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        self.setupPreworkoutVC()
        setViewControllers([workoutNavController, /*browseNavController,*/ progressionNavController, dashboardNavController,  settingsNavController], animated: true)
        self.customizableViewControllers = []
        
        selectedViewController = viewControllers?[0]
    }
    
    private func setupTabBar() {
        // Use Apple's modern tab bar appearance APIs
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        
        // Modern background with blur
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        // Selection indicator
        appearance.selectionIndicatorTintColor = UIColor.goatBlue
        
        // Normal state styling
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.6)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.6),
            .font: UIFont.systemFont(ofSize: 11, weight: .medium)
        ]
        
        // Selected state styling
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.goatBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.goatBlue,
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
        ]
        
        // Apply the appearance
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        // Additional styling
        tabBar.isTranslucent = true
        tabBar.tintColor = UIColor.goatBlue
        tabBar.unselectedItemTintColor = UIColor.white.withAlphaComponent(0.6)
        
        // Background color
        view.backgroundColor = .black
    }
}

extension HomeViewController: StoreManagerDelegate {
    
    func storeManagerDidReceiveMessage(_ message: String) {
        let ac = AlertController.alert(Messages.productRequestStatus, message: message)
        navigationController?.present(ac, animated: true, completion: nil)
    }
    
}

extension HomeViewController: StoreObserverDelegate {
    func storeObserverDidReceiveMessage(_ message: String) {
        let ac = AlertController.alert(Messages.purchaseStatus, message: message)
        present(ac, animated: true, completion: nil)
    }
    
    func storeObserverRestoreDidSucceed() {
        let ac = AlertController.alert(Messages.purchaseStatus, message: "All successful purchases have been restored.")
        present(ac, animated: true, completion: nil)
    }
}
