//
//  ExercisePreviewViewController.swift
//  CoreBlast
//
//  Created by Claude AI on 11/29/25.
//

import UIKit

protocol ExercisePreviewDisplayLogic: AnyObject {
    func displayExercisePreview(viewModel: ExercisePreview.FetchExercisePreview.ViewModel)
}

class ExercisePreviewViewController: UIViewController, ExercisePreviewDisplayLogic {
    var interactor: (ExercisePreviewBusinessLogic & ExercisePreviewDataStore)?
    var router: (NSObjectProtocol & ExercisePreviewRoutingLogic & ExercisePreviewDataPassing)?
    
    private var exercisePreviewView: ExercisePreviewView?
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = ExercisePreviewInteractor()
        let presenter = ExercisePreviewPresenter()
        let router = ExercisePreviewRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        hideTabBar()
        fetchExercisePreview()
    }
    
    private func hideTabBar() {
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Clean up navigation again in case buttons were re-added
        cleanupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Final cleanup after view appears
        cleanupNavigationBar()
        
        // Force remove ellipsis button one more time
        DispatchQueue.main.async { [weak self] in
            self?.navigationItem.rightBarButtonItem = nil
            self?.cleanupNavigationBar()
        }
    }
    
    private func setupNavigationBar() {
        view.backgroundColor = .black
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = ""
        
        // Clean up any custom buttons added by previous view controllers
        cleanupNavigationBar()
        
        // Add close button
        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        closeButton.tintColor = .white
        navigationItem.leftBarButtonItem = closeButton
        
        // Remove the ellipsis button - not needed on exercise preview
        navigationItem.rightBarButtonItem = nil
    }
    
    private func cleanupNavigationBar() {
        // Remove any custom subviews added by previous view controllers
        var subviewsToRemove: [UIView] = []
        
        navigationController?.navigationBar.subviews.forEach { subview in
            // Remove custom buttons and views that shouldn't be there
            if subview is UIButton {
                print("Found custom button to remove: \(subview)")
                subviewsToRemove.append(subview)
            }
            // Also check for any custom views that might contain buttons
            if subview.subviews.contains(where: { $0 is UIButton }) {
                print("Found custom view with buttons to remove: \(subview)")
                subviewsToRemove.append(subview)
            }
        }
        
        // Remove all found subviews
        subviewsToRemove.forEach { subview in
            print("Removing subview: \(subview)")
            subview.removeFromSuperview()
        }
        
        // Clear all bar button items
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItem = nil
        
        // Clear any custom title view
        navigationItem.titleView = nil
        
        // Force navigation bar to update
        navigationController?.navigationBar.setNeedsLayout()
        navigationController?.navigationBar.layoutIfNeeded()
        
        // Additional cleanup - remove any orphaned constraints
        navigationController?.navigationBar.subviews.forEach { subview in
            if subview is UIButton || subview.tag == 999 { // Use tag to identify custom views
                subview.removeFromSuperview()
            }
        }
    }
    
    @objc private func closeButtonTapped() {
        showTabBar()
        navigationController?.popViewController(animated: true)
    }
    
    private func showTabBar() {
        tabBarController?.tabBar.isHidden = false
    }
    
    @objc private func moreButtonTapped() {
        // Add share/more options functionality here
        print("More options tapped")
    }
    
    @objc private func startWorkoutTapped() {
        showTabBar()
        router?.routeToWorkout()
    }
    
    // MARK: Do something
    
    func fetchExercisePreview() {
        guard let exercises = interactor?.exercises,
              let workoutDetails = interactor?.workoutDetails else { return }
        
        let request = ExercisePreview.FetchExercisePreview.Request(
            exercises: exercises,
            workoutTitle: workoutDetails.title,
            workoutDuration: workoutDetails.duration,
            workoutDescription: workoutDetails.description,
            exerciseDuration: workoutDetails.exerciseDuration,
            numberOfSets: workoutDetails.numberOfSets
        )
        interactor?.fetchExercisePreview(request: request)
    }
    
    func displayExercisePreview(viewModel: ExercisePreview.FetchExercisePreview.ViewModel) {
        setupExercisePreviewView(with: viewModel)
    }
    
    private func setupExercisePreviewView(with viewModel: ExercisePreview.FetchExercisePreview.ViewModel) {
        exercisePreviewView = ExercisePreviewView(
            viewModel: viewModel,
            startAction: { [weak self] in
                self?.startWorkoutTapped()
            }
        )
        
        guard let exercisePreviewView = exercisePreviewView else { return }
        
        view.addSubview(exercisePreviewView)
        exercisePreviewView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            exercisePreviewView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            exercisePreviewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            exercisePreviewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            exercisePreviewView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}