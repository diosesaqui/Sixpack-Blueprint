//
//  LoadingView.swift
//  CoreBlast
//
//  Created by Riccardo Washington on 12/13/19.
//  Copyright © 2019 Riccardo Washington. All rights reserved.
//

import UIKit
import AVFoundation

final class LoadingView: UIView {
    private var videoView: VideoView?
    private var seconds = 3 // Changed to 3 seconds for better UX
    private var timer = Timer()
    private var isRunning = false
    private var nextExerciseLabel = UILabel(text: "", font: UIDevice.isIpad ? UIFont.makeTitleFontDB(size: 36) : UIFont.makeTitleFontDB(size: 22), numberOfLines: 0)
    private var getReadyLabel = UILabel()
    private var pulseView = UIView() // For pulsing animation
    
    func runTimer(completion: @escaping(() -> Void)) {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateLabel), userInfo: nil, repeats: true)
        isRunning = true
        dismissedCompletion = {
            completion()
        }
    }
    
    var dismissedCompletion: (() -> Void)?
    
    @objc private func updateLabel() {
        
        if seconds < 1 {
            timer.invalidate()
            seconds = 3
            isRunning = false
            dismissedCompletion?()
        } else {
            countDownLabel.text = "\(seconds)"
            
            // Add pulse animation for countdown
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.countDownLabel.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                self?.pulseView.alpha = 0.8
            }) { [weak self] _ in
                UIView.animate(withDuration: 0.3) {
                    self?.countDownLabel.transform = .identity
                    self?.pulseView.alpha = 0.2
                }
            }
            
            seconds -= 1
        }
    }
    
    private let countDownLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: UIDevice.isIpad ? 180 : 140, weight: .black)
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.textColor = .white
        
        // Add shadow for depth
        label.layer.shadowColor = UIColor.goatBlue.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 0)
        label.layer.shadowRadius = 20
        label.layer.shadowOpacity = 0.8
        
        return label
    }()
    
    init(frame: CGRect, nextExercise: String = "Get ready first exercise", backgroundColor: UIColor = .clear, secondsOfRest: Int = 5, videoURL: URL?, isFirstWorkout: Bool = false) {
        super.init(frame: frame)
        self.backgroundColor = backgroundColor
        self.seconds = secondsOfRest
        countDownLabel.text = "10"
        setupGetReadyLabel()
        setupPulseView()
        
        if !nextExercise.isEmpty {
            let textToSpeak = "\(nextExercise) is coming up"
          //  SpeechSynthesizer.shared.textToSpeak(text: textToSpeak)
            nextExerciseLabel.text = nextExercise.uppercased()
            nextExerciseLabel.textColor = .white
            nextExerciseLabel.textAlignment = .center
            nextExerciseLabel.font = UIFont.systemFont(ofSize: UIDevice.isIpad ? 32 : 24, weight: .bold)
            
        }
        
        if let url = videoURL, isFirstWorkout {
            let videoView = VideoViewV2(frame: CGRect(x: 0, y: 100, width: 450, height: 500), videoURL: url)
            let videoContainer = VideoContainerView(videoView: videoView)
            let vstack = VerticalStackView(arrangedSubviews: [countDownLabel, nextExerciseLabel])
            let vstack2 = VerticalStackView(arrangedSubviews: [videoContainer, vstack], spacing: 10)

            // Add vstack2 to the main view
            addSubview(vstack2)
            vstack2.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                vstack2.topAnchor.constraint(equalTo: topAnchor, constant: UIDevice.isIpad ? 100 : 50),
                vstack2.leadingAnchor.constraint(equalTo: leadingAnchor),
                vstack2.trailingAnchor.constraint(equalTo: trailingAnchor),
                vstack2.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            videoView.play()
        } else {
            setupConstraints()
        }
    }
    
    @objc func pauseWorkout() {
        DispatchQueue.main.async { [weak self] in
            self?.isRunning = false
           // NotificationCenter.default.post(name: PauseWorkoutNotification, object: self)
        }
    }
    
    private func setupGetReadyLabel() {
        // Hide the GET READY label - we only want numbers
        getReadyLabel.isHidden = true
    }
    
    private func setupPulseView() {
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
    }
    
    private func setupConstraints() {
        // Add pulse view behind countdown
        addSubview(pulseView)
        pulseView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add main labels
        addSubview(getReadyLabel)
        addSubview(countDownLabel)
        addSubview(nextExerciseLabel)
        
        getReadyLabel.translatesAutoresizingMaskIntoConstraints = false
        countDownLabel.translatesAutoresizingMaskIntoConstraints = false
        nextExerciseLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Pulse view constraints - centered behind countdown
            pulseView.centerXAnchor.constraint(equalTo: centerXAnchor),
            pulseView.centerYAnchor.constraint(equalTo: centerYAnchor),
            pulseView.widthAnchor.constraint(equalToConstant: UIDevice.isIpad ? 300 : 240),
            pulseView.heightAnchor.constraint(equalToConstant: UIDevice.isIpad ? 300 : 240),
            
            // Countdown number - centered (no GET READY label)
            countDownLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            countDownLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            countDownLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            countDownLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            // Exercise name - bottom
            nextExerciseLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            nextExerciseLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: UIDevice.isIpad ? -80 : -60),
            nextExerciseLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            nextExerciseLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
        
        // Add entrance animation for countdown only
        countDownLabel.alpha = 0
        nextExerciseLabel.alpha = 0
        
        UIView.animate(withDuration: 0.6, delay: 0.1, options: [.curveEaseOut], animations: { [weak self] in
            self?.countDownLabel.alpha = 1.0
        })
        
        UIView.animate(withDuration: 0.6, delay: 0.3, options: [.curveEaseOut], animations: { [weak self] in
            self?.nextExerciseLabel.alpha = 0.8
        })
    }

    required init?(coder: NSCoder) {
        return nil
    }
    
}


import UIKit
import AVFoundation

class VideoViewV2: UIView {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?

    init(frame: CGRect, videoURL: URL) {
        super.init(frame: frame)
        setupPlayer(with: videoURL)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupPlayer(with url: URL) {
        // Initialize the AVPlayer with the provided URL
        player = AVPlayer(url: url)
        player?.isMuted = true
        
        // Set up the AVPlayerLayer and add it as a sublayer
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = self.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        if let playerLayer = playerLayer {
            layer.addSublayer(playerLayer)
        }

        // Start playing the video
       // player?.play()
        
        // Observe layout changes to ensure the video fills the view
        NotificationCenter.default.addObserver(self, selector: #selector(repositionPlayerLayer), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    @objc private func repositionPlayerLayer() {
        playerLayer?.frame = self.bounds
    }
    
    func play() {
        player?.play()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}



class VideoContainerView: UIView {
    private let videoView: VideoViewV2
    
    init(videoView: VideoViewV2) {
        self.videoView = videoView
        super.init(frame: .zero)
        addSubview(videoView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Manually set the frame of videoView to match the container
        videoView.frame = self.bounds
    }
}
