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
    
    // Custom decoding to handle missing properties from older saved data
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Required properties
        id = try container.decodeIfPresent(UUID.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        coreLevel = try container.decodeIfPresent(Level.self, forKey: .coreLevel) ?? .beginner
        totalPoints = try container.decodeIfPresent(Int.self, forKey: .totalPoints) ?? 0
        lastWorkoutComplete = try container.decodeIfPresent(Date.self, forKey: .lastWorkoutComplete)
        requestReviewCount = try container.decodeIfPresent(Int.self, forKey: .requestReviewCount) ?? 0
        lastReviewRequestDate = try container.decodeIfPresent(Date.self, forKey: .lastReviewRequestDate)
        
        // Streak tracking - provide defaults for missing properties
        currentStreak = try container.decodeIfPresent(Int.self, forKey: .currentStreak) ?? 0
        longestStreak = try container.decodeIfPresent(Int.self, forKey: .longestStreak) ?? 0
        totalWorkoutDays = try container.decodeIfPresent(Int.self, forKey: .totalWorkoutDays) ?? 0
        lastWorkoutDate = try container.decodeIfPresent(Date.self, forKey: .lastWorkoutDate)
        workoutHistory = try container.decodeIfPresent([Date].self, forKey: .workoutHistory) ?? []
        
        // Time properties
        selectedHour = try container.decodeIfPresent(Int.self, forKey: .selectedHour)
        selectedMinute = try container.decodeIfPresent(Int.self, forKey: .selectedMinute)
        selectedTime = try container.decodeIfPresent(Date.self, forKey: .selectedTime)
    }
    
    // Define coding keys for all properties
    private enum CodingKeys: String, CodingKey {
        case id, name, coreLevel, totalPoints, lastWorkoutComplete, requestReviewCount, lastReviewRequestDate
        case currentStreak, longestStreak, totalWorkoutDays, lastWorkoutDate, workoutHistory
        case selectedHour, selectedMinute, selectedTime
    }
    let id: UUID?
    var name: String?
    var coreLevel: Level = .beginner
    var totalPoints: Int = 0
    var lastWorkoutComplete: Date?
    var requestReviewCount = 0
    var lastReviewRequestDate: Date?
    
    // Streak tracking
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var totalWorkoutDays: Int = 0
    var lastWorkoutDate: Date?
    var workoutHistory: [Date] = []
    var requestReview: Bool {
        // Check if we haven't reached the max request count
        guard requestReviewCount < 3 else { return false }
        
        // Check if enough time has passed since last request (24 hours)
        if let lastRequest = lastReviewRequestDate {
            let twentyFourHoursAgo = Date().addingTimeInterval(-24 * 60 * 60)
            return lastRequest < twentyFourHoursAgo
        }
        
        // If no previous request, allow it
        return true
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
