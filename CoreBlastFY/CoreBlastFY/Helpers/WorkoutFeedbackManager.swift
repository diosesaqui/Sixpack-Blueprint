//
//  WorkoutFeedbackManager.swift
//  CoreBlast
//
//  Created by Claude AI on 11/30/25.
//

import UIKit
import AVFoundation

class WorkoutFeedbackManager {
    static let shared = WorkoutFeedbackManager()
    
    private var audioPlayer: AVAudioPlayer?
    
    private init() {
        setupAudioSession()
    }
    
    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - Workout Start Feedback
    func playWorkoutStartFeedback() {
        // Heavy haptic feedback for workout start
        if isHapticEnabled() {
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.prepare()
            impactFeedback.impactOccurred()
        }
        
        // Play start sound
        playSystemSound(.workoutStart)
    }
    
    // MARK: - Exercise Transition Feedback
    func playExerciseTransitionFeedback() {
        // Medium haptic feedback for exercise transitions
        if isHapticEnabled() {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.prepare()
            impactFeedback.impactOccurred()
        }
        
        // Play transition sound
        playSystemSound(.exerciseTransition)
    }
    
    // MARK: - Countdown Feedback
    func playCountdownFeedback(for count: Int) {
        // Medium haptic for countdown
        if count <= 3 && count > 0 && isHapticEnabled() {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.prepare()
            impactFeedback.impactOccurred()
        }
        
        // Play tick sound for all countdown numbers (no special final sound)
        if count > 0 {
            playSystemSound(.countdownTick)
        }
    }
    
    // MARK: - Rest Period Feedback
    func playRestPeriodFeedback() {
        // Medium haptic feedback for rest period
        if isHapticEnabled() {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.prepare()
            impactFeedback.impactOccurred()
        }
        
        playSystemSound(.restPeriod)
    }
    
    // MARK: - Workout Complete Feedback
    func playWorkoutCompleteFeedback() {
        // Strong haptic feedback for workout completion
        if isHapticEnabled() {
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.prepare()
            impactFeedback.impactOccurred()
            
            // Success notification feedback
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.prepare()
            notificationFeedback.notificationOccurred(.success)
        }
        
        playSystemSound(.workoutComplete)
    }
}

// MARK: - Sound System
extension WorkoutFeedbackManager {
    
    private enum WorkoutSound {
        case workoutStart
        case exerciseTransition
        case countdownTick
        case countdownFinal
        case restPeriod
        case workoutComplete
        
        var systemSoundID: SystemSoundID {
            switch self {
            case .workoutStart:
                return 1104 // Glass sound - clear and motivating
            case .exerciseTransition:
                return 1057 // Tock sound - gentle transition
            case .countdownTick:
                return 1103 // Tick sound - short and clear
            case .countdownFinal:
                return 1005 // New mail sound - attention-grabbing for "GO!"
            case .restPeriod:
                return 1016 // Alert sound - gentle rest indicator
            case .workoutComplete:
                return 1025 // Fanfare sound - celebratory completion
            }
        }
    }
    
    private func playSystemSound(_ sound: WorkoutSound) {
        // Ensure sounds are enabled in settings
        guard isSoundEnabledByUser() else { return }
        
        // Play system sound at lower volume to not interfere with music
        AudioServicesPlaySystemSound(sound.systemSoundID)
    }
}

// MARK: - Settings and Preferences
extension WorkoutFeedbackManager {
    
    // Enable/disable haptic feedback
    func setHapticEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "WorkoutHapticEnabled")
    }
    
    func isHapticEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: "WorkoutHapticEnabled") != false // Default to true
    }
    
    // Enable/disable sound feedback
    func setSoundEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "WorkoutSoundEnabled")
    }
    
    func isSoundEnabledByUser() -> Bool {
        return UserDefaults.standard.bool(forKey: "WorkoutSoundEnabled") != false // Default to true
    }
}