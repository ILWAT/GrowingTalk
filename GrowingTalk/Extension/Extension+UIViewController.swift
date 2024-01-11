//
//  Extension+UIViewController.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/5/24.
//

import UIKit
import Toast

extension UIView {
    func makeAppBottomToast(toastMessage: String, point: CGPoint) {
        var toastStyle = ToastStyle()
        toastStyle.backgroundColor = .BrandColor.brandGreen.withAlphaComponent(0.8)
        
        self.makeToast(toastMessage, point: point, title: nil, image: nil, style: toastStyle, completion: nil)
    }
}
