//
//  ModernWorkoutView.swift
//  CoreBlast
//
//  Created by Claude AI on 11/29/25.
//

import UIKit
import AVFoundation
import SwiftUI


class ModernWorkoutView: UIView {
    
    // MARK: - Properties
    private var currentSet = 1
    private var currentExercise = 0
    private var workoutDuration: TimeInterval
    private var remainingTime: TimeInterval = 30 // Initial exercise time
    var timerIsRunning = false
    private var isRestPeriod = false // Track if we're in a rest period
    private var isCountdownPhase = true // Track if we're in the 3-second countdown
    private var countdownTime: TimeInterval = 3 // 3-second countdown
    
    weak var rootViewController: WorkoutViewController?
    private var workoutViewModel: WorkoutInfo.FetchWorkout.ViewModel
    
    private let pauseLabel = UILabel()
    private let progressLabel = UILabel() // "1 of 8"
    private let exerciseNameLabel = UILabel()
    private let timeLabel = UILabel()
    private let countdownLabel = UILabel() // "3"
    private let getReadyLabel = UILabel() // "GET READY"
    private let pulseView = UIView() // Background pulse animation
    private let exerciseVideoPlayer = ExerciseVideoPlayerView()
    private let progressIndicator = CircularProgressView()
    
    private let exitButton = UIButton(type: .system)
    private let settingsButton = UIButton(type: .system)
    private let previousButton = UIButton(type: .system)
    private let playPauseButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    
    var loadingView: LoadingView?
    private var exercises: [Exercise]
    private let setDuration: TimeInterval
    private let exerciseDuration: TimeInterval
    private let secondsOfRest: Int
    private var workoutTimer = Timer()
    
    private var numberOfSets: Int {
        guard let number = Int(workoutViewModel.workoutDetails.numberOfSets) else { return 4 }
        return number
    }
    
    // MARK: - Initialization
    init(frame: CGRect, rootVC: UIViewController, viewModel: WorkoutInfo.FetchWorkout.ViewModel, secondsOfRest: Int) {
        rootViewController = rootVC as? WorkoutViewController
        workoutViewModel = viewModel
        workoutDuration = workoutViewModel.workoutDetails.workoutDurationDouble
        self.secondsOfRest = secondsOfRest
        
        exercises = workoutViewModel.workoutDetails.exercises
        exerciseDuration = workoutViewModel.workoutDetails.secondsOfExercise
        setDuration = workoutViewModel.workoutDetails.setDuration
        remainingTime = exerciseDuration
        
        super.init(frame: frame)
        
        backgroundColor = .black
        setupUI()
        configureInitialState()
        
        // Provide haptic and audio feedback for workout start
        WorkoutFeedbackManager.shared.playWorkoutStartFeedback()
        
        startTimer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupExitButton()
        setupSettingsButton()
        setupProgressIndicator()
        setupTopSection()
        setupCenterSection()
        setupBottomSection()
        setupConstraints()
    }
    
    private func setupExitButton() {
        exitButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        exitButton.tintColor = .white
        exitButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        exitButton.layer.cornerRadius = 20
        exitButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
        
        addSubview(exitButton)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            exitButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            exitButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            exitButton.widthAnchor.constraint(equalToConstant: 40),
            exitButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupSettingsButton() {
        settingsButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        settingsButton.tintColor = .white
        settingsButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        settingsButton.layer.cornerRadius = 20
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        
        addSubview(settingsButton)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            settingsButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            settingsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            settingsButton.widthAnchor.constraint(equalToConstant: 40),
            settingsButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupProgressIndicator() {
        progressIndicator.lineWidth = 6
        progressIndicator.strokeColor = UIColor.goatBlue
        progressIndicator.backgroundColor = UIColor.clear
        
        // Add shadow for better visual definition
        progressIndicator.layer.shadowColor = UIColor.black.cgColor
        progressIndicator.layer.shadowOffset = CGSize(width: 0, height: 2)
        progressIndicator.layer.shadowRadius = 4
        progressIndicator.layer.shadowOpacity = 0.3
        
        addSubview(progressIndicator)
    }
    
    private func setupTopSection() {
        // Progress label (1 of 8)
        progressLabel.text = "Set \(currentSet) • \(currentExercise + 1) of \(exercises.count)"
        progressLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        progressLabel.textColor = .white
        progressLabel.textAlignment = .center
        
        addSubview(progressLabel)
    }
    
    private func setupCenterSection() {
        // Exercise video player container - perfect circle
        exerciseVideoPlayer.backgroundColor = UIColor.clear
        exerciseVideoPlayer.layer.cornerRadius = 190 // Perfect circle for 380x380 view
        exerciseVideoPlayer.clipsToBounds = true
        
        // Add border for perfect circle appearance
        exerciseVideoPlayer.layer.borderWidth = 3
        exerciseVideoPlayer.layer.borderColor = UIColor.goatBlue.withAlphaComponent(0.4).cgColor
        
        // Exercise name
        exerciseNameLabel.font = UIFont.boldSystemFont(ofSize: 28)
        exerciseNameLabel.textColor = .white
        exerciseNameLabel.textAlignment = .center
        exerciseNameLabel.numberOfLines = 2
        
        addSubview(exerciseVideoPlayer)
        addSubview(exerciseNameLabel)
    }
    
    private func setupBottomSection() {
        // Time display
        timeLabel.font = UIFont.boldSystemFont(ofSize: 56)
        timeLabel.textColor = .white
        timeLabel.textAlignment = .center
        
        // Control buttons
        setupControlButtons()
        
        // Pause label
        pauseLabel.text = "PAUSED"
        pauseLabel.font = UIFont.boldSystemFont(ofSize: 36)
        pauseLabel.textColor = .white
        pauseLabel.textAlignment = .center
        pauseLabel.isHidden = true
        
        // Hide GET READY label - we only want numbers
        getReadyLabel.isHidden = true
        
        // Countdown label - enhanced design
        countdownLabel.text = "3"
        countdownLabel.font = UIFont.systemFont(ofSize: UIDevice.isIpad ? 180 : 140, weight: .black)
        countdownLabel.textColor = .white
        countdownLabel.textAlignment = .center
        countdownLabel.layer.shadowColor = UIColor.goatBlue.cgColor
        countdownLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        countdownLabel.layer.shadowRadius = 20
        countdownLabel.layer.shadowOpacity = 0.8
        countdownLabel.isHidden = false
        
        // Pulse view setup
        pulseView.backgroundColor = UIColor.goatBlue.withAlphaComponent(0.1)
        pulseView.layer.cornerRadius = UIDevice.isIpad ? 150 : 120
        pulseView.alpha = 0.2
        
        // Create continuous subtle pulse
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 1.5
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.1
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseView.layer.add(pulseAnimation, forKey: "pulse")
        
        addSubview(pulseView)
        addSubview(getReadyLabel)
        addSubview(timeLabel)
        addSubview(pauseLabel)
        addSubview(countdownLabel)
    }
    
    private func setupControlButtons() {
        // Previous button
        previousButton.setImage(UIImage(systemName: "backward.end.fill"), for: .normal)
        previousButton.tintColor = .white
        previousButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        previousButton.layer.cornerRadius = 30
        previousButton.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
        
        // Play/Pause button - signature blue primary action
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        playPauseButton.tintColor = .white
        playPauseButton.backgroundColor = UIColor.goatBlue
        playPauseButton.layer.cornerRadius = 40
        
        // Ensure perfect circle shape
        playPauseButton.contentHorizontalAlignment = .center
        playPauseButton.contentVerticalAlignment = .center
        playPauseButton.imageView?.contentMode = .scaleAspectFit
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add shadow and border for better visual definition
        playPauseButton.layer.shadowColor = UIColor.black.cgColor
        playPauseButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        playPauseButton.layer.shadowRadius = 8
        playPauseButton.layer.shadowOpacity = 0.3
        playPauseButton.layer.borderWidth = 2
        playPauseButton.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        
        // Next button
        nextButton.setImage(UIImage(systemName: "forward.end.fill"), for: .normal)
        nextButton.tintColor = .white
        nextButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        nextButton.layer.cornerRadius = 30
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        // Set up buttons individually to avoid stack view distortion
        addSubview(previousButton)
        addSubview(playPauseButton)
        addSubview(nextButton)
        
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Play/Pause button - center and perfect circle
            playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playPauseButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -40),
            playPauseButton.widthAnchor.constraint(equalToConstant: 80),
            playPauseButton.heightAnchor.constraint(equalToConstant: 80),
            
            // Previous button - left of play/pause
            previousButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            previousButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -50),
            previousButton.widthAnchor.constraint(equalToConstant: 60),
            previousButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Next button - right of play/pause
            nextButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            nextButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 50),
            nextButton.widthAnchor.constraint(equalToConstant: 60),
            nextButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupConstraints() {
        progressIndicator.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        exerciseVideoPlayer.translatesAutoresizingMaskIntoConstraints = false
        exerciseNameLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        pauseLabel.translatesAutoresizingMaskIntoConstraints = false
        getReadyLabel.translatesAutoresizingMaskIntoConstraints = false
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        pulseView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Progress indicator (circular background) - bigger and higher
            progressIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressIndicator.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -120),
            progressIndicator.widthAnchor.constraint(equalToConstant: 400),
            progressIndicator.heightAnchor.constraint(equalToConstant: 400),
            
            // Progress label
            progressLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            
            // Exercise video player - bigger and higher
            exerciseVideoPlayer.centerXAnchor.constraint(equalTo: centerXAnchor),
            exerciseVideoPlayer.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -120),
            exerciseVideoPlayer.widthAnchor.constraint(equalToConstant: 380),
            exerciseVideoPlayer.heightAnchor.constraint(equalToConstant: 380),
            
            // Exercise name - better spacing
            exerciseNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            exerciseNameLabel.topAnchor.constraint(equalTo: exerciseVideoPlayer.bottomAnchor, constant: 40),
            exerciseNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            exerciseNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            
            // Time label - better spacing
            timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            timeLabel.topAnchor.constraint(equalTo: exerciseNameLabel.bottomAnchor, constant: 25),
            
            // Pause label
            pauseLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            pauseLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // Pulse view constraints - centered in video view area
            pulseView.centerXAnchor.constraint(equalTo: exerciseVideoPlayer.centerXAnchor),
            pulseView.centerYAnchor.constraint(equalTo: exerciseVideoPlayer.centerYAnchor),
            pulseView.widthAnchor.constraint(equalToConstant: UIDevice.isIpad ? 300 : 240),
            pulseView.heightAnchor.constraint(equalToConstant: UIDevice.isIpad ? 300 : 240),
            
            // Countdown label - centered in video view area
            countdownLabel.centerXAnchor.constraint(equalTo: exerciseVideoPlayer.centerXAnchor),
            countdownLabel.centerYAnchor.constraint(equalTo: exerciseVideoPlayer.centerYAnchor),
            countdownLabel.leadingAnchor.constraint(equalTo: exerciseVideoPlayer.leadingAnchor, constant: 20),
            countdownLabel.trailingAnchor.constraint(equalTo: exerciseVideoPlayer.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Configuration
    private func configureInitialState() {
        updateExerciseDisplay()
        updateTimeDisplay()
        updateProgressIndicator()
        
        // Hide normal UI during countdown
        timeLabel.isHidden = true
        exerciseNameLabel.alpha = 0.3
        progressIndicator.alpha = 0.3
        
        // Show countdown UI with entrance animation
        countdownLabel.alpha = 0
        
        UIView.animate(withDuration: 0.6, delay: 0.1, options: [.curveEaseOut], animations: { [weak self] in
            self?.countdownLabel.alpha = 1.0
        })
        
        // Disable buttons during countdown
        previousButton.isEnabled = false
        nextButton.isEnabled = false
        playPauseButton.isEnabled = false
        
        // Update countdown display
        updateCountdownDisplay()
    }
    
    private func updateExerciseDisplay() {
        let exercise = exercises[currentExercise]
        progressLabel.text = "Set \(currentSet) • \(currentExercise + 1) of \(exercises.count)"
        exerciseNameLabel.text = exercise.name.capitalized
        
        // Configure video player with current exercise
        exerciseVideoPlayer.configure(with: exercise)
    }
    
    
    private func updateTimeDisplay() {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        timeLabel.text = String(format: "%d:%02d", minutes, seconds)
    }
    
    private func updateProgressIndicator() {
        let totalTime: TimeInterval = isRestPeriod ? TimeInterval(secondsOfRest) : exerciseDuration
        let progress = 1.0 - (remainingTime / totalTime)
        
        // Change ring color and video border based on rest vs exercise
        if isRestPeriod {
            progressIndicator.strokeColor = UIColor.systemOrange
            exerciseVideoPlayer.layer.borderColor = UIColor.systemOrange.withAlphaComponent(0.4).cgColor
        } else {
            progressIndicator.strokeColor = UIColor.goatBlue
            exerciseVideoPlayer.layer.borderColor = UIColor.goatBlue.withAlphaComponent(0.4).cgColor
        }
        
        progressIndicator.setProgress(progress, animated: true)
    }
    
    private func updateCountdownDisplay() {
        let seconds = Int(countdownTime)
        if seconds > 0 {
            countdownLabel.text = "\(seconds)"
            
            // Provide haptic and audio feedback for countdown
            WorkoutFeedbackManager.shared.playCountdownFeedback(for: seconds)
            
            // Add pulse animation for countdown
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.countdownLabel.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                self?.pulseView.alpha = 0.8
            }) { [weak self] _ in
                UIView.animate(withDuration: 0.3) {
                    self?.countdownLabel.transform = .identity
                    self?.pulseView.alpha = 0.2
                }
            }
        } else {
            countdownLabel.text = "GO!"
            countdownLabel.textColor = .white
        }
    }
    
    private func endCountdown() {
        isCountdownPhase = false
        
        // Hide countdown UI with animation
        UIView.animate(withDuration: 0.4, animations: { [weak self] in
            self?.countdownLabel.alpha = 0
            self?.pulseView.alpha = 0
        }) { [weak self] _ in
            self?.countdownLabel.isHidden = true
            self?.pulseView.isHidden = true
        }
        
        // Show normal UI with animation
        UIView.animate(withDuration: 0.6, delay: 0.2, options: [.curveEaseOut], animations: { [weak self] in
            self?.timeLabel.isHidden = false
            self?.exerciseNameLabel.alpha = 1.0
            self?.progressIndicator.alpha = 1.0
        })
        
        // Enable buttons
        previousButton.isEnabled = true
        nextButton.isEnabled = true
        playPauseButton.isEnabled = true
        
        // Start video if not paused
        if timerIsRunning {
            exerciseVideoPlayer.play()
        }
    }
    
    // MARK: - Timer Management
    private func startTimer() {
        workoutTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        timerIsRunning = true
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    
    @objc private func timerFired() {
        if isCountdownPhase {
            // Handle countdown phase
            if countdownTime > 0 {
                countdownTime -= 1
                updateCountdownDisplay()
            } else {
                // Countdown finished, start actual workout
                endCountdown()
            }
        } else {
            // Handle normal workout/rest timing
            if remainingTime > 0 {
                remainingTime -= 1
                updateTimeDisplay()
                updateProgressIndicator()
            } else {
                if isRestPeriod {
                    // End rest period, move to next exercise
                    startNextExercise()
                } else {
                    // End current exercise, start rest or advance
                    advanceToNextExercise()
                }
            }
        }
    }
    
    private func advanceToNextExercise() {
        // Stop current video before advancing
        exerciseVideoPlayer.stop()
        
        // Check if we've completed all exercises in current set
        if currentExercise < exercises.count - 1 {
            // Move to next exercise in same set with 3-second countdown
            currentExercise += 1
            remainingTime = exerciseDuration
            
            // Show 3-second countdown before next exercise
            showCountdownForNextExercise()
        } else {
            // Completed all exercises in current set
            if currentSet < numberOfSets {
                // Start rest period before next set
                isRestPeriod = true
                remainingTime = TimeInterval(secondsOfRest)
                
                // Provide haptic and audio feedback for rest period
                WorkoutFeedbackManager.shared.playRestPeriodFeedback()
                
                // Update display for rest period
                exerciseNameLabel.text = "Rest - Set \(currentSet) Complete!"
                let minutes = secondsOfRest / 60
                let seconds = secondsOfRest % 60
                timeLabel.text = String(format: "%d:%02d", minutes, seconds)
                updateProgressIndicator()
                
                // Show rest image instead of stale exercise video
                exerciseVideoPlayer.showRestImage()
            } else {
                // All sets complete - workout finished
                workoutFinished()
            }
        }
    }
    
    private func startNextExercise() {
        isRestPeriod = false
        
        // Start next set from first exercise
        currentSet += 1
        currentExercise = 0
        remainingTime = exerciseDuration
        
        // Show 3-second countdown before starting new set
        showCountdownForNextExercise()
    }
    
    private func showCountdownForNextExercise() {
        // Pause the main timer
        workoutTimer.invalidate()
        timerIsRunning = false
        
        // Reset countdown
        isCountdownPhase = true
        countdownTime = 3
        
        // Provide haptic and audio feedback for exercise transition
        WorkoutFeedbackManager.shared.playExerciseTransitionFeedback()
        
        // Update display to show upcoming exercise
        updateExerciseDisplay()
        updateProgressIndicator()
        
        // Hide normal UI and show countdown UI
        timeLabel.isHidden = true
        exerciseNameLabel.alpha = 0.3
        progressIndicator.alpha = 0.3
        
        // Show countdown elements with animation
        countdownLabel.isHidden = false
        pulseView.isHidden = false
        
        countdownLabel.alpha = 0
        pulseView.alpha = 0.2
        
        UIView.animate(withDuration: 0.6, delay: 0.1, options: [.curveEaseOut], animations: { [weak self] in
            self?.countdownLabel.alpha = 1.0
        })
        
        // Start countdown timer
        startTimer()
        updateCountdownDisplay()
    }
    
    // MARK: - Control Actions
    @objc private func exitButtonTapped() {
        workoutTimer.invalidate()
        timerIsRunning = false
        exerciseVideoPlayer.stop()
        exerciseVideoPlayer.cleanupPlayer()
        
        // Go back to the main app flow instead of just the previous screen
        rootViewController?.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func settingsButtonTapped() {
        // Pause the workout while settings are open
        if timerIsRunning {
            pauseWorkout()
        }
        
        // Create and present the settings view as a bottom sheet
        var settingsShowing = true
        let settingsView = WorkoutSettingsView(isPresented: Binding(
            get: { settingsShowing },
            set: { newValue in
                settingsShowing = newValue
                if !newValue {
                    // Settings dismissed, nothing specific to do here
                    // User can manually resume the workout
                }
            }
        ))
        
        let hostingController = HostingViewController(view: settingsView)
        hostingController.modalPresentationStyle = .pageSheet
        
        if #available(iOS 15.0, *) {
            if let sheet = hostingController.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
            }
        }
        
        rootViewController?.present(hostingController, animated: true, completion: nil)
    }
    
    @objc private func playPauseButtonTapped() {
        // Don't allow pause/play during countdown
        if isCountdownPhase {
            return
        }
        
        // Add subtle button press animation
        playPauseButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        UIView.animate(withDuration: 0.1) {
            self.playPauseButton.transform = CGAffineTransform.identity
        }
        
        if timerIsRunning {
            pauseWorkout()
        } else {
            resumeWorkout()
        }
    }
    
    @objc private func previousButtonTapped() {
        // Don't allow navigation during countdown
        if isCountdownPhase {
            return
        }
        
        // Don't allow going back during rest periods
        if isRestPeriod {
            return
        }
        
        if currentExercise > 0 {
            // Stop current video before going back
            exerciseVideoPlayer.stop()
            
            currentExercise -= 1
            remainingTime = exerciseDuration
            updateExerciseDisplay()
            updateProgressIndicator()
            
            // Start playing previous exercise video if workout is running
            if timerIsRunning {
                exerciseVideoPlayer.play()
            }
        }
    }
    
    @objc private func nextButtonTapped() {
        // Don't allow navigation during countdown
        if isCountdownPhase {
            return
        }
        
        if isRestPeriod {
            // Skip rest period and go directly to next exercise
            startNextExercise()
        } else {
            // Normal advance to next exercise or rest
            advanceToNextExercise()
        }
    }
    
    // MARK: - Public Methods
    func pauseWorkout() {
        workoutTimer.invalidate()
        timerIsRunning = false
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        
        // Show pause overlay without changing layout
        pauseLabel.isHidden = false
        exerciseVideoPlayer.pause()
        exerciseVideoPlayer.alpha = 0.5
        
        // Dim other elements but keep layout intact
        progressIndicator.alpha = 0.5
        exerciseNameLabel.alpha = 0.5
        timeLabel.alpha = 0.5
        previousButton.alpha = 0.5
        nextButton.alpha = 0.5
    }
    
    func resumeWorkout() {
        startTimer()
        pauseLabel.isHidden = true
        exerciseVideoPlayer.play()
        exerciseVideoPlayer.alpha = 1.0
        
        // Restore normal opacity
        progressIndicator.alpha = 1.0
        exerciseNameLabel.alpha = 1.0
        timeLabel.alpha = 1.0
        previousButton.alpha = 1.0
        nextButton.alpha = 1.0
    }
    
    private func workoutFinished() {
        workoutTimer.invalidate()
        timerIsRunning = false
        
        // Provide haptic and audio feedback for workout completion
        WorkoutFeedbackManager.shared.playWorkoutCompleteFeedback()
        
        // Stop and cleanup video player
        exerciseVideoPlayer.stop()
        exerciseVideoPlayer.cleanupPlayer()
        
        UserManager.incrementPoint()
        UserManager.calculateLevel(totalPoints: UserAPI.user.totalPoints)
        
        // Mark today's workout as complete for streak tracking
        let today = Date()
        let dateKey = "workout_\(DateFormatter.yyyyMMdd.string(from: today))"
        UserDefaults.standard.set(true, forKey: dateKey)
        
        // Trigger engagement notifications
        OptimizedNotificationManager.shared.triggerWorkoutCompletionFlow()
        
        NotificationCenter.default.post(name: workoutCompleteNotification, object: nil)
    }
    
    deinit {
        workoutTimer.invalidate()
        exerciseVideoPlayer.cleanupPlayer()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Don't allow tap to pause during countdown
        if !isCountdownPhase {
            playPauseButtonTapped()
        }
    }
}

// MARK: - Circular Progress View
class CircularProgressView: UIView {
    
    var lineWidth: CGFloat = 10 {
        didSet {
            backgroundLayer.lineWidth = lineWidth
            progressLayer.lineWidth = lineWidth
            updatePaths()
        }
    }
    
    var strokeColor: UIColor = UIColor.goatBlue {
        didSet {
            progressLayer.strokeColor = strokeColor.cgColor
        }
    }
    
    private var progress: CGFloat = 0
    private var backgroundLayer: CAShapeLayer!
    private var progressLayer: CAShapeLayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayers()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    private func setupLayers() {
        // Background layer
        backgroundLayer = CAShapeLayer()
        backgroundLayer.strokeColor = UIColor.white.withAlphaComponent(0.15).cgColor
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineWidth = lineWidth
        backgroundLayer.lineCap = .round
        layer.addSublayer(backgroundLayer)
        
        // Progress layer
        progressLayer = CAShapeLayer()
        progressLayer.strokeColor = strokeColor.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
    }
    
    private func updatePaths() {
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = (min(bounds.width, bounds.height) - lineWidth) / 2
        
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * CGFloat.pi
        
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        backgroundLayer.path = path.cgPath
        progressLayer.path = path.cgPath
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePaths()
    }
    
    func setProgress(_ progress: CGFloat, animated: Bool = false) {
        let clampedProgress = max(0, min(1, progress))
        self.progress = clampedProgress
        
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = progressLayer.strokeEnd
            animation.toValue = clampedProgress
            animation.duration = 0.1 // Very smooth, short duration for frequent updates
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            
            progressLayer.add(animation, forKey: "progressAnimation")
        }
        
        progressLayer.strokeEnd = clampedProgress
    }
}
