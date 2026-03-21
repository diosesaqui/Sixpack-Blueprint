//
//  HapticFeedbackManager.swift
//  Sixpack Blueprint
//
//  Created by Assistant on 12/23/24.
//  Copyright © 2024 Riccardo Washington. All rights reserved.
//

import UIKit
import CoreHaptics

final class HapticFeedbackManager {
    static let shared = HapticFeedbackManager()
    
    private var engine: CHHapticEngine?
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let impactSoft = UIImpactFeedbackGenerator(style: .soft)
    private let impactRigid = UIImpactFeedbackGenerator(style: .rigid)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()
    
    // Track active haptic operations
    private var activeHapticOperations = [DispatchWorkItem]()
    
    private init() {
        prepareHaptics()
    }
    
    private func prepareHaptics() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        impactSoft.prepare()
        impactRigid.prepare()
        selection.prepare()
        notification.prepare()
        
        // Setup Core Haptics for custom patterns
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptic engine creation error: \(error)")
        }
    }
    
    // MARK: - Basic Haptics
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        switch style {
        case .light:
            impactLight.impactOccurred()
        case .medium:
            impactMedium.impactOccurred()
        case .heavy:
            impactHeavy.impactOccurred()
        case .soft:
            impactSoft.impactOccurred()
        case .rigid:
            impactRigid.impactOccurred()
        @unknown default:
            impactMedium.impactOccurred()
        }
    }
    
    func selectionChanged() {
        selection.selectionChanged()
    }
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        notification.notificationOccurred(type)
    }
    
    // MARK: - Custom Patterns for Onboarding
    
    func buttonTap() {
        // Stronger button feedback with medium impact
        impact(.medium)
        
        // Add subtle secondary feedback for important buttons
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.impact(.light)
        }
    }
    
    func stepTransition() {
        // More noticeable transition with rigid impact
        impact(.rigid)
        
        // Create a forward motion feel
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            self.impact(.soft)
        }
    }
    
    func optionSelected() {
        // Strong selection with immediate feedback
        selectionChanged()
        impact(.medium)
        
        // Confirmation pulse
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.impact(.light)
        }
    }
    
    func planReady() {
        // Epic celebration moment
        notification(.success)
        
        // Add rhythmic celebration pattern
        DispatchQueue.main.async {
            self.impact(.heavy)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.impact(.medium)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    self.impact(.heavy)
                }
            }
        }
    }
    
    func subscriptionSuccess() {
        // Triple tap pattern for major success
        DispatchQueue.main.async {
            self.impact(.heavy)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.impact(.rigid)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.notification(.success)
                }
            }
        }
    }
    
    func error() {
        notification(.error)
        // Add attention-grabbing pulse
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.impact(.heavy)
        }
    }
    
    func warning() {
        notification(.warning)
        impact(.medium)
    }
    
    func progressUpdate() {
        // More satisfying progress feedback
        impact(.medium)
        
        // Create momentum feeling
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.impact(.light)
        }
    }
    
    // MARK: - Complex Custom Patterns
    
    func celebrationPattern() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = engine else {
            // Fallback to powerful simple pattern
            notification(.success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.impact(.heavy)
            }
            return
        }
        
        do {
            // Create an ascending celebration pattern - like fireworks!
            let pattern = try CHHapticPattern(events: [
                // Quick buildup
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ], relativeTime: 0),
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ], relativeTime: 0.1),
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                ], relativeTime: 0.2),
                // Big celebration burst
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                ], relativeTime: 0.35),
                // Echo effects
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                ], relativeTime: 0.5),
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                ], relativeTime: 0.65)
            ], parameters: [])
            
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            // Fallback
            notification(.success)
            impact(.heavy)
        }
    }
    
    func pulsePattern() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = engine else {
            // Strong fallback pulse
            impact(.medium)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.impact(.soft)
            }
            return
        }
        
        do {
            // Create a heartbeat-like pulse
            let pattern = try CHHapticPattern(events: [
                CHHapticEvent(eventType: .hapticContinuous, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ], relativeTime: 0, duration: 0.2),
                CHHapticEvent(eventType: .hapticContinuous, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
                ], relativeTime: 0.2, duration: 0.1),
                CHHapticEvent(eventType: .hapticContinuous, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
                ], relativeTime: 0.35, duration: 0.25)
            ], parameters: [])
            
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            impact(.medium)
        }
    }
    
    // New dynamic patterns for enhanced feedback
    
    func excitementBuild() {
        // Rapid escalating taps for building excitement
        DispatchQueue.main.async {
            for i in 0..<4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                    switch i {
                    case 0: self.impact(.light)
                    case 1: self.impact(.medium)
                    case 2: self.impact(.rigid)
                    case 3: self.impact(.heavy)
                    default: break
                    }
                }
            }
        }
    }
    
    func rhythmicSelection() {
        // Create a satisfying rhythm when selecting options
        impact(.medium)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            self.impact(.light)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                self.impact(.medium)
            }
        }
    }
    
    func swipeTransition() {
        // Dynamic swipe feeling
        impact(.soft)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.impact(.rigid)
        }
    }
    
    func achievementUnlocked() {
        // Epic achievement pattern
        notification(.success)
        DispatchQueue.main.async {
            self.impact(.heavy)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.impact(.light)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.impact(.heavy)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.pulsePattern()
                    }
                }
            }
        }
    }
    
    // MARK: - Cleanup Methods
    
    func cancelAllPendingHaptics() {
        // Cancel all pending haptic operations
        activeHapticOperations.forEach { $0.cancel() }
        activeHapticOperations.removeAll()
        
        // Stop the haptic engine if needed
        engine?.stop(completionHandler: nil)
        
        // Restart engine for future use
        prepareHaptics()
    }
    
    // Helper to track delayed haptic operations
    private func performDelayedHaptic(after delay: Double, operation: @escaping () -> Void) {
        let workItem = DispatchWorkItem {
            operation()
        }
        
        activeHapticOperations.append(workItem)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            workItem.perform()
            // Clean up after execution
            self?.activeHapticOperations.removeAll { $0 === workItem }
        }
    }
}
