//
//  ExercisePreviewRouter.swift
//  CoreBlast
//
//  Created by Claude AI on 11/29/25.
//

import UIKit

@objc protocol ExercisePreviewRoutingLogic {
    func routeToWorkout()
}

protocol ExercisePreviewDataPassing {
    var dataStore: ExercisePreviewDataStore? { get }
}

class ExercisePreviewRouter: NSObject, ExercisePreviewRoutingLogic, ExercisePreviewDataPassing {
    weak var viewController: ExercisePreviewViewController?
    var dataStore: ExercisePreviewDataStore?
    
    // MARK: Routing
    
    func routeToWorkout() {
        let destinationVC = WorkoutViewController()
        var destinationDS = destinationVC.interactor
        passDataToWorkout(source: dataStore, destination: &destinationDS)
        navigateToWorkout(source: viewController, destination: destinationVC)
    }
    
    // MARK: Navigation
    
    func navigateToWorkout(source: ExercisePreviewViewController?, destination: WorkoutViewController) {
        source?.navigationController?.pushViewController(destination, animated: true)
    }
    
    // MARK: Passing data
    
    func passDataToWorkout(source: ExercisePreviewDataStore?, destination: inout (WorkoutBusinessLogic & WorkoutDataStore)?) {
        destination?.exercises = source?.exercises ?? []
        
        // Create a workout with the exercises if needed
        if let exercises = source?.exercises, !exercises.isEmpty {
            let user = UserManager.loadUserFromFile()
            let workout = Workout(user: user, exercises: exercises)
            destination?.workout = workout
        }
    }
}