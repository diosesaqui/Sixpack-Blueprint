//
//  ProgressionViewController.swift
//  CoreBlast
//
//  Created by Riccardo Washington on 12/8/19.
//  Copyright © 2019 Riccardo Washington. All rights reserved.
//

import UIKit
import SwiftUI

private let reuseIdentifier = "ProgressionPicsCell"

class ProgressionCollectionViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    //MARK: - Properties
    
    var screenWidth: CGFloat?
    var screenHeight: CGFloat?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        view.backgroundColor = .black
        collectionView.backgroundColor = .black
        screenWidth = view.frame.width
        screenHeight = view.frame.height
        collectionView.decelerationRate = .fast
        imagePicker.delegate = self
        // Register cell classes
        self.collectionView!.register(ProgressionPicsCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateProgressPicTV(_:)), name: ProgressionPicController.progressNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        imagePicker.delegate = nil
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        view.setNeedsDisplay()
        view.setNeedsLayout()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpCameraButton()
       
        
        if ProgressionPicController.shared.noProgressionPics {
            // Start the sophisticated camera attention animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.cameraBarButtonItem.cameraAttentionAnimation()
            }
            self.collectionView?.isHidden = true
            setupProgressionView()
            addCameraPrompt()
            view.setNeedsLayout()
        }
        
        if let paths = collectionView?.indexPathsForSelectedItems {
            for path in paths {
                collectionView?.deselectItem(at: path, animated: true)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop camera animations when leaving the screen
        cameraBarButtonItem.stopCameraAttentionAnimation()
    }
    

    
    //MARK: - Methods
    
    let imagePicker = UIImagePickerController()
    
    @objc func takePicture() {
        // Stop the attention animation and play shutter animation
        cameraBarButtonItem.stopCameraAttentionAnimation()
        
        cameraBarButtonItem.cameraShutterAnimation { [weak self] in
            guard let self = self else { return }
            
            //TO DO: FIX memory leaks
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
            } else {
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let picture = info[.originalImage] as? UIImage else {
            return
        }
        let data = picture.jpegData(compressionQuality: 0.5)
        let progressionPic = ProgressionPic(timestamp: Date(), progressionPicData: data)
        ProgressionPicController.shared.progressionPics.append(progressionPic)
        dismiss(animated: true, completion: nil)
       
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func updateProgressPicTV(_ notification: Notification) {
        switch ProgressionPicController.shared.noProgressionPics {
        case true: collectionView.isHidden = true
            progressionView.isHidden = false
        case false:
            if collectionView?.isHidden == true {
                collectionView?.isHidden = false
                self.progressionView.isHidden = true
            }
        }
        self.collectionView?.reloadData()
    }
    
    let cameraBarButtonItem = UIButton(type: .custom)
    
    func setUpCameraButton() {
        
        cameraBarButtonItem.setImage(UIImage(systemName: "camera.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)), for: .normal)
        cameraBarButtonItem.tintColor = .goatBlue
        cameraBarButtonItem.addTarget(self, action: #selector(takePicture), for: .touchDown)
        cameraBarButtonItem.contentVerticalAlignment = .center
        cameraBarButtonItem.contentHorizontalAlignment = .center
        cameraBarButtonItem.imageView?.contentMode = .scaleAspectFit
        
        addCameraButton()
    }
    
    func addCameraButton() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
        navigationController?.navigationBar.addSubview(cameraBarButtonItem)
        cameraBarButtonItem.translatesAutoresizingMaskIntoConstraints = false
        cameraBarButtonItem.topAnchor.constraint(equalTo:  (navigationController?.navigationBar.topAnchor)!, constant: 20).isActive = true
        cameraBarButtonItem.trailingAnchor.constraint(equalTo:  (navigationController?.navigationBar.trailingAnchor)!, constant: -20).isActive = true
        cameraBarButtonItem.widthAnchor.constraint(equalToConstant: 33).isActive = true
        cameraBarButtonItem.heightAnchor.constraint(equalToConstant: 33).isActive = true
        } else {
            //do something
        }

    }
    
    private func setupNavBar() {
        navigationItem.title = "Progression"
    }
    
    //MARK: - Private views
    
    private lazy var progressionView: UIView = {
        let pgView = UIView()
        pgView.backgroundColor = .black
        pgView.translatesAutoresizingMaskIntoConstraints = false
        return pgView
    }()
    
    private func createShadowLayer(view: UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.goatBlack.withAlphaComponent(0.8).cgColor, UIColor.black.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.8)
        gradientLayer.frame = view.layer.bounds
        view.layer.addSublayer(gradientLayer)
        
        let saturateLayer = CALayer()
        saturateLayer.backgroundColor = UIColor.black.cgColor
        saturateLayer.frame = view.layer.bounds
        saturateLayer.opacity = 0.3
        view.layer.addSublayer(saturateLayer)
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Track Your\nTransformation"
        label.font = UIFont.systemFont(ofSize: UIDevice.isIpad ? 40 : 32, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Take your first progress photo\nto begin your fitness journey."
        label.font = UIFont.systemFont(ofSize: UIDevice.isIpad ? 20 : 17, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        return label
    }()
    
    
    private func setupProgressionView() {
        view.addSubview(progressionView)
        progressionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        progressionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        progressionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        progressionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        progressionView.addSubview(titleLabel)
        progressionView.addSubview(subtitleLabel)
        setupLabelConstraints()
    }
    
    private func setupLabelConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Title Label
            titleLabel.centerXAnchor.constraint(equalTo: progressionView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: progressionView.centerYAnchor, constant: -40),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: progressionView.leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: progressionView.trailingAnchor, constant: -40),
            
            // Subtitle Label
            subtitleLabel.centerXAnchor.constraint(equalTo: progressionView.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            subtitleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: progressionView.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: progressionView.trailingAnchor, constant: -40)
        ])
    }
    
    private lazy var cameraPromptLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Tap  to get started"
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = UIColor.goatBlue
        label.textAlignment = .center
        label.alpha = 0.9
        return label
    }()
    
    private func addCameraPrompt() {
        progressionView.addSubview(cameraPromptLabel)
        
        NSLayoutConstraint.activate([
            cameraPromptLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 48),
            cameraPromptLabel.centerXAnchor.constraint(equalTo: progressionView.centerXAnchor)
        ])
        
        // Add subtle pulsing animation
        UIView.animate(withDuration: 2.0, delay: 1.0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
            self.cameraPromptLabel.alpha = 0.4
        })
    }
    
    
    
    // MARK: - Navigation
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return ProgressionPicController.shared.sortedPics.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProgressionPicsCollectionViewCell
        
        let progressionPic = ProgressionPicController.shared.sortedPics[indexPath.row]
        cell.progressionPic = progressionPic
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.overrideUserInterfaceStyle = .dark
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (delete) in
            let progressionPic = ProgressionPicController.shared.sortedPics[indexPath.row]
            ProgressionPicController.shared.deletePic(progressionPic: progressionPic)
            collectionView.deleteItems(at: [indexPath])
        }
        let shareAction = UIAlertAction(title: "Share", style: .default) { (share) in
            
            guard let progressionPic = ProgressionPicController.shared.progressionPics[indexPath.row].photo else { return }
            
            let activityController = UIActivityViewController(activityItems: [progressionPic], applicationActivities: nil)
            activityController.popoverPresentationController?.sourceView = self.view
            
            self.present(activityController, animated: true)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(shareAction)
        ac.addAction(deleteAction)
        ac.addAction(cancel)
        
        self.present(ac, animated: true)
    }
    
}

extension ProgressionCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        guard let screenWidth = screenWidth, let screenHeight = screenHeight else { return CGSize(width: 300, height: 500)}
        let screenSize = CGSize(width: screenWidth * 0.85, height: screenHeight * 0.60)
        return CGSize(width: screenSize.width, height: screenSize.height)
    }
}
