//
//  CustomDatePicker.swift
//  CoreBlastFY
//
//  Created by Riccardo Washington on 4/13/20.
//  Copyright © 2020 Riccardo Washington. All rights reserved.
//

import UIKit

class CustomDatePicker: UIDatePicker {
    
    // MARK: - Properties
    
     let titleLabel = UILabel()
    
    // MARK: - Init(s)
    

     override init(frame: CGRect) {
         super.init(frame: frame)
         preferredDatePickerStyle = .wheels
         backgroundColor = .black
         setValue(UIColor.white, forKeyPath: "textColor")
        // addSubview(titleLabel)
      
       //  titleLabel.text = "Workout Reminder"
//         titleLabel.textColor = .white
//         titleLabel.textAlignment = .center
//         titleLabel.font = UIDevice.isIpad ? UIFont.makeAvenirNext(size: 35) : UIFont.makeAvenirNext(size: 25)

        // titleLabel.backgroundColor = .goatBlack
  
//         titleLabel.translatesAutoresizingMaskIntoConstraints = false
//         titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//         titleLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
//         titleLabel.bottomAnchor.constraint(equalTo: topAnchor).isActive = true
//         titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
//         titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

     }
     
     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
     
 }

class CustomPicker: UIPickerView {
    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setValue(UIColor.white, forKeyPath: "textColor")
        addSubview(titleLabel)
     
      //  titleLabel.text = "Workout Reminder"
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = UIDevice.isIpad ? UIFont.makeAvenirNext(size: 35) : UIFont.makeAvenirNext(size: 25)

        titleLabel.backgroundColor = .goatBlack
 
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
