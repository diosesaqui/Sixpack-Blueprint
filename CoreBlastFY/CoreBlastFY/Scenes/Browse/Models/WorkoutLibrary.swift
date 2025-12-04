//
//  WorkoutLibrary.swift
//  CoreBlast
//
//  Created by Claude on 12/1/24.
//  Copyright © 2024 Riccardo Washington. All rights reserved.
//

import Foundation

struct PresetWorkout {
    let id: String
    let name: String
    let description: String
    let exerciseNames: [String]
    let numberOfSets: Int
    let secondsPerExercise: Int
    let secondsOfRest: Int
    let categoryIds: [String] // Which categories this workout belongs to
    let level: Exercise.Level?
    let estimatedDuration: Int // in minutes
    let focusAreas: [String] // e.g., ["core", "obliques", "lower abs"]
}

class WorkoutLibrary {
    
    static let shared = WorkoutLibrary()
    
    private init() {}
    
    // MARK: - Preset Workouts Database
    
    private let presetWorkouts: [PresetWorkout] = [
        
        // MARK: Beginner Workouts (5 workouts)
        PresetWorkout(
            id: "beginner_core_intro",
            name: "Core Introduction",
            description: "Perfect starting point for core training",
            exerciseNames: ["Plank", "Dead Bug", "Bird Dog", "Crunches", "Wall Sit"],
            numberOfSets: 2,
            secondsPerExercise: 15,
            secondsOfRest: 10,
            categoryIds: ["beginner", "core_focus", "5_minutes"],
            level: .beginner,
            estimatedDuration: 5,
            focusAreas: ["core", "stability"]
        ),
        
        PresetWorkout(
            id: "beginner_total_body",
            name: "Total Body Starter",
            description: "Full body workout for beginners",
            exerciseNames: ["Jumping Jacks", "Push Ups", "Squats", "Plank", "Mountain Climbers"],
            numberOfSets: 2,
            secondsPerExercise: 15,
            secondsOfRest: 10,
            categoryIds: ["beginner", "total_body", "5_minutes"],
            level: .beginner,
            estimatedDuration: 5,
            focusAreas: ["total body"]
        ),
        
        PresetWorkout(
            id: "beginner_abs_basics",
            name: "Abs Basics",
            description: "Foundation building for abdominal strength",
            exerciseNames: ["Crunches", "Leg Raises", "Plank", "Bicycle Crunches"],
            numberOfSets: 2,
            secondsPerExercise: 15,
            secondsOfRest: 10,
            categoryIds: ["beginner", "core_focus", "5_minutes"],
            level: .beginner,
            estimatedDuration: 5,
            focusAreas: ["abs"]
        ),
        
        PresetWorkout(
            id: "beginner_gentle_start",
            name: "Gentle Start",
            description: "Low impact introduction to fitness",
            exerciseNames: ["Marching In Place", "Arm Circles", "Wall Push Ups", "Standing Knee Raises", "Side Steps"],
            numberOfSets: 2,
            secondsPerExercise: 20,
            secondsOfRest: 10,
            categoryIds: ["beginner", "quick", "5_minutes"],
            level: .beginner,
            estimatedDuration: 6,
            focusAreas: ["low impact", "cardio"]
        ),
        
        PresetWorkout(
            id: "beginner_energy_boost",
            name: "Energy Boost",
            description: "Wake up your body with simple movements",
            exerciseNames: ["Jumping Jacks", "High Knees", "Arm Swings", "Butt Kicks", "Star Jumps"],
            numberOfSets: 3,
            secondsPerExercise: 15,
            secondsOfRest: 10,
            categoryIds: ["beginner", "wake_up", "10_minutes"],
            level: .beginner,
            estimatedDuration: 7,
            focusAreas: ["cardio", "energy"]
        ),
        
        // MARK: Novice Workouts (5 workouts)
        PresetWorkout(
            id: "novice_core_builder",
            name: "Core Builder",
            description: "Build core strength and endurance",
            exerciseNames: ["Plank", "Side Plank", "Bicycle Crunches", "Leg Raises", "Russian Twists", "Dead Bug"],
            numberOfSets: 3,
            secondsPerExercise: 20,
            secondsOfRest: 10,
            categoryIds: ["novice", "core_focus", "10_minutes"],
            level: .novice,
            estimatedDuration: 10,
            focusAreas: ["core", "obliques"]
        ),
        
        PresetWorkout(
            id: "novice_morning_wake",
            name: "Morning Energizer",
            description: "Wake up your body and mind",
            exerciseNames: ["Arm Circles", "High Knees", "Butt Kicks", "Jumping Jacks", "Burpees"],
            numberOfSets: 3,
            secondsPerExercise: 18,
            secondsOfRest: 10,
            categoryIds: ["novice", "wake_up", "wake_shake", "quick"],
            level: .novice,
            estimatedDuration: 7,
            focusAreas: ["cardio", "total body"]
        ),
        
        PresetWorkout(
            id: "novice_power_circuit",
            name: "Power Circuit",
            description: "Build strength and endurance",
            exerciseNames: ["Push Ups", "Squats", "Lunges", "Plank", "Dips", "Calf Raises"],
            numberOfSets: 3,
            secondsPerExercise: 20,
            secondsOfRest: 8,
            categoryIds: ["novice", "total_body", "10_minutes"],
            level: .novice,
            estimatedDuration: 10,
            focusAreas: ["strength", "endurance"]
        ),
        
        PresetWorkout(
            id: "novice_abs_sculpt",
            name: "Abs Sculptor",
            description: "Target your entire core",
            exerciseNames: ["Crunches", "Reverse Crunches", "Toe Touches", "Flutter Kicks", "Plank"],
            numberOfSets: 3,
            secondsPerExercise: 20,
            secondsOfRest: 8,
            categoryIds: ["novice", "core_focus", "10_minutes"],
            level: .novice,
            estimatedDuration: 9,
            focusAreas: ["abs", "lower abs"]
        ),
        
        PresetWorkout(
            id: "novice_cardio_blast",
            name: "Cardio Blast",
            description: "Heart-pumping cardio workout",
            exerciseNames: ["Jumping Jacks", "Mountain Climbers", "Burpees", "High Knees", "Jump Squats"],
            numberOfSets: 4,
            secondsPerExercise: 15,
            secondsOfRest: 10,
            categoryIds: ["novice", "total_body", "10_minutes"],
            level: .novice,
            estimatedDuration: 8,
            focusAreas: ["cardio", "fat burn"]
        ),
        
        // MARK: Solid Workouts (5 workouts)
        PresetWorkout(
            id: "solid_core_crusher",
            name: "Core Crusher",
            description: "Intense core workout for intermediate athletes",
            exerciseNames: ["V-Ups", "Plank", "Mountain Climbers", "Flutter Kicks", "Russian Twists"],
            numberOfSets: 4,
            secondsPerExercise: 25,
            secondsOfRest: 8,
            categoryIds: ["solid", "core_focus", "15_plus"],
            level: .solid,
            estimatedDuration: 15,
            focusAreas: ["core", "abs", "obliques"]
        ),
        
        PresetWorkout(
            id: "solid_side_sculptor",
            name: "Side Core Sculptor",
            description: "Target your obliques and side core",
            exerciseNames: ["Side Plank", "Russian Twists", "Bicycle Crunches", "Side Crunches", "Oblique Crunches"],
            numberOfSets: 4,
            secondsPerExercise: 23,
            secondsOfRest: 8,
            categoryIds: ["solid", "side_core", "15_plus"],
            level: .solid,
            estimatedDuration: 12,
            focusAreas: ["obliques", "side core"]
        ),
        
        PresetWorkout(
            id: "solid_athletic_performance",
            name: "Athletic Performance",
            description: "Build functional strength and power",
            exerciseNames: ["Burpees", "Box Jumps", "Push Ups", "Jump Squats", "Plank", "Mountain Climbers"],
            numberOfSets: 4,
            secondsPerExercise: 25,
            secondsOfRest: 8,
            categoryIds: ["solid", "total_body", "15_plus"],
            level: .solid,
            estimatedDuration: 16,
            focusAreas: ["power", "athleticism"]
        ),
        
        PresetWorkout(
            id: "solid_hiit_burn",
            name: "HIIT Burn",
            description: "High intensity interval training",
            exerciseNames: ["Burpees", "Jump Squats", "Mountain Climbers", "High Knees", "Jump Lunges"],
            numberOfSets: 5,
            secondsPerExercise: 20,
            secondsOfRest: 5,
            categoryIds: ["solid", "total_body", "15_plus"],
            level: .solid,
            estimatedDuration: 14,
            focusAreas: ["hiit", "cardio", "fat burn"]
        ),
        
        PresetWorkout(
            id: "solid_strength_builder",
            name: "Strength Builder",
            description: "Build serious muscle and strength",
            exerciseNames: ["Push Ups", "Diamond Push Ups", "Wide Push Ups", "Pike Push Ups", "Tricep Dips", "Plank"],
            numberOfSets: 4,
            secondsPerExercise: 30,
            secondsOfRest: 10,
            categoryIds: ["solid", "total_body", "15_plus"],
            level: .solid,
            estimatedDuration: 17,
            focusAreas: ["strength", "muscle"]
        ),
        
        // MARK: Advanced Workouts (5 workouts)
        PresetWorkout(
            id: "advanced_total_destruction",
            name: "Total Body Destruction",
            description: "High-intensity full body workout",
            exerciseNames: ["Burpees", "Diamond Push Ups", "Jump Squats", "Pike Push Ups", "V-Ups", "Mountain Climbers"],
            numberOfSets: 5,
            secondsPerExercise: 30,
            secondsOfRest: 5,
            categoryIds: ["advanced", "total_body", "15_plus"],
            level: .advanced,
            estimatedDuration: 20,
            focusAreas: ["total body", "strength", "cardio"]
        ),
        
        PresetWorkout(
            id: "advanced_core_elite",
            name: "Core Elite",
            description: "Elite level core training",
            exerciseNames: ["V-Ups", "Leg Raises", "Russian Twists", "Flutter Kicks", "Plank", "Mountain Climbers", "Bicycle Crunches"],
            numberOfSets: 5,
            secondsPerExercise: 30,
            secondsOfRest: 5,
            categoryIds: ["advanced", "core_focus", "15_plus"],
            level: .advanced,
            estimatedDuration: 20,
            focusAreas: ["core", "advanced strength"]
        ),
        
        PresetWorkout(
            id: "advanced_explosive_power",
            name: "Explosive Power",
            description: "Build explosive strength and speed",
            exerciseNames: ["Box Jumps", "Clap Push Ups", "Jump Lunges", "Burpees", "Squat Jumps", "Plank Jacks"],
            numberOfSets: 5,
            secondsPerExercise: 25,
            secondsOfRest: 10,
            categoryIds: ["advanced", "total_body", "15_plus"],
            level: .advanced,
            estimatedDuration: 18,
            focusAreas: ["power", "explosiveness"]
        ),
        
        PresetWorkout(
            id: "advanced_endurance_test",
            name: "Endurance Test",
            description: "Push your limits with this endurance challenge",
            exerciseNames: ["Burpees", "Mountain Climbers", "Jump Squats", "Push Ups", "High Knees", "Plank"],
            numberOfSets: 6,
            secondsPerExercise: 30,
            secondsOfRest: 5,
            categoryIds: ["advanced", "total_body", "15_plus"],
            level: .advanced,
            estimatedDuration: 22,
            focusAreas: ["endurance", "mental toughness"]
        ),
        
        PresetWorkout(
            id: "advanced_abs_annihilator",
            name: "Abs Annihilator",
            description: "The ultimate abs challenge",
            exerciseNames: ["V-Ups", "Toe Touches", "Russian Twists", "Leg Raises", "Flutter Kicks", "Bicycle Crunches", "Plank"],
            numberOfSets: 5,
            secondsPerExercise: 30,
            secondsOfRest: 5,
            categoryIds: ["advanced", "core_focus", "15_plus"],
            level: .advanced,
            estimatedDuration: 20,
            focusAreas: ["abs", "core strength"]
        ),
        
        // MARK: Rockstar Workouts (4 workouts)
        PresetWorkout(
            id: "rockstar_ultimate",
            name: "Rockstar Ultimate",
            description: "The ultimate challenge for elite athletes",
            exerciseNames: ["Burpees", "Diamond Push Ups", "Pistol Squats", "V-Ups", "Pike Push Ups", "Mountain Climbers", "Plank"],
            numberOfSets: 6,
            secondsPerExercise: 35,
            secondsOfRest: 3,
            categoryIds: ["rockstar", "total_body", "15_plus"],
            level: .rockstar,
            estimatedDuration: 25,
            focusAreas: ["elite", "total body", "strength"]
        ),
        
        PresetWorkout(
            id: "rockstar_beast_mode",
            name: "Beast Mode",
            description: "Unleash your inner beast",
            exerciseNames: ["Burpees", "Clap Push Ups", "Jump Squats", "Mountain Climbers", "Diamond Push Ups", "Box Jumps"],
            numberOfSets: 6,
            secondsPerExercise: 40,
            secondsOfRest: 5,
            categoryIds: ["rockstar", "total_body", "15_plus"],
            level: .rockstar,
            estimatedDuration: 26,
            focusAreas: ["beast mode", "extreme"]
        ),
        
        PresetWorkout(
            id: "rockstar_superhero",
            name: "Superhero Training",
            description: "Train like a superhero",
            exerciseNames: ["Spider Push Ups", "Superman", "V-Ups", "Pike Push Ups", "Plank", "Jump Lunges", "Russian Twists"],
            numberOfSets: 6,
            secondsPerExercise: 35,
            secondsOfRest: 5,
            categoryIds: ["rockstar", "total_body", "15_plus"],
            level: .rockstar,
            estimatedDuration: 25,
            focusAreas: ["superhero", "power"]
        ),
        
        PresetWorkout(
            id: "rockstar_core_domination",
            name: "Core Domination",
            description: "Dominate your core like never before",
            exerciseNames: ["V-Ups", "Russian Twists", "Flutter Kicks", "Leg Raises", "Bicycle Crunches", "Plank", "Mountain Climbers", "Toe Touches"],
            numberOfSets: 6,
            secondsPerExercise: 35,
            secondsOfRest: 3,
            categoryIds: ["rockstar", "core_focus", "15_plus"],
            level: .rockstar,
            estimatedDuration: 25,
            focusAreas: ["core mastery", "abs"]
        ),
        
        // MARK: Quick & Easy Workouts (4 workouts)
        PresetWorkout(
            id: "wake_up_routine",
            name: "Wake Up Routine",
            description: "Gentle morning wake up",
            exerciseNames: ["Arm Circles", "Jumping Jacks", "High Knees", "Butt Kicks", "Arm Swings"],
            numberOfSets: 2,
            secondsPerExercise: 20,
            secondsOfRest: 5,
            categoryIds: ["wake_up", "5_minutes", "quick"],
            level: nil,
            estimatedDuration: 5,
            focusAreas: ["mobility", "stretching"]
        ),
        
        PresetWorkout(
            id: "quick_core_blast",
            name: "5-Minute Core Blast",
            description: "Quick but effective core workout",
            exerciseNames: ["Plank", "Crunches", "Leg Raises", "Russian Twists", "Mountain Climbers"],
            numberOfSets: 2,
            secondsPerExercise: 20,
            secondsOfRest: 10,
            categoryIds: ["quick_core", "5_minutes", "quick"],
            level: nil,
            estimatedDuration: 5,
            focusAreas: ["core", "quick"]
        ),
        
        PresetWorkout(
            id: "desk_break",
            name: "Desk Break",
            description: "Quick movement break from sitting",
            exerciseNames: ["Standing Knee Raises", "Arm Circles", "Neck Rolls", "Wall Push Ups", "Calf Raises"],
            numberOfSets: 2,
            secondsPerExercise: 15,
            secondsOfRest: 5,
            categoryIds: ["quick", "5_minutes", "recovery"],
            level: nil,
            estimatedDuration: 5,
            focusAreas: ["mobility", "office workout"]
        ),
        
        PresetWorkout(
            id: "energy_booster",
            name: "Energy Booster",
            description: "Quick energy boost anytime",
            exerciseNames: ["Jumping Jacks", "High Knees", "Star Jumps", "Arm Swings"],
            numberOfSets: 2,
            secondsPerExercise: 20,
            secondsOfRest: 10,
            categoryIds: ["quick", "5_minutes", "wake_up"],
            level: nil,
            estimatedDuration: 5,
            focusAreas: ["energy", "cardio"]
        ),
        
        // MARK: Recommended Workouts (4 workouts)
        PresetWorkout(
            id: "wake_shake",
            name: "Wake & Shake",
            description: "Energizing morning routine",
            exerciseNames: ["Jumping Jacks", "High Knees", "Butt Kicks", "Arm Circles", "Burpees", "Mountain Climbers"],
            numberOfSets: 3,
            secondsPerExercise: 20,
            secondsOfRest: 10,
            categoryIds: ["wake_shake", "recommended", "10_minutes"],
            level: nil,
            estimatedDuration: 7,
            focusAreas: ["cardio", "energy"]
        ),
        
        PresetWorkout(
            id: "tech_neck_relief",
            name: "Tech Neck Relief",
            description: "Relieve tension from screen time",
            exerciseNames: ["Neck Rolls", "Shoulder Rolls", "Wall Angels", "Arm Circles", "Shoulder Shrugs"],
            numberOfSets: 2,
            secondsPerExercise: 20,
            secondsOfRest: 5,
            categoryIds: ["tech_neck", "recommended", "5_minutes", "recovery"],
            level: nil,
            estimatedDuration: 5,
            focusAreas: ["neck", "shoulders", "upper back"]
        ),
        
        PresetWorkout(
            id: "daily_essential",
            name: "Daily Essential",
            description: "Your essential daily workout",
            exerciseNames: ["Push Ups", "Squats", "Plank", "Lunges", "Crunches", "Mountain Climbers"],
            numberOfSets: 3,
            secondsPerExercise: 20,
            secondsOfRest: 10,
            categoryIds: ["recommended", "10_minutes", "popular"],
            level: nil,
            estimatedDuration: 10,
            focusAreas: ["full body", "daily routine"]
        ),
        
        PresetWorkout(
            id: "stress_relief",
            name: "Stress Relief Flow",
            description: "Release tension and stress",
            exerciseNames: ["Deep Breathing", "Arm Circles", "Neck Rolls", "Standing Forward Fold", "Side Stretches"],
            numberOfSets: 2,
            secondsPerExercise: 30,
            secondsOfRest: 10,
            categoryIds: ["recommended", "recovery", "10_minutes"],
            level: nil,
            estimatedDuration: 8,
            focusAreas: ["stress relief", "relaxation"]
        ),
        
        // MARK: Recovery Workouts (4 workouts)
        PresetWorkout(
            id: "recovery_stretch",
            name: "Recovery Stretch",
            description: "Gentle stretching for recovery",
            exerciseNames: ["Standing Forward Fold", "Side Stretches", "Quad Stretches", "Calf Stretches", "Arm Circles"],
            numberOfSets: 2,
            secondsPerExercise: 30,
            secondsOfRest: 5,
            categoryIds: ["recovery", "10_minutes"],
            level: nil,
            estimatedDuration: 10,
            focusAreas: ["flexibility", "recovery"]
        ),
        
        PresetWorkout(
            id: "evening_wind_down",
            name: "Evening Wind Down",
            description: "Relax before bed",
            exerciseNames: ["Deep Breathing", "Neck Rolls", "Shoulder Rolls", "Standing Forward Fold", "Side Stretches"],
            numberOfSets: 1,
            secondsPerExercise: 45,
            secondsOfRest: 10,
            categoryIds: ["recovery", "5_minutes"],
            level: nil,
            estimatedDuration: 5,
            focusAreas: ["relaxation", "sleep"]
        ),
        
        PresetWorkout(
            id: "post_workout_cool_down",
            name: "Post-Workout Cool Down",
            description: "Essential cool down after intense workouts",
            exerciseNames: ["Walking In Place", "Arm Circles", "Standing Forward Fold", "Quad Stretches", "Deep Breathing"],
            numberOfSets: 2,
            secondsPerExercise: 20,
            secondsOfRest: 5,
            categoryIds: ["recovery", "5_minutes"],
            level: nil,
            estimatedDuration: 6,
            focusAreas: ["cool down", "recovery"]
        ),
        
        PresetWorkout(
            id: "mobility_flow",
            name: "Mobility Flow",
            description: "Improve flexibility and range of motion",
            exerciseNames: ["Arm Circles", "Hip Circles", "Leg Swings", "Torso Twists", "Shoulder Rolls", "Neck Rolls"],
            numberOfSets: 3,
            secondsPerExercise: 20,
            secondsOfRest: 5,
            categoryIds: ["recovery", "10_minutes"],
            level: nil,
            estimatedDuration: 10,
            focusAreas: ["mobility", "flexibility"]
        ),
        
        // MARK: Popular/Featured Workouts (4 workouts)
        PresetWorkout(
            id: "fan_favorite_abs",
            name: "Fan Favorite Abs",
            description: "Most popular ab workout",
            exerciseNames: ["Plank", "Bicycle Crunches", "Russian Twists", "Leg Raises", "Mountain Climbers", "V-Ups"],
            numberOfSets: 3,
            secondsPerExercise: 25,
            secondsOfRest: 8,
            categoryIds: ["popular", "featured", "core_focus", "10_minutes"],
            level: .solid,
            estimatedDuration: 10,
            focusAreas: ["abs", "core"]
        ),
        
        PresetWorkout(
            id: "weekly_challenge",
            name: "Weekly Challenge",
            description: "This week's featured workout",
            exerciseNames: ["Burpees", "Push Ups", "Jump Squats", "Plank", "Mountain Climbers", "High Knees", "V-Ups"],
            numberOfSets: 4,
            secondsPerExercise: 20,
            secondsOfRest: 10,
            categoryIds: ["featured", "total_body", "15_plus"],
            level: .solid,
            estimatedDuration: 15,
            focusAreas: ["total body", "challenge"]
        ),
        
        PresetWorkout(
            id: "trending_hiit",
            name: "Trending HIIT",
            description: "The most trending HIIT workout",
            exerciseNames: ["Burpees", "Jump Squats", "Mountain Climbers", "High Knees", "Plank Jacks"],
            numberOfSets: 4,
            secondsPerExercise: 20,
            secondsOfRest: 10,
            categoryIds: ["popular", "featured", "total_body", "10_minutes"],
            level: .novice,
            estimatedDuration: 10,
            focusAreas: ["hiit", "trending"]
        ),
        
        PresetWorkout(
            id: "community_favorite",
            name: "Community Favorite",
            description: "Voted best by the community",
            exerciseNames: ["Push Ups", "Squats", "Plank", "Lunges", "Crunches", "Burpees"],
            numberOfSets: 3,
            secondsPerExercise: 20,
            secondsOfRest: 10,
            categoryIds: ["popular", "featured", "total_body", "10_minutes"],
            level: .novice,
            estimatedDuration: 10,
            focusAreas: ["community choice", "balanced"]
        )
    ]
    
    // MARK: - Public Methods
    
    func getWorkouts(for categoryId: String) -> [PresetWorkout] {
        return presetWorkouts.filter { $0.categoryIds.contains(categoryId) }
    }
    
    func getWorkouts(for category: WorkoutCategory) -> [PresetWorkout] {
        return getWorkouts(for: category.id)
    }
    
    func getAllWorkouts() -> [PresetWorkout] {
        return presetWorkouts
    }
    
    func getWorkout(by id: String) -> PresetWorkout? {
        return presetWorkouts.first { $0.id == id }
    }
    
    func convertToWorkout(_ preset: PresetWorkout, user: User) -> Workout? {
        // Get actual Exercise objects from the exercise names
        let exercises = preset.exerciseNames.compactMap { name in
            ExerciseStorage.exercises.first { 
                $0.name.lowercased() == name.lowercased() 
            }
        }
        
        // If we couldn't find all exercises, create a basic workout
        if exercises.isEmpty {
            return nil
        }
        
        // Create workout with custom settings
        let workout = Workout(
            exercises: exercises,
            numberOfSets: preset.numberOfSets,
            duration: preset.secondsPerExercise,
            secondsOfRest: preset.secondsOfRest,
            isCustom: true
        )
        
        return workout
    }
    
    // MARK: - User Favorites (stored in UserDefaults)
    
    private let favoritesKey = "userFavoriteWorkouts"
    
    func getFavoriteWorkoutIds() -> [String] {
        return UserDefaults.standard.stringArray(forKey: favoritesKey) ?? []
    }
    
    func toggleFavorite(workoutId: String) {
        var favorites = getFavoriteWorkoutIds()
        if let index = favorites.firstIndex(of: workoutId) {
            favorites.remove(at: index)
        } else {
            favorites.append(workoutId)
        }
        UserDefaults.standard.set(favorites, forKey: favoritesKey)
    }
    
    func isFavorite(workoutId: String) -> Bool {
        return getFavoriteWorkoutIds().contains(workoutId)
    }
    
    func getFavoriteWorkouts() -> [PresetWorkout] {
        let favoriteIds = getFavoriteWorkoutIds()
        return presetWorkouts.filter { favoriteIds.contains($0.id) }
    }
}