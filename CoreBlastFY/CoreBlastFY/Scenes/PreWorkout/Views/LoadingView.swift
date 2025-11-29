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
    private var seconds = 5
    private var timer = Timer()
    private var isRunning = false
    private var nextExerciseLabel = UILabel(text: "", font: UIDevice.isIpad ? UIFont.makeTitleFontDB(size: 36) : UIFont.makeTitleFontDB(size: 22), numberOfLines: 0)
    
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
            seconds -= 1
        }
    }
    
    private let countDownLabel: UILabel = {
        let label = UILabel()
        label.font = UIDevice.isIpad ? UIFont.makeAvenirNext(size: 300) : UIFont.makeAvenirNext(size: 200)
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.textColor = .goatBlue
        return label
    }()
    
    init(frame: CGRect, nextExercise: String = "Get ready first exercise", backgroundColor: UIColor = .clear, secondsOfRest: Int = 5, videoURL: URL?, isFirstWorkout: Bool = false) {
        super.init(frame: frame)
        self.backgroundColor = backgroundColor
        self.seconds = secondsOfRest
        countDownLabel.text = "10"
        if !nextExercise.isEmpty {
            let textToSpeak = "\(nextExercise) is coming up"
          //  SpeechSynthesizer.shared.textToSpeak(text: textToSpeak)
            nextExerciseLabel.text = textToSpeak
            nextExerciseLabel.textColor = .white
            nextExerciseLabel.textAlignment = .center
            
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
            addSubview(countDownLabel)
            countDownLabel.fillSuperview(padding: UIEdgeInsets(top: UIDevice.isIpad ? 100 : 50, left: 0, bottom: 0, right: 0))
            addSubview(nextExerciseLabel)
            nextExerciseLabel.translatesAutoresizingMaskIntoConstraints = false
            nextExerciseLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -100).isActive = true
            nextExerciseLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
            nextExerciseLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
        }
    }
    
    @objc func pauseWorkout() {
        DispatchQueue.main.async { [weak self] in
            self?.isRunning = false
           // NotificationCenter.default.post(name: PauseWorkoutNotification, object: self)
        }
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
