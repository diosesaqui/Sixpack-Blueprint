//
//  User.swift
//  CoreBlast
//
//  Created by Riccardo Washington on 12/10/19.
//  Copyright © 2019 Riccardo Washington. All rights reserved.
//

import Foundation

class User: Codable {
    
    init() {
        self.id = UUID()
    }
    let id: UUID?
    var name: String?
    var coreLevel: Level = .beginner
    var totalPoints: Int = 0
    var lastWorkoutComplete: Date?
    var requestReviewCount = 0
    var requestReview: Bool {
        requestReviewCount < 3
    }
    var nextWorkout: Date {
        guard let selectedTime = selectedTime else { 
            // Fallback to tomorrow at noon if no time is set
            let calendar = Calendar.current
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
            return calendar.date(bySettingHour: 12, minute: 0, second: 0, of: tomorrow)!
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Get today's workout time using the selected hour and minute
        let todayWorkoutTime = calendar.date(bySettingHour: selectedHour ?? 12, minute: selectedMinute ?? 0, second: 0, of: now)!
        
        // If today's workout time hasn't passed yet, return it
        if todayWorkoutTime > now {
            return todayWorkoutTime
        } else {
            // Otherwise, return tomorrow's workout time
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: todayWorkoutTime)!
            return tomorrow
        }
    }
    
    var mode: Mode {
        if totalPoints % 3 == 0 {
            return .totalBody
        } else if totalPoints % 2 == 0 {
            return .side
        } else {
            return .front
        }
    }
    
    enum Mode: String, Codable {
        case totalBody
        case front
        case side
    }
    
    var selectedHour: Int?
    var selectedMinute: Int?
    
    var selectedTime: Date? {
        didSet {
            guard let selectedTime = selectedTime else { return }
           let (hour, minute) = getHourAndMinuteFromDate(date: selectedTime)
            selectedHour = hour
            selectedMinute = minute
        }
    }
    
    enum Level: String, Codable, CaseIterable {
        case beginner = "Beginner"
        case novice = "Novice"
        case solid = "Solid"
        case advanced = "Advanced"
        case rockstar = "Rockstar"
    }
    var currentLevel: Level {
        switch totalPoints {
        case 0...14: return .beginner
        case 15...29: return .novice
        case 30...44: return .solid
        case 45...59: return .advanced
        case 60...: return .rockstar
        default: return .beginner
        }
    }
    
    var nextLevelUp: Int {
        switch currentLevel {
        case .beginner: return 15
        case .novice: return 30
        case .solid: return 45
        case .advanced: return 60
        case .rockstar: return 90
        }
    }
    
    var nextLevel: Level {
        switch coreLevel {
        case .beginner: return .novice
        case .novice: return .solid
        case .solid: return .advanced
        case .advanced, .rockstar: return .rockstar
        }
    }
    
}

extension User: Equatable {
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}
