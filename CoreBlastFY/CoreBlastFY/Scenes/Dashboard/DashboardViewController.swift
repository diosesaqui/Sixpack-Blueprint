//
//  DashboardViewController.swift
//  CoreBlastFY
//
//  Created on 11/30/24.
//

import UIKit

class DashboardViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Dashboard"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let activeStreakCard = StatsCardView(title: "ACTIVE\nSTREAK", value: "-")
    private let longestStreakCard = StatsCardView(title: "LONGEST\nSTREAK", value: "-")
    private let daysCompletedCard = StatsCardView(title: "DAYS\nCOMPLETED", value: "-")
    private let lastStretchCard = StatsCardView(title: "LAST\nWORKOUT", value: "-")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadStats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadStats()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(titleLabel)
        view.addSubview(statsContainerView)
        
        // Add cards to container
        statsContainerView.addSubview(activeStreakCard)
        statsContainerView.addSubview(longestStreakCard)
        statsContainerView.addSubview(daysCompletedCard)
        statsContainerView.addSubview(lastStretchCard)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Stats Container
            statsContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            statsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            statsContainerView.heightAnchor.constraint(equalTo: statsContainerView.widthAnchor),
            
            // Cards - 2x2 grid
            activeStreakCard.topAnchor.constraint(equalTo: statsContainerView.topAnchor),
            activeStreakCard.leadingAnchor.constraint(equalTo: statsContainerView.leadingAnchor),
            activeStreakCard.widthAnchor.constraint(equalTo: statsContainerView.widthAnchor, multiplier: 0.47),
            activeStreakCard.heightAnchor.constraint(equalTo: statsContainerView.heightAnchor, multiplier: 0.47),
            
            longestStreakCard.topAnchor.constraint(equalTo: statsContainerView.topAnchor),
            longestStreakCard.trailingAnchor.constraint(equalTo: statsContainerView.trailingAnchor),
            longestStreakCard.widthAnchor.constraint(equalTo: statsContainerView.widthAnchor, multiplier: 0.47),
            longestStreakCard.heightAnchor.constraint(equalTo: statsContainerView.heightAnchor, multiplier: 0.47),
            
            daysCompletedCard.bottomAnchor.constraint(equalTo: statsContainerView.bottomAnchor),
            daysCompletedCard.leadingAnchor.constraint(equalTo: statsContainerView.leadingAnchor),
            daysCompletedCard.widthAnchor.constraint(equalTo: statsContainerView.widthAnchor, multiplier: 0.47),
            daysCompletedCard.heightAnchor.constraint(equalTo: statsContainerView.heightAnchor, multiplier: 0.47),
            
            lastStretchCard.bottomAnchor.constraint(equalTo: statsContainerView.bottomAnchor),
            lastStretchCard.trailingAnchor.constraint(equalTo: statsContainerView.trailingAnchor),
            lastStretchCard.widthAnchor.constraint(equalTo: statsContainerView.widthAnchor, multiplier: 0.47),
            lastStretchCard.heightAnchor.constraint(equalTo: statsContainerView.heightAnchor, multiplier: 0.47),
        ])
    }
    
    private func loadStats() {
        // Ensure user is loaded
        if UserAPI.user == nil {
            UserAPI.user = UserManager.loadUserFromFile()
        }
        
        guard let user = UserAPI.user else { 
            // No user data, show defaults
            activeStreakCard.updateValue("0")
            longestStreakCard.updateValue("0")
            daysCompletedCard.updateValue("0")
            lastStretchCard.updateValue("-")
            return 
        }
        
        // Update active streak
        activeStreakCard.updateValue("\(user.currentStreak)")
        
        // Update longest streak
        longestStreakCard.updateValue("\(user.longestStreak)")
        
        // Update total days completed
        daysCompletedCard.updateValue("\(user.totalWorkoutDays)")
        
        // Update last stretch date
        if let lastStretch = user.lastWorkoutDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            lastStretchCard.updateValue(formatter.string(from: lastStretch))
        } else {
            lastStretchCard.updateValue("-")
        }
    }
}

class StatsCardView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(title: String, value: String) {
        super.init(frame: .zero)
        setupUI()
        titleLabel.text = title
        valueLabel.text = value
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.white.withAlphaComponent(0.1)
        layer.cornerRadius = 20
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 10)
        ])
    }
    
    func updateValue(_ value: String) {
        valueLabel.text = value
    }
}
