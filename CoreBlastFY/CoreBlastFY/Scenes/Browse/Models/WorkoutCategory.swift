//
//  WorkoutCategory.swift
//  CoreBlast
//
//  Created by Claude on 12/1/24.
//  Copyright © 2024 Riccardo Washington. All rights reserved.
//

import UIKit

enum WorkoutCategorySection: Int, CaseIterable {
    case byLevel = 0
    case recommended
    case quickAndEasy
    case byFocus
    case byDuration
    case special
    
    var title: String {
        switch self {
        case .byLevel:
            return "BY FITNESS LEVEL"
        case .recommended:
            return "RECOMMENDED"
        case .quickAndEasy:
            return "QUICK & EASY"
        case .byFocus:
            return "BY BODY FOCUS"
        case .byDuration:
            return "BY DURATION"
        case .special:
            return "SPECIAL COLLECTIONS"
        }
    }
}

struct WorkoutCategory {
    let id: String
    let title: String
    let subtitle: String
    let section: WorkoutCategorySection
    let icon: String // SF Symbol name
    let iconBackgroundColor: UIColor
    let minDuration: Int? // in minutes
    let maxDuration: Int? // in minutes
    let level: Exercise.Level?
    let type: WorkoutType
    
    enum WorkoutType {
        case level(Exercise.Level)
        case duration(min: Int, max: Int?)
        case bodyFocus(Exercise.ExerciseType)
        case special(String)
        case recommended
        case quick
        case intense
        case recovery
        case custom
    }
}

class WorkoutCategoryManager {
    
    static func getAllCategories() -> [WorkoutCategory] {
        var categories: [WorkoutCategory] = []
        
        // By Fitness Level
        categories.append(contentsOf: [
            WorkoutCategory(
                id: "beginner",
                title: "Beginner",
                subtitle: "0-15 POINTS",
                section: .byLevel,
                icon: "figure.walk",
                iconBackgroundColor: UIColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 1.0),
                minDuration: nil,
                maxDuration: nil,
                level: .beginner,
                type: .level(.beginner)
            ),
            WorkoutCategory(
                id: "novice",
                title: "Novice",
                subtitle: "16-30 POINTS",
                section: .byLevel,
                icon: "figure.run",
                iconBackgroundColor: UIColor(red: 0.3, green: 0.7, blue: 0.6, alpha: 1.0),
                minDuration: nil,
                maxDuration: nil,
                level: .novice,
                type: .level(.novice)
            ),
            WorkoutCategory(
                id: "solid",
                title: "Solid",
                subtitle: "31-50 POINTS",
                section: .byLevel,
                icon: "figure.strengthtraining.traditional",
                iconBackgroundColor: UIColor(red: 0.5, green: 0.5, blue: 0.8, alpha: 1.0),
                minDuration: nil,
                maxDuration: nil,
                level: .solid,
                type: .level(.solid)
            ),
            WorkoutCategory(
                id: "advanced",
                title: "Advanced",
                subtitle: "51-70 POINTS",
                section: .byLevel,
                icon: "figure.highintensity.intervaltraining",
                iconBackgroundColor: UIColor(red: 0.7, green: 0.4, blue: 0.7, alpha: 1.0),
                minDuration: nil,
                maxDuration: nil,
                level: .advanced,
                type: .level(.advanced)
            ),
            WorkoutCategory(
                id: "rockstar",
                title: "Rockstar",
                subtitle: "71+ POINTS",
                section: .byLevel,
                icon: "star.fill",
                iconBackgroundColor: UIColor(red: 0.9, green: 0.6, blue: 0.2, alpha: 1.0),
                minDuration: nil,
                maxDuration: nil,
                level: .rockstar,
                type: .level(.rockstar)
            )
        ])
        
        // Recommended
        categories.append(contentsOf: [
            WorkoutCategory(
                id: "wake_shake",
                title: "Wake & Shake",
                subtitle: "7 MINUTES",
                section: .recommended,
                icon: "sun.max.fill",
                iconBackgroundColor: UIColor(red: 0.2, green: 0.6, blue: 0.7, alpha: 1.0),
                minDuration: 7,
                maxDuration: 7,
                level: nil,
                type: .recommended
            ),
            WorkoutCategory(
                id: "tech_neck",
                title: "Tech Neck Relief",
                subtitle: "5 MINUTES",
                section: .recommended,
                icon: "laptopcomputer",
                iconBackgroundColor: UIColor(red: 0.3, green: 0.7, blue: 0.5, alpha: 1.0),
                minDuration: 5,
                maxDuration: 5,
                level: nil,
                type: .recovery
            )
        ])
        
        // Quick & Easy
        categories.append(contentsOf: [
            WorkoutCategory(
                id: "wake_up",
                title: "Wake Up",
                subtitle: "5 MINUTES",
                section: .quickAndEasy,
                icon: "sunrise.fill",
                iconBackgroundColor: UIColor(red: 0.5, green: 0.7, blue: 0.8, alpha: 1.0),
                minDuration: 5,
                maxDuration: 5,
                level: nil,
                type: .quick
            ),
            WorkoutCategory(
                id: "quick_core",
                title: "Quick Core",
                subtitle: "5 MINUTES",
                section: .quickAndEasy,
                icon: "bolt.fill",
                iconBackgroundColor: UIColor(red: 0.2, green: 0.5, blue: 0.8, alpha: 1.0),
                minDuration: 5,
                maxDuration: 5,
                level: nil,
                type: .quick
            )
        ])
        
        // By Body Focus
        categories.append(contentsOf: [
            WorkoutCategory(
                id: "core_focus",
                title: "Core",
                subtitle: "ABS & OBLIQUES",
                section: .byFocus,
                icon: "figure.core.training",
                iconBackgroundColor: UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 1.0),
                minDuration: nil,
                maxDuration: nil,
                level: nil,
                type: .bodyFocus(.core)
            ),
            WorkoutCategory(
                id: "total_body",
                title: "Total Body",
                subtitle: "FULL WORKOUT",
                section: .byFocus,
                icon: "figure.stand",
                iconBackgroundColor: UIColor(red: 0.4, green: 0.6, blue: 0.8, alpha: 1.0),
                minDuration: nil,
                maxDuration: nil,
                level: nil,
                type: .special("totalBody")
            ),
            WorkoutCategory(
                id: "side_core",
                title: "Side Core",
                subtitle: "OBLIQUES",
                section: .byFocus,
                icon: "arrow.left.and.right",
                iconBackgroundColor: UIColor(red: 0.5, green: 0.7, blue: 0.4, alpha: 1.0),
                minDuration: nil,
                maxDuration: nil,
                level: nil,
                type: .special("sideCore")
            )
        ])
        
        // By Duration
        categories.append(contentsOf: [
            WorkoutCategory(
                id: "5_minutes",
                title: "5 Minutes",
                subtitle: "QUICK SESSION",
                section: .byDuration,
                icon: "5.circle.fill",
                iconBackgroundColor: UIColor(red: 0.3, green: 0.6, blue: 0.8, alpha: 1.0),
                minDuration: 5,
                maxDuration: 5,
                level: nil,
                type: .duration(min: 5, max: 5)
            ),
            WorkoutCategory(
                id: "10_minutes",
                title: "10 Minutes",
                subtitle: "STANDARD",
                section: .byDuration,
                icon: "10.circle.fill",
                iconBackgroundColor: UIColor(red: 0.5, green: 0.5, blue: 0.8, alpha: 1.0),
                minDuration: 10,
                maxDuration: 10,
                level: nil,
                type: .duration(min: 10, max: 10)
            ),
            WorkoutCategory(
                id: "15_plus",
                title: "15+ Minutes",
                subtitle: "EXTENDED",
                section: .byDuration,
                icon: "15.circle.fill",
                iconBackgroundColor: UIColor(red: 0.7, green: 0.4, blue: 0.6, alpha: 1.0),
                minDuration: 15,
                maxDuration: nil,
                level: nil,
                type: .duration(min: 15, max: nil)
            ),
            WorkoutCategory(
                id: "custom_duration",
                title: "Custom Duration",
                subtitle: "YOU CHOOSE",
                section: .byDuration,
                icon: "slider.horizontal.3",
                iconBackgroundColor: UIColor(red: 0.6, green: 0.6, blue: 0.4, alpha: 1.0),
                minDuration: nil,
                maxDuration: nil,
                level: nil,
                type: .custom
            )
        ])
        
        // Special Collections
        categories.append(contentsOf: [
            WorkoutCategory(
                id: "featured",
                title: "Featured This Week",
                subtitle: "EDITOR'S PICK",
                section: .special,
                icon: "star.circle.fill",
                iconBackgroundColor: UIColor(red: 0.9, green: 0.7, blue: 0.2, alpha: 1.0),
                minDuration: nil,
                maxDuration: nil,
                level: nil,
                type: .special("featured")
            ),
            WorkoutCategory(
                id: "popular",
                title: "Most Popular",
                subtitle: "TOP RATED",
                section: .special,
                icon: "chart.line.uptrend.xyaxis",
                iconBackgroundColor: UIColor(red: 0.8, green: 0.3, blue: 0.5, alpha: 1.0),
                minDuration: nil,
                maxDuration: nil,
                level: nil,
                type: .special("popular")
            ),
//            WorkoutCategory(
//                id: "favorites",
//                title: "Your Favorites",
//                subtitle: "SAVED WORKOUTS",
//                section: .special,
//                icon: "heart.fill",
//                iconBackgroundColor: UIColor(red: 0.9, green: 0.3, blue: 0.4, alpha: 1.0),
//                minDuration: nil,
//                maxDuration: nil,
//                level: nil,
//                type: .special("favorites")
//            ),
            WorkoutCategory(
                id: "recovery",
                title: "Recovery",
                subtitle: "STRETCH & MOBILITY",
                section: .special,
                icon: "leaf.fill",
                iconBackgroundColor: UIColor(red: 0.3, green: 0.7, blue: 0.4, alpha: 1.0),
                minDuration: nil,
                maxDuration: nil,
                level: nil,
                type: .recovery
            )
        ])
        
        return categories
    }
}
