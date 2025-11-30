//
//  ExerciseVideoPlayerView.swift
//  CoreBlast
//
//  Created by Claude AI on 11/29/25.
//

import UIKit
import AVFoundation
import AVKit

class ExerciseVideoPlayerView: UIView {
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var looper: AVPlayerLooper?
    private var exercise: Exercise?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.goatBlue.withAlphaComponent(0.8)
        layer.cornerRadius = 150
        clipsToBounds = true
    }
    
    func configure(with exercise: Exercise) {
        self.exercise = exercise
        setupVideoPlayer()
    }
    
    private func setupVideoPlayer() {
        guard let exercise = exercise else { return }
        
        // Remove existing player if any
        cleanupPlayer()
        
        // First try to load from videoURL
        if let videoURL = exercise.videoURL {
            setupPlayer(with: videoURL)
        }
        // Fallback to videoData if available
        else if let videoData = exercise.videoData {
            setupPlayer(with: videoData)
        }
        // Final fallback to bundle resource
        else {
            setupPlayerFromBundle(exerciseName: exercise.name)
        }
    }
    
    private func setupPlayer(with url: URL) {
        let playerItem = AVPlayerItem(url: url)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        
        // Create looper for seamless video looping
        looper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        
        player = queuePlayer
        setupPlayerLayer()
        
        // Start playing automatically
        player?.play()
    }
    
    private func setupPlayer(with data: Data) {
        // Create temporary file from data
        let tempURL = createTempFileURL(from: data)
        setupPlayer(with: tempURL)
    }
    
    private func setupPlayerFromBundle(exerciseName: String) {
        let resourceName = exerciseName.lowercased()
        
        // Try different video formats
        let formats = ["mov", "mp4", "m4v"]
        
        for format in formats {
            if let bundlePath = Bundle.main.path(forResource: resourceName, ofType: format) {
                let url = URL(fileURLWithPath: bundlePath)
                setupPlayer(with: url)
                return
            }
        }
        
        // If no video found, show fallback image
        showFallbackImage(for: exerciseName)
    }
    
    private func setupPlayerLayer() {
        guard let player = player else { return }
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        playerLayer?.frame = bounds
        
        if let playerLayer = playerLayer {
            layer.insertSublayer(playerLayer, at: 0)
        }
        
        // Mute the video for workout context
        player.isMuted = true
    }
    
    private func createTempFileURL(from data: Data) -> URL {
        let tempDirectory = NSTemporaryDirectory()
        let tempFileName = UUID().uuidString + ".mov"
        let tempURL = URL(fileURLWithPath: tempDirectory).appendingPathComponent(tempFileName)
        
        try? data.write(to: tempURL)
        return tempURL
    }
    
    private func showFallbackImage(for exerciseName: String) {
        // Clean up any existing fallback images first
        cleanupFallbackImages()
        
        // Create fallback image view with system icon
        let imageView = UIImageView()
        let imageName = getSystemImageName(for: exerciseName)
        imageView.image = UIImage(systemName: imageName)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.tag = 1001 // Tag for easy removal
        
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 120),
            imageView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    private func getSystemImageName(for exerciseName: String) -> String {
        let name = exerciseName.lowercased()
        
        if name.contains("plank") {
            return "figure.strengthtraining.traditional"
        } else if name.contains("salute") {
            return "figure.stand"
        } else if name.contains("touch") {
            return "figure.flexibility"
        } else if name.contains("lunge") {
            return "figure.strengthtraining.traditional"
        } else if name.contains("dog") {
            return "figure.yoga"
        } else if name.contains("child") || name.contains("pose") {
            return "figure.mind.and.body"
        } else if name.contains("crunch") || name.contains("sit") {
            return "figure.core.training"
        } else {
            return "figure.walk"
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
    
    // MARK: - Public Methods
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func stop() {
        player?.pause()
        player?.seek(to: .zero)
    }
    
    func showRestImage() {
        // Stop and cleanup any video
        cleanupPlayer()
        
        // Remove any existing fallback images
        cleanupFallbackImages()
        
        // Create rest image view
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "pause.circle.fill")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.8
        imageView.tag = 1001 // Tag for easy removal
        
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5)
        ])
        
        // Set background to a rest color
        backgroundColor = UIColor.systemOrange.withAlphaComponent(0.6)
    }
    
    private func cleanupFallbackImages() {
        // Remove any fallback images with our tag
        subviews.filter { $0.tag == 1001 || $0 is UIImageView }.forEach { $0.removeFromSuperview() }
    }

    func cleanupPlayer() {
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        looper = nil
        player = nil
        playerLayer = nil
        
        // Also cleanup any fallback images when cleaning up player
        cleanupFallbackImages()
        
        // Reset background color
        backgroundColor = UIColor.goatBlue.withAlphaComponent(0.8)
    }
    
    deinit {
        cleanupPlayer()
    }
}