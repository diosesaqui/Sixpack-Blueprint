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
            // Get duration from workout details or default to 30 seconds
            let durationSeconds = response.exerciseDuration ?? 30
            let duration = formatDuration(seconds: Int(durationSeconds))
            
            ExercisePreview.ExerciseRowViewModel(
                id: index,
                name: exercise.name.capitalized,
                duration: duration,
                backgroundColor: .clear, // Remove colored background
                imageURL: exercise.videoURL
            )
        }
        
        let viewModel = ExercisePreview.FetchExercisePreview.ViewModel(
            exercises: exerciseViewModels,
            workoutTitle: response.workoutTitle,
            workoutDuration: response.workoutDuration,
            workoutDescription: response.workoutDescription,
            numberOfSets: response.numberOfSets
        )
        
        viewController?.displayExercisePreview(viewModel: viewModel)
    }
    
    private func formatDuration(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, remainingSeconds)
        } else {
            return String(format: "0:%02d", seconds)
        }
    }
    
    private func getExerciseColor(for exercise: Exercise) -> UIColor {
        // Generate consistent colors based on exercise type or name
        switch exercise.type {
        case .core:
            return UIColor.goatBlue.withAlphaComponent(0.8)
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