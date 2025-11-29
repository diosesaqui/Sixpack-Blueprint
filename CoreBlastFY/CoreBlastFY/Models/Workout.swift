//
//  Workout.swift
//  CoreBlast
//
//  Created by Riccardo Washington on 12/10/19.
//  Copyright © 2019 Riccardo Washington. All rights reserved.
//

import Foundation

struct Workout: Codable {
    
    init(user: User, exercises: [Exercise]) {
        self.user = user
        self.exercises = exercises
    }
    
    init(exercises: [Exercise], numberOfSets: Int, duration: Int, secondsOfRest: Int = 5, isCustom: Bool = false) {
        customNumberOfSets = numberOfSets
        customSecondsOfExercise = duration
        customSecondsOfRest = secondsOfRest
        self.exercises = exercises
        self.user = UserManager.loadUserFromFile()
        self.isCustom = isCustom
    }
    
    var user: User
    var exercises: [Exercise]
    var isCustom = false
    
    var exercisesToReturn: [Exercise] {
        var exercises: [Exercise]
        switch user.totalPoints {
        case 0,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48,51,54,57,60,63,66,69,72,75,78,81,84,87:
            exercises = self.exercises.filter( { $0.isSide == false })
        case 1,4,7,10,13,16,19,22,25,28,31,34,37,40,43,46,49,52,55,58,61,64,67,70,73,76,79,82,85,88:
            exercises = self.exercises.filter( { $0.isSide == true })
        case 2,5,8,11,14,17,20,23,26,29,32,35,38,41,44,47,50,53,56,59,62,65,68,71,74,77,80,83,86,89:
            exercises = self.exercises.filter( { $0.totalBody == true })
        default:
            exercises = self.exercises
        }
        exercises.append(updog)
        
        return exercises
    }
    
    var numberOfSets: Int {
        switch user.coreLevel {
        case .beginner: return 3
        case .novice: return 3
        case .solid: return 4
        case .advanced: return 5
        case .rockstar: return 6
        }
    }
    
    var numberOfCustomExercises: Int {
        return exercises.count
    }
    
    var customWorkoutDuration: Double {
        guard let seconds = customSecondsOfExercise, let sets = customNumberOfSets else { return 0.0}
        return Double(((numberOfCustomExercises) * seconds) * sets)
    }
    
    var numberOfExercises: Int {
        return exercisesToReturn.count
    }
    
    var workoutDuration: Double {
        return Double(((numberOfExercises) * secondsOfExercise) * numberOfSets)
    }
    
    var customSetDuration: Double {
        guard let sets = customNumberOfSets else { return 0.0 }
         return customWorkoutDuration / Double(sets)
    }
    
    var setDuration: Double {
        return workoutDuration / Double(numberOfSets)
    }
    
    var customSecondsOfExercise: Int?
    var customNumberOfSets: Int?
    var customSecondsOfRest: Int?
    
    var secondsOfRest: Int {
        // Return custom rest duration if this is a custom workout
        if isCustom, let customRest = customSecondsOfRest {
            return customRest
        }
        switch user.totalPoints {
        case 0...4: return 10
        case 5...15: return 10
        case 16...20: return 10
        case 21...25: return 5
        case 26...30: return 5
        case 31...35: return 5
        case 36...70: return 5
        case 71...75: return 3
        default: return 20
        }
    }
    
    var secondsOfExercise: Int {
        switch user.totalPoints {
        case 0...4: return 15
        case 5...15: return 18
        case 16...20: return 23
        case 21...25: return 28
        case 26...30: return 33
        case 31...35: return 38
        case 36...40: return 43
        case 41...45: return 48
        case 46...50: return 53
        case 51...55: return 58
        case 56...60: return 63
        case 61...65: return 68
        case 66...70: return 73
        case 71...75: return 78
        default: return 90
        }
    }
}
