//
//  CustomWorkoutViewController.swift
//  CoreBlastFY
//
//  Created by Riccardo Washington on 7/20/20.
//  Copyright © 2020 Riccardo Washington. All rights reserved.
//

import UIKit

protocol CreateWorkoutDelegate: AnyObject {
    func createWorkout(duration: Int, numberOfSets: Int)
}

class CustomWorkoutViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(workoutComplete), name: workoutCompleteNotification2, object: nil)
        navigationController?.navigationBar.prefersLargeTitles  =  false
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViews()
        // Reset the exercise selection view if coming back from workout
        if workoutViewController == nil && exerciseSelectionView.superview != nil {
            exerciseSelectionView.removeFromSuperview()
        }
    }
    
    // MARK: - Views
    
    private let customWorkoutVM = CustomWorkoutViewModel()
    
    lazy var exerciseSelectionView = ExerciseSelectionView(customViewController: self)
    
    private lazy var mainView = CustomWorkoutView(vm: customWorkoutVM, customWorkoutViewController: self)
    private var workoutViewController: WorkoutViewController?
    
    private var loadingView: LoadingView?
    private var loadingSpinner: UIActivityIndicatorView?
    
    // MARK: - Methods
    
    @objc func workoutComplete() {
        workoutViewController = nil
        // Reset after workout is complete
        customWorkoutVM.workout = nil
        exerciseSelectionView.exerciseSelectionViewDataSource.resetSelectedExercises()
        customWorkoutVM.reset()
        view.setNeedsDisplay()
    }
    
    private func setBackgroundColor() {
        view.backgroundColor = .black
    }
    
    private func setupMainView() {
        view.addSubview(mainView)
        mainView.fillSuperview()
    }
    
    private func setupViews() {
        setBackgroundColor()
        setupMainView()
        navigationItem.title = "Custom Workout"
    }
    
    func removeView(_ view: UIView) {
        view.removeFromSuperview()
    }
    
    func createWorkout() {
        // Check if user has hit the workout limit and needs subscription
        if shouldShowPaywall() {
            showHardPaywall()
            return
        }
        
        let exercises = exerciseSelectionView.exerciseSelectionViewDataSource.selectedExercises
        customWorkoutVM.addExercises(exercises: exercises)
        
        // Track custom workout creation
        if let workout = customWorkoutVM.workout {
            AnalyticsManager.shared.trackCustomWorkoutCreated(
                exercises: exercises.count,
                duration: workout.customSecondsOfExercise ?? 0,
                sets: workout.customNumberOfSets ?? 0
            )
        }
        
        // Navigate directly to WorkoutViewController with custom workout
        showWorkout()
    }
    
    private func shouldShowPaywall() -> Bool {
        let completedWorkouts = UserDefaults.standard.integer(forKey: "completedWorkoutsCount")
        let hasSubscribed = UserDefaults.standard.bool(forKey: "hasSubscribed")
        let isPremium = StoreManager.shared.isPremium
        
        return completedWorkouts >= 3 && !hasSubscribed && !isPremium
    }
    
    private func showHardPaywall() {
        let subscriptionView = HostingViewController(view: SubscriptionView() { [weak self] success in
            if success {
                UserDefaults.standard.set(true, forKey: "hasSubscribed")
                // User subscribed, now they can start the custom workout
                self?.dismiss(animated: true) {
                    self?.createWorkoutAfterSubscription()
                }
            } else {
                // Hard paywall - user must subscribe
                self?.dismiss(animated: true) {
                    self?.showSubscriptionRequiredAlert()
                }
            }
        })
        
        subscriptionView.modalPresentationStyle = .fullScreen
        present(subscriptionView, animated: true)
    }
    
    private func createWorkoutAfterSubscription() {
        let exercises = exerciseSelectionView.exerciseSelectionViewDataSource.selectedExercises
        customWorkoutVM.addExercises(exercises: exercises)
        showWorkout()
    }
    
    private func showSubscriptionRequiredAlert() {
        let alert = UIAlertController(
            title: "Subscription Required",
            message: "You've completed your 3 free workouts! Subscribe to unlock unlimited access to all workouts and custom workout features.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Subscribe", style: .default) { [weak self] _ in
            self?.showHardPaywall()
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showWorkout() {
        guard let workout = customWorkoutVM.workout else { return }
        
        workoutViewController = WorkoutViewController()
        workoutViewController?.interactor?.workout = workout
        
        navigationController?.pushViewController(workoutViewController!, animated: true)
        
        // Don't reset here - wait until workout is complete or view disappears
    }
    
}
