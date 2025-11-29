//
//  ExerciseSelectionView.swift
//  CoreBlastFY
//
//  Created by Riccardo Washington on 7/25/20.
//  Copyright © 2020 Riccardo Washington. All rights reserved.
//

import UIKit

class ExerciseSelectionView: UIView {
    
    static let cellID = "ExerciseSelectionViewID"
    weak var customViewController: CustomWorkoutViewController?
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Start Workout".capitalized, for: .normal)
        button.setTitleColor(UIColor.gray, for: .normal)
        button.isUserInteractionEnabled = true
        button.backgroundColor = .goatBlack
        button.titleLabel?.font = UIDevice.isIpad ? UIFont.makeTitleFontDB(size: 38) : UIFont.makeTitleFontDB(size: 20)
        button.addTarget(self, action: #selector(selectExercises(_:)), for: .touchDown)
        button.layer.cornerRadius = UIDevice.isIpad ? 40 : 30
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive =  true
        return button
    }()
    
    @objc func selectExercises(_ sender: UIButton) {
        guard exerciseSelectionViewDataSource.selectedExercises.count > 1 else { promptUser(); return }
        customViewController?.removeView(self)
        customViewController?.createWorkout()
        tableView.reloadData()
    }
    
    private func promptUser() {
        let ac = AlertController.alert("Oops", message: "Select atleast two exercises!")
        customViewController?.present(ac, animated: true, completion: nil)
    }
    
    private lazy var container: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [tableView, doneButton])
        sv.axis = .vertical
        sv.spacing = 4
        return sv
    }()
    
    private func setupContainer() {
        addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -50) // Account for tab bar
        ])
    }
    
    let exerciseSelectionViewDataSource = ExerciseSelectionDataSourceDelegate()
    
    private func setUpTableView() {
        tableView.dataSource = exerciseSelectionViewDataSource
        tableView.delegate = exerciseSelectionViewDataSource
        tableView.allowsMultipleSelection = true
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ExerciseSelectionView.cellID)
        tableView.separatorStyle  = .none
    }
    
    private func setupBind()   {
        exerciseSelectionViewDataSource.hasEnoughExercisesSelected =  { [weak self] success in
            self?.doneButton.isEnabled = success
            self?.doneButton.backgroundColor = success ? .goatBlue : .goatBlack
            self?.doneButton.setTitleColor(success ? UIColor.goatBlack : .gray, for: .normal)
            self?.doneButton.setNeedsDisplay()
        }
    }
    
    
    init(customViewController: CustomWorkoutViewController) {
        self.customViewController = customViewController
        super.init(frame: .zero)
        backgroundColor = .black
        setupContainer()
        setUpTableView()
        setupBind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
