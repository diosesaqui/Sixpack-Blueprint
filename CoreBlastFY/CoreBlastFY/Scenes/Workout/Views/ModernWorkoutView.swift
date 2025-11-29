//
//  ModernWorkoutView.swift
//  CoreBlast
//
//  Created by Claude AI on 11/29/25.
//

import UIKit

class ModernWorkoutView: UIView {
    
    // MARK: - Properties
    private var setNumber = 1
    private var iteration = 0
    private var workoutDuration: TimeInterval
    private var remainingTime: TimeInterval = 30 // Initial exercise time
    var timerIsRunning = false
    private var isRestPeriod = false // Track if we're in a rest period
    
    weak var rootViewController: WorkoutViewController?
    private var workoutViewModel: WorkoutInfo.FetchWorkout.ViewModel
    
    private let pauseLabel = UILabel()
    private let progressLabel = UILabel() // "1 of 8"
    private let exerciseNameLabel = UILabel()
    private let timeLabel = UILabel()
    private let exerciseVideoPlayer = ExerciseVideoPlayerView()
    private let progressIndicator = CircularProgressView()
    
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
        startTimer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupProgressIndicator()
        setupTopSection()
        setupCenterSection()
        setupBottomSection()
        setupConstraints()
    }
    
    private func setupProgressIndicator() {
        progressIndicator.lineWidth = 8
        progressIndicator.strokeColor = UIColor.systemBlue
        progressIndicator.backgroundColor = UIColor.clear
        addSubview(progressIndicator)
    }
    
    private func setupTopSection() {
        // Progress label (1 of 8)
        progressLabel.text = "\(iteration + 1) of \(exercises.count)"
        progressLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        progressLabel.textColor = .white
        progressLabel.textAlignment = .center
        
        addSubview(progressLabel)
    }
    
    private func setupCenterSection() {
        // Exercise video player container
        exerciseVideoPlayer.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        exerciseVideoPlayer.layer.cornerRadius = 150
        exerciseVideoPlayer.clipsToBounds = true
        
        // Exercise name
        exerciseNameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        exerciseNameLabel.textColor = .white
        exerciseNameLabel.textAlignment = .center
        exerciseNameLabel.numberOfLines = 2
        
        addSubview(exerciseVideoPlayer)
        addSubview(exerciseNameLabel)
    }
    
    private func setupBottomSection() {
        // Time display
        timeLabel.font = UIFont.boldSystemFont(ofSize: 48)
        timeLabel.textColor = .white
        timeLabel.textAlignment = .center
        
        // Control buttons
        setupControlButtons()
        
        // Pause label
        pauseLabel.text = "PAUSED"
        pauseLabel.font = UIFont.boldSystemFont(ofSize: 30)
        pauseLabel.textColor = .white
        pauseLabel.textAlignment = .center
        pauseLabel.isHidden = true
        
        addSubview(timeLabel)
        addSubview(pauseLabel)
    }
    
    private func setupControlButtons() {
        // Previous button
        previousButton.setImage(UIImage(systemName: "backward.end.fill"), for: .normal)
        previousButton.tintColor = .white
        previousButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        previousButton.layer.cornerRadius = 25
        previousButton.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
        
        // Play/Pause button
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        playPauseButton.tintColor = .white
        playPauseButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        playPauseButton.layer.cornerRadius = 35
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        
        // Next button
        nextButton.setImage(UIImage(systemName: "forward.end.fill"), for: .normal)
        nextButton.tintColor = .white
        nextButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        nextButton.layer.cornerRadius = 25
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        let buttonStackView = UIStackView(arrangedSubviews: [previousButton, playPauseButton, nextButton])
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 40
        buttonStackView.alignment = .center
        
        addSubview(buttonStackView)
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -40),
            buttonStackView.widthAnchor.constraint(equalToConstant: 220),
            buttonStackView.heightAnchor.constraint(equalToConstant: 70),
            
            previousButton.widthAnchor.constraint(equalToConstant: 50),
            previousButton.heightAnchor.constraint(equalToConstant: 50),
            playPauseButton.widthAnchor.constraint(equalToConstant: 70),
            playPauseButton.heightAnchor.constraint(equalToConstant: 70),
            nextButton.widthAnchor.constraint(equalToConstant: 50),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupConstraints() {
        progressIndicator.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        exerciseVideoPlayer.translatesAutoresizingMaskIntoConstraints = false
        exerciseNameLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        pauseLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Progress indicator (circular background)
            progressIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressIndicator.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -50),
            progressIndicator.widthAnchor.constraint(equalToConstant: 320),
            progressIndicator.heightAnchor.constraint(equalToConstant: 320),
            
            // Progress label
            progressLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            
            // Exercise video player
            exerciseVideoPlayer.centerXAnchor.constraint(equalTo: centerXAnchor),
            exerciseVideoPlayer.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -50),
            exerciseVideoPlayer.widthAnchor.constraint(equalToConstant: 300),
            exerciseVideoPlayer.heightAnchor.constraint(equalToConstant: 300),
            
            // Exercise name
            exerciseNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            exerciseNameLabel.topAnchor.constraint(equalTo: exerciseVideoPlayer.bottomAnchor, constant: 30),
            exerciseNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            exerciseNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            
            // Time label
            timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            timeLabel.topAnchor.constraint(equalTo: exerciseNameLabel.bottomAnchor, constant: 20),
            
            // Pause label
            pauseLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            pauseLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    // MARK: - Configuration
    private func configureInitialState() {
        updateExerciseDisplay()
        updateTimeDisplay()
        updateProgressIndicator()
    }
    
    private func updateExerciseDisplay() {
        let currentExercise = exercises[iteration]
        progressLabel.text = "\(iteration + 1) of \(exercises.count)"
        exerciseNameLabel.text = currentExercise.name.capitalized
        
        // Configure video player with current exercise
        exerciseVideoPlayer.configure(with: currentExercise)
    }
    
    
    private func updateTimeDisplay() {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        timeLabel.text = String(format: "%d:%02d", minutes, seconds)
    }
    
    private func updateProgressIndicator() {
        let totalTime: TimeInterval = isRestPeriod ? TimeInterval(secondsOfRest) : exerciseDuration
        let progress = 1.0 - (remainingTime / totalTime)
        
        // Change ring color based on rest vs exercise
        if isRestPeriod {
            progressIndicator.strokeColor = UIColor.systemOrange
        } else {
            progressIndicator.strokeColor = UIColor.systemBlue
        }
        
        progressIndicator.setProgress(progress, animated: true)
    }
    
    // MARK: - Timer Management
    private func startTimer() {
        workoutTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        timerIsRunning = true
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    
    @objc private func timerFired() {
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
    
    private func advanceToNextExercise() {
        if iteration < exercises.count - 1 {
            // Stop current video before advancing
            exerciseVideoPlayer.stop()
            
            // Start rest period before next exercise
            isRestPeriod = true
            remainingTime = TimeInterval(secondsOfRest)
            
            // Update display for rest period
            exerciseNameLabel.text = "Rest"
            let minutes = secondsOfRest / 60
            let seconds = secondsOfRest % 60
            timeLabel.text = String(format: "%d:%02d", minutes, seconds)
            updateProgressIndicator()
            
            // Show rest image instead of stale exercise video
            exerciseVideoPlayer.showRestImage()
            
        } else {
            // Workout complete
            workoutFinished()
        }
    }
    
    private func startNextExercise() {
        isRestPeriod = false
        iteration += 1
        remainingTime = exerciseDuration
        updateExerciseDisplay()
        updateProgressIndicator()
        
        // Start playing new exercise video if workout is running
        if timerIsRunning {
            exerciseVideoPlayer.play()
        }
    }
    
    // MARK: - Control Actions
    @objc private func playPauseButtonTapped() {
        if timerIsRunning {
            pauseWorkout()
        } else {
            resumeWorkout()
        }
    }
    
    @objc private func previousButtonTapped() {
        if iteration > 0 {
            // Stop current video before going back
            exerciseVideoPlayer.stop()
            
            iteration -= 1
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
        advanceToNextExercise()
    }
    
    // MARK: - Public Methods
    func pauseWorkout() {
        workoutTimer.invalidate()
        timerIsRunning = false
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        pauseLabel.isHidden = false
        exerciseVideoPlayer.pause()
        exerciseVideoPlayer.alpha = 0.5
    }
    
    func resumeWorkout() {
        startTimer()
        pauseLabel.isHidden = true
        exerciseVideoPlayer.play()
        exerciseVideoPlayer.alpha = 1.0
    }
    
    private func workoutFinished() {
        workoutTimer.invalidate()
        timerIsRunning = false
        
        // Stop and cleanup video player
        exerciseVideoPlayer.stop()
        exerciseVideoPlayer.cleanupPlayer()
        
        UserManager.incrementPoint()
        UserManager.calculateLevel(totalPoints: UserAPI.user.totalPoints)
        NotificationCenter.default.post(name: workoutCompleteNotification, object: nil)
    }
    
    deinit {
        workoutTimer.invalidate()
        exerciseVideoPlayer.cleanupPlayer()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        playPauseButtonTapped()
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
    
    var strokeColor: UIColor = UIColor.systemBlue {
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
        backgroundLayer.strokeColor = UIColor.darkGray.withAlphaComponent(0.3).cgColor
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