//
//  WorkoutView.swift
//  CoreBlast
//
//  Created by Riccardo Washington on 12/13/19.
//  Copyright © 2019 Riccardo Washington. All rights reserved.
//

import UIKit
import SwiftUI
import Combine
import AVFoundation

class ExerciseViewModel: ObservableObject {
    @Published var exercises: [String] = []
    
    init(exercises: [String]) {
        self.exercises = exercises
    }
}

struct ExerciseListView: View {
    @ObservedObject var viewModel: ExerciseViewModel

    var body: some View {
        NavigationView {
            List(viewModel.exercises, id: \.self) { exercise in
                Text(exercise)
            }
            .navigationTitle("Exercise order")
        }
    }
}

class ExerciseIconView: UIView {

    let iconButton: UIButton
    private var viewModel: ExerciseViewModel

    init(frame: CGRect, exercises: [String]) {
        iconButton = UIButton(type: .system)
        viewModel = ExerciseViewModel(exercises: exercises)
        super.init(frame: frame)

        setupIconButton()
        addTapGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupIconButton() {
        iconButton.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        iconButton.tintColor = .goatBlue
        iconButton.isUserInteractionEnabled = true
        iconButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconButton)
    }

    private func addTapGesture() {
        iconButton.addTarget(self, action: #selector(iconTapped), for: .touchUpInside)
    }

    @objc private func iconTapped() {
        let swiftUIView = ExerciseListView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.present(hostingController, animated: true, completion: nil)
        }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: PauseWorkoutNotification, object: self)
        }
    }
}

let workoutCompleteNotification = NSNotification.Name("workoutCompleteNotification")
let workoutCompleteNotification2 = NSNotification.Name("workoutCompleteNotification2")

class WorkoutView: UIView {
    
    private var setNumber = 1
    private var iteration = 0
    private var workoutDuration: TimeInterval
    var timerIsRunning = false
    
    weak var rootViewController: WorkoutViewController?
    private var workoutViewModel: WorkoutInfo.FetchWorkout.ViewModel
    
    private let pauseLabel = UILabel.init(text: "PAUSED", font: UIFont.makeTitleFont(size: UIDevice.isIpad ? 40 : 30), numberOfLines: 0)
    private let setCountLabel = UILabel()
    private let tipsLabel = UILabel()
    private let instructionsLabel = UILabel()
    private let durationLeftLabel = UILabel()
    private let exerciseNameButton = UIButton()
    private let timeLeftLabel = UILabel()
    private var workoutTimer = Timer()
   
    
    var loadingView: LoadingView?
    lazy var exerciseIconView = ExerciseIconView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), exercises: exercises.map { $0.name })
    
    private var videoView: VideoView?
    
    private var exercises: [Exercise]
    private let setDuration: TimeInterval
    private let exerciseDuration: TimeInterval
    private let secondsOfRest: Int
    
    private var numberOfSets: Int {
        guard let number = Int(workoutViewModel.workoutDetails.numberOfSets) else { return 4 }
        return number
    }
    
    @objc func fireRestTimer() {
        if setNumber < numberOfSets {
            setNumber += 1
            setCountLabel.text = "Set \(setNumber) of \(workoutViewModel.workoutDetails.numberOfSets)"
            //TO DO: - make reusable
            UIView.animate(withDuration: 1.0) { [weak self] in
                self?.setCountLabel.transform = CGAffineTransform(scaleX: 5, y: 5)
                self?.setCountLabel.transform = .identity
            }
        }
    }
    
    @objc private func fireExerciseTimer() {
        if iteration < exercises.count - 1 {
            iteration += 1
        } else {
            iteration = 0
        }
        updateExerciseViews()
    }
    
    private func runTimer() {
        workoutTimer = Timer.scheduledTimer(timeInterval: 0.99, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        timerIsRunning = true
    }
    
    @objc private func fireTimer() {
            if workoutDuration > 1 {
                workoutDuration -= 1
                durationLeftLabel.text = timeString(time: workoutDuration)
                
                if workoutDuration.truncatingRemainder(dividingBy: setDuration) == 0 {
                    fireRestTimer()
                }
                if workoutDuration.truncatingRemainder(dividingBy: exerciseDuration) == 0 {
                    fireExerciseTimer()
                }
                
            } else {
                workoutFinished()
            }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let buttonPoint = exerciseIconView.convert(point, from: self)
        
        // Check if the point is within the icon button bounds
        if exerciseIconView.iconButton.point(inside: buttonPoint, with: event) {
            return exerciseIconView.iconButton
        }
        
        // Otherwise, handle as normal
        return super.hitTest(point, with: event)
    }
    
    func resumeWorkout() {
        DispatchQueue.main.async { [weak self] in
            self?.exerciseIconView.isHidden = false
            self?.pauseLabel.isHidden = true
            self?.durationLeftLabel.isHidden = false
            self?.timeLeftLabel.isHidden = false
            self?.runTimer()
            self?.videoView?.resume()
            self?.setNeedsDisplay()
            self?.setNeedsLayout()
        }
    }
    
    func pauseWorkout() {
        DispatchQueue.main.async { [weak self] in
            self?.exerciseIconView.isHidden = true
            self?.pauseLabel.isHidden = false
            self?.durationLeftLabel.isHidden = true
            self?.timeLeftLabel.isHidden = true
            self?.invalidateTimers()
            self?.videoView?.pauseVideo()
            self?.setNeedsDisplay()
            self?.setNeedsLayout()
        }
    }
    
    private func pauseWorkoutForTransition() {
        DispatchQueue.main.async { [weak self] in
            self?.invalidateTimers()
            self?.hideLabelsForTransition()
            self?.videoView?.advanceToNextItem()
            self?.setNeedsDisplay()
            self?.setNeedsLayout()
        }
    }
    
    func runTimersForTransition() {
        invalidateTimers()
        
    }
    
    private func resumeWorkoutForTransition() {
        DispatchQueue.main.async { [weak self] in
            self?.showLabelsAfterTransition()
            self?.runTimer()
            self?.setNeedsDisplay()
            self?.setNeedsLayout()
        }
    }
    
    private func hideLabelsForTransition() {
        exerciseIconView.isHidden = true
        tipsLabel.isHidden = true
        instructionsLabel.isHidden = true
        setCountLabel.isHidden = true
        exerciseNameButton.isHidden = true
        timeLeftLabel.isHidden = true
        durationLeftLabel.isHidden = true
    }
    
    private func showLabelsAfterTransition() {
        exerciseIconView.isHidden = false
        tipsLabel.isHidden = false
        instructionsLabel.isHidden = false
        setCountLabel.isHidden = false
        exerciseNameButton.isHidden = false
        timeLeftLabel.isHidden = false
        durationLeftLabel.isHidden = false
    }
    
    private func invalidateTimers() {
        timerIsRunning = false
        workoutTimer.invalidate()
    }
    
    private func workoutFinished() {
        // Provide haptic and audio feedback for workout completion
        WorkoutFeedbackManager.shared.playWorkoutCompleteFeedback()
        
        UserManager.incrementPoint()
        UserManager.calculateLevel(totalPoints: UserAPI.user.totalPoints)
        videoView = nil
        invalidateTimers()
        workoutComplete()
    }
    
    
    private func updateExerciseViews() {
        
        let nextExercise = workoutViewModel.workoutDetails.exercises[iteration].name.capitalized
        let tipsText = workoutViewModel.workoutDetails.exercises[iteration].tip.capitalized
        tipsLabel.text = tipsText
        exerciseNameButton.setTitle(nextExercise, for: .normal)
        
        // Provide haptic and audio feedback for exercise transition
        WorkoutFeedbackManager.shared.playExerciseTransitionFeedback()
        
        let videoURL = workoutViewModel.workoutDetails.exercises[iteration].videoURL
        // Use 3 seconds for exercise transition countdown, regardless of rest period
        loadingView = LoadingView(frame: .zero, nextExercise: nextExercise, secondsOfRest: 3, videoURL: videoURL)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: { [weak self] in
            if let loadingView = self?.loadingView {
                self?.pauseWorkoutForTransition()
                self?.addSubview(loadingView)
                loadingView.fillSuperview(padding: UIEdgeInsets(top: 0, left: 0, bottom: -100, right: 0))
            }
        }) { (true) in
            self.loadingView!.runTimer { [weak self] in
                self?.loadingView?.removeFromSuperview()
                self?.resumeWorkoutForTransition()
                self?.loadingView = nil
              //  SpeechSynthesizer.shared.textToSpeak(text: tipsText)
            }
        }
    }
    
    var workoutComplete = {
        NotificationCenter.default.post(name: workoutCompleteNotification, object: nil)
    }
    
    init(frame: CGRect, rootVC: UIViewController, viewModel: WorkoutInfo.FetchWorkout.ViewModel, secondsOfRest: Int) {
        rootViewController = rootVC as? WorkoutViewController
        workoutViewModel = viewModel
        workoutDuration = workoutViewModel.workoutDetails.workoutDurationDouble
        self.secondsOfRest = secondsOfRest
        
        let screenHeight = UIScreen.main.bounds.height
        
        exercises = workoutViewModel.workoutDetails.exercises
        exerciseDuration = workoutViewModel.workoutDetails.secondsOfExercise
        setDuration = workoutViewModel.workoutDetails.setDuration
        let videoUrls: [URL] = workoutViewModel.workoutDetails.exercises.compactMap {  $0.videoURL }
        super.init(frame: frame)
        videoView = VideoView(frame: frame, urls: videoUrls, loopCount: -1, numberOfSets:  Int(workoutViewModel.workoutDetails.numberOfSets) ?? 4)
        
        backgroundColor = .black
        
        setCountLabel.font = UIDevice.isIpad ? UIFont.makeTitleFontDB(size: 28) : UIFont.makeTitleFontDB(size: Style.titleFontSize)
        setCountLabel.textColor = .white
        
        setCountLabel.text = "Set \(setNumber) of \(workoutViewModel.workoutDetails.numberOfSets)"

        
        let icon = #imageLiteral(resourceName: "muscleflex").withRenderingMode(.alwaysTemplate)
        
        exerciseNameButton.setImage(icon, for: .normal)
        exerciseNameButton.imageView?.tintColor = UIColor.goatBlue
        exerciseNameButton.backgroundColor = UIColor.goatBlack.withAlphaComponent(0.7)
        exerciseNameButton.imageView?.layer.transform = CATransform3DMakeScale(0.7, 0.7, 0.7)
        exerciseNameButton.contentEdgeInsets  = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        exerciseNameButton.layer.cornerRadius = 9
        exerciseNameButton.setTitle(workoutViewModel.workoutDetails.exercises[iteration].name.capitalized, for: .normal)
        exerciseNameButton.titleLabel?.font = UIDevice.isIpad ? UIFont.makeAvenirNext(size: 32) : UIFont.makeAvenirNext(size: Style.titleFontSize)
        
        let setAndExerciseContainerStackView = UIStackView(arrangedSubviews: [exerciseIconView, setCountLabel, exerciseNameButton])
       // setAndExerciseContainerStackView.alignment = .leading
        setAndExerciseContainerStackView.distribution = .equalCentering
        setAndExerciseContainerStackView.spacing = 10
        setAndExerciseContainerStackView.backgroundColor = .clear
        
        let containerPauseView = UIStackView(arrangedSubviews: [setAndExerciseContainerStackView, pauseLabel])
        containerPauseView.alignment = .fill
        containerPauseView.distribution = .fillProportionally
        containerPauseView.axis = .vertical
        containerPauseView.spacing = 10
        containerPauseView.backgroundColor = .clear
        
        guard let videoView = videoView else { return }
        addSubview(videoView)
        
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        videoView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        videoView.topAnchor.constraint(equalTo: topAnchor, constant: -(frame.height * 0.2)).isActive = true
        videoView.heightAnchor.constraint(equalToConstant: frame.height * 0.83).isActive = true
        videoView.bounds = videoView.frame
        
        let instructions = "Tips for success"
        instructionsLabel.text = instructions
        instructionsLabel.numberOfLines = 0
        instructionsLabel.font = UIDevice.isIpad ? UIFont.makeTitleFontDB(size: 28) : UIFont.makeTitleFontDB(size: Style.titleFontSize)
        instructionsLabel.textColor = .white
        
        let tipsText = workoutViewModel.workoutDetails.exercises[iteration].tip.capitalized
        tipsLabel.text = tipsText
        tipsLabel.numberOfLines = 0
        tipsLabel.font = UIDevice.isIpad ? UIFont.makeTitleFontDB(size: 28) : UIFont.makeTitleFontDB(size: Style.titleFontSize)
        tipsLabel.textColor = .white.withAlphaComponent(0.8)
        
        
        let tipsStackView = UIStackView(arrangedSubviews: [instructionsLabel, tipsLabel])
        tipsStackView.alignment = .leading
        tipsStackView.distribution = .fillEqually
        tipsStackView.axis = .vertical
        tipsStackView.spacing = Style.stackViewSpacing
        tipsStackView.backgroundColor = .clear
        
        
        timeLeftLabel.text = "Time Remaining"
        timeLeftLabel.font = UIDevice.isIpad ? UIFont.makeAvenirNext(size: 28) : UIFont.makeAvenirNext(size: Style.titleFontSize)
        timeLeftLabel.textColor = .white.withAlphaComponent(0.8)
        durationLeftLabel.text = workoutViewModel.workoutDetails.workoutDuration
        durationLeftLabel.font = UIDevice.isIpad ? UIFont.makeTitleFontDB(size: 52) : UIFont.makeTitleFontDB(size: 42)
        durationLeftLabel.textColor = .white
        
        let durationStackView = UIStackView(arrangedSubviews: [timeLeftLabel, durationLeftLabel])
        durationStackView.alignment = .center
        durationStackView.distribution = .fillProportionally
        durationStackView.axis = .vertical
       // durationStackView.spacing = Style.stackViewSpacing
        durationStackView.backgroundColor = .clear

        
        addSubview(containerPauseView)
        containerPauseView.translatesAutoresizingMaskIntoConstraints = false
        containerPauseView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Style.Dimension.edgeInsets.bottom).isActive = true
        containerPauseView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Style.Dimension.edgeInsets.left).isActive = true
        containerPauseView.topAnchor.constraint(equalTo: videoView.bottomAnchor, constant: screenHeight * 0.02).isActive = true
        
        addSubview(tipsStackView)
        tipsStackView.translatesAutoresizingMaskIntoConstraints  = false
        tipsStackView.topAnchor.constraint(equalTo: containerPauseView.bottomAnchor, constant: screenHeight * 0.02).isActive = true
        tipsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Style.Dimension.edgeInsets.bottom).isActive = true
        tipsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Style.Dimension.edgeInsets.bottom).isActive = true
        
        
        
        addSubview(durationStackView)
        durationStackView.translatesAutoresizingMaskIntoConstraints  = false
        durationStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Style.Dimension.edgeInsets.left).isActive = true
        durationStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Style.Dimension.edgeInsets.right).isActive = true
        durationStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Style.Dimension.edgeInsets.left).isActive = true
    
        
        
        videoView.playVideo()
        
       // SpeechSynthesizer.shared.textToSpeak(text: tipsText)
        
        pauseLabel.textColor = .white
        pauseLabel.isHidden = true
        
        // Provide haptic and audio feedback for workout start
        WorkoutFeedbackManager.shared.playWorkoutStartFeedback()
        
        runTimer()
    }
    
    func setupVideoView(frame: CGRect, urls: [URL], numberOfSets: Int) {
        videoView = VideoView(frame: frame, urls: urls, loopCount: -1, numberOfSets: numberOfSets)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
}

extension WorkoutView {
    enum Style {
        static let titleFontSize: CGFloat = 18
        static let dataFontSize: CGFloat = 22
        static let stackViewSpacing: CGFloat = 4
        static let stackViewTop: CGFloat = 8
        
        enum Dimension {
            static let edgeInsets = UIEdgeInsets(top: 4, left: 12, bottom: 24, right: 44)
        }
    }
}
