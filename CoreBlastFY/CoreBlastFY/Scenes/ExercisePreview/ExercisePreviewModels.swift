//
//  ExercisePreviewModels.swift
//  CoreBlast
//
//  Created by Claude AI on 11/29/25.
//

import UIKit

enum ExercisePreview {
    
    // MARK: Use cases
    
    enum FetchExercisePreview {
        struct Request {
            let exercises: [Exercise]
            let workoutTitle: String
            let workoutDuration: String
            let workoutDescription: String
            let exerciseDuration: TimeInterval?
            let numberOfSets: Int
        }
        
        struct Response {
            let exercises: [Exercise]
            let workoutTitle: String
            let workoutDuration: String
            let workoutDescription: String
            let exerciseDuration: TimeInterval?
            let numberOfSets: Int
        }
        
        struct ViewModel {
            let exercises: [ExerciseRowViewModel]
            let workoutTitle: String
            let workoutDuration: String
            let workoutDescription: String
            let numberOfSets: Int
        }
    }
    
    struct ExerciseRowViewModel {
        let id: Int
        let name: String
        let duration: String
        let backgroundColor: UIColor
        let imageURL: URL?
    }
}