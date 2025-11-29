//
//  ExercisePreviewInteractor.swift
//  CoreBlast
//
//  Created by Claude AI on 11/29/25.
//

import UIKit

protocol ExercisePreviewBusinessLogic {
    func fetchExercisePreview(request: ExercisePreview.FetchExercisePreview.Request)
}

protocol ExercisePreviewDataStore {
    var exercises: [Exercise]? { get set }
    var workoutDetails: (title: String, duration: String, description: String, exerciseDuration: TimeInterval, numberOfSets: Int)? { get set }
}

class ExercisePreviewInteractor: ExercisePreviewBusinessLogic, ExercisePreviewDataStore {
    var presenter: ExercisePreviewPresentationLogic?
    var exercises: [Exercise]?
    var workoutDetails: (title: String, duration: String, description: String, exerciseDuration: TimeInterval, numberOfSets: Int)?
    
    // MARK: Do something
    
    func fetchExercisePreview(request: ExercisePreview.FetchExercisePreview.Request) {
        let response = ExercisePreview.FetchExercisePreview.Response(
            exercises: request.exercises,
            workoutTitle: request.workoutTitle,
            workoutDuration: request.workoutDuration,
            workoutDescription: request.workoutDescription,
            exerciseDuration: request.exerciseDuration,
            numberOfSets: request.numberOfSets
        )
        presenter?.presentExercisePreview(response: response)
    }
}
