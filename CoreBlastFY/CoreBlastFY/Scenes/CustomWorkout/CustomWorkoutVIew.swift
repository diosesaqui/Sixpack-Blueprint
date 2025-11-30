//
//  CustomWorkoutVIew.swift
//  CoreBlastFY
//
//  Created by Riccardo Washington on 7/20/20.
//  Copyright © 2020 Riccardo Washington. All rights reserved.
//

import UIKit

class CustomWorkoutView: UIView {
    
    var customWorkoutViewModel: CustomWorkoutViewModel
    weak var customWorkoutViewController: CustomWorkoutViewController?
    
    // Configuration values
    private var selectedSets: Int = 2
    private var selectedDuration: Int = 10
    private var selectedRest: Int = 5
    
    init(vm: CustomWorkoutViewModel, customWorkoutViewController: CustomWorkoutViewController?) {
        self.customWorkoutViewModel = vm
        self.customWorkoutViewController = customWorkoutViewController
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var delegate: CreateWorkoutDelegate?
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let setsLabel: UILabel = {
        let label = UILabel()
        label.text = "Select a number of sets"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let setsSelectionView = UIView()
    private var setsButtons: [UIButton] = []
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.text = "Select duration of each exercise"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let durationSelectionView = UIView()
    private var durationButtons: [UIButton] = []
    
    private let restLabel: UILabel = {
        let label = UILabel()
        label.text = "Select seconds of rest"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let restSelectionView = UIView()
    private var restButtons: [UIButton] = []
    
    private lazy var selectExercisesButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Select Exercises", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = UIColor.goatBlue
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(selectExercises), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Setup Methods
    
    private func setupViews() {
        backgroundColor = .black
        setupScrollView()
        setupSetsSelection()
        setupDurationSelection()
        setupRestSelection()
        setupSelectButton()
    }
    
    private func setupScrollView() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -100),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupSetsSelection() {
        contentView.addSubview(setsLabel)
        contentView.addSubview(setsSelectionView)
        
        setsLabel.translatesAutoresizingMaskIntoConstraints = false
        setsSelectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            setsLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            setsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            setsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            setsSelectionView.topAnchor.constraint(equalTo: setsLabel.bottomAnchor, constant: 20),
            setsSelectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            setsSelectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            setsSelectionView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Create sets buttons (2, 3, 4, 5)
        let setsOptions = [2, 3, 4, 5]
        // Set default value
        customWorkoutViewModel.numberOfSets = setsOptions[0]
        createSelectionButtons(in: setsSelectionView, options: setsOptions.map { "\($0)" }, selectedIndex: 0) { [weak self] index in
            self?.selectedSets = setsOptions[index]
            self?.customWorkoutViewModel.numberOfSets = setsOptions[index]
        }
        setsButtons = setsSelectionView.subviews.compactMap { $0 as? UIButton }
    }
    
    private func setupDurationSelection() {
        contentView.addSubview(durationLabel)
        contentView.addSubview(durationSelectionView)
        
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationSelectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            durationLabel.topAnchor.constraint(equalTo: setsSelectionView.bottomAnchor, constant: 40),
            durationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            durationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            durationSelectionView.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 20),
            durationSelectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            durationSelectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            durationSelectionView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Create duration buttons (10, 15, 20, 25, 30)
        let durationOptions = [10, 15, 20, 25, 30]
        // Set default value
        customWorkoutViewModel.durationOfExercise = durationOptions[0]
        createSelectionButtons(in: durationSelectionView, options: durationOptions.map { "\($0)" }, selectedIndex: 0) { [weak self] index in
            self?.selectedDuration = durationOptions[index]
            self?.customWorkoutViewModel.durationOfExercise = durationOptions[index]
        }
        durationButtons = durationSelectionView.subviews.compactMap { $0 as? UIButton }
    }
    
    private func setupRestSelection() {
        contentView.addSubview(restLabel)
        contentView.addSubview(restSelectionView)
        
        restLabel.translatesAutoresizingMaskIntoConstraints = false
        restSelectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            restLabel.topAnchor.constraint(equalTo: durationSelectionView.bottomAnchor, constant: 40),
            restLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            restLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            restSelectionView.topAnchor.constraint(equalTo: restLabel.bottomAnchor, constant: 20),
            restSelectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            restSelectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            restSelectionView.heightAnchor.constraint(equalToConstant: 60),
            restSelectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        // Create rest buttons (5, 10, 15, 20)
        let restOptions = [5, 10, 15, 20]
        createSelectionButtons(in: restSelectionView, options: restOptions.map { "\($0)" }, selectedIndex: 0) { [weak self] index in
            self?.selectedRest = restOptions[index]
            self?.customWorkoutViewModel.secondsOfRest = restOptions[index]
        }
        restButtons = restSelectionView.subviews.compactMap { $0 as? UIButton }
    }
    
    private func setupSelectButton() {
        addSubview(selectExercisesButton)
        selectExercisesButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            selectExercisesButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            selectExercisesButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            selectExercisesButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            selectExercisesButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func createSelectionButtons(in containerView: UIView, options: [String], selectedIndex: Int, onSelection: @escaping (Int) -> Void) {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        stackView.alignment = .fill
        
        containerView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.fillSuperview()
        
        for (index, option) in options.enumerated() {
            let button = UIButton(type: .custom)
            button.setTitle(option, for: .normal)
            button.setTitleColor(.lightGray, for: .normal)
            button.setTitleColor(.black, for: .selected)
            button.backgroundColor = UIColor.darkGray.withAlphaComponent(0.3)
            button.layer.cornerRadius = 25
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            button.tag = index
            
            if index == selectedIndex {
                button.isSelected = true
                button.backgroundColor = UIColor.goatBlue
                button.setTitleColor(.black, for: .normal)
            }
            
            button.addAction(UIAction { _ in
                // Deselect all buttons in this container
                for btn in stackView.arrangedSubviews.compactMap({ $0 as? UIButton }) {
                    btn.isSelected = false
                    btn.backgroundColor = UIColor.darkGray.withAlphaComponent(0.3)
                    btn.setTitleColor(.lightGray, for: .normal)
                }
                
                // Select tapped button
                button.isSelected = true
                button.backgroundColor = UIColor.goatBlue
                button.setTitleColor(.black, for: .normal)
                
                onSelection(index)
            }, for: .touchUpInside)
            
            stackView.addArrangedSubview(button)
        }
    }
    
    @objc private func selectExercises() {
        advanceToExerciseSelection()
    }
    
    private func advanceToExerciseSelection() {
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self = self else { return }
            guard let exerciseView = self.customWorkoutViewController?.exerciseSelectionView else { return }
            self.customWorkoutViewController?.view.addSubview(exerciseView)
            exerciseView.translatesAutoresizingMaskIntoConstraints = false
            exerciseView.fillSuperview(padding: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))
        }
    }
}
