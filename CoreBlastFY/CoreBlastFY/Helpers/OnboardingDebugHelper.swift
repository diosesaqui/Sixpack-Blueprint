//
//  OnboardingDebugHelper.swift
//  CoreBlast
//
//  Created by Claude AI on 11/29/25.
//

import Foundation
import UIKit

#if DEBUG
/// Debug helper for onboarding testing (only available in debug builds)
class OnboardingDebugHelper {
    
    /// Show an alert to reset onboarding (useful for testing)
    static func showResetOnboardingAlert(from viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Debug: Reset Onboarding",
            message: "This will reset the onboarding state and show onboarding on next app launch. This is only available in debug builds.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { _ in
            OnboardingManager.resetOnboarding()
            
            let confirmAlert = UIAlertController(
                title: "Onboarding Reset",
                message: "Onboarding has been reset. The onboarding flow will be shown on next app launch.",
                preferredStyle: .alert
            )
            confirmAlert.addAction(UIAlertAction(title: "OK", style: .default))
            viewController.present(confirmAlert, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        viewController.present(alert, animated: true)
    }
    
    /// Show current onboarding state in an alert
    static func showOnboardingStatus(from viewController: UIViewController) {
        let hasCompleted = OnboardingManager.hasCompletedOnboarding
        let currentVersion = OnboardingManager.currentVersion
        let completedVersion = OnboardingManager.completedVersion ?? "none"
        let isFresh = OnboardingManager.isFreshInstall
        
        let message = """
        Has Completed: \(hasCompleted)
        Current Version: \(currentVersion)
        Completed Version: \(completedVersion)
        Is Fresh Install: \(isFresh)
        """
        
        let alert = UIAlertController(
            title: "Onboarding Status",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { _ in
            showResetOnboardingAlert(from: viewController)
        })
        
        viewController.present(alert, animated: true)
    }
    
    /// Add onboarding debug buttons to any view controller (useful for testing)
    static func addDebugButtons(to viewController: UIViewController) {
        let statusButton = UIButton(type: .system)
        statusButton.setTitle("Onboarding Status", for: .normal)
        statusButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        statusButton.setTitleColor(.white, for: .normal)
        statusButton.layer.cornerRadius = 8
        statusButton.addTarget(self, action: #selector(statusButtonTapped), for: .touchUpInside)
        
        let resetButton = UIButton(type: .system)
        resetButton.setTitle("Reset Onboarding", for: .normal)
        resetButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.8)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.layer.cornerRadius = 8
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [statusButton, resetButton])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        
        viewController.view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalToConstant: 150),
            stackView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        // Store reference to view controller for button actions
        debugViewController = viewController
    }
    
    private static weak var debugViewController: UIViewController?
    
    @objc private static func statusButtonTapped() {
        guard let vc = debugViewController else { return }
        showOnboardingStatus(from: vc)
    }
    
    @objc private static func resetButtonTapped() {
        guard let vc = debugViewController else { return }
        showResetOnboardingAlert(from: vc)
    }
}
#endif