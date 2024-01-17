//
//  Extension+UIView.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/3/24.
//

import UIKit
import Toast

extension UIView {
    func addSubViews(_ views: [UIView]) {
        for view in views {
            self.addSubview(view)
        }
    }
    
    func makeAppBottomToast(toastMessage: String, point: CGPoint) {
        var toastStyle = ToastStyle()
        toastStyle.backgroundColor = .BrandColor.brandGreen.withAlphaComponent(0.8)
        
        self.makeToast(toastMessage, point: point, title: nil, image: nil, style: toastStyle, completion: nil)
    }
    
}
