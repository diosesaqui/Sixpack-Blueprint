//
//  ExercisePreviewView.swift
//  CoreBlast
//
//  Created by Claude AI on 11/29/25.
//

import UIKit

class ExercisePreviewView: UIView {
    
    private let viewModel: ExercisePreview.FetchExercisePreview.ViewModel
    private let startAction: () -> Void
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel()
    private let durationLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let exercisesStackView = UIStackView()
    private let startButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)
    
    init(viewModel: ExercisePreview.FetchExercisePreview.ViewModel, startAction: @escaping () -> Void) {
        self.viewModel = viewModel
        self.startAction = startAction
        super.init(frame: .zero)
        setupUI()
        configureContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .black
        
        setupScrollView()
        setupHeader()
        setupExercisesList()
        setupBottomButtons()
    }
    
    private func setupScrollView() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -120), // Space for buttons
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupHeader() {
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        durationLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        durationLabel.textColor = UIColor.lightGray
        durationLabel.textAlignment = .center
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textColor = UIColor.lightGray
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        
        let headerStackView = UIStackView(arrangedSubviews: [titleLabel, durationLabel, descriptionLabel])
        headerStackView.axis = .vertical
        headerStackView.spacing = 8
        headerStackView.alignment = .center
        
        contentView.addSubview(headerStackView)
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupExercisesList() {
        exercisesStackView.axis = .vertical
        exercisesStackView.spacing = 0
        exercisesStackView.distribution = .fillEqually
        
        contentView.addSubview(exercisesStackView)
        exercisesStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            exercisesStackView.topAnchor.constraint(equalTo: contentView.subviews.first!.bottomAnchor, constant: 40),
            exercisesStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            exercisesStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            exercisesStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupBottomButtons() {
        // Share button
        shareButton.setTitle("Share Routine", for: .normal)
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.backgroundColor = UIColor.darkGray
        shareButton.tintColor = .white
        shareButton.layer.cornerRadius = 25
        shareButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        
        // Start button
        startButton.setTitle("START", for: .normal)
        startButton.backgroundColor = UIColor.goatBlue
        startButton.tintColor = .white
        startButton.layer.cornerRadius = 25
        startButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        
        let buttonStackView = UIStackView(arrangedSubviews: [shareButton, startButton])
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 12
        buttonStackView.distribution = .fillEqually
        
        addSubview(buttonStackView)
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 100),
            
            shareButton.heightAnchor.constraint(equalToConstant: 44),
            startButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func configureContent() {
        titleLabel.text = viewModel.workoutTitle
        durationLabel.text = viewModel.workoutDuration
        descriptionLabel.text = viewModel.workoutDescription
        
        // Clear previous exercise stacks
        exerciseStacks.removeAll()
        
        // Add exercise rows
        for exerciseViewModel in viewModel.exercises {
            let exerciseRow = createExerciseRow(for: exerciseViewModel)
            exercisesStackView.addArrangedSubview(exerciseRow)
            exerciseStacks.append(exerciseRow)
        }
    }
    
    private func createExerciseRow(for exercise: ExercisePreview.ExerciseRowViewModel) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        
        // Exercise name
        let nameLabel = UILabel()
        nameLabel.text = exercise.name
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        nameLabel.textColor = .white
        
        // Duration label (read-only)
        let durationLabel = UILabel()
        durationLabel.text = exercise.duration
        durationLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        durationLabel.textColor = .lightGray
        durationLabel.textAlignment = .right
        
        // Add subviews
        containerView.addSubview(nameLabel)
        containerView.addSubview(durationLabel)
        
        // Set up constraints
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 60),
            
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: durationLabel.leadingAnchor, constant: -16),
            
            durationLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            durationLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            durationLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
        
        return containerView
    }
    
    
    @objc private func startButtonTapped() {
        startAction()
    }
    
    @objc private func shareButtonTapped() {
        // Implement share functionality
        print("Share button tapped")
    }
    
    private var exerciseStacks: [UIView] = []
}