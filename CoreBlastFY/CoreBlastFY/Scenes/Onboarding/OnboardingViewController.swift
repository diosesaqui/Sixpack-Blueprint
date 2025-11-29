//
//  OnboardingViewController.swift
//  ForeverYoungFitness
//
//  Created by Riccardo Washington on 7/8/19.
//  Copyright © 2019 Riccardo Washington. All rights reserved.
//

import UIKit
import AVFoundation

let onboardingKey = "hasViewedWalkThrough"


final class OnboardingViewController: UIViewController {
 
    var headingLabel = UILabel()
    var contentLabel = UILabel()
    let infoLabel = UILabel()
    var pageControl = UIPageControl()
    var forwardButton = UIButton()
    var stackView = UIStackView()
    
    var index = 0
    var heading = ""
    var content = ""
    var imageView = UIImageView()
   
    var datePicker = CustomDatePicker()
    var nameTextField = UITextField()
    var date = Date()

    
    private func configureDatePicker() {
        datePicker.datePickerMode = .time
        datePicker.addTarget(self, action: #selector(grabInputFromUser), for: .editingDidEnd)
        
        view.addSubview(datePicker)
        datePicker.backgroundColor = .goatBlack
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        datePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: UIDevice.isIpad ? 350 : 250).isActive = true
        
    }
    
    
    private func configureImageView() {
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        imageView.contentMode = .redraw
    }
    
    @objc func grabInputFromUser(_ sender: UIDatePicker) {
        UserAPI.user.selectedTime = sender.date
        UserManager.save()
        UserDefaults.standard.setValue(UserAPI.user.selectedTime, forKey: UserManager.workoutDateKey)
        
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
       
        headingLabel.text = heading
        contentLabel.text = content
        infoLabel.text = "Swipe right to proceed"
        pageControl.numberOfPages = 4
        pageControl.currentPage = index
        
        
        switch index {
        case 0...2: forwardButton.setTitle("NEXT", for: .normal)
        case 3: forwardButton.setTitle("DONE", for: .normal)
        default: break
        }
        
        setupForwardButton()
        
        setupPageControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.index == 3 {
            self.configureDatePicker()
            infoLabel.alpha = 0
            forwardButton.alpha = 1
        }
    }

    
    private func setupLabels() {
        headingLabel.textColor = .white
        headingLabel.font = UIDevice.isIpad ? UIFont.makeTitleFontDB(size: 50) :  UIFont.makeTitleFontDB(size: 40)
        headingLabel.numberOfLines = 0
        contentLabel.textColor = .white
        contentLabel.font = UIDevice.isIpad ? UIFont.makeTitleFontDB(size: 32) :  UIFont.makeAvenirNext(size: 20)
        contentLabel.numberOfLines = 0
        
        
        infoLabel.textColor = .white
        infoLabel.font = UIDevice.isIpad ? UIFont.preferredFont(forTextStyle: .callout).withSize(22) : UIFont.preferredFont(forTextStyle: .callout).withSize(12)
        infoLabel.numberOfLines = 1
    }

 
    private func setupPageControl() {
        pageControl.pageIndicatorTintColor = .white
        pageControl.currentPageIndicatorTintColor = .goatBlue
    }
    
    private func setupForwardButton() {
        forwardButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        forwardButton.backgroundColor = .goatBlue
        forwardButton.layer.cornerRadius = 12
        forwardButton.clipsToBounds = true
        forwardButton.alpha = 0
        forwardButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchDown)
    }
  
    
    private func setupUI() {
        setupLabels()
        view.backgroundColor = .black
        
        
        view.addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        infoLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -70).isActive = true
        
        let spacer = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 30))
        spacer.backgroundColor = .clear
        
        let containerStack = UIStackView(arrangedSubviews: [headingLabel,contentLabel, spacer])
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        containerStack.axis = .vertical
        containerStack.distribution =  .fillEqually
        containerStack.alignment  = .leading
        containerStack.layoutMargins  = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        containerStack.isLayoutMarginsRelativeArrangement = true
        //containerStack.spacing = 8
        
        stackView.distribution = .fillEqually
        stackView.axis  = .vertical
        
        stackView.addArrangedSubview(imageView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(containerStack)
        
        view.addSubview(stackView)
        stackView.fillSuperview()
        
        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12).isActive = true
        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageControl.widthAnchor.constraint(equalToConstant: 44).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        view.addSubview(forwardButton)
        forwardButton.translatesAutoresizingMaskIntoConstraints = false
        forwardButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        forwardButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        forwardButton.widthAnchor.constraint(equalToConstant: 74).isActive = true
        forwardButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
    }
    
    static var completion: (() -> Void)?
    
    @objc func nextButtonTapped() {
        switch index {
        case 0...2:
            break
        case 3: //Done Button
            
            grabInputFromUser(datePicker)
            OnboardingManager.markOnboardingCompleted()
            OnboardingViewController.completion?()
           
        default: break
        }
    }
    
    
}
