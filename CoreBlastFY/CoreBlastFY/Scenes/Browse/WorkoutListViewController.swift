//
//  WorkoutListViewController.swift
//  CoreBlast
//
//  Created by Claude on 12/1/24.
//  Copyright © 2024 Riccardo Washington. All rights reserved.
//

import UIKit

class WorkoutListViewController: UIViewController {
    
    private let category: WorkoutCategory
    private var presetWorkouts: [PresetWorkout] = []
    private var tableView: UITableView!
    
    init(category: WorkoutCategory) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        loadWorkouts()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = category.title
        view.backgroundColor = .black
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .black
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(WorkoutListCell.self, forCellReuseIdentifier: WorkoutListCell.identifier)
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadWorkouts() {
        // Get preset workouts for this category
        presetWorkouts = WorkoutLibrary.shared.getWorkouts(for: category)
        
        // Special handling for certain categories
        switch category.id {
        case "custom_duration":
            // Navigate to custom workout creation
            navigateToCustomWorkout()
            return
            
        case "favorites":
            // Get user's favorite workouts
            presetWorkouts = WorkoutLibrary.shared.getFavoriteWorkouts()
            
        default:
            break
        }
        
        tableView.reloadData()
    }
    
    private func navigateToCustomWorkout() {
        navigationController?.popViewController(animated: false)
        let customWorkoutVC = CustomWorkoutViewController()
        navigationController?.pushViewController(customWorkoutVC, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension WorkoutListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presetWorkouts.isEmpty ? 1 : presetWorkouts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutListCell.identifier, for: indexPath) as! WorkoutListCell
        
        if presetWorkouts.isEmpty {
            cell.configureEmpty(for: category)
        } else {
            cell.configure(with: presetWorkouts[indexPath.row])
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension WorkoutListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard !presetWorkouts.isEmpty else { return }
        
        // Start workout
        let presetWorkout = presetWorkouts[indexPath.row]
        startWorkout(presetWorkout)
    }
    
    private func startWorkout(_ presetWorkout: PresetWorkout) {
        // Check if user has premium access
        let isPremium = StoreManager.shared.isPremium
        
        // Allow first two beginner workouts for free
        let freeWorkoutIds = ["beginner_core_intro", "beginner_total_body"]
        let isFreeBeginner = freeWorkoutIds.contains(presetWorkout.id)
        
        if !isPremium && !isFreeBeginner {
            // Show subscription page for non-premium users
            showSubscriptionPage()
            return
        }
        
        // Convert preset to actual workout
        guard let user = UserAPI.user,
              let workout = WorkoutLibrary.shared.convertToWorkout(presetWorkout, user: user) else {
            // Show error if workout can't be created
            let alert = UIAlertController(
                title: "Unable to Start Workout",
                message: "Some exercises in this workout are not available. Please try another workout.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Navigate directly to ExercisePreview
        let exercisePreviewVC = ExercisePreviewViewController()
        
        // Configure the exercise preview with workout data
        if var dataStore = exercisePreviewVC.interactor {
            // Set exercises from the workout
            dataStore.exercises = workout.exercisesToReturn
            
            // Determine workout title and description
            let workoutTitle = presetWorkout.name
            
            // Calculate workout duration
            let workoutDuration: String
            if workout.isCustom {
                let totalMinutes = Int(workout.customWorkoutDuration / 60)
                workoutDuration = "\(totalMinutes) MINUTES"
            } else {
                let totalMinutes = Int(workout.workoutDuration / 60)
                workoutDuration = "\(totalMinutes) MINUTES"
            }
            
            // Get exercise duration
            let exerciseDuration: TimeInterval
            if workout.isCustom, let customDuration = workout.customSecondsOfExercise {
                exerciseDuration = TimeInterval(customDuration)
            } else {
                exerciseDuration = TimeInterval(workout.secondsOfExercise)
            }
            
            // Set workout details
            dataStore.workoutDetails = (
                title: workoutTitle,
                duration: workoutDuration,
                description: presetWorkout.description,
                exerciseDuration: exerciseDuration,
                numberOfSets: workout.numberOfSets
            )
        }
        
        navigationController?.pushViewController(exercisePreviewVC, animated: true)
    }
    
    private func showSubscriptionPage() {
        let subscriptionView = HostingViewController(view: SubscriptionView() { [weak self] success in
            if success {
                // StoreManager will handle the subscription state
                self?.dismiss(animated: true) {
                    // Reload the table to reflect any changes
                    self?.tableView.reloadData()
                }
            } else {
                // User declined subscription
                self?.dismiss(animated: true)
            }
        })
        
        subscriptionView.modalPresentationStyle = .fullScreen
        present(subscriptionView, animated: true)
    }
}

// MARK: - WorkoutListCell
class WorkoutListCell: UITableViewCell {
    
    static let identifier = "WorkoutListCell"
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.goatBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.goatBlue
        button.layer.cornerRadius = 20
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let lockIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "lock.fill")
        imageView.tintColor = UIColor.systemYellow
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(durationLabel)
        containerView.addSubview(playButton)
        containerView.addSubview(lockIcon)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            playButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            playButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            playButton.widthAnchor.constraint(equalToConstant: 40),
            playButton.heightAnchor.constraint(equalToConstant: 40),
            
            lockIcon.centerXAnchor.constraint(equalTo: playButton.centerXAnchor),
            lockIcon.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            lockIcon.widthAnchor.constraint(equalToConstant: 20),
            lockIcon.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -16),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -16),
            
            durationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            durationLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            durationLabel.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -16)
        ])
    }
    
    func configure(with presetWorkout: PresetWorkout) {
        titleLabel.text = presetWorkout.name
        subtitleLabel.text = presetWorkout.description
        durationLabel.text = "\(presetWorkout.estimatedDuration) minutes • \(presetWorkout.numberOfSets) sets"
        playButton.isHidden = false
        
        // Check premium status and show lock if needed
        let isPremium = StoreManager.shared.isPremium
        
        // Allow first two beginner workouts for free
        let freeWorkoutIds = ["beginner_core_intro", "beginner_total_body"]
        let isFreeBeginner = freeWorkoutIds.contains(presetWorkout.id)
        
        let isLocked = !isPremium && !isFreeBeginner
        
        lockIcon.isHidden = !isLocked
        playButton.setImage(UIImage(systemName: isLocked ? "" : "play.fill"), for: .normal)
        playButton.backgroundColor = isLocked ? UIColor.gray.withAlphaComponent(0.3) : UIColor.goatBlue
    }
    
    func configureEmpty(for category: WorkoutCategory) {
        titleLabel.text = "No workouts available"
        subtitleLabel.text = "Check back later for \(category.title.lowercased()) workouts"
        durationLabel.text = ""
        playButton.isHidden = true
    }
}