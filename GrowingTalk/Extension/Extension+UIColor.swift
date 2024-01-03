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
        static let brandGreen = UIColor(red: 74/255, green: 198/255, blue: 69/255, alpha: 1)
        static let brandError = UIColor(red: 233/255, green: 102/255, blue: 107/255, alpha: 1)
        static let brandInactive = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        static let brandGray = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1)
    }
    
    
    //MARK: - Text
    enum TextColor {
        static let textPrimaryColor = UIColor(red: 28/255, green: 28/255, blue: 28/255, alpha: 1)
        static let textSecondaryColor = UIColor(red: 96/255, green: 96/255, blue: 96/255, alpha: 1)
    }
    
    
    //MARK: - Background
    enum BackgroundColor {
        static let backgroundPrimaryColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
    }
    
    
    //MARK: - View
    enum ViewColor {
        static let separateViewColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1)
        static let alphaViewColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    }
    
}
