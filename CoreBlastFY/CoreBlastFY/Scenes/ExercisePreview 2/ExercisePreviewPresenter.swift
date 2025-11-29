//
//  ExercisePreviewPresenter.swift
//  CoreBlast
//
//  Created by Claude AI on 11/29/25.
//

import UIKit

protocol ExercisePreviewPresentationLogic {
    func presentExercisePreview(response: ExercisePreview.FetchExercisePreview.Response)
}

class ExercisePreviewPresenter: ExercisePreviewPresentationLogic {
    weak var viewController: ExercisePreviewDisplayLogic?
    
    // MARK: Do something
    
    func presentExercisePreview(response: ExercisePreview.FetchExercisePreview.Response) {
        let exerciseViewModels = response.exercises.enumerated().map { (index, exercise) in
            ExercisePreview.ExerciseRowViewModel(
                id: index,
                name: exercise.name.capitalized,
                duration: "0:30", // Default duration, can be customized
                backgroundColor: getExerciseColor(for: exercise),
                imageURL: exercise.videoURL
            )
        }
        
        let viewModel = ExercisePreview.FetchExercisePreview.ViewModel(
            exercises: exerciseViewModels,
            workoutTitle: response.workoutTitle,
            workoutDuration: response.workoutDuration,
            workoutDescription: response.workoutDescription
        )
        
        viewController?.displayExercisePreview(viewModel: viewModel)
    }
    
    private func getExerciseColor(for exercise: Exercise) -> UIColor {
        // Generate consistent colors based on exercise type or name
        switch exercise.type {
        case .core:
            return UIColor.systemBlue.withAlphaComponent(0.8)
        case .legs:
            return UIColor.systemGreen.withAlphaComponent(0.8)
        case .back:
            return UIColor.systemOrange.withAlphaComponent(0.8)
        case .chest:
            return UIColor.systemRed.withAlphaComponent(0.8)
        case .arms:
            return UIColor.systemPurple.withAlphaComponent(0.8)
        }
    }
}