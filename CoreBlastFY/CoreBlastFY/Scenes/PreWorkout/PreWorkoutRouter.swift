//
//  PreWorkoutRouter.swift
//  CoreBlast
//
//  Created by Riccardo Washington on 1/25/20.
//  Copyright (c) 2020 Riccardo Washington. All rights reserved.
//

import UIKit

@objc protocol PreWorkoutRoutingLogic {
  func routeToWorkoutScene()
  func routeToExercisePreview()
}

protocol PreWorkoutDataPassing {
  var preWorkoutDataStore: PreWorkoutDataStore? { get set }
}

class PreWorkoutRouter: NSObject, PreWorkoutRoutingLogic, PreWorkoutDataPassing {
    
  weak var viewController: PreWorkoutViewController?
  var preWorkoutDataStore: PreWorkoutDataStore?
  
  // MARK: Routing
  
    func routeToWorkoutScene() {
        // This method is kept for backward compatibility
        // New flow should use routeToExercisePreview()
        guard let source = viewController else { return }
        let destination = WorkoutViewController()
        
        guard let preWorkoutDataStore = preWorkoutDataStore else { return }
        guard var destinationDataStore = destination.router?.dataStore else { return }
        passExercisesToWorkoutScene(source: preWorkoutDataStore, destination: &destinationDataStore)
        navigateToWorkoutScene(source: source, destination: destination)
    }
    
    func routeToExercisePreview() {
        guard let source = viewController else { return }
        let destination = ExercisePreviewViewController()
        
        guard let preWorkoutDataStore = preWorkoutDataStore,
              var destinationDataStore = destination.interactor else { return }
        passDataToExercisePreview(source: preWorkoutDataStore, destination: &destinationDataStore)
        navigateToExercisePreview(source: source, destination: destination)
    }

  // MARK: Navigation
  
  private func navigateToWorkoutScene(source: PreWorkoutViewController, destination: WorkoutViewController) {
    source.show(destination, sender: nil)
  }
  
  private func navigateToExercisePreview(source: PreWorkoutViewController, destination: ExercisePreviewViewController) {
    source.navigationController?.pushViewController(destination, animated: true)
  }

  // MARK: Passing data

 private func passExercisesToWorkoutScene(source: PreWorkoutDataStore, destination: inout WorkoutDataStore) {
      destination.exercises = source.exercises
      destination.workout = source.workout
  }
  
  private func passDataToExercisePreview(source: PreWorkoutDataStore, destination: inout (ExercisePreviewBusinessLogic & ExercisePreviewDataStore)) {
      // Ensure we have a workout - create one if missing
      let workout: Workout
      if let existingWorkout = source.workout {
          workout = existingWorkout
      } else {
          // Create workout if missing - this ensures consistent data
          let user = UserManager.loadUserFromFile()
          workout = Workout(user: user, exercises: source.exercises)
      }
      
      // Use the actual exercises that will be shown in workout (filtered by user level)
      destination.exercises = workout.exercisesToReturn
      
      // Determine workout title based on workout type
      let workoutTitle = workout.isCustom ? "Custom Workout" : "Wake Up"
      
      // Get exercise duration from workout - this matches what the actual workout will use
      let exerciseDuration: TimeInterval
      if workout.isCustom, let customDuration = workout.customSecondsOfExercise {
          exerciseDuration = TimeInterval(customDuration)
      } else {
          exerciseDuration = TimeInterval(workout.secondsOfExercise)
      }
      
      // Calculate workout duration using the same logic as the actual workout
      let workoutDuration: String
      if workout.isCustom {
          let totalMinutes = Int(workout.customWorkoutDuration / 60)
          workoutDuration = "\(totalMinutes) MINUTES"
      } else {
          let totalMinutes = Int(workout.workoutDuration / 60)
          workoutDuration = "\(totalMinutes) MINUTES"
      }
      
      // Set description based on workout type
      let workoutDescription: String
      if workout.isCustom {
          workoutDescription = "Your personalized workout routine. Challenge yourself with exercises you've selected, tailored to your fitness goals."
      } else {
          workoutDescription = "A simple routine to progress your body's natural mobility and range of motion. Quick, convenient, and effective. Do it anytime, anywhere, everyday."
      }
      
      destination.workoutDetails = (title: workoutTitle,
                                    duration: workoutDuration,
                                    description: workoutDescription,
                                    exerciseDuration: exerciseDuration,
                                    numberOfSets: workout.numberOfSets)
  }
}

