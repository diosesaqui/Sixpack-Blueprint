//
//  OnboardingManager.swift
//  CoreBlast
//
//  Created by Claude AI on 11/29/25.
//

import Foundation

class OnboardingManager {
    
    // MARK: - Constants
    private static let onboardingCompletedKey = "hasViewedWalkThrough"
    private static let onboardingVersionKey = "onboardingVersion"
    private static let currentOnboardingVersion = "1.0"
    
    // MARK: - Public Methods
    
    /// Check if onboarding has been completed
    static var hasCompletedOnboarding: Bool {
        let hasCompleted = UserDefaults.standard.bool(forKey: onboardingCompletedKey)
        let completedVersion = UserDefaults.standard.string(forKey: onboardingVersionKey) ?? ""
        
        // Return true only if both conditions are met:
        // 1. Onboarding has been marked as completed
        // 2. The completed version matches the current version (in case we add new onboarding steps)
        return hasCompleted && completedVersion == currentOnboardingVersion
    }
    
    /// Mark onboarding as completed
    static func markOnboardingCompleted() {
        UserDefaults.standard.set(true, forKey: onboardingCompletedKey)
        UserDefaults.standard.set(currentOnboardingVersion, forKey: onboardingVersionKey)
        UserDefaults.standard.synchronize()
        
        print("✅ Onboarding marked as completed - Version: \(currentOnboardingVersion)")
    }
    
    /// Reset onboarding (useful for testing or if user wants to see onboarding again)
    static func resetOnboarding() {
        UserDefaults.standard.removeObject(forKey: onboardingCompletedKey)
        UserDefaults.standard.removeObject(forKey: onboardingVersionKey)
        UserDefaults.standard.synchronize()
        
        print("🔄 Onboarding reset - will be shown on next app launch")
    }
    
    /// Check if this is a fresh install (no onboarding data exists)
    static var isFreshInstall: Bool {
        return !UserDefaults.standard.bool(forKey: onboardingCompletedKey) &&
               UserDefaults.standard.string(forKey: onboardingVersionKey) == nil
    }
    
    /// Get current onboarding version
    static var currentVersion: String {
        return currentOnboardingVersion
    }
    
    /// Get completed onboarding version
    static var completedVersion: String? {
        return UserDefaults.standard.string(forKey: onboardingVersionKey)
    }
    
    /// Debug method to print onboarding state (useful during development)
    static func debugOnboardingState() {
        let hasCompleted = UserDefaults.standard.bool(forKey: onboardingCompletedKey)
        let version = UserDefaults.standard.string(forKey: onboardingVersionKey)
        let shouldShow = !hasCompletedOnboarding
        
        print("🔍 Onboarding Debug State:")
        print("  - Has completed: \(hasCompleted)")
        print("  - Completed version: \(version ?? "none")")
        print("  - Current version: \(currentOnboardingVersion)")
        print("  - Should show onboarding: \(shouldShow)")
        print("  - Is fresh install: \(isFreshInstall)")
    }
}