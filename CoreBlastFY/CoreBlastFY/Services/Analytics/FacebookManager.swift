//
//  FacebookManager.swift
//  Sixpack Blueprint
//
//  Handles Facebook SDK initialization, ATT prompt, and App Events.
//

import Foundation
import AppTrackingTransparency
import AdServices
import StoreKit
import FacebookCore

// MARK: - Facebook Events (mirrors SpeakLife setup)

enum FBEvent: String {
    case appLaunched        = "fb_mobile_activate_app"
    case paywallShown       = "ViewContent"
    case ctaTapped          = "InitiateCheckout"
    case trialStarted       = "StartTrial"
    case purchased          = "fb_mobile_purchase"
    case onboardingComplete = "CompleteRegistration"
}

class FacebookManager {
    static let shared = FacebookManager()
    private init() {}

    // MARK: - ATT Permission

    /// Call this after the first onboarding step (Pain Hook) — best timing per industry data.
    /// ATT prompt must be shown before any tracking occurs.
    func requestATTPermission(completion: ((Bool) -> Void)? = nil) {
        guard #available(iOS 14.5, *) else {
            completion?(true)
            return
        }

        // Must be called from main thread
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    let granted = status == .authorized
                    print("📱 ATT status: \(status.rawValue) — granted: \(granted)")

                   // Settings.shared.isAdvertiserTrackingEnabled = granted

                    UserDefaults.standard.set(granted, forKey: "att_granted")
                    UserDefaults.standard.set(true, forKey: "att_requested")
                    completion?(granted)
                }
            }
        }
    }

    var hasRequestedATT: Bool {
        return UserDefaults.standard.bool(forKey: "att_requested")
    }

    // MARK: - App Events

    func logEvent(_ event: FBEvent, parameters: [String: Any]? = nil) {
        print("📊 FB Event: \(event.rawValue) — params: \(parameters ?? [:])")

        let fbParams: [AppEvents.ParameterName: Any] = (parameters ?? [:]).reduce(into: [:]) {
            $0[AppEvents.ParameterName($1.key)] = $1.value
        }
        AppEvents.shared.logEvent(AppEvents.Name(event.rawValue), parameters: fbParams)

        // Also fire SKAdNetwork update for key conversion events
        updateSKAdNetworkConversionValue(for: event)
    }

    func logPurchase(amount: Double, currency: String = "USD", productId: String) {
        print("💰 FB Purchase: \(amount) \(currency) — product: \(productId)")

        AppEvents.shared.logPurchase(
            amount: amount,
            currency: currency,
            parameters: [AppEvents.ParameterName("fb_content_id"): productId]
        )
    }

    // MARK: - SKAdNetwork Conversion Values

    private func updateSKAdNetworkConversionValue(for event: FBEvent) {
        if #available(iOS 16.1, *) {
            // SKAdNetwork 4.0 — coarse + fine values
            let (fineValue, coarseValue) = conversionValues(for: event)
            SKAdNetwork.updatePostbackConversionValue(fineValue, coarseValue: coarseValue, lockWindow: false) { error in
                if let error = error {
                    print("⚠️ SKAdNetwork update error: \(error)")
                }
            }
        } else if #available(iOS 15.4, *) {
            let (fineValue, _) = conversionValues(for: event)
            SKAdNetwork.updatePostbackConversionValue(fineValue) { error in
                if let error = error {
                    print("⚠️ SKAdNetwork update error: \(error)")
                }
            }
        }
    }

    private func conversionValues(for event: FBEvent) -> (Int, SKAdNetwork.CoarseConversionValue) {
        // Conversion value schema — maps to FB Events Manager configuration
        // Fine values 0-63, coarse: low/medium/high
        switch event {
        case .appLaunched:        return (1,  .low)
        case .onboardingComplete: return (10, .low)
        case .paywallShown:       return (20, .medium)
        case .ctaTapped:          return (30, .medium)
        case .trialStarted:       return (50, .high)
        case .purchased:          return (63, .high)
        }
    }
}
