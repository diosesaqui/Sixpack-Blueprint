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
    var workoutDetails: (title: String, duration: String, description: String)? { get set }
}

class ExercisePreviewInteractor: ExercisePreviewBusinessLogic, ExercisePreviewDataStore {
    var presenter: ExercisePreviewPresentationLogic?
    var exercises: [Exercise]?
    var workoutDetails: (title: String, duration: String, description: String)?
    
    // MARK: Do something
    
    func fetchExercisePreview(request: ExercisePreview.FetchExercisePreview.Request) {
        let response = ExercisePreview.FetchExercisePreview.Response(
            exercises: request.exercises,
            workoutTitle: request.workoutTitle,
            workoutDuration: request.workoutDuration,
            workoutDescription: request.workoutDescription
        )
        presenter?.presentExercisePreview(response: response)
    }
}