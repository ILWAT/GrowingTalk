//
//  Extension+UIColor.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/3/24.
//

import UIKit


extension UIColor {
    //MARK: - Brand Color
    enum BrandColor {
        static let brandGreen = UIColor(red: 74, green: 198, blue: 69, alpha: 1)
        static let brandError = UIColor(red: 233, green: 102, blue: 107, alpha: 1)
        static let brandInactive = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        static let brandGray = UIColor(red: 221, green: 221, blue: 221, alpha: 1)
    }
    
    
    //MARK: - Text
    enum TextColor {
        static let textPrimaryColor = UIColor(red: 28, green: 28, blue: 28, alpha: 1)
        static let textSecondaryColor = UIColor(red: 96, green: 96, blue: 96, alpha: 1)
    }
    
    
    //MARK: - Background
    enum BackgroundColor {
        static let backgroundPrimaryColor = UIColor(red: 246, green: 246, blue: 246, alpha: 1)
    }
    
    
    //MARK: - View
    enum ViewColor {
        static let separateViewColor = UIColor(red: 236, green: 236, blue: 236, alpha: 1)
        static let alphaViewColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    }
    
}
