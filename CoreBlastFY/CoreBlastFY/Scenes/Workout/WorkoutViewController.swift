//
//  WorkoutViewController.swift
//  CoreBlast
//
//  Created by Riccardo Washington on 1/26/20.
//  Copyright (c) 2020 Riccardo Washington. All rights reserved.
//

import UIKit
import StoreKit

protocol WorkoutDisplayLogic: AnyObject {
    func displayWorkout(viewModel: WorkoutInfo.FetchWorkout.ViewModel)
}

class WorkoutViewController: UIViewController, WorkoutDisplayLogic {
    var interactor: (WorkoutBusinessLogic & WorkoutDataStore)?
    var router: (NSObjectProtocol & WorkoutRoutingLogic & WorkoutDataPassing)?
    var workoutView: ModernWorkoutView?
    var viewModel: WorkoutInfo.FetchWorkout.ViewModel?
    var tapGesture: UITapGestureRecognizer?
    
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit {
        viewModel = nil
        workoutView = nil
        interactor = nil
        print(workoutView == nil)
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = WorkoutInteractor()
        let presenter = WorkoutPresenter()
        let router = WorkoutRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        view.setNeedsDisplay()
        view.setNeedsLayout()
    }
    
    private func setupNavigationBar() {
        self.tabBarController?.tabBar.isHidden = true
        view.backgroundColor = .black
    }
    
    // MARK: Routing
    
    private func routeToPreWorkoutScene() {
        router?.routeToPreWorkoutScene()
    }
    
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        
        fetchCustomWorkout()
        registerObservers()
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleStateOfWorkout))
        view.addGestureRecognizer(tapGesture!)
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.navigationBar.isHidden = true
            self?.view.setNeedsDisplay()
            self?.view.setNeedsLayout()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func fetchCustomWorkout() {
        if let workout = interactor?.workout, workout.isCustom {
            interactor?.createCustomWorkout(workout: workout)
        } else {
            fetchWorkout()
        }
    }
    
    
    @objc private func preventScreenRecording() {
        let isRecording = UIScreen.main.isCaptured
        
        if isRecording {
            workoutView?.isHidden = true
            workoutView?.pauseWorkout()
        } else {
            workoutView?.isHidden = false
            workoutView?.resumeWorkout()
        }
    }
    
    
    private func registerObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(workoutComplete), name: workoutCompleteNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pauseWorkoutFromInterruption), name: PauseWorkoutNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(preventScreenRecording), name: UIScreen.capturedDidChangeNotification, object: nil)
    }
    
    @objc private func pauseWorkoutFromInterruption() {
        workoutView?.pauseWorkout()
    }
    
    @objc private func pauseWorkout() {
        guard let tapGesture = tapGesture else { return }
        handleStateOfWorkout(tapGesture)
    }
    
    @objc private func handleStateOfWorkout(_ gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .ended :
            guard workoutView != nil else { return }
            if workoutView!.timerIsRunning {
                workoutView?.pauseWorkout()
            } else {
                workoutView?.resumeWorkout()
            }
        default: break
        }
    }
    
    @objc private func workoutComplete() {
        workoutView = nil
        
        // Track workout completion for paywall logic
        trackWorkoutCompletion()
        
        showPreWorkoutUI()
        NotificationCenter.default.post(name: workoutCompleteNotification2, object: nil)
        
        // Request review after completing a workout (only if user has points/engagement)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            if UserAPI.user.totalPoints > 0, UserAPI.user.requestReview {
                if let scene = self.view.window?.windowScene {
                    AppStore.requestReview(in: scene)
                    UserAPI.user.requestReviewCount += 1
                    UserAPI.user.lastReviewRequestDate = Date()
                    UserManager.save()
                }
            }
        }
    }
    
    private func trackWorkoutCompletion() {
        let completedWorkouts = UserDefaults.standard.integer(forKey: "completedWorkoutsCount")
        let newCount = completedWorkouts + 1
        UserDefaults.standard.set(newCount, forKey: "completedWorkoutsCount")
        UserDefaults.standard.synchronize()
        
        print("🏋️‍♂️ Workout completed! Total: \(newCount)")
        
        // Track workout completion in Firebase Analytics
        if let workout = interactor?.workout {
            let workoutType = workout.isCustom ? "custom" : "preset"
            let exerciseCount = workout.isCustom ? workout.exercises.count : workout.exercisesToReturn.count
            let duration = workout.isCustom ? workout.customWorkoutDuration : workout.workoutDuration
            
            AnalyticsManager.shared.trackWorkoutCompleted(
                workoutType: workoutType,
                duration: duration,
                exercises: exerciseCount
            )
            
            // Update user properties
            AnalyticsManager.shared.setWorkoutCount(newCount)
        }
        
        // Check if we need to show paywall after 3 completed workouts
        if newCount >= 3 && !isUserSubscribed() {
            AnalyticsManager.shared.trackPaywallShown(workoutsCompleted: newCount)
            DispatchQueue.main.async {
                self.showPaywallAfterWorkout()
            }
        }
    }
    
    private func isUserSubscribed() -> Bool {
        let hasSubscribed = UserDefaults.standard.bool(forKey: "hasSubscribed")
        let isPremium = StoreManager.shared.isPremium
        return hasSubscribed || isPremium
    }
    
    private func showPaywallAfterWorkout() {
        let subscriptionView = HostingViewController(view: SubscriptionView() { [weak self] success in
            if success {
                UserDefaults.standard.set(true, forKey: "hasSubscribed")
                // User subscribed, continue normally
                print("✅ User subscribed after workout completion")
            } else {
                // This is now a hard paywall - user must subscribe to continue
                // Show alert and prevent further workout access
                self?.showHardPaywallAlert()
            }
        })
        
        subscriptionView.modalPresentationStyle = .fullScreen
        present(subscriptionView, animated: true)
    }
    
    private func showHardPaywallAlert() {
        let alert = UIAlertController(
            title: "Subscription Required",
            message: "You've completed your 3 free workouts! Subscribe to continue your fitness journey with unlimited access to all workouts.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Subscribe", style: .default) { [weak self] _ in
            self?.showPaywallAfterWorkout()
        })
        
        alert.addAction(UIAlertAction(title: "Maybe Later", style: .cancel) { [weak self] _ in
            // Navigate back to home - they can't access workouts anymore
            self?.navigationController?.popToRootViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    // MARK: Do something
    
    func fetchWorkout() {
        guard let exercises = interactor?.exercises else { return }
        let request = WorkoutInfo.FetchWorkout.Request(exercises: exercises)
        interactor?.fetchWorkout(request: request)
    }
    
    func displayWorkout(viewModel: WorkoutInfo.FetchWorkout.ViewModel) {
        showWorkoutUI(with: viewModel)
    }
    
    private func showWorkoutUI(with viewModel: WorkoutInfo.FetchWorkout.ViewModel) {
        if workoutView == nil {
            workoutView = ModernWorkoutView(frame: view.frame, rootVC: self, viewModel: viewModel, secondsOfRest: interactor?.workout?.secondsOfRest ?? 10)
        }
        guard let workoutView = workoutView else { return }
        view.addSubview(workoutView)
        workoutView.translatesAutoresizingMaskIntoConstraints = false
        workoutView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        workoutView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        workoutView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        workoutView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
    }
    
    @objc private func showPreWorkoutUI() {
        self.navigationController?.popViewController(animated: true)
        
    }
    
}
