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
    
    private func setupNavigationBar() {
        view.backgroundColor = .black
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = ""
        
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
    
    @objc private func closeButtonTapped() {
        showTabBar()
        navigationController?.popViewController(animated: true)
    }
    
    private func showTabBar() {
        tabBarController?.tabBar.isHidden = false
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
