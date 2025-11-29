//
//  AnalyticsManager.swift
//  CoreBlastFY
//
//  Created by Claude AI on 11/29/25.
//

import Foundation
import Firebase

class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private init() {}
    
    // MARK: - App Events
    
    func trackAppLaunch() {
        Analytics.logEvent("app_launch", parameters: nil)
    }
    
    func trackOnboardingCompleted() {
        Analytics.logEvent("onboarding_completed", parameters: [
            "funnel_step": "completed"
        ])
    }
    
    // MARK: - Onboarding Funnel Events
    
    func trackOnboardingStarted() {
        Analytics.logEvent("onboarding_started", parameters: [
            "funnel_step": "started"
        ])
    }
    
    func trackOnboardingStep(step: String, stepNumber: Int) {
        Analytics.logEvent("onboarding_step", parameters: [
            "step_name": step,
            "step_number": stepNumber,
            "funnel_step": "step_\(stepNumber)"
        ])
    }
    
    func trackOnboardingAbandoned(lastStep: String, stepNumber: Int) {
        Analytics.logEvent("onboarding_abandoned", parameters: [
            "last_step": lastStep,
            "step_number": stepNumber,
            "funnel_step": "abandoned_at_\(stepNumber)"
        ])
    }
    
    // MARK: - Workout Events
    
    func trackWorkoutStarted(workoutType: String, exercises: Int) {
        Analytics.logEvent("workout_started", parameters: [
            "workout_type": workoutType,
            "exercise_count": exercises
        ])
    }
    
    func trackWorkoutCompleted(workoutType: String, duration: TimeInterval, exercises: Int) {
        Analytics.logEvent("workout_completed", parameters: [
            "workout_type": workoutType,
            "duration_seconds": Int(duration),
            "exercise_count": exercises,
            "value": 1 // Completed workout has value
        ])
    }
    
    func trackWorkoutAbandoned(workoutType: String, timeSpent: TimeInterval) {
        Analytics.logEvent("workout_abandoned", parameters: [
            "workout_type": workoutType,
            "time_spent_seconds": Int(timeSpent)
        ])
    }
    
    // MARK: - Subscription Events
    
    func trackSubscriptionViewShown(trigger: String) {
        Analytics.logEvent("subscription_view_shown", parameters: [
            "trigger": trigger // "app_launch", "workout_limit", "manual"
        ])
    }
    
    func trackSubscriptionStarted(productId: String, price: Double) {
        Analytics.logEvent(AnalyticsEventPurchase, parameters: [
            AnalyticsParameterItemID: productId,
            AnalyticsParameterValue: price,
            AnalyticsParameterCurrency: "USD"
        ])
    }
    
    func trackSubscriptionCancelled() {
        Analytics.logEvent("subscription_cancelled", parameters: nil)
    }
    
    func trackTrialStarted(productId: String) {
        Analytics.logEvent("trial_started", parameters: [
            "product_id": productId
        ])
    }
    
    // MARK: - Subscription Funnel Events
    
    func trackSubscriptionOptionSelected(productId: String, isYearly: Bool) {
        Analytics.logEvent("subscription_option_selected", parameters: [
            "product_id": productId,
            "is_yearly": isYearly,
            "funnel_step": "option_selected"
        ])
    }
    
    func trackSubscriptionPaymentStarted(productId: String) {
        Analytics.logEvent("subscription_payment_started", parameters: [
            "product_id": productId,
            "funnel_step": "payment_started"
        ])
    }
    
    func trackSubscriptionPaymentFailed(productId: String, error: String) {
        Analytics.logEvent("subscription_payment_failed", parameters: [
            "product_id": productId,
            "error": error,
            "funnel_step": "payment_failed"
        ])
    }
    
    func trackOneTimeOfferShown() {
        Analytics.logEvent("one_time_offer_shown", parameters: [
            "funnel_step": "offer_shown"
        ])
    }
    
    func trackOneTimeOfferAccepted() {
        Analytics.logEvent("one_time_offer_accepted", parameters: [
            "funnel_step": "offer_accepted"
        ])
    }
    
    func trackOneTimeOfferDismissed() {
        Analytics.logEvent("one_time_offer_dismissed", parameters: [
            "funnel_step": "offer_dismissed"
        ])
    }
    
    // MARK: - Custom Workout Events
    
    func trackCustomWorkoutCreated(exercises: Int, duration: Int, sets: Int) {
        Analytics.logEvent("custom_workout_created", parameters: [
            "exercise_count": exercises,
            "duration_seconds": duration,
            "sets": sets
        ])
    }
    
    // MARK: - User Progression Events
    
    func trackLevelUp(newLevel: String) {
        Analytics.logEvent(AnalyticsEventLevelUp, parameters: [
            AnalyticsParameterLevel: newLevel
        ])
    }
    
    func trackProgressionPhotoTaken() {
        Analytics.logEvent("progression_photo_taken", parameters: nil)
    }
    
    // MARK: - Paywall Events
    
    func trackPaywallShown(workoutsCompleted: Int) {
        Analytics.logEvent("paywall_shown", parameters: [
            "workouts_completed": workoutsCompleted,
            "trigger": "workout_limit"
        ])
    }
    
    func trackPaywallDismissed(workoutsCompleted: Int) {
        Analytics.logEvent("paywall_dismissed", parameters: [
            "workouts_completed": workoutsCompleted
        ])
    }
    
    // MARK: - User Properties
    
    func setUserLevel(_ level: String) {
        Analytics.setUserProperty(level, forName: "user_level")
    }
    
    func setSubscriptionStatus(_ isSubscribed: Bool) {
        Analytics.setUserProperty(isSubscribed ? "premium" : "free", forName: "subscription_status")
    }
    
    func setWorkoutCount(_ count: Int) {
        Analytics.setUserProperty(String(count), forName: "total_workouts")
    }
}
