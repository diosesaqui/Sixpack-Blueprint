//
//  Colors.swift
//  CoreBlast
//
//  Created by Riccardo Washington on 12/8/19.
//  Copyright © 2019 Riccardo Washington. All rights reserved.
//

import UIKit
import SwiftUI

extension UIColor {
    static var goatBlack: UIColor {
        return UIColor(white: 0.1, alpha: 0.8)
    }
    
    static var goatBlue: UIColor {
        return #colorLiteral(red: 0.1517632902, green: 0.8681253791, blue: 1, alpha: 1)
    }
}

extension Color {
    static var goatBlue: Color {
        return Color(red: 0.1517632902, green: 0.8681253791, blue: 1)
    }
    
    static var goatBlack: Color {
        return Color(white: 0.1, opacity: 0.8)
    }
}
